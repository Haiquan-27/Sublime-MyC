@echo off
::运行并将返回值输出到文件
set cmd=%1
set ERRORLEVEL=
%cmd%
set err_res=%ERRORLEVEL%
echo %err_res% > "%~dp0\last_res.tmp"

