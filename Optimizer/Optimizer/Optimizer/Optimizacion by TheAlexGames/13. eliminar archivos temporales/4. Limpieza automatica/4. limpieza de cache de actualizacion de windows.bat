@echo off
net stop wuauserv
net stop UsoSvc
rd /s /q C:\Windows\SoftwareDistribution
md C:\Windows\SoftwareDistribution
pause
msg * limpieza de cache de actualizacion de windows by TheAlexGames