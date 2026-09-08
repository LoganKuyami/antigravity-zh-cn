@echo off
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0switch-language.ps1" -Mode English
if errorlevel 1 (
 echo 切换未完成，请检查上方提示。请先从托盘完全退出 Antigravity。
 pause
 exit /b 1
)
