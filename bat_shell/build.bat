@echo off

set c_source=%1
set out_exe=%2
set out_dir=%3
set build_ext=%4
set to_run=%5

set c_source=%c_source:~1,-1%
set out_exe=%out_exe:~1,-1%
set out_dir=%out_dir:~1,-1%
set build_ext=%build_ext:~1,-1%

ping 192.0.2.2 -n 1 -w 1000 > nul

rem 判断文件后缀
IF NOT %c_source:~-2%==.c (
	echo ^[build 源文件后缀%c_source:~-2%并非为".c"^]
	echo ^[build 请选择".c"后缀的文件^]
	exit /B 0
) ELSE (
	rem 创建输出文件夹
	IF NOT EXIST "%out_dir%" (
		echo ^[md %out_dir%^]
		md "%out_dir%"
	)
	rem 编译
	rem 输出文件设置成".exe.tmp"文件
	echo ^[build gcc.exe "%c_source%" -o "%out_dir%\%c_source:~0,-2%.exe.tmp" %build_ext%^]
	gcc.exe "%c_source%" -o "%out_dir%\%c_source:~0,-2%.exe.tmp" %build_ext%
	rem 查看".exe.tmp"文件是否存在,判断编译是否成功
	IF EXIST "%out_dir%\%c_source:~0,-2%.exe.tmp" (
		rem ".exe.tmp"覆盖".exe"文件
		echo ^[move: "%out_dir%\%c_source:~0,-2%.exe.tmp" ^>^> "%out_dir%\%c_source:~0,-2%.exe"^]
		move /Y "%out_dir%\%c_source:~0,-2%.exe.tmp" "%out_dir%\%c_source:~0,-2%.exe"
		rem 覆盖失败,".exe.tmp"存在
		rem 覆盖成功,".exe.tmp"不存在
		IF EXIST "%out_dir%\%c_source:~0,-2%.exe.tmp" (
			del "%out_dir%\%c_source:~0,-2%.exe.tmp"
			exit /B 0
		) ELSE (
			echo ^[build 编译完成^]
			IF "%to_run%"=="" (
				exit /B 0
			) ELSE (
				echo ^[run "%out_dir%\%c_source:~0,-2%.exe"^]
				"%~dp0\run.bat" "%out_dir%\%c_source:~0,-2%.exe"
			)
		)
	) ELSE (exit /B 0)
)
