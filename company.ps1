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

$MainAppCheck = "$DestinationPath\Correspondences_APP\MASDAR_OCMA.exe"
if (!(Test-Path $MainAppCheck)) {
    Write-Host "[*] Starting main files copy process..." -ForegroundColor Cyan
    robocopy $SourcePath $DestinationPath /E /COPY:DAT /R:3 /W:3 | Out-Null
    Write-Host "[*] Copy process completed!" -ForegroundColor Green
} else {
    Write-Host "[*] Main application files already exist. Skipping copy process." -ForegroundColor Yellow
}

Write-Host "[*] Checking and copying DLLs if needed..." -ForegroundColor Cyan
robocopy $SourcePath2 $DestinationPath2 /E /COPY:DAT /XX /R:3 /W:3 | Out-Null
Write-Host "[*] DLLs check/copy process completed!" -ForegroundColor Green

if (Test-Path $SourcePathFonts) {
    $FontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem -Path $SourcePathFonts -Include *.ttf, *.otf, *.fon -Recurse | ForEach-Object {
        $FontTarget = "C:\Windows\Fonts\$($_.Name)"
        if (!(Test-Path $FontTarget)) {
            $FontsFolder.CopyHere($_.FullName, 16)
            Write-Host "[*] Installed Font: $($_.Name)" -ForegroundColor Green
        } else {
            Write-Host "[~] Font already exists (Skipped): $($_.Name)" -ForegroundColor DarkGray
        }
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


$PublicDesktop = [Environment]::GetFolderPath('CommonDesktopDirectory')
$WScriptShell = New-Object -ComObject WScript.Shell

$Shortcuts = @(
    @{ Name = "Correspondences APP"; Target = "$DestinationPath\Correspondences_APP\MASDAR_OCMA.exe" },
    @{ Name = "Diamond Sell";        Target = "$DestinationPath\dimond sell\MASDAR_RCS.exe" },
    @{ Name = "Empire Sell";         Target = "$DestinationPath\Empire_Sell\MASDAR_RCS.exe" },
    @{ Name = "Project Management";  Target = "$DestinationPath\project managemant\MASDAR_MANAGEMENT.exe" },
    @{ Name = "Sell DownTown";       Target = "$DestinationPath\sell_DownTown\MASDAR_RCS.exe" }
)

foreach ($sc in $Shortcuts) {
    if (Test-Path $sc.Target) {
        $ShortcutPath = Join-Path $PublicDesktop "$($sc.Name).lnk"
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $sc.Target
        $Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($sc.Target)
        $Shortcut.Save()
        Write-Host "[*] Created/Verified shortcut for: $($sc.Name)" -ForegroundColor Green
    } else {
        Write-Host "[!] Target file not found for shortcut: $($sc.Name) at $($sc.Target)" -ForegroundColor Yellow
    }
}

Write-Host "[*] All processes completed successfully!" -ForegroundColor Green
