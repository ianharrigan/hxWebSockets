@echo off
if %1 == debug (
	build\hxwidgets\Main-debug.exe
    pause
) else (
	build\hxwidgets\Main.exe
)
