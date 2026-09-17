@echo off
chcp 65001 >nul
set "PATH=%LOCALAPPDATA%\Programs\nodejs;C:\Program Files\nodejs;C:\Program Files (x86)\nodejs;%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin;%LOCALAPPDATA%\OpenAI\Codex\runtimes\cua_node\6f12e0ef1c6e5061\bin;%PATH%"
where node.exe >nul 2>&1
if errorlevel 1 (
    echo 需要 Node.js 18 或更新版本。请安装后重试：https://nodejs.org/
    pause
    exit /b 1
)
node "%~dp0build.cjs"
if errorlevel 1 (
    echo 构建失败，请检查上方提示。
    pause
    exit /b 1
)
echo 构建成功。请完全退出 Antigravity，再运行 apply_chinese.bat。
pause
