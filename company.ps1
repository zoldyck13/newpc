
param(
	[string]$SourcePath = "\\192.168.13.26\IT\company"
)


if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "RUN THE SCRIPT IN ADMIN MODE!!" -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit
}

$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"

if (!(Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

New-ItemProperty -Path $RegistryPath -Name "AllowInsecureGuestAuth" -Value 1 -PropertyType DWORD -Force | Out-Null
Write-Host "[*] AllowInsecureGuestAuth Done!" -ForegroundColor Green

New-ItemProperty -Path $RegistryPath -Name "EnableSecuritySignature" -Value 1 -PropertyType DWORD -Force | Out-Null
Write-Host "[*] EnableSecuritySignature Done!" -ForegroundColor Green

New-ItemProperty -Path $RegistryPath -Name "RequireSecuritySignature" -Value 0 -PropertyType DWORD -Force | Out-Null
Write-Host "[*] RequireSecuritySignature Done!" -ForegroundColor Green

cmdkey /add:192.168.157.3 /user:1 /pass:1
Write-Host "[*] Save Login 192.168.157.3 Done!" -ForegroundColor Green


$DestinationPath = "C:\Users\Public\system"

if (!(Test-Path -Path $DestinationPath)) {
    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    Write-Host "Successfully created folder: $DestinationPath" -ForegroundColor Green
} else {
    Write-Host "Destination folder already exists." -ForegroundColor Yellow
}

robocopy $SourcePath $DestinationPath /E /COPY:DAT /R:3 /W:3

Write-Host "[*] Copy process completed!" -ForegroundColor Green
