# DoraSSR EDU 网页启动器

这个工具为 Windows 当前用户注册 `dorassredu://open-webide`。网页只能请求一个固定动作；Dora 可执行文件和教育版 Assets 路径保存在本机配置中，不由网页传入。

## 构建与发布

在仓库根目录运行：

```powershell
dotnet run --project Tools\DoraEduLauncher\tests\DoraEduLauncher.Tests\DoraEduLauncher.Tests.csproj
dotnet publish Tools\DoraEduLauncher\src\DoraEduLauncher\DoraEduLauncher.csproj -c Release -r win-x64 --self-contained false
```

发布目录是：

```text
Tools\DoraEduLauncher\src\DoraEduLauncher\bin\Release\net8.0-windows\win-x64\publish
```

本地测试机需要安装 .NET 8 Desktop Runtime。正式发布时可以改用 `--self-contained true -p:PublishSingleFile=true`，让启动器不依赖目标机预装 .NET。

## 注册本地测试协议

路径参数必须指向已经存在的文件或目录：

```powershell
& Tools\DoraEduLauncher\scripts\Register-DoraEduProtocol.ps1 `
	-LauncherPath 'Tools\DoraEduLauncher\src\DoraEduLauncher\bin\Release\net8.0-windows\win-x64\publish\DoraEduLauncher.exe' `
	-DoraExecutable 'D:\Software-Game\dora-ssr-v1.7.9-windows-x86\Dora.exe' `
	-AssetPath 'E:\Projects\AtomGameAssociation\Dora-SSR-EDU\Assets'
```

脚本写入：

- 注册表：`HKCU\Software\Classes\dorassredu`
- 配置：`%LOCALAPPDATA%\DoraSSREDU\launcher.json`

验证协议：

```powershell
Start-Process 'dorassredu://open-webide'
```

## 测试网页

在仓库根目录启动无第三方依赖的 Node 测试服务：

```powershell
node Tools\DoraEduLauncher\web-example\serve.mjs
```

然后访问 `http://127.0.0.1:8870/` 并点击按钮。不同浏览器可能显示“打开外部应用”的确认提示，这是预期的安全行为。

业务网页中只需要：

```html
<a href="dorassredu://open-webide">打开 DoraSSR 教育版</a>
```

## 注销

只删除协议注册，保留配置：

```powershell
& Tools\DoraEduLauncher\scripts\Unregister-DoraEduProtocol.ps1
```

同时删除配置文件：

```powershell
& Tools\DoraEduLauncher\scripts\Unregister-DoraEduProtocol.ps1 -RemoveConfiguration
```
