
param(
    [string]$SourcePath = "\\192.168.13.26\IT\office"
)

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "RUN THE SCRIPT IN ADMIN MODE!!" -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit
}



$DestinationPath = "C:\Users\Public\system"

if (!(Test-Path -Path $DestinationPath)) {
    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    Write-Host "Successfully created folder: $DestinationPath" -ForegroundColor Green
} else {
    Write-Host "Destination folder already exists." -ForegroundColor Yellow
}

Write-Host "[*] Starting file copy from SMB..." -ForegroundColor Cyan
robocopy $SourcePath $DestinationPath /E /COPY:DAT /R:3 /W:3 | Out-Null
Write-Host "[*] Copy process completed!" -ForegroundColor Green

$OfficeSetupPath = "$DestinationPath\Office\Setup.exe"

if (Test-Path $OfficeSetupPath) {
    Write-Host "[*] Installing Microsoft Office silently..." -ForegroundColor Cyan
    
    Start-Process -FilePath $OfficeSetupPath -ArgumentList "/silent" -Wait -NoNewWindow

    Write-Host "[*] Microsoft Office installation finished!" -ForegroundColor Green
} else {
    Write-Host "[!] Office Setup.exe not found in destination path. Skipping installation." -ForegroundColor Yellow
}

Write-Host "[*] Running Microsoft Activation Scripts (MAS)..." -ForegroundColor Cyan

try {
    irm https://get.activated.win | iex
    Write-Host "[*] MAS Activation executed successfully!" -ForegroundColor Green
}catch {
    Write-Host "[!] Failed to execute MAS activation: $_" -ForegroundColor Red
}


Write-Host "[*] All deployment steps completed successfully!" -ForegroundColor Green
