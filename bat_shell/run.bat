@echo off
:: 调用运行,获取返回值

set r_run="%~dp0\r_run.bat"
set res_file="%~dp0\last_res.tmp"

set run_cmd=%1
start %run_cmd% /wait cmd /c "%r_run% %run_cmd% & echo. & pause"

IF EXIST %res_file% (
	echo exit code:
	type %res_file%
	rem set /p code=<%res_file%
	rem echo ^[run: exit^( %code% ^)^]
	rem echo ^[run: exit^( %code% ^)^]
	del %res_file%
) ELSE (
	echo ^[run: no last_res.tmp?^]
)
