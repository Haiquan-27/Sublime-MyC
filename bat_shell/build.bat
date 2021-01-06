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

rem �ж��ļ���׺
IF NOT %c_source:~-2%==.c (
	echo ^[build Դ�ļ���׺%c_source:~-2%����Ϊ".c"^]
	echo ^[build ��ѡ��".c"��׺���ļ�^]
	exit /B 0
) ELSE (
	rem ��������ļ���
	IF NOT EXIST "%out_dir%" (
		echo ^[md %out_dir%^]
		md "%out_dir%"
	)
	rem ����
	rem ����ļ����ó�".exe.tmp"�ļ�
	echo ^[build gcc.exe "%c_source%" -o "%out_dir%\%c_source:~0,-2%.exe.tmp" %build_ext%^]
	gcc.exe "%c_source%" -o "%out_dir%\%c_source:~0,-2%.exe.tmp" %build_ext%
	rem �鿴".exe.tmp"�ļ��Ƿ����,�жϱ����Ƿ�ɹ�
	IF EXIST "%out_dir%\%c_source:~0,-2%.exe.tmp" (
		rem ".exe.tmp"����".exe"�ļ�
		echo ^[move: "%out_dir%\%c_source:~0,-2%.exe.tmp" ^>^> "%out_dir%\%c_source:~0,-2%.exe"^]
		move /Y "%out_dir%\%c_source:~0,-2%.exe.tmp" "%out_dir%\%c_source:~0,-2%.exe"
		rem ����ʧ��,".exe.tmp"����
		rem ���ǳɹ�,".exe.tmp"������
		IF EXIST "%out_dir%\%c_source:~0,-2%.exe.tmp" (
			del "%out_dir%\%c_source:~0,-2%.exe.tmp"
			exit /B 0
		) ELSE (
			echo ^[build �������^]
			IF "%to_run%"=="" (
				exit /B 0
			) ELSE (
				echo ^[run "%out_dir%\%c_source:~0,-2%.exe"^]
				"%~dp0\run.bat" "%out_dir%\%c_source:~0,-2%.exe"
			)
		)
	) ELSE (exit /B 0)
)
