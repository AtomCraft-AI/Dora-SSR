---
name: atompie-submission
description: Prepare and submit a game to AtomPie (原子派) when the author requests AtomPie publication or draft management.
requiredTools:
  - execute_command
---

# 向原子派投稿

使用权限明确的当前项目。投稿只接受 AtomGit、GitHub 或 Gitee 的公开仓库首页。用 Git 核对仓库和作品所在目录，确认入口、资料和封面已提交到公开仓库默认分支。添加 remote 或推送应按作者授权执行。

- 作品标题、简介用所选语言读取 `.dora/repo.json` 中的 `title`、`description`，兼容同语言的 `desc`。如需补充资料，可编辑 IDE 里的「项目资料」，或合并更新项目文件并保留已有字段。
- 详细介绍优先读作品目录的对应语言 README，其次查仓库根目录。中文查 `README.zh-CN.md`、`README.zh.md`、`README.md`，英文查 `README.en.md`。保留作者内容。从构建记录或导出包 `runtime.json` 确认原生项目的开发版本，当前引擎版本只能标为当前环境。
- 封面优先选 `.dora/banner.jpg`、`.dora/banner.png`、`Image/banner.jpg`、`Image/banner.png`。使用作者选定的普通 PNG 或 JPEG 文件。一个仓库有多个作品时，以实际作品目录作为命令工作区。

## 执行投稿

用 `execute_command` 的 Lua 模式按需加载模块，每步打印返回的 JSON。下面演示读取已授权账号。

```lua
local atompie = requireProjectModule("Doc.skills.atompie-submission.atompie")
print(json.encode(atompie(projectDir, "account", {})))
```

1. `begin` 获取授权链接和匹配码。把两者显示给作者，请作者在浏览器完成授权。在作者完成后用 `poll` 传入 `user_code`，按模块返回的轮询间隔重试。用 `account` 核对账号和可选组织。短期会话仅保存在引擎内存中，过期后重新授权。`disconnect` 清除当前项目的本地会话。
2. `create` 保存新稿件，或先用 `read` 核对作者提供的已有稿件 ID，再用 `update` 更新。稿件操作传 `account_id`，组织发稿还传 `organization_id`。创建和更新传 `title`、`short_description`、`long_description`、`repository_url`、`version`、`tags`、`game_metadata`，可选 `video_url`。`game_metadata` 含 `engine`（`dora_ssr`、`godot`、`love2d` 或 `tic_80`）、`play_modes`（`single_player`、`local_multiplayer`）和 `platforms`（`pc`、`mobile`）。标签和归属由作者确认。
3. `cover` 传作品目录内的 `cover_path`。已有稿件操作使用 `draft_id`，更新、封面和送审还要使用最近确认返回的 `lock_version` 作为 `expected_version`。封面操作同时传原来的 `cover_file_id` 作为 `expected_file_id`（没有则省略）。更新或上传结果丢失时，先 `read` 核对平台内容和版本，再继续。
4. 送审前展示语言、仓库、账号或组织、稿件内容和版本，请作者明确确认。用 `submit` 送审，返回审核回执及「我的稿件」链接。创建与送审各用一个独立的 `idempotency_key`（16–64 位字母、数字、下划线或连字符）。记录作品语言、稿件 ID、已确认版本及本次操作键。响应丢失时使用同一操作键和原始参数重试。确认稿件后凭回执报告结果。
