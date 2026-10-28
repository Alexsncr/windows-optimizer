@echo off
setlocal EnableExtensions
chcp 65001 >nul
title SCRIPT MAESTRO TCP Y RED

fltmc >nul 2>&1
if errorlevel 1 (
    echo ERROR: Ejecuta este archivo como administrador.
    pause
    exit /b 1
)

echo ============================================
echo        SCRIPT MAESTRO TCP Y RED
echo ============================================
echo.
echo No se crearan copias de seguridad.
echo.

echo [1/7] Configurando TCP...

netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set heuristics disabled wsh=disabled forcews=disabled
netsh interface tcp set global congestionprovider=cubic
netsh interface tcp set global rss=enabled
netsh interface tcp set global rsc=disabled
netsh interface tcp set global chimney=disabled
netsh interface tcp set global ecncapability=enabled
netsh interface tcp set global timestamps=disabled
netsh interface tcp set global nonsackrttresiliency=disabled
netsh interface tcp set global maxsynretransmissions=2
netsh interface tcp set global initialRto=2000
netsh interface tcp set supplemental template=internet congestionprovider=cubic minrto=300

echo.
echo [2/7] Estableciendo MTU 1500 en adaptadores fisicos...

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object {$_.Status -ne 'Disabled'} | ForEach-Object {Set-NetIPInterface -InterfaceAlias $_.Name -AddressFamily IPv4 -NlMtuBytes 1500 -ErrorAction SilentlyContinue; Set-NetIPInterface -InterfaceAlias $_.Name -AddressFamily IPv6 -NlMtuBytes 1500 -ErrorAction SilentlyContinue}"

echo.
echo [3/7] Configurando parametros TCP/IP...

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 64 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f

echo.
echo [4/7] Configurando prioridades...

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v LocalPriority /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v HostsPriority /t REG_DWORD /d 5 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v DnsPriority /t REG_DWORD /d 6 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v NetbtPriority /t REG_DWORD /d 7 /f

echo.
echo [5/7] Configurando limites de conexiones...

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v MaxConnectionsPer1_0Server /t REG_DWORD /d 10 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v MaxConnectionsPerServer /t REG_DWORD /d 10 /f

reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v explorer.exe /t REG_DWORD /d 10 /f
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v iexplore.exe /t REG_DWORD /d 10 /f

reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v explorer.exe /t REG_DWORD /d 10 /f
reg add "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v iexplore.exe /t REG_DWORD /d 10 /f

echo.
echo [6/7] Configurando QoS...

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_SZ /d 1 /f

echo.
echo [7/7] Configurando SystemProfile, memoria y ACK...

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v Size /t REG_DWORD /d 3 /f

powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'; Get-ChildItem $p -ErrorAction SilentlyContinue | ForEach-Object {New-ItemProperty -Path $_.PSPath -Name TcpAckFrequency -PropertyType DWord -Value 1 -Force | Out-Null; New-ItemProperty -Path $_.PSPath -Name TCPNoDelay -PropertyType DWord -Value 1 -Force | Out-Null; New-ItemProperty -Path $_.PSPath -Name TcpDelAckTicks -PropertyType DWord -Value 0 -Force | Out-Null}"

reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f

echo.
echo ============================================
echo Proceso terminado.
echo Comprueba los mensajes de error, si aparecen.
echo Reinicia Windows para aplicar los cambios.
echo ============================================
pause
endlocal