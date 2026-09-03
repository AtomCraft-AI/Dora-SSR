# DoraSSR EDU Web Launch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and locally verify a safe Windows URL-protocol launcher that opens the DoraSSR education edition and its Web IDE from a webpage.

**Architecture:** A small dependency-free .NET WinExe handles one allowlisted `dorassredu` URI, loads installer-owned local configuration, probes an education-only localhost identity endpoint, starts Dora with structured `--asset` arguments when needed, and opens the Web IDE. PowerShell scripts register the current-user protocol, while a static HTML page supplies the browser entry point.

**Tech Stack:** C# / .NET 8, Windows Registry PowerShell provider, YueScript/Lua Dora WebServer, HTML.

## Global Constraints

- Windows local testing only; no signed production installer in this increment.
- The only accepted protocol action is exactly `dorassredu://open-webide`.
- Web content never supplies an executable path, asset path, shell command, or Web IDE URL.
- Web IDE is loopback HTTP on port 8866.
- Keep existing Web IDE PIN authentication unchanged.
- Use no third-party NuGet dependencies.

---

### Task 1: Education identity endpoint

**Files:**
- Modify: `Assets/Script/Dev/WebServer.yue`
- Modify: `Assets/Script/Dev/WebServer.lua`

**Interfaces:**
- Produces: `GET /launcher/status -> { success: true, edition: "education", version: string }`

- [x] **Step 1: Write the failing endpoint assertion**

Run a PowerShell request against the current server and assert that `edition` is `education`:

```powershell
$status = Invoke-RestMethod -Method Get -Uri http://127.0.0.1:8866/launcher/status
if ($status.edition -ne 'education') { throw 'education launcher endpoint unavailable' }
```

- [x] **Step 2: Verify it fails**

Expected: request returns HTTP 404 because the route does not exist.

- [x] **Step 3: Add the minimal route**

Add to `WebServer.yue` before the existing server status helpers:

```yue
HttpServer\get "/launcher/status", ->
	return
		success: true
		edition: "education"
		version: App.version
```

Regenerate the checked-in `WebServer.lua` using the Dora CLI build command so runtime and source stay synchronized.

- [x] **Step 4: Restart Dora and verify the endpoint**

Expected: HTTP 200 and JSON fields `success=true`, `edition=education`, and a non-empty `version`.

- [x] **Step 5: Commit**

```powershell
git add Assets/Script/Dev/WebServer.yue Assets/Script/Dev/WebServer.lua
git commit -m "feat: 添加教育版启动状态端点"
```

### Task 2: Protocol parser and launch workflow

**Files:**
- Create: `Tools/DoraEduLauncher/src/DoraEduLauncher/DoraEduLauncher.csproj`
- Create: `Tools/DoraEduLauncher/src/DoraEduLauncher/ProtocolRequest.cs`
- Create: `Tools/DoraEduLauncher/src/DoraEduLauncher/LauncherConfiguration.cs`
- Create: `Tools/DoraEduLauncher/src/DoraEduLauncher/DoraStatusClient.cs`
- Create: `Tools/DoraEduLauncher/src/DoraEduLauncher/LauncherWorkflow.cs`
- Create: `Tools/DoraEduLauncher/src/DoraEduLauncher/WindowsLauncherPlatform.cs`
- Create: `Tools/DoraEduLauncher/src/DoraEduLauncher/Program.cs`
- Create: `Tools/DoraEduLauncher/tests/DoraEduLauncher.Tests/DoraEduLauncher.Tests.csproj`
- Create: `Tools/DoraEduLauncher/tests/DoraEduLauncher.Tests/Program.cs`

**Interfaces:**
- Consumes: `GET /launcher/status` from Task 1.
- Produces: `ProtocolRequest.TryParse(string[] args, out ProtocolRequest?, out string)`; `LauncherConfiguration.Load(string path)`; `DoraStatusClient.ProbeAsync`; `LauncherWorkflow.RunAsync`.

- [x] **Step 1: Write the dependency-free failing test harness**

Create a console test project referencing the launcher and cover:

```csharp
AssertTrue(ProtocolRequest.TryParse(["dorassredu://open-webide"], out _, out _));
AssertFalse(ProtocolRequest.TryParse(["https://example.com"], out _, out _));
AssertFalse(ProtocolRequest.TryParse(["dorassredu://open-webide?asset=C:/tmp"], out _, out _));
```

Add fake probe/platform implementations to assert that an education probe opens the browser without starting Dora, an unavailable probe starts Dora once with the configured asset path, another service does not start Dora, and timeout returns failure.

- [x] **Step 2: Run the harness and verify it fails to compile**

```powershell
dotnet run --project Tools/DoraEduLauncher/tests/DoraEduLauncher.Tests/DoraEduLauncher.Tests.csproj
```

Expected: build errors for missing launcher types.

- [x] **Step 3: Implement the minimal launcher core**

Implement exact URI allowlisting, JSON configuration validation, the three-state HTTP probe, structured Dora process arguments, loopback URL opening, timeout polling, and named-mutex serialization. Use `System.Text.Json`, `HttpClient`, and `ProcessStartInfo`; add no package references.

- [x] **Step 4: Run tests and build**

```powershell
dotnet run --project Tools/DoraEduLauncher/tests/DoraEduLauncher.Tests/DoraEduLauncher.Tests.csproj
dotnet build Tools/DoraEduLauncher/src/DoraEduLauncher/DoraEduLauncher.csproj -c Release
```

Expected: all named tests print `PASS`; build reports zero warnings and zero errors.

- [x] **Step 5: Commit**

```powershell
git add Tools/DoraEduLauncher/src Tools/DoraEduLauncher/tests
git commit -m "feat: 添加 DoraSSR EDU 协议启动器"
```

### Task 3: Registration scripts and browser example

**Files:**
- Create: `Tools/DoraEduLauncher/scripts/Register-DoraEduProtocol.ps1`
- Create: `Tools/DoraEduLauncher/scripts/Unregister-DoraEduProtocol.ps1`
- Create: `Tools/DoraEduLauncher/web-example/index.html`
- Create: `Tools/DoraEduLauncher/README.md`

**Interfaces:**
- Consumes: published `DoraEduLauncher.exe` from Task 2.
- Produces: current-user `dorassredu` handler and `%LOCALAPPDATA%\DoraSSREDU\launcher.json`.

- [x] **Step 1: Write registration validation commands**

```powershell
$command = (Get-Item 'HKCU:\Software\Classes\dorassredu\shell\open\command').GetValue('')
$config = Get-Content "$env:LOCALAPPDATA\DoraSSREDU\launcher.json" -Raw | ConvertFrom-Json
if (-not $command -or -not $config.doraExecutable -or -not $config.assetPath) { throw 'protocol registration invalid' }
```

Use the registry key default value through `Get-Item`/`GetValue('')` in the actual verification command to avoid provider-property ambiguity.

- [x] **Step 2: Implement register and unregister scripts**

The register script validates and resolves all input paths, writes JSON with PowerShell JSON serialization, creates the URL Protocol marker, and writes the quoted `"<launcher>" "%1"` command. The unregister script removes only `HKCU\Software\Classes\dorassredu`; configuration removal requires an explicit `-RemoveConfiguration` switch.

- [x] **Step 3: Add the browser example and usage guide**

The page contains:

```html
<a class="launch-button" href="dorassredu://open-webide">打开 DoraSSR 教育版</a>
```

Document build, publish, registration, local static hosting, verification, and cleanup commands with concrete paths as parameters rather than machine-specific committed values.

- [x] **Step 4: Publish and register the local build**

```powershell
dotnet publish Tools/DoraEduLauncher/src/DoraEduLauncher/DoraEduLauncher.csproj -c Release -r win-x64 --self-contained false
& Tools/DoraEduLauncher/scripts/Register-DoraEduProtocol.ps1 -LauncherPath 'E:\Projects\AtomGameAssociation\Dora-SSR-EDU\Tools\DoraEduLauncher\src\DoraEduLauncher\bin\Release\net8.0-windows\win-x64\publish\DoraEduLauncher.exe' -DoraExecutable 'D:\Software-Game\dora-ssr-v1.7.9-windows-x86\Dora.exe' -AssetPath 'E:\Projects\AtomGameAssociation\Dora-SSR-EDU\Assets'
```

Expected: registry command targets the published launcher and the JSON config contains resolved local paths.

- [x] **Step 5: Commit**

```powershell
git add Tools/DoraEduLauncher/scripts Tools/DoraEduLauncher/web-example Tools/DoraEduLauncher/README.md
git commit -m "feat: 添加网页唤起注册与示例"
```

### Task 4: End-to-end local verification

**Files:**
- Test only; no tracked file changes required.

**Interfaces:**
- Consumes: protocol handler, launcher, Dora executable, education assets, and Web IDE.

- [x] **Step 1: Stop only the verified Dora test process**

Resolve the listener owner and command line first. Stop it only if the executable and asset path match this test environment, then verify port 8866 is released.

- [x] **Step 2: Invoke the protocol**

```powershell
Start-Process 'dorassredu://open-webide'
```

Expected: the configured Dora executable starts with `--asset E:\Projects\AtomGameAssociation\Dora-SSR-EDU\Assets`.

- [x] **Step 3: Verify education identity and Web IDE**

Poll up to 15 seconds:

```powershell
Invoke-RestMethod -Method Get -Uri http://127.0.0.1:8866/launcher/status
Invoke-WebRequest -UseBasicParsing -Uri http://127.0.0.1:8866/
```

Expected: identity has `edition=education`, and Web IDE returns HTTP 200.

- [x] **Step 4: Verify repeat invocation**

Invoke the protocol again and confirm no second Dora process is created for this configured executable and asset path.

- [ ] **Step 5: Serve the example for manual browser acceptance**

```powershell
node Tools/DoraEduLauncher/web-example/serve.mjs
```

Expected: the page is reachable at `http://127.0.0.1:8870/`; clicking its button invokes the registered launcher. Browser-native external application confirmation remains a manual acceptance gate.

Current local verification: the page returns HTTP 200; protocol cold start returns `edition=education`, the Web IDE returns HTTP 200, and repeat protocol invocation keeps one Dora process. A human browser click is intentionally left open for final acceptance.
