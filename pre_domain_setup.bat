@echo off
setlocal enabledelayedexpansion

:: ============================
:: Ask for password
:: ============================

echo.
set /p IT_PASSWORD=Enter password for local user "it": 

if "%IT_PASSWORD%"=="" (
    echo [ERROR] Password cannot be empty
    exit /b 1
)

:: ============================
:: Paths
:: ============================

set SCRIPT_DIR=%~dp0
set VCR=%SCRIPT_DIR%VC_redist.x64.exe
set POW=%SCRIPT_DIR%goreltex.pow

echo.
echo === Pre-domain system setup started ===
echo.

:: ============================
:: Install .NET Framework 3.5
:: ============================

echo [INFO] Installing .NET Framework 3.5...
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart
set NETFX_RC=%errorlevel%

if NOT %NETFX_RC%==0 (
    echo [ERROR] .NET Framework 3.5 installation failed. Code: %NETFX_RC%
    goto END
)
echo [OK] .NET Framework 3.5 installed
echo.

:: ============================
:: Enable SMBv1 Client
:: ============================

echo [INFO] Enabling SMBv1 Client...
DISM /Online /Enable-Feature /FeatureName:SMB1Protocol-Client /All /NoRestart
set SMB_RC=%errorlevel%

if %SMB_RC%==0 (
    echo [OK] SMBv1 Client enabled
) else if %SMB_RC%==3010 (
    echo [OK] SMBv1 Client enabled, reboot required
) else (
    echo [ERROR] Failed to enable SMBv1 Client. Code: %SMB_RC%
)
echo.

:: ============================
:: Install Visual C++ Redistributable x64
:: ============================

if not exist "%VCR%" (
    echo [ERROR] VC_redist.x64.exe not found next to the script
    goto END
)

echo [INFO] Installing Visual C++ Redistributable x64...
"%VCR%" /install /quiet /norestart
set VCR_RC=%errorlevel%

if %VCR_RC%==0 (
    echo [OK] VC++ installed successfully
) else if %VCR_RC%==3010 (
    echo [OK] VC++ installed, reboot required
) else if %VCR_RC%==1638 (
    echo [OK] Newer VC++ version already installed
) else (
    echo [ERROR] VC++ installation failed. Code: %VCR_RC%
)
echo.

:: ============================
:: Import power plan
:: ============================

if not exist "%POW%" (
    echo [ERROR] goreltex.pow not found next to the script
    goto END
)

echo [INFO] Importing power plan...
powercfg /import "%POW%"

if %errorlevel%==0 (
    echo [OK] Power plan imported
) else (
    echo [ERROR] Power plan import failed
)
echo.

:: ============================
:: Set password for local account "it"
:: ============================

echo [INFO] Setting password for local user "it"...
net user it "%IT_PASSWORD%"

if %errorlevel%==0 (
    echo [OK] Password set for user "it"
) else (
    echo [ERROR] Failed to set password for user "it"
)
echo.

:: ============================
:: Finish and reboot
:: ============================

:END
echo === Setup completed. System will reboot in 10 seconds ===
shutdown /r /t 10 /c "Initial system setup completed"

endlocal
