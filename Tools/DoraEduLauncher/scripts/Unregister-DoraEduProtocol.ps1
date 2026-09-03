[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[ValidatePattern('^[A-Za-z][A-Za-z0-9+.-]*$')]
	[string] $Scheme = 'dorassredu',

	[string] $ConfigurationDirectory = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'DoraSSREDU'),

	[switch] $RemoveConfiguration
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$protocolKey = "HKCU:\Software\Classes\$Scheme"
$configurationPath = Join-Path ([System.IO.Path]::GetFullPath($ConfigurationDirectory)) 'launcher.json'

if ((Test-Path -LiteralPath $protocolKey) -and $PSCmdlet.ShouldProcess($protocolKey, '注销当前用户 URL 协议')) {
	Remove-Item -LiteralPath $protocolKey -Recurse -Force
}

if (
	$RemoveConfiguration -and
	(Test-Path -LiteralPath $configurationPath -PathType Leaf) -and
	$PSCmdlet.ShouldProcess($configurationPath, '删除 DoraSSR EDU 启动配置')
) {
	Remove-Item -LiteralPath $configurationPath -Force
}

[pscustomobject]@{
	Scheme = $Scheme
	ProtocolRemoved = -not (Test-Path -LiteralPath $protocolKey)
	ConfigurationRemoved = -not (Test-Path -LiteralPath $configurationPath)
}
