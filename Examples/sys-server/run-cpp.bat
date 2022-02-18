@echo off
if %1 == debug (
	bin\cpp\Main-debug.exe
    pause
) else (
	bin\cpp\Main.exe
)
