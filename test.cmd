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
echo            System Maintenance Script
echo ===================================================
echo.
echo This script will execute the following tasks:
echo.
echo - Network reset commands (IP reset, Winsock reset, DNS flush, etc.)
echo - Run system performance assessment (winsat)
echo - Upgrade Apps And Repair FPS Issues
echo - Clear / Clean Extensive Degrading FPS Cache
echo - Delete cached/pre-stored files, unnecessary files, and empty Recycle Bin
echo - Please Note This Is Open Source And You Can View Code
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

echo ===================================================
echo All commands have been executed successfully.
echo ===================================================
pause
goto EXIT

:EXIT
echo Exiting script. Goodbye!
pause
exit
