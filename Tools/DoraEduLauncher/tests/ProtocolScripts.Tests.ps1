$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$toolRoot = Split-Path -Parent $PSScriptRoot
$registerScript = Join-Path $toolRoot 'scripts\Register-DoraEduProtocol.ps1'
$unregisterScript = Join-Path $toolRoot 'scripts\Unregister-DoraEduProtocol.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("DoraEduProtocolTests\" + [guid]::NewGuid().ToString('N'))
$scheme = 'dorassredutest' + $PID
$registryPath = "HKCU:\Software\Classes\$scheme"
$configurationDirectory = Join-Path $testRoot 'config'

function Assert-Equal {
	param($Expected, $Actual, [string] $Message)
	if ($Expected -ne $Actual) {
		throw "$Message Expected '$Expected', got '$Actual'."
	}
}

try {
	if (-not (Test-Path -LiteralPath $registerScript -PathType Leaf)) {
		throw "Register script missing: $registerScript"
	}
	if (-not (Test-Path -LiteralPath $unregisterScript -PathType Leaf)) {
		throw "Unregister script missing: $unregisterScript"
	}

	New-Item -ItemType Directory -Path $testRoot | Out-Null
	$launcherPath = Join-Path $testRoot 'DoraEduLauncher.exe'
	$doraPath = Join-Path $testRoot 'Dora.exe'
	$assetPath = Join-Path $testRoot 'Assets'
	New-Item -ItemType File -Path $launcherPath | Out-Null
	New-Item -ItemType File -Path $doraPath | Out-Null
	New-Item -ItemType Directory -Path $assetPath | Out-Null
	$invalidUrlAccepted = $true
	try {
		& $registerScript `
			-LauncherPath $launcherPath `
			-DoraExecutable $doraPath `
			-AssetPath $assetPath `
			-Scheme ($scheme + 'invalid') `
			-ConfigurationDirectory $configurationDirectory `
			-WebIdeUrl 'http://127.0.0.1:8866/not-root' `
			-WhatIf | Out-Null
	}
	catch {
		$invalidUrlAccepted = $false
	}
	if ($invalidUrlAccepted) { throw 'Register script accepted a non-root Web IDE URL.' }

	& $registerScript `
		-LauncherPath $launcherPath `
		-DoraExecutable $doraPath `
		-AssetPath $assetPath `
		-Scheme $scheme `
		-ConfigurationDirectory $configurationDirectory | Out-Null

	$commandKey = Get-Item -LiteralPath "$registryPath\shell\open\command"
	$registeredCommand = $commandKey.GetValue('')
	Assert-Equal ('"{0}" "%1"' -f [System.IO.Path]::GetFullPath($launcherPath)) $registeredCommand 'Protocol command mismatch.'
	Assert-Equal '' (Get-ItemPropertyValue -LiteralPath $registryPath -Name 'URL Protocol') 'URL Protocol marker mismatch.'

	$configurationPath = Join-Path $configurationDirectory 'launcher.json'
	$config = Get-Content -LiteralPath $configurationPath -Raw | ConvertFrom-Json
	Assert-Equal ([System.IO.Path]::GetFullPath($doraPath)) $config.doraExecutable 'Dora path mismatch.'
	Assert-Equal ([System.IO.Path]::GetFullPath($assetPath)) $config.assetPath 'Asset path mismatch.'
	Assert-Equal 'http://127.0.0.1:8866/' $config.webIdeUrl 'Web IDE URL mismatch.'

	& $unregisterScript `
		-Scheme $scheme `
		-ConfigurationDirectory $configurationDirectory `
		-RemoveConfiguration | Out-Null

	if (Test-Path -LiteralPath $registryPath) { throw 'Protocol key was not removed.' }
	if (Test-Path -LiteralPath $configurationPath) { throw 'Configuration file was not removed.' }
	Write-Output 'PASS protocol registration and cleanup'
}
finally {
	if (Test-Path -LiteralPath $registryPath) {
		Remove-Item -LiteralPath $registryPath -Recurse -Force
	}
	if (Test-Path -LiteralPath $testRoot) {
		$resolvedTestRoot = [System.IO.Path]::GetFullPath($testRoot)
		$resolvedTempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
		if (-not $resolvedTestRoot.StartsWith($resolvedTempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
			throw "Refusing to delete test path outside temp: $resolvedTestRoot"
		}
		Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
	}
}
