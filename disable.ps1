
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "RUN THE SCRIPT IN ADMIN MODE!!" -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit
}



Set-Service -Name WinDefend -StartupType Disabled
Stop-Service -Name WinDefend -Force -ErrorAction SilentlyContinue

Set-Service -Name MpsSvc -StartupType Disabled
Stop-Service -Name MpsSvc -Force -ErrorAction SilentlyContinue

Set-Service -Name wscsvc -StartupType Disabled
Stop-Service -Name wscsvc -Force -ErrorAction SilentlyContinue


$Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if (!(Test-Path $Path)) { New-Item -Path $Path -Force }


Set-ItemProperty -Path $Path -Name "DisableAntiSpyware" -Value 1 -Type DWord


$RTPath = "$Path\Real-Time Protection"
if (!(Test-Path $RTPath)) { New-Item -Path $RTPath -Force }
Set-ItemProperty -Path $RTPath -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord
Set-ItemProperty -Path $RTPath -Name "DisableOnAccessProtection" -Value 1 -Type DWord
Set-ItemProperty -Path $RTPath -Name "DisableScanOnRealtimeEnable" -Value 1 -Type DWord
Set-ItemProperty -Path $RTPath -Name "DisableIOAVProtection" -Value 1 -Type DWord
