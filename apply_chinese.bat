@echo off
chcp 65001 >nul
if not exist "%~dp0.local-build\manifest.json" (
    echo 请先运行 build.bat 构建本机汉化资源。
    pause
    exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0switch-language.ps1" -Mode Chinese
if errorlevel 1 (
    echo 切换未完成，请检查上方提示。请先从托盘完全退出 Antigravity。
    pause
    exit /b 1
)
pause
