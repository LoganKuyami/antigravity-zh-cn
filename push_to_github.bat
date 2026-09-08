@echo off
chcp 65001 >nul
set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;C:\Program Files\Git\cmd;C:\Users\Administrator\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\git\cmd;%PATH%"
cd /d "%~dp0"
echo 正在推送到 GitHub (LoganKuyami/antigravity-zh-cn)...
echo.
git push -u origin main
if errorlevel 1 (
    echo.
    echo 推送未完成，请检查上方提示。
) else (
    echo.
    echo =======================================
    echo 推送成功！代码已同步至 GitHub。
    echo =======================================
)
echo.
pause
