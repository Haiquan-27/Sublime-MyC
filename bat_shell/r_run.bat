@echo off
::���в�������ֵ������ļ�
set cmd=%1
set ERRORLEVEL=
%cmd%
set err_res=%ERRORLEVEL%
echo %err_res% > "%~dp0\last_res.tmp"

