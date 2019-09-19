set CURDIR=%~dp0
echo off
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%CURDIR%\envbackupgui.ps1"