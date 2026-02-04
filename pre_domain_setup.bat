@echo off
setlocal

:: Ask for password
set /p IT_PASSWORD=Enter password for local user "it": 

echo.
echo Starting system setup...

:: Paths
set DIR=%~dp0

:: .NET Framework 3.5
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart

:: SMBv1 Client
DISM /Online /Enable-Feature /FeatureName:SMB1Protocol-Client /All /NoRestart

:: Visual C++ Redistributable x64
"%DIR%VC_redist.x64.exe" /install /quiet /norestart

:: Import power plan
powercfg /import "%DIR%goreltex.pow"

:: Set password for user "it"
net user it "%IT_PASSWORD%"

echo.
echo Setup completed. Rebooting...

shutdown /r /t 5

endlocal
