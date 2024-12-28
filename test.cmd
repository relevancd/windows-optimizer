@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    echo Please run as Administrator.
    pause
    exit /b
)

:MENU
cls
echo ===================================================
echo            Enhanced System Maintenance Script
echo ===================================================
echo.
echo This script will execute the following tasks:
echo.
echo - Network reset commands (IP reset, Winsock reset, DNS flush, etc.)
echo - Run system performance assessment (winsat)
echo - Upgrade Apps And Repair FPS Issues
echo - Clear Extensive FPS-degrading Cache

echo - Delete cached/pre-stored files, unnecessary files, and empty Recycle Bin
echo - Advanced FPS and Graphics Optimization Tweaks
echo - Disable all startup applications
echo.
echo [1] Run all commands
echo [2] Exit
echo.
set /p userChoice="Please select an option: "

if "%userChoice%"=="1" goto EXECUTE
if "%userChoice%"=="2" goto EXIT

echo Invalid choice, please try again.
pause
goto MENU

:EXECUTE
echo Starting system maintenance...

echo Resetting network configurations...
netsh int ip reset
netsh winsock reset
ipconfig /release
ipconfig /flushdns
ipconfig /renew

netsh interface tcp show global
netsh int tcp set global autotuninglevel=normal

echo Running system file check...
sfc /scannow

echo Performing DISM repair...
DISM.exe /Online /Cleanup-image /Restorehealth

echo Configuring file system memory usage...
fsutil behavior set memoryusage 2

echo Configuring virtual address space...
bcdedit /set increaseuserva 4096

echo Running system performance assessment...
winsat formal

echo Setting High Performance power plan...
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Disable all startup applications
echo Disabling all startup applications...
powershell -Command "Get-CimInstance Win32_StartupCommand | ForEach-Object { $_.Delete() }"
echo All startup applications disabled.

echo Upgrading all apps with Winget...
winget upgrade --all --include-unknown

echo Cleaning %TEMP% folder...
del /q /f /s %temp%\*
echo %TEMP% folder cleaned.

echo Cleaning Prefetch folder cache...
del /q /f /s C:\Windows\Prefetch\*
echo Prefetch folder cache cleaned.

echo Cleaning Windows Update Cache...
del /q /f /s C:\Windows\SoftwareDistribution\Download\*
echo Windows Update cache cleaned.

echo Clearing browser caches (if applicable)...
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    del /q /f /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*"
    echo Google Chrome cache cleaned.
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    del /q /f /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*"
    echo Microsoft Edge cache cleaned.
)
if exist "%APPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%d in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do (
        del /q /f /s "%%d\cache2\*"
        echo Firefox cache cleaned for profile %%d.
    )
)

echo Emptying Recycle Bin...
powershell -Command "Clear-RecycleBin -Force"
echo Recycle Bin emptied.

echo Deleting unnecessary system files...
cleanmgr /sagerun:1

REM =============================
REM FPS Optimization Tweaks
REM =============================

REM Disable Game DVR and Xbox Game Bar
reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v HistoricalCaptureEnabled /t REG_DWORD /d 0 /f

REM Disable Fullscreen Optimization
reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f

REM Increase GPU Priority
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v GPU Priority /t REG_DWORD /d 8 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f

REM Enable Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

REM =============================
REM Network Optimization Tweaks
REM =============================

REM Disable Nagle's Algorithm
rem Replace {YOUR-NETWORK-ADAPTER-ID} with your network adapter ID.
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{YOUR-NETWORK-ADAPTER-ID}" /v TcpAckFrequency /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{YOUR-NETWORK-ADAPTER-ID}" /v TCPNoDelay /t REG_DWORD /d 1 /f

REM Disable Large Send Offload (LSO)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{YOUR-NETWORK-ADAPTER-ID}" /v DisableLargeSendOffload /t REG_DWORD /d 1 /f

REM Set Network Throttling Index
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d ffffffff /f

REM Reduce DNS Cache Timeout
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxNegativeCacheTtl /t REG_DWORD /d 0 /f

REM Optimize MTU and RWIN Settings
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 64 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpWindowSize /t REG_DWORD /d 64240 /f

REM Disable Auto-Tuning
netsh interface tcp set global autotuninglevel=disabled

REM =============================
REM Optional Advanced Tweaks
REM =============================

REM Disable Dynamic Tick
bcdedit /set disabledynamictick yes

REM Enable MSI Mode for GPUs and Network Adapters (requires MSI Utility Tool)

REM Disable Interrupt Moderation
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0001" /v *InterruptModeration /t REG_SZ /d 0 /f

REM =============================
REM Final Steps
REM =============================
echo All optimizations applied. Please restart your PC for changes to take effect.
pause

echo ===================================================
echo All commands have been executed successfully.
echo ===================================================
pause
goto EXIT

:EXIT
echo Exiting script. Goodbye!
pause
exit
