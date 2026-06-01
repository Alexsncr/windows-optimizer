@echo Off
color 6
echo.
echo.
echo.                 --------------------------------------------------------------------------------------------------------
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A 
:::                
:::                   $$$$$$$$\ $$\   $$\ $$\      $$\       $$$$$$$$\ $$\      $$\ $$$$$$$$\  $$$$$$\  $$\   $$\   $$$$$$\  
:::                   $$  _____|$$ |  $$ |$$$\    $$$ |      \__$$  __|$$ | $\  $$ |$$  _____|$$  __$$\ $$ | $$  | $$  __$$\ 
:::                   $$ |      \$$\ $$  |$$$$\  $$$$ |         $$ |   $$ |$$$\ $$ |$$ |      $$ /  $$ |$$ |$$  / $$ /  \__|
:::                   $$$$$\     \$$$$  / $$\$$\$$ $$ |         $$ |   $$ $$ $$\$$ |$$$$$\    $$$$$$$$ |$$$$$  /  \$$$$$$\  
:::                   $$  __|    $$  $$<  $$ \$$$  $$ |         $$ |   $$$$  _$$$$ |$$  __|   $$  __$$ |$$  $$<    \____$$\ 
:::                   $$ |      $$  /\$$\ $$ |\$  /$$ |         $$ |   $$$  / \$$$ |$$ |      $$ |  $$ |$$ |\$$\  $$\   $$ |
:::                   $$$$$$$$\ $$ /  $$ |$$ | \_/ $$ |         $$ |   $$  /   \$$ |$$$$$$$$\ $$ |  $$ |$$ | \$$\  \$$$$$$  |
:::                   \________|\__|  \__|\__|     \__|         \__|   \__/     \__|\________|\__|  \__|\__|  \__|  \______/ 
:::                                                                                                                 	
echo.                ----------------------------------------------------------------------------------------------------------
echo.  
echo.
echo.
echo 
echo.
echo                                                        Press Any Key To Continue...     
pause >nul  

echo Aplicando tweaks de red...

:: =========================
:: NETSH SETTINGS
:: =========================
netsh int tcp set global autotuninglevel=normal
netsh int tcp set heuristics enabled
netsh int tcp set global congestionprovider=ctcp
netsh int tcp set global rss=enabled
netsh int tcp set global chimney=enabled
netsh int tcp set global timestamps=enabled
netsh int tcp set global nonsackrttresiliency=enabled
netsh int tcp set global initialRto=2000

:: OFFLOAD (algunos valores no existen en netsh moderno, se ignoran si falla)
netsh int tcp set global rsc=enabled
netsh int tcp set global ecncapability=enabled
netsh int tcp set global maxsynretransmissions=1

:: =========================
:: INTERNET EXPLORER LIMITS
:: =========================
reg add "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v explorer.exe /t REG_DWORD /d 10 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" /v iexplore.exe /t REG_DWORD /d 10 /f

reg add "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v explorer.exe /t REG_DWORD /d 10 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" /v iexplore.exe /t REG_DWORD /d 10 /f

:: =========================
:: TCPIP SERVICE PROVIDER
:: =========================
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v LocalPriority /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v HostsPriority /t REG_DWORD /d 5 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v DnsPriority /t REG_DWORD /d 6 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v NetbtPriority /t REG_DWORD /d 7 /f

:: =========================
:: QOS / NETWORK THROTTLING
:: =========================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f

:: =========================
:: LANMAN SERVER
:: =========================
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v Size /t REG_DWORD /d 3 /f

:: =========================
:: MEMORY MANAGEMENT
:: =========================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f

:: =========================
:: TCP GLOBAL PARAMETERS
:: =========================
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 64 /f

:: =========================
:: MSMQ
:: =========================
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f

echo.
echo Cambios aplicados. Reinicia el PC para que todo tenga efecto.
pause
echo.  
echo.
echo.
echo 
echo.
echo                                                        Press Any Key To Exit...     
pause >nul  
exit