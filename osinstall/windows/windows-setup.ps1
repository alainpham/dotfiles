# Windows Standard Setup - Step by Step
# Run as Administrator
#
# If you get "not authorized to run scripts", launch it with:
#   powershell -ExecutionPolicy Bypass -File .\windows-setup.ps1

# ── Versions ─────────────────────────────────────────────────────────────────
$MAVEN_VERSION          = "3.9.16"
$RETROARCH_VERSION      = "1.22.2"
$RETROARCH_BIOS_VERSION = "v2026.08.06"
$PCSX2_VERSION          = "2.6.3"
$DOLPHIN_VERSION        = "2606a"
$CEMU_VERSION           = "2.6"
$BTHPS3_VERSION         = "2.17.0"
$DSHIDMINI_VERSION      = "3.5.1"

# ── Step definitions ─────────────────────────────────────────────────────────
$Steps = @(
    @{ Title = "Activate Administrator account and set password"; Action = {
        net user administrator /active:yes
        net user administrator Password1!
    }},
    @{ Title = "Configure auto-login"; Action = {
        $Username = Read-Host "Username for auto-login (default: user)"
        if ([string]::IsNullOrWhiteSpace($Username)) { $Username = "user" }
        $Pass = Read-Host "Password for auto-login (default: Password1!)"
        if ([string]::IsNullOrWhiteSpace($Pass)) { $Pass = "Password1!" }

        Set-ExecutionPolicy RemoteSigned -Force
        $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
        Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String
        Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$Username" -Type String
        Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$Pass" -Type String
        Write-Warning "Auto-Login for $Username configured. Restart to apply."
    }},
    @{ Title = "Enable NumLock on startup"; Action = {
        Set-ItemProperty -Path 'Registry::HKU\.DEFAULT\Control Panel\Keyboard' -Name "InitialKeyboardIndicators" -Value "2"
    }},
    @{ Title = "Activate Windows (get.activated.win)"; Action = {
        irm https://get.activated.win | iex
    }},
    @{ Title = "Rename computer and fix taskbar (never combine)"; Action = {
        $NewName = Read-Host "New computer name (default: wind)"
        if ([string]::IsNullOrWhiteSpace($NewName)) { $NewName = "wind" }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -Name TaskbarGlomLevel -Value 2
        Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue
        Rename-Computer -NewName $NewName -Force
        Write-Host "Computer will be renamed to '$NewName' on next restart." -ForegroundColor Yellow
    }},
    @{ Title = "Show file extensions in Explorer"; Action = {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -Name HideFileExt -Value 0
        Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue
        Start-Process explorer
    }},
    @{ Title = "Restore classic right-click context menu (Windows 11 only)"; Action = {
        $os = Get-CimInstance Win32_OperatingSystem
        if ([int]$os.BuildNumber -lt 22000) {
            Write-Host "Skipping: Windows 11 is required; Windows 10 detected." -ForegroundColor Yellow
            return
        }
        reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    }},
    @{ Title = "Show seconds in clock, set date/locale format, taskbar tweaks"; Action = {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortDate"      -Value "yyyy-MM-dd"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sThousand"       -Value " "
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime"      -Value "HH:mm"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat"     -Value "HH:mm:ss"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "iFirstDayOfWeek" -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "iMeasure"        -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sCurrency"       -Value "€"
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sMonThousandSep" -Value " "
        Set-TimeZone -Name "Romance Standard Time"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
            -Name "SearchboxTaskbarMode" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -Name "ShowTaskViewButton" -Value 0 -Type DWord
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -Name "TaskbarAl" -Value 0 -Type DWord
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    }},
    @{ Title = "Enable dark theme"; Action = {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme   -Value 0
        $code = @'
using System;
using System.Runtime.InteropServices;
public class NativeMethods {
  [DllImport("user32.dll")]
  public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint flags, uint timeout, out UIntPtr result);
}
'@
        Add-Type -TypeDefinition $code
        [UIntPtr]$result = [UIntPtr]::Zero
        [NativeMethods]::SendMessageTimeout([IntPtr]0xffff, 0x1A, [UIntPtr]::Zero, "ImmersiveColorSet", 2, 5000, [ref]$result) | Out-Null
    }},
    @{ Title = "Install winget (needed on Win10 / LTSC)"; Action = {
        Invoke-WebRequest https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1 -UseBasicParsing | iex
    }},
    @{ Title = "Install Syncthing and WireGuard"; Action = {
        winget install --id Syncthing.Syncthing -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id WireGuard.WireGuard -e --accept-source-agreements --accept-package-agreements --silent
    }},
    @{ Title = "Configure Syncthing startup shortcut"; Action = {
        mkdir -Force "C:\syncthing" | Out-Null
        $SyncthingExe = (Get-Command syncthing.exe -ErrorAction Stop).Source
        $StartupFolder = [Environment]::GetFolderPath("Startup")
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut((Join-Path $StartupFolder "Syncthing.lnk"))
        $Shortcut.TargetPath = $SyncthingExe
        $Shortcut.Arguments = "--no-browser --no-console"
        $Shortcut.WorkingDirectory = "C:\syncthing"
        $Shortcut.Save()
    }},
    @{ Title = "Install core apps (Terminal, qView, Chrome, Bitwarden, Git, 7zip, AutoHotkey, NodeJS, OpenJDK, VSCode)"; Action = {
        winget install --id Microsoft.WindowsTerminal          -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id jurplel.qView                      -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Google.Chrome                      -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Bitwarden.Bitwarden                   -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Git.Git                            -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id 7zip.7zip                          -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id AutoHotkey.AutoHotkey              -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id OpenJS.NodeJS.22                   -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Microsoft.OpenJDK.25               -e --accept-source-agreements --accept-package-agreements --silent
        winget install --force Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements `
            --override '/VERYSILENT /SP- /MERGETASKS="runcode,desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
    }},
    @{ Title = "Install Apache Maven $MAVEN_VERSION to C:\apps\maven"; Action = {
        mkdir -Force c:\temp | Out-Null
        mkdir -Force c:\apps | Out-Null
        curl.exe -L "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" -o c:\temp\maven.zip
        Push-Location c:\temp
        & "C:\Program Files\7-Zip\7z.exe" x maven.zip
        Move-Item .\apache-maven* C:\apps\maven -Force
        Pop-Location
        $newPath = "C:\apps\maven\bin"
        $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
        if ($currentPath -notlike "*$newPath*") {
            [Environment]::SetEnvironmentVariable("Path", $currentPath + ";" + $newPath, [EnvironmentVariableTarget]::Machine)
        }
    }},
    @{ Title = "Install extra apps (Moonlight, Postman, VLC, GIMP, WinSCP, Inkscape, LibreHardwareMonitor, LocalSend)"; Action = {
        winget install --id MoonlightGameStreamingProject.Moonlight   -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Postman.Postman                           -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id VideoLAN.VLC                              -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id GIMP.GIMP.3                               -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id WinSCP.WinSCP                             -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Inkscape.Inkscape                         -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id LibreHardwareMonitor.LibreHardwareMonitor  -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id LocalSend.LocalSend  -e --accept-source-agreements --accept-package-agreements --silent
    }},
    @{ Title = "Install MSYS2"; Action = {
        winget install --id MSYS2.MSYS2 -e --accept-source-agreements --accept-package-agreements --silent
        Write-Host "MSYS2 installed. Open MSYS2 shell and run:" -ForegroundColor Yellow
        Write-Host "  pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-SDL2 git vim" -ForegroundColor Yellow
    }},
    @{ Title = "Install advanced workstation apps (OBS, Shotcut, Zoom, Avidemux)"; Action = {
        winget install --id OBSProject.OBSStudio       -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Meltytech.Shotcut          -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Zoom.Zoom                  -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id Avidemux.Avidemux          -e --accept-source-agreements --accept-package-agreements --silent
    }},
    @{ Title = "Install WSL + Tumbleweed"; Action = {
        winget install --id Microsoft.WSL              -e --accept-source-agreements --accept-package-agreements --silent
        winget install --id SUSE.openSUSE.Tumbleweed   -e --accept-source-agreements --accept-package-agreements --silent
        wsl --install --no-distribution
    }},
    @{ Title = "Install OnlyOffice Desktop Editors"; Action = {
        winget install --id ONLYOFFICE.DesktopEditors  -e --accept-source-agreements --accept-package-agreements --silent
    }},
    @{ Title = "Disable Xbox Game Bar"; Action = {
        # Redirect protocol handlers to systray.exe (AveYo method - proven on LTSC)
        "ms-gamebar","ms-gamebarservices","ms-gamingoverlay","ms-gamingdevice" | ForEach-Object {
            $proto = $_
            if (!(Test-Path "Registry::HKCR\$proto\shell")) { New-Item "Registry::HKCR\$proto\shell" -Force | Out-Null }
            if (!(Test-Path "Registry::HKCR\$proto\shell\open")) { New-Item "Registry::HKCR\$proto\shell\open" -Force | Out-Null }
            if (!(Test-Path "Registry::HKCR\$proto\shell\open\command")) { New-Item "Registry::HKCR\$proto\shell\open\command" -Force | Out-Null }
            Set-ItemProperty "Registry::HKCR\$proto" "(Default)" "URL:$proto" -Force
            Set-ItemProperty "Registry::HKCR\$proto" "URL Protocol" "" -Force
            Set-ItemProperty "Registry::HKCR\$proto" "NoOpenWith" "" -Force
            Set-ItemProperty "Registry::HKCR\$proto\shell\open\command" "(Default)" "`"$env:SystemRoot\System32\systray.exe`"" -Force
        }

        # Disable GameDVR / Game Bar
        reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f 2>&1 | Out-Null
        reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f 2>&1 | Out-Null
        reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "NoWinKeys" /t REG_DWORD /d 1 /f 2>&1 | Out-Null
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f 2>&1 | Out-Null

        # Disable Game Bar tips and "open Game Bar when controller connected"
        reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        reg add "HKCU\Software\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d 3 /f 2>&1 | Out-Null
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "GamePanelStartupTipIndex" /t REG_DWORD /d 3 /f 2>&1 | Out-Null

        # Group-policy level GameDVR block
        reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\GameDVR\AllowGameDVR" /v "value" /t REG_DWORD /d 0 /f 2>&1 | Out-Null

        # Disable Game Bar scheduled tasks (prevent background triggers)
        Get-ScheduledTask -TaskName "XboxGameBar*" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue

        # Kill Game Bar Presence Writer (triggers on gamepad plug)
        reg add "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" /v "ActivationType" /t REG_DWORD /d 0 /f 2>&1 | Out-Null

        # Disable Xbox-related services
        Get-Service -Name "XboxGipSvc" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Get-Service -Name "XblAuthManager" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Get-Service -Name "XblGameSave" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Get-Service -Name "XboxNetApiSvc" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Set-Service -Name "XboxGipSvc" -StartupType Disabled -ErrorAction SilentlyContinue
        Set-Service -Name "XblAuthManager" -StartupType Disabled -ErrorAction SilentlyContinue
        Set-Service -Name "XblGameSave" -StartupType Disabled -ErrorAction SilentlyContinue
        Set-Service -Name "XboxNetApiSvc" -StartupType Disabled -ErrorAction SilentlyContinue

        # Remove Game Bar appx package if present
        Get-AppxPackage -Name "Microsoft.XboxGamingOverlay" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage -Name "Microsoft.Xbox.TCUI" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage -Name "Microsoft.XboxApp" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage -Name "Microsoft.XboxIdentityProvider" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage -Name "Microsoft.XboxSpeechToTextOverlay" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    }},
    @{ Title = "Disable AutoPlay and AutoRun for all existing users"; Action = {
        $autoRunValue = 0xFF
        $machinePolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        if (!(Test-Path $machinePolicyPath)) { New-Item -Path $machinePolicyPath -Force | Out-Null }
        New-ItemProperty -Path $machinePolicyPath -Name "NoDriveTypeAutoRun" -PropertyType DWord -Value $autoRunValue -Force | Out-Null

        $profileListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        $profiles = foreach ($profileKey in Get-ChildItem $profileListPath) {
            $profileData = Get-ItemProperty -LiteralPath $profileKey.PSPath -ErrorAction SilentlyContinue
            if ($profileData.ProfileImagePath) {
                $profilePath = [Environment]::ExpandEnvironmentVariables($profileData.ProfileImagePath)
                $ntUserPath = Join-Path $profilePath "NTUSER.DAT"
                if (Test-Path $ntUserPath) {
                    [PSCustomObject]@{
                        Sid = $profileKey.PSChildName
                        NtUserPath = $ntUserPath
                    }
                }
            }
        }

        foreach ($profile in $profiles) {
            $hiveName = $profile.Sid
            $hivePath = "Registry::HKEY_USERS\$hiveName"
            $mountedByStep = $false

            if (!(Test-Path $hivePath)) {
                $mountName = "AutoPlay_$($profile.Sid -replace '[^A-Za-z0-9_]', '_')"
                & reg.exe load "HKU\$mountName" $profile.NtUserPath | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    Write-Warning "Could not load profile hive $($profile.Sid); skipping."
                    continue
                }
                $hiveName = $mountName
                $hivePath = "Registry::HKEY_USERS\$hiveName"
                $mountedByStep = $true
            }

            try {
                $autoplayPath = Join-Path $hivePath "Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers"
                if (!(Test-Path $autoplayPath)) { New-Item -Path $autoplayPath -Force | Out-Null }
                New-ItemProperty -Path $autoplayPath -Name "DisableAutoplay" -PropertyType DWord -Value 1 -Force | Out-Null

                $policyPath = Join-Path $hivePath "Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
                if (!(Test-Path $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
                New-ItemProperty -Path $policyPath -Name "NoDriveTypeAutoRun" -PropertyType DWord -Value $autoRunValue -Force | Out-Null
            }
            finally {
                if ($mountedByStep) {
                    & reg.exe unload "HKU\$hiveName" | Out-Null
                }
            }
        }

        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Process explorer.exe
    }},
    @{ Title = "Install BthPS3 $BTHPS3_VERSION and DsHidMini $DSHIDMINI_VERSION drivers"; Action = {
        mkdir -Force "C:\temp" | Out-Null
        Push-Location C:\temp
        $BthPS3Msi = "C:\temp\Nefarius_BthPS3_Drivers_x64_arm64_v$($BTHPS3_VERSION).msi"
        $DsHidMiniMsi = "C:\temp\Nefarius_DsHidMini_Drivers_x64_arm64_v$($DSHIDMINI_VERSION).msi"
        curl.exe -L "https://github.com/nefarius/BthPS3/releases/download/setup-v$($BTHPS3_VERSION)/Nefarius_BthPS3_Drivers_x64_arm64_v$($BTHPS3_VERSION).msi" -o $BthPS3Msi
        curl.exe -L "https://github.com/nefarius/DsHidMini/releases/download/setup-v$($DSHIDMINI_VERSION)/Nefarius_DsHidMini_Drivers_x64_arm64_v$($DSHIDMINI_VERSION).msi" -o $DsHidMiniMsi
        $BthPS3Install = Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", $BthPS3Msi, "/qn", "/norestart") -Wait -PassThru
        if ($BthPS3Install.ExitCode -notin @(0, 3010)) { throw "BthPS3 installation failed with exit code $($BthPS3Install.ExitCode)." }
        $DsHidMiniInstall = Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", $DsHidMiniMsi, "/qn", "/norestart") -Wait -PassThru
        if ($DsHidMiniInstall.ExitCode -notin @(0, 3010)) { throw "DsHidMini installation failed with exit code $($DsHidMiniInstall.ExitCode)." }
        Pop-Location
    }},
    @{ Title = "Install RetroArch $RETROARCH_VERSION + cores + BIOS and create shortcut"; Action = {
        mkdir -Force "C:\temp" | Out-Null
        Push-Location C:\temp
        curl.exe -LO "https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/windows/x86_64/RetroArch.7z"
        curl.exe -LO "https://buildbot.libretro.com/stable/${RETROARCH_VERSION}/windows/x86_64/RetroArch_cores.7z"
        & "C:\Program Files\7-Zip\7z.exe" x RetroArch.7z -y
        & "C:\Program Files\7-Zip\7z.exe" x RetroArch_cores.7z -y
        curl.exe -L "https://github.com/Abdess/retrobios/releases/download/${RETROARCH_BIOS_VERSION}/RetroArch_Lakka_v${RETROARCH_VERSION}_Platform_BIOS_Pack.zip" -o bios.zip
        & "C:\Program Files\7-Zip\7z.exe" x "bios.zip" -o".\RetroArch-Win64\system\" -y
        mkdir -Force "C:\apps" | Out-Null
        Remove-Item "C:\apps\RetroArch-Win64" -Recurse -Force -ErrorAction SilentlyContinue
        Move-Item RetroArch-Win64 "C:\apps\" -Force
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\retroarch.lnk")
        $Shortcut.TargetPath = "C:\apps\RetroArch-Win64\retroarch.exe"
        $Shortcut.WorkingDirectory = "C:\apps\RetroArch-Win64\"
        $Shortcut.Save()
        Pop-Location
    }},
    @{ Title = "Configure RetroArch"; Action = {
        Copy-Item "C:\dotfiles\home\.config\retroarch\retroarch.win64.cfg" "C:\apps\RetroArch-Win64\retroarch.cfg" -Force
        Copy-Item "C:\dotfiles\home\.config\retroarch\autoconfig" "C:\apps\RetroArch-Win64" -Recurse -Force
        Copy-Item "C:\dotfiles\home\.config\retroarch\config" "C:\apps\RetroArch-Win64" -Recurse -Force
    }},
    @{ Title = "Install EmulationStation DE"; Action = {
        mkdir -Force "C:\temp" | Out-Null
        Push-Location C:\temp
        curl.exe -L https://gitlab.com/es-de/emulationstation-de/-/package_files/288156909/download -o estation.zip
        & "C:\Program Files\7-Zip\7z.exe" x estation.zip -y
        Move-Item ES-DE "C:\apps" -Force
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\estation.lnk")
        $Shortcut.TargetPath = "C:\apps\ES-DE\ES-DE.exe"
        $Shortcut.WorkingDirectory = "C:\"
        $Shortcut.Save()
        Pop-Location
    }},
    @{ Title = "Configure EmulationStation DE"; Action = {
        mkdir -Force "C:\apps\ES-DE\ES-DE\settings" | Out-Null
        Copy-Item "C:\dotfiles\home\ES-DE\settings\es_settings.win64.xml" "C:\apps\ES-DE\ES-DE\settings\es_settings.xml" -Force
        mkdir -Force "C:\apps\ES-DE\resources\systems\windows" | Out-Null
        Copy-Item "C:\dotfiles\home\ES-DE\settings\es_systems.win64.xml" "C:\apps\ES-DE\resources\systems\windows\es_systems.xml" -Force
        $GameLists = @(
            "gc\gamelist.xml",
            "n3ds\gamelist.xml",
            "ps2\gamelist.xml",
            "psp\gamelist.xml",
            "psx\gamelist.xml",
            "wii\gamelist.xml"
        )
        foreach ($GameList in $GameLists) {
            $GameListPath = Join-Path "C:\apps\ES-DE\ES-DE\gamelists" $GameList
            mkdir -Force (Split-Path $GameListPath -Parent) | Out-Null
            Copy-Item (Join-Path "C:\dotfiles\home\ES-DE\gamelists" $GameList) $GameListPath -Force
        }
    }},
    @{ Title = "Install PCSX2 v$PCSX2_VERSION + BIOS"; Action = {
        mkdir -Force "C:\temp" | Out-Null
        Push-Location C:\temp
        curl.exe -L "https://github.com/PCSX2/pcsx2/releases/download/v$($PCSX2_VERSION)/pcsx2-v$($PCSX2_VERSION)-windows-x64-Qt.7z" -o pcsx2.7z
        & "C:\Program Files\7-Zip\7z.exe" x pcsx2.7z -opcsx2 -f
        Move-Item pcsx2 "C:\apps" -Force
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\pcsx2.lnk")
        $Shortcut.TargetPath = "C:\apps\pcsx2\pcsx2-qt.exe"
        $Shortcut.WorkingDirectory = "C:\apps\pcsx2\"
        $Shortcut.Save()
        $username = $env:USERNAME
        mkdir -Force "C:\Users\$username\Documents\PCSX2\bios" | Out-Null
        curl.exe -L https://github.com/archtaurus/RetroPieBIOS/raw/master/BIOS/pcsx2/bios/ps2-0230a-20080220.bin -o "C:\Users\$username\Documents\PCSX2\bios\ps2-0230a-20080220.bin"
        Pop-Location
    }},
    @{ Title = "Configure PCSX2 v$PCSX2_VERSION"; Action = {
        $username = $env:USERNAME
        mkdir -Force "C:\Users\$username\Documents\PCSX2\inis" | Out-Null
        Copy-Item "C:\dotfiles\home\.config\PCSX2\inis\PCSX2-win.ini" "C:\Users\$username\Documents\PCSX2\inis\PCSX2.ini" -Force
    }},
    @{ Title = "Install Dolphin $DOLPHIN_VERSION"; Action = {
        mkdir -Force "C:\temp" | Out-Null
        Push-Location C:\temp
        curl.exe -L "https://dl.dolphin-emu.org/releases/$($DOLPHIN_VERSION)/dolphin-$($DOLPHIN_VERSION)-x64.7z" -o dolphin.7z
        & "C:\Program Files\7-Zip\7z.exe" x dolphin.7z
        Move-Item Dolphin-x64 "C:\apps" -Force
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\dolphin.lnk")
        $Shortcut.TargetPath = "C:\apps\Dolphin-x64\Dolphin.exe"
        $Shortcut.WorkingDirectory = "C:\apps\Dolphin-x64\"
        $Shortcut.Save()
        Pop-Location
    }},
    @{ Title = "Configure Dolphin $DOLPHIN_VERSION"; Action = {
        $username = $env:USERNAME
        $cfg = "C:\Users\$username\AppData\Roaming\Dolphin Emulator\Config"
        mkdir -Force $cfg | Out-Null
        Copy-Item "C:\dotfiles\home\.config\dolphin-emu\win\Dolphin.ini" "$cfg\Dolphin.ini" -Force
        Copy-Item "C:\dotfiles\home\.config\dolphin-emu\GCPadNew.ini" "$cfg\GCPadNew.ini" -Force
        Copy-Item "C:\dotfiles\home\.config\dolphin-emu\WiimoteNew.ini" "$cfg\WiimoteNew.ini" -Force
        Copy-Item "C:\dotfiles\home\.config\dolphin-emu\GFX.ini" "$cfg\GFX.ini" -Force
        Copy-Item "C:\dotfiles\home\.config\dolphin-emu\Hotkeys.ini" "$cfg\Hotkeys.ini" -Force
    }},
    @{ Title = "Install Cemu v$CEMU_VERSION"; Action = {
        mkdir -Force "C:\temp" | Out-Null
        Push-Location C:\temp
        curl.exe -L "https://github.com/cemu-project/Cemu/releases/download/v$($CEMU_VERSION)/cemu-$($CEMU_VERSION)-windows-x64.zip" -o cmu.zip
        & "C:\Program Files\7-Zip\7z.exe" x cmu.zip -y
        if (Test-Path "C:\apps\cemu") {
            Remove-Item "C:\apps\cemu" -Recurse -Force -ErrorAction Stop
        }
        Move-Item Cemu* "C:\apps\cemu" -Force
        Copy-Item "C:\dotfiles\home\bin\cemu.bat" "C:\apps\cemu\cemu.bat" -Force
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\cemu.lnk")
        $Shortcut.TargetPath = "C:\apps\cemu\cemu.bat"
        $Shortcut.WorkingDirectory = "C:\apps\cemu"
        $Shortcut.Save()
        Pop-Location
    }},
    @{ Title = "Configure Cemu v$CEMU_VERSION"; Action = {
        $username = $env:USERNAME
        $cfg = "C:\Users\$username\AppData\Roaming\Cemu"
        mkdir -Force "$cfg\controllerProfiles" | Out-Null
        Copy-Item "C:\dotfiles\home\.config\cemu\settings-win.xml" "$cfg\settings.xml" -Force
    }},
    @{ Title = "Download gshorts source, compile, and create startup shortcut"; Action = {
        mkdir -Force "C:\apps\gshorts" | Out-Null
        $base = "https://raw.githubusercontent.com/alainpham/gshorts/master"
        curl.exe -L "$base/gshorts.c"   -o "C:\apps\gshorts\gshorts.c"
        $MsysBash = "C:\msys64\usr\bin\bash.exe"
        if (!(Test-Path $MsysBash)) { throw "MSYS2 Bash was not found at $MsysBash." }
        $PreviousMSYSTEM = $env:MSYSTEM
        $env:MSYSTEM = "UCRT64"
        try {
            & $MsysBash -lc 'pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-SDL2 && cd /c/apps/gshorts && rm -f gshorts.exe && gcc gshorts.c -o gshorts.exe $(pkg-config --cflags --libs sdl2) -mconsole && cp /ucrt64/bin/SDL2.dll /c/apps/gshorts/SDL2.dll'
            if ($LASTEXITCODE -ne 0) { throw "gshorts compilation failed with exit code $LASTEXITCODE." }
        }
        finally {
            if ($null -eq $PreviousMSYSTEM) { Remove-Item Env:MSYSTEM -ErrorAction SilentlyContinue }
            else { $env:MSYSTEM = $PreviousMSYSTEM }
        }
        $StartupFolder = [Environment]::GetFolderPath("Startup")
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut((Join-Path $StartupFolder "gshorts.lnk"))
        $Shortcut.TargetPath = "C:\apps\gshorts\gshorts.exe"
        $Shortcut.WorkingDirectory = "C:\apps\gshorts"
        $Shortcut.Save()
    }},
    @{ Title = "Download and compile SDL2 joystick tester"; Action = {
        mkdir -Force "C:\temp" | Out-Null
        mkdir -Force "C:\apps\sdl2-jstest" | Out-Null
        $MsysBash = "C:\msys64\usr\bin\bash.exe"
        if (!(Test-Path $MsysBash)) { throw "MSYS2 Bash was not found at $MsysBash." }
        $PreviousMSYSTEM = $env:MSYSTEM
        $env:MSYSTEM = "UCRT64"
        try {
            & $MsysBash -lc 'pacman -S --needed --noconfirm git mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-SDL2 mingw-w64-ucrt-x86_64-ncurses mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja && rm -rf /c/temp/sdl-jstest && git clone --depth 1 https://github.com/Grumbel/sdl-jstest.git /c/temp/sdl-jstest && sed -i ''s@setenv(\x22ESCDELAY\x22,[[:space:]]*\x2225\x22,[[:space:]]*1);@_putenv_s(\x22ESCDELAY\x22,\x2225\x22);@'' /c/temp/sdl-jstest/src/ui/test_ui.c && cd /c/temp/sdl-jstest && cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS=-DSDL_MAIN_HANDLED -DBUILD_SDL_JSTEST=OFF -DBUILD_SDL3_JSTEST=OFF && cmake --build build --config Release && exe=$(find build -type f -name "sdl2-jstest.exe" -print -quit) && test -n "$exe" && cp "$exe" /c/apps/sdl2-jstest/sdl2-jstest.exe && for dll in $(ldd "$exe" | awk ''$3 ~ /^\/ucrt64\/bin\/.*\.dll$/ {print $3}''); do cp "$dll" /c/apps/sdl2-jstest/; done'
            if ($LASTEXITCODE -ne 0) { throw "sdl2-jstest compilation failed with exit code $LASTEXITCODE." }
        }
        finally {
            if ($null -eq $PreviousMSYSTEM) { Remove-Item Env:MSYSTEM -ErrorAction SilentlyContinue }
            else { $env:MSYSTEM = $PreviousMSYSTEM }
        }
    }}
)

# ── Menu ─────────────────────────────────────────────────────────────────────
function Show-Menu {
    Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Windows Standard Setup               ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    for ($i = 0; $i -lt $Steps.Count; $i++) {
        Write-Host ("  {0,2}. {1}" -f ($i + 1), $Steps[$i].Title)
    }
    Write-Host ""
    Write-Host "  Enter step numbers to run (e.g. 1,3,5 or 1-5 or 'all')"
    Write-Host "  Press Enter with no input to exit"
}

function Parse-Selection {
    param([string]$Raw)
    $selected = @()
    foreach ($part in $Raw -split ',') {
        $part = $part.Trim()
        if ($part -match '^(\d+)-(\d+)$') {
            $selected += [int]$Matches[1]..[int]$Matches[2]
        } elseif ($part -match '^\d+$') {
            $selected += [int]$part
        }
    }
    return $selected | Sort-Object -Unique
}

function Run-Step {
    param($Step, [int]$Number)
    Write-Host "`n──────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host " Step $Number : $($Step.Title)" -ForegroundColor Cyan
    Write-Host "──────────────────────────────────────────" -ForegroundColor Cyan
    $confirm = Read-Host "Run? (Y/n/q to quit)"
    if ($confirm -eq 'q') { Write-Host "Exiting." -ForegroundColor Yellow; exit }
    if ($confirm -eq 'n') { Write-Host "Skipped." -ForegroundColor DarkGray; return }
    try {
        & $Step.Action
        Write-Host "Done." -ForegroundColor Green
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# ── Main loop ─────────────────────────────────────────────────────────────────
while ($true) {
    Show-Menu
    $raw = Read-Host "Selection"
    if ([string]::IsNullOrWhiteSpace($raw)) { Write-Host "Exiting." -ForegroundColor Yellow; break }

    if ($raw.Trim().ToLower() -eq 'all') {
        $indices = 1..$Steps.Count
    } else {
        $indices = Parse-Selection $raw
    }

    $invalid = $indices | Where-Object { $_ -lt 1 -or $_ -gt $Steps.Count }
    if ($invalid) {
        Write-Host "Invalid step(s): $($invalid -join ', '). Valid range: 1-$($Steps.Count)" -ForegroundColor Red
        continue
    }

    foreach ($i in $indices) {
        Run-Step $Steps[$i - 1] $i
    }

    Write-Host "`nDone with selection. Returning to menu..." -ForegroundColor Green
}
