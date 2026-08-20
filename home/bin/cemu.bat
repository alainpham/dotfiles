@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "CEMU_EXE=C:\apps\cemu\Cemu.exe"
set "SDL2_JSTEST=C:\apps\sdl2-jstest\sdl2-jstest.exe"
set "CEMU_PROFILES=%APPDATA%\Cemu\controllerProfiles"
set "TEMPLATE=C:\dotfiles\home\.config\Cemu\controllerProfiles\sdl.xml"

if not exist "%CEMU_EXE%" (
    echo Cemu was not found at "%CEMU_EXE%" 1>&2
    exit /b 1
)
if not exist "%SDL2_JSTEST%" (
    echo sdl2-jstest was not found at "%SDL2_JSTEST%" 1>&2
    exit /b 1
)
if not exist "%TEMPLATE%" (
    echo Cemu controller profile template was not found at "%TEMPLATE%" 1>&2
    exit /b 1
)

if not exist "%CEMU_PROFILES%" mkdir "%CEMU_PROFILES%"
del /q "%CEMU_PROFILES%\controller*.xml" 2>nul
set /a PROFILE_INDEX=0

for /f "tokens=3" %%G in ('"%SDL2_JSTEST%" --list ^| findstr GUID:') do (
    if not defined seen_%%G set /a seen_%%G=0
    set "PAD_UUID=!seen_%%G!_%%G"
    set "PROFILE=%CEMU_PROFILES%\controller!PROFILE_INDEX!.xml"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
        "$content = Get-Content -Raw -LiteralPath '%TEMPLATE%'; $content = $content.Replace('${PAD_UUID}', $env:PAD_UUID); Set-Content -LiteralPath '!PROFILE!' -Value $content -Encoding utf8"
    if errorlevel 1 exit /b 1
    set /a seen_%%G+=1
    set /a PROFILE_INDEX+=1
)

pushd "%~dp0" >nul
"%CEMU_EXE%" %*
set "EXIT_CODE=%ERRORLEVEL%"
popd >nul
exit /b %EXIT_CODE%
