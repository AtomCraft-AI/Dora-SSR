[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $LauncherPath,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $DoraExecutable,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $AssetPath,

	[ValidatePattern('^[A-Za-z][A-Za-z0-9+.-]*$')]
	[string] $Scheme = 'dorassredu',

	[string] $ConfigurationDirectory = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'DoraSSREDU'),

	[uri] $WebIdeUrl = 'http://127.0.0.1:8866/'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Resolve-RequiredPath {
	param(
		[Parameter(Mandatory = $true)][string] $LiteralPath,
		[Parameter(Mandatory = $true)][ValidateSet('Leaf', 'Container')][string] $PathType,
		[Parameter(Mandatory = $true)][string] $Label
	)

	if (-not (Test-Path -LiteralPath $LiteralPath -PathType $PathType)) {
		throw "$Label 不存在：$LiteralPath"
	}
	return (Resolve-Path -LiteralPath $LiteralPath).ProviderPath
}

if ($WebIdeUrl.Scheme -ne 'http' -or -not $WebIdeUrl.IsLoopback -or $WebIdeUrl.Port -ne 8866) {
	throw 'WebIdeUrl 必须是端口 8866 上的 loopback HTTP 地址。'
}
if ($WebIdeUrl.UserInfo -or $WebIdeUrl.Query -or $WebIdeUrl.Fragment) {
	throw 'WebIdeUrl 不能包含用户信息、查询参数或片段。'
}

$resolvedLauncher = Resolve-RequiredPath -LiteralPath $LauncherPath -PathType Leaf -Label '启动器'
$resolvedDora = Resolve-RequiredPath -LiteralPath $DoraExecutable -PathType Leaf -Label 'Dora 可执行文件'
$resolvedAssets = Resolve-RequiredPath -LiteralPath $AssetPath -PathType Container -Label '教育版 Assets 目录'
$resolvedConfigurationDirectory = [System.IO.Path]::GetFullPath($ConfigurationDirectory)
$configurationPath = Join-Path $resolvedConfigurationDirectory 'launcher.json'
$protocolKey = "HKCU:\Software\Classes\$Scheme"
$commandKey = Join-Path $protocolKey 'shell\open\command'
$protocolCommand = '"{0}" "%1"' -f $resolvedLauncher

if ($PSCmdlet.ShouldProcess($configurationPath, '写入 DoraSSR EDU 启动配置')) {
	New-Item -ItemType Directory -Path $resolvedConfigurationDirectory -Force | Out-Null
	$config = [ordered]@{
		doraExecutable = $resolvedDora
		assetPath = $resolvedAssets
		webIdeUrl = $WebIdeUrl.AbsoluteUri
		startupTimeoutSeconds = 15
		pollIntervalMilliseconds = 250
	}
	$config | ConvertTo-Json | Set-Content -LiteralPath $configurationPath -Encoding utf8NoBOM
}

if ($PSCmdlet.ShouldProcess($protocolKey, '注册当前用户 URL 协议')) {
	New-Item -Path $protocolKey -Force | Out-Null
	Set-Item -Path $protocolKey -Value 'URL:DoraSSR EDU Protocol'
	New-ItemProperty -Path $protocolKey -Name 'URL Protocol' -PropertyType String -Value '' -Force | Out-Null
	New-Item -Path $commandKey -Force | Out-Null
	Set-Item -Path $commandKey -Value $protocolCommand
}

[pscustomobject]@{
	Scheme = $Scheme
	LauncherPath = $resolvedLauncher
	DoraExecutable = $resolvedDora
	AssetPath = $resolvedAssets
	ConfigurationPath = $configurationPath
	Command = $protocolCommand
}
