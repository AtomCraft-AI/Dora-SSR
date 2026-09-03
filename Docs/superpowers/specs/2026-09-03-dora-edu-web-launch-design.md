# DoraSSR EDU 网页唤起设计

## 目标

在 Windows 本地测试环境中，让用户从网页点击按钮后，通过 `dorassredu://open-webide` 唤起指定的 DoraSSR 教育版；若教育版已经运行，则直接打开其 Web IDE。方案同时保留未来随公网网站和正式安装包发布的演进路径。

## 非目标

- 网页不能静默执行任意本机程序，也不绕过浏览器的外部应用确认。
- 网页不能传入 Dora 可执行文件、资产目录、脚本或任意命令。
- 本次不制作正式签名安装包，不实现 macOS 或 Linux 协议注册。
- 本次不改变 Web IDE 现有的一次性 PIN 认证流程。

## 用户流程

1. 用户首次在测试机运行协议注册脚本，脚本记录固定的 `Dora.exe` 和教育版 `Assets` 路径，并为当前用户注册 `dorassredu` 协议。
2. 用户打开本地测试网页，点击“打开 DoraSSR 教育版”。
3. 浏览器请求打开 `dorassredu://open-webide`。
4. `DoraEduLauncher.exe` 检查 `http://127.0.0.1:8866/launcher/status`。
5. 如果端口上已经是教育版，启动器直接打开 `http://127.0.0.1:8866/`。
6. 如果端口未监听，启动器以两个独立参数启动 `Dora.exe --asset <教育版 Assets>`，等待教育版状态端点就绪，然后打开 Web IDE。
7. 如果 8866 被其他应用或非教育版 Dora 占用，启动器停止并显示可操作的错误信息。

## 架构

### 网页入口

测试页使用普通链接 `href="dorassredu://open-webide"`。网页不探测 localhost，也不参与本机路径选择，避免公网 HTTPS 页面受跨域或本地网络访问策略影响。

### Windows 协议注册

PowerShell 脚本在 `HKCU\Software\Classes\dorassredu` 注册 URL 协议，命令固定为：

```text
"<LauncherPath>" "%1"
```

注册信息只写入当前用户。运行配置保存在 `%LOCALAPPDATA%\DoraSSREDU\launcher.json`，其中的路径由注册脚本解析为绝对路径并验证存在。

### 启动器

启动器是 `net8.0-windows`、无第三方 NuGet 依赖的 WinExe。它由以下职责单元组成：

- `ProtocolRequest`：只接受无查询参数、无片段、无额外路径的 `dorassredu://open-webide`。
- `LauncherConfiguration`：加载并验证固定本地配置，只允许 loopback HTTP Web IDE 地址。
- `DoraStatusClient`：读取教育版匿名状态端点并区分未监听、教育版和其他服务。
- `LauncherWorkflow`：处理已运行、冷启动、超时和端口冲突状态。
- `WindowsLauncherPlatform`：使用结构化参数启动 Dora，并通过系统 Shell 打开 Web IDE。

启动器使用当前用户命名互斥体串行化连续点击。任何来自协议 URI 的内容都不会拼接进 Shell 命令。

### 教育版状态端点

教育版 WebServer 新增只读 GET 端点 `/launcher/status`，仅返回：

```json
{
  "success": true,
  "edition": "education",
  "version": "1.9.2.12"
}
```

该端点不返回资产路径、可写路径、认证令牌或运行内容，用于本机启动器确认 8866 上的服务身份。现有 `/status` 和认证逻辑保持不变。

## 错误处理

- 协议格式错误：显示“无效的 DoraSSR EDU 启动请求”。
- 配置缺失或路径无效：提示重新运行协议注册脚本。
- 8866 返回非教育版响应：提示关闭占用 8866 的其他 Dora 或应用。
- Dora 进程无法创建：显示操作系统返回的启动错误。
- 15 秒内未就绪：提示检查 Dora 窗口和日志。
- Web IDE 无法打开：保留 Dora 进程，并显示可手动访问的地址。

## 安全边界

- 协议名和动作采用固定允许列表。
- 注册脚本和启动器均不接受网页提供的文件路径、命令或 Web IDE 地址。
- `ProcessStartInfo.ArgumentList` 分别传递 `--asset` 和资产路径，不构造命令字符串。
- Web IDE 地址必须是 `http://localhost`、`http://127.0.0.1` 或其他 loopback 表示，端口固定为 8866。
- 状态端点只暴露版本和教育版标识。

## 测试与验收

自动化测试覆盖协议解析、配置校验、已运行直接打开、冷启动、端口冲突和启动超时。集成测试执行以下路径：

1. 构建并发布启动器。
2. 为当前测试用户注册协议，配置现有 Dora 可执行文件和当前分支 `Assets`。
3. 验证 `/launcher/status` 返回 `edition=education`。
4. 通过 `dorassredu://open-webide` 调用启动器，验证 Dora 进程存在且 Web IDE 返回 HTTP 200。
5. 启动本地示例网页，人工点击按钮验证浏览器到外部协议的交互。

验收成功条件是：网页不接触本机路径；协议只能启动教育版；重复点击不产生冲突进程；启动完成后能访问 Web IDE；未安装或端口冲突时有明确提示。
