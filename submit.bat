@echo off

del hxWebSockets.zip /q
7za a hxWebSockets.zip haxelib.json hx

haxelib submit hxWebSockets.zip ianharrigan
del hxWebSockets.zip /q
