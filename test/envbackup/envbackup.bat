echo off
set CURDIR=%~dp0
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%CURDIR%\envbackupgui.ps1"