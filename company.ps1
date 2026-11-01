$SourcePath = "\\192.168.13.26\IT\company"  

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "RUN THE SCRIPT IN ADMIN MODE!!" -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit
}

$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$SourcePath2 = "\\192.168.13.26\IT\company\dlls"
$SourcePathFonts = "\\192.168.13.26\IT\company\fonts"

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
$DestinationPath2 = "C:\Windows"

if (!(Test-Path -Path $DestinationPath)) {
    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    Write-Host "Successfully created folder: $DestinationPath" -ForegroundColor Green
} else {
    Write-Host "Destination folder already exists." -ForegroundColor Yellow
}

robocopy $SourcePath $DestinationPath /E /COPY:DAT /R:3 /W:3
Write-Host "[*] Copy process completed!" -ForegroundColor Green

robocopy $SourcePath2 $DestinationPath2 /E /COPY:DAT /R:3 /W:3
Write-Host "[*] Copy process completed!" -ForegroundColor Green

# قسم تثبيت الخطوط تلقائياً
if (Test-Path $SourcePathFonts) {
    $FontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem -Path $SourcePathFonts -Include *.ttf, *.otf, *.fon -Recurse | ForEach-Object {
        $FontsFolder.CopyHere($_.FullName, 16)
        Write-Host "[*] Installed Font: $($_.Name)" -ForegroundColor Green
    }
    Write-Host "[*] Fonts installation process completed!" -ForegroundColor Green
} else {
    Write-Host "[!] Fonts folder not found at: $SourcePathFonts" -ForegroundColor Yellow
}

$UserLocalePath = "HKCU:\Control Panel\International"
Set-ItemProperty -Path $UserLocalePath -Name "sShortDate" -Value "yyyy-MM-dd"
Set-ItemProperty -Path $UserLocalePath -Name "sLongDate" -Value "dddd, d MMMM, yyyy"
Set-ItemProperty -Path $UserLocalePath -Name "sTimeFormat" -Value "HH:mm:ss"
Set-ItemProperty -Path $UserLocalePath -Name "sShortTime" -Value "hh:mm tt"
Write-Host "[*] Date and Time formats updated successfully!" -ForegroundColor Green

$DesktopPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $DesktopPath -Name "LogPixels" -Value 96 -PropertyType DWORD
Set-ItemProperty -Path $DesktopPath -Name "Win8DpiScaling" -Value 1 -PropertyType DWORD
Write-Host "[*] Screen scaling set to 100% successfully!" -ForegroundColor Green
