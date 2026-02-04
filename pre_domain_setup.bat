@echo off
setlocal enabledelayedexpansion

:: ============================
:: Configuration
:: ============================

set SCRIPT_DIR=%~dp0
set LOG=%SCRIPT_DIR%setup_log.txt
set VCR=%SCRIPT_DIR%VC_redist.x64.exe
set POW=%SCRIPT_DIR%goreltex.pow

:: Password for local account "it"
:: CHANGE THIS PASSWORD BEFORE USE
set IT_PASSWORD=ChangeMe123!

:: ============================
:: Init log
:: ============================

if exist "%LOG%" del "%LOG%"
echo === Script started: %DATE% %TIME% === >> "%LOG%"
echo. >> "%LOG%"

:: ============================
:: Install .NET Framework 3.5
:: ============================

echo [INFO] Installing .NET Framework 3.5 >> "%LOG%"
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart >> "%LOG%" 2>&1
set NETFX_RC=%errorlevel%

if NOT %NETFX_RC%==0 (
    echo [ERROR] .NET Framework 3.5 installation failed. Code: %NETFX_RC% >> "%LOG%"
    goto END
)

echo [OK] .NET Framework 3.5 installed >> "%LOG%"
echo. >> "%LOG%"

:: ============================
:: Enable SMBv1 Client
:: ============================

echo [INFO] Enabling SMBv1 Client >> "%LOG%"
DISM /Online /Enable-Feature /FeatureName:SMB1Protocol-Client /All /NoRestart >> "%LOG%" 2>&1
set SMB_RC=%errorlevel%

if %SMB_RC%==0 (
    echo [OK] SMBv1 Client enabled >> "%LOG%"
) else if %SMB_RC%==3010 (
    echo [OK] SMBv1 Client enabled, reboot required >> "%LOG%"
) else (
    echo [ERROR] Failed to enable SMBv1 Client. Code: %SMB_RC% >> "%LOG%"
)
echo. >> "%LOG%"

:: ============================
:: Install Visual C++ Redistributable x64
:: ============================

if not exist "%VCR%" (
    echo [ERROR] VC_redist.x64.exe not found >> "%LOG%"
    goto END
)

echo [INFO] Installing VC++ Redistributable x64 >> "%LOG%"
"%VCR%" /install /quiet /norestart >> "%LOG%" 2>&1
set VCR_RC=%errorlevel%

if %VCR_RC%==0 (
    echo [OK] VC++ installed >> "%LOG%"
) else if %VCR_RC%==3010 (
    echo [OK] VC++ installed, reboot required >> "%LOG%"
) else if %VCR_RC%==1638 (
    echo [OK] Newer VC++ version already installed >> "%LOG%"
) else (
    echo [ERROR] VC++ installation failed. Code: %VCR_RC% >> "%LOG%"
)
echo. >> "%LOG%"

:: ============================
:: Import power plan
:: ============================

if not exist "%POW%" (
    echo [ERROR] goreltex.pow not found >> "%LOG%"
    goto END
)

echo [INFO] Importing power plan >> "%LOG%"
powercfg /import "%POW%" >> "%LOG%" 2>&1

if %errorlevel%==0 (
    echo [OK] Power plan imported >> "%LOG%"
) else (
    echo [ERROR] Power plan import failed >> "%LOG%"
)
echo. >> "%LOG%"

:: ============================
:: Set password for local account "it"
:: ============================

echo [INFO] Setting password for local user "it" >> "%LOG%"
net user it "%IT_PASSWORD%" >> "%LOG%" 2>&1

if %errorlevel%==0 (
    echo [OK] Password set for user "it" >> "%LOG%"
) else (
    echo [ERROR] Failed to set password for user "it" >> "%LOG%"
)
echo. >> "%LOG%"

:: ============================
:: Finish and reboot
:: ============================

:END
echo === Script finished: %DATE% %TIME% === >> "%LOG%"

echo [INFO] System will reboot in 10 seconds >> "%LOG%"
shutdown /r /t 10 /c "Initial system setup completed"

endlocal
