@ECHO OFF
SETLOCAL

CD /D %~dp0

for /f "usebackq" %%i in (`wsl.exe -d Ubuntu-18.04 exec hostname -I`) do set CONNECTADDRESS=%%i
REM スペースを削除
SET CONNECTADDRESS=%CONNECTADDRESS: =%
netsh.exe interface portproxy delete v4tov4 listenport=22
netsh.exe interface portproxy add v4tov4 listenport=22 connectaddress=%CONNECTADDRESS%
netsh.exe interface portproxy show v4tov4
PAUSE

ENDLOCAL
EXIT /B 0
REM vim:ft=dosbatch fenc=cp932 ff=dos
