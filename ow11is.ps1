#Requires -RunAsAdministrator
#Requires -Version 6.0
<#
.SYNPOSIS
	A perfectly opinionated script to improve Windows 11.

.DESCRIPTION
	This is Odysseys' Windows 11 Improvement Script. It does stuff.
.NOTES
	Version: 1.0.0
	Author: Odyssey346
	Last Updated: 17.10.2022
.LINK
	https://odyssey346.dev/ow11is
#>
$Version = "1.0.0"

Write-Host "Ow11is - Odyssey's Windows 11 Improvement Script - running on $env:computername - v$Version" -ForegroundColor Cyan

if ([System.Environment]::OSVersion.Version.Build -lt 22000) {
	Write-Host "This script is only for Windows 11 build 22000 and above. Exiting..." -ForegroundColor Red
	exit
}

Write-Host 'Enabling file extensions in Explorer' -ForegroundColor Green
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0
Write-Host 'Disabling the built-in bandwidth limit' -ForegroundColor Green
Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Psched' -Name 'NonBestEffortLimit' -Value 0
Write-Host 'Disabling ads in Start Menu' -ForegroundColor Green
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SystemPaneSuggestionsEnabled' -Value 0
Write-Host 'Disabling Cortana' -ForegroundColor Green
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -Value 0
Write-Host 'Disabling useless Taskbar buttons (Widgets, Chat, Search and Task View)' -ForegroundColor Green
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSi' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 0

$YesOrNo = Read-Host -Prompt 'Would you like to use the legacy right-click menu? (y/n)'

if ($YesOrNo -eq 'y') {
	Write-Host 'Setting registry key' -ForegroundColor blue

	reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve # TODO: Don't use reg.exe

	Write-Host 'Restarting explorer.exe' -ForegroundColor yellow
	Stop-Process -Name explorer -Force
	Start-Process -FilePath 'C:\Windows\explorer.exe'
}

$MoveTaskbarIconsToLeft = Read-Host -Prompt 'Would you like to move the taskbar icons to the left? (y/n)'
if ($MoveTaskbarIconsToLeft -eq 'y') {
	$TaskbarIconsRegValue = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl'
	if ($TaskbarIconsRegValue -eq 0) {
		Write-Host 'Taskbar icons are already on the left. Skipping...' -ForegroundColor Yellow
	} else {
		Write-Host 'Moving taskbar icons to the left' -ForegroundColor Green
		Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Value 0
	}
}

$SetDarkTheme = Read-Host -Prompt 'Want to set the Dark theme? (y/n)'
if ($SetDarkTheme -eq 'y') {
	Write-Host 'Setting Dark theme' -ForegroundColor Green
	# TODO: Find a better method to set themes? Doing this opens System Settings for some weird reason.
	Start-Process -Filepath "C:\Windows\Resources\Themes\dark.theme"
	Start-Sleep -Seconds 1.5
	Stop-Process -Name systemsettings.exe -Force
}

if ($(Get-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0).State -eq "Installed") {
	Write-Host 'OpenSSH Client is already installed. Skipping...' -ForegroundColor Yellow
} else {
	$EnableOpenSSH = Read-Host -Prompt 'Would you like to enable the OpenSSH Client? (allows you to use SSH) (y/n)'
	if ($EnableOpenSSH -eq 'y') {
		Write-Host 'Enabling OpenSSH Client' -ForegroundColor Green
		Add-WindowsCapability -Online -Name OpenSSH.Client
	}
}

$InstallMSEdgeRedirect = Read-Host -Prompt 'Would you like to install MSEdgeRedirect? (y/n)' #TODO: check if already installed
if ($InstallMSEdgeRedirect -eq 'y') {
	Write-Host 'Installing MSEdgeRedirect' -ForegroundColor Green
	if (Get-Command winget -errorAction SilentlyContinue) {
		winget install MSEdgeRedirect
	} else {
		Write-Host 'winget is not installed. Skipping...' -ForegroundColor Yellow
	}
}

$InstallRecommendedSoftware = Read-Host -Prompt 'Would you like to install recommended software? (check GitHub for list) (y/n)'
if ($InstallRecommendedSoftware -eq 'y') {
	Write-Host 'Installing recommended software (PowerToys, QuickLook)' -ForegroundColor Green
	if (Get-Command winget -errorAction SilentlyContinue) {
		Write-Host 'Installing PowerToys using winget' -ForegroundColor Green
		winget install Microsoft.PowerToys --silent
		Write-Host 'Installing QuickLook using winget' -ForegroundColor Green
		winget install QL-Win.QuickLook --silent
		Write-Host 'Installation complete!' -ForegroundColor Cyan
	} else {
		Write-Host 'winget not found. Not going to install recommended software' -ForegroundColor Red
	}
}

$Reboot = Read-Host -Prompt 'A reboot is strongly recommended. Would you like to reboot now? (y/n)'
if ($Reboot -eq 'y') {
	Write-Host 'Rebooting...' -ForegroundColor yellow
	Restart-Computer -Force
}

Write-Host 'Done - thanks for using' -ForegroundColor green
