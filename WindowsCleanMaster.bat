@echo off
title Windows 系统垃圾清理工具

color 0A
mode con cols=80 lines=30

echo.
echo =========================================================================
echo                 欢迎使用 Windows 系统垃圾清理工具
echo =========================================================================
echo.

:: 检查并获取管理员权限
:: 如果当前不是管理员权限，则尝试以管理员身份重新运行此批处理文件
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO 注意：此脚本未以管理员权限运行。
    ECHO 正在尝试以管理员身份重新启动脚本...
    ECHO.
    goto UACPrompt
)

goto MainScript

:UACPrompt
    :: 调用 PowerShell 以管理员权限重新运行当前批处理文件
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs"
    exit /b

:MainScript
echo 警告：此脚本将清理系统中的临时文件、缓存和回收站。
set /p "confirm_start=是否继续？(Y/N): "
if /i "%confirm_start%" neq "Y" (
    echo 操作已取消。
    goto END
)

echo.
echo 正在准备清理...请耐心等待。
echo.

:: --- 清理用户临时文件 (%TEMP%) ---
echo.
echo ## 清理用户临时文件 (%%TEMP%%) ##
echo.
set "user_temp_path=%TEMP%"
if exist "%user_temp_path%\" (
    echo 正在清理用户临时文件："%user_temp_path%\"
    :: 尝试删除目录内所有文件和子目录，忽略错误（由于文件占用是常态）
    del /f /s /q "%user_temp_path%\*" >nul 2>&1
    for /d %%d in ("%user_temp_path%\*") do (
        rmdir /s /q "%%d" >nul 2>&1
    )
    
    :: 再次尝试删除所有文件，并根据是否存在判断是否跳过
    pushd "%user_temp_path%" 2>nul
    if %errorlevel% equ 0 (
        for %%f in (*) do (
            if exist "%%f" (
                echo   跳过占用或无法删除的文件：%%f
            )
        )
        for /d %%d in (*) do (
            if exist "%%d" (
                echo   跳过占用或无法删除的目录：%%d
            )
        )
        popd
        echo 用户临时文件清理尝试完成。
    ) else (
        echo   无法访问或清理用户临时目录："*%user_temp_path%"，请检查权限。
    )
) else (
    echo **%user_temp_path%** 路径不存在，跳过。
)
echo.

:: --- 清理系统临时文件 (C:\Windows\Temp) ---
echo.
echo ## 清理系统临时文件 (C:\Windows\Temp) ##
echo.
set "system_temp_path=%SystemRoot%\Temp"
if exist "%system_temp_path%\" (
    echo 正在清理系统临时文件："%system_temp_path%\"
    echo **注意：此操作需要管理员权限，部分文件可能因系统占用而无法删除。**
    :: 尝试进入目录并删除内容
    pushd "%system_temp_path%" 2>nul
    if %errorlevel% equ 0 (
        :: 更改文件属性，以便删除只读或隐藏文件
        attrib -h -r -s "%system_temp_path%\*" /s /d >nul 2>&1
        
        :: 尝试删除目录中的所有文件和子目录
        del /f /s /q "%system_temp_path%\*" >nul 2>&1
        for /d %%d in ("%system_temp_path%\*") do (
            rmdir /s /q "%%d" >nul 2>&1
        )

        :: 再次遍历并报告未能删除的文件/目录
        for %%f in (*) do (
            if exist "%%f" (
                echo   跳过占用或无法删除的文件：%%f
            )
        )
        for /d %%d in (*) do (
            if exist "%%d" (
                echo   跳过占用或无法删除的目录：%%d
            )
        )
        popd
        echo 系统临时文件清理尝试完成。
    ) else (
        echo   无法访问系统临时目录："%system_temp_path%"，请确保已授予管理员权限。
    )
) else (
    echo **%system_temp_path%** 路径不存在，跳过。
)
echo.

:: --- 清空回收站 ---
echo.
echo ## 清空回收站 ##
echo.
set /p "confirm_recycle=是否清空所有用户的回收站内容？(Y/N): "
if /i "%confirm_recycle%"=="Y" (
    echo 正在清空回收站...
    :: 使用 PowerShell 清空所有回收站，这是最安全、可靠且非交互式的方法。
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
    if %errorlevel% equ 0 (
        echo 回收站清空完成。
    ) else (
        echo 清空回收站失败或遇到问题，请确保已授予管理员权限。
    )
) else (
    echo 跳过清空回收站。
)
echo.

:: --- 清理浏览器缓存 (仅提示常见路径，不强制删除) ---
echo.
echo ## 清理浏览器缓存 (仅提示常见路径，不强制删除) ##
echo.
echo 以下是主流浏览器常见缓存路径，请自行通过浏览器设置进行清理，或理解风险后手动删除：
echo   - Google Chrome: "%%LocalAppData%%\Google\Chrome\User Data\Default\Cache"
echo   - Microsoft Edge: "%%LocalAppData%%\Microsoft\Edge\User Data\Default\Cache"
echo   - Mozilla Firefox: "%%AppData%%\Mozilla\Firefox\Profiles\*.default-release\cache2" (具体文件夹名不同)
echo.
echo 由于直接删除可能导致浏览器配置问题，本脚本不自动清理。
echo.

:: --- 清理常见的软件安装残留文件 (*.tmp, *.bak, *.old) ---
echo.
echo ## 清理常见的软件安装残留文件 (*.tmp, *.bak, *.old) ##
echo.
echo 正在搜索并删除以下类型文件：
echo   - *.tmp
echo   - *.bak
echo   - *.old
echo.

:: 搜索并删除常见垃圾文件，仅在特定用户相关和系统临时目录中进行。
set "search_paths=%TEMP% %SystemRoot%\Temp %UserProfile%\Downloads %UserProfile%\AppData\Local\Temp"

for %%p in (%search_paths%) do (
    if exist "%%p\" (
        echo 正在 "%%p\" 目录中搜索...
        pushd "%%p" 2>nul
        if %errorlevel% equ 0 (
            :: 删除文件，并根据是否存在判断是否跳过
            for %%f in (*.tmp *.bak *.old) do (
                del /f /q "%%f" >nul 2>&1
                if exist "%%f" (
                    echo   跳过占用或无法删除的文件：%%f
                )
            )
            popd
        ) else (
            echo   无法访问目录 "%%p"，跳过。
        )
    )
)
echo.

:: --- 清理日志文件 (*.log) ---
echo.
echo ## 清理日志文件 (*.log) ##
echo.
echo 警告：删除日志文件可能导致某些应用程序或系统组件在排查问题时失去重要的历史数据。
echo 本脚本将尝试删除常见的可清理日志文件，并跳过正在使用的文件。
echo.

:: 扩展日志文件搜索路径
set "log_search_paths=%TEMP% %SystemRoot%\Temp %UserProfile%\Downloads %UserProfile%\AppData\Local\Temp %SystemRoot%\Logs %ProgramData%"

for %%p in (%log_search_paths%) do (
    if exist "%%p\" (
        echo 正在 "%%p\" 目录中搜索并删除 *.log 文件...
        pushd "%%p" 2>nul
        if %errorlevel% equ 0 (
            for %%f in (*.log) do (
                del /f /q "%%f" >nul 2>&1
                if exist "%%f" (
                    echo   跳过占用或无法删除的日志文件：%%f
                )
            )
            popd
        ) else (
            echo   无法访问目录 "%%p"，跳过。
        )
    )
)
echo.

:: --- 清理预取文件 (C:\Windows\Prefetch) ---
echo.
echo ## 清理预取文件 (C:\Windows\Prefetch) ##
echo.
set "prefetch_path=%SystemRoot%\Prefetch"
if exist "%prefetch_path%\" (
    echo 正在删除预取文件："%prefetch_path%\"
    :: 保留 Prefetch 目录本身，只删除其内容，主要是 .pf 文件和 .tmp 文件
    pushd "%prefetch_path%" 2>nul
    if %errorlevel% equ 0 (
        del /f /q "*.pf" >nul 2>&1
        del /f /q "*.tmp" >nul 2>&1
        :: 报告未能删除的文件
        for %%f in ("*.pf" "*.tmp") do (
            if exist "%%f" (
                echo   跳过占用或无法删除的文件：%%f
            )
        )
        popd
        echo 预取文件清理完成。
    ) else (
        echo   无法访问预取目录："%prefetch_path%"，请确保以管理员身份运行脚本。
    )
) else (
    echo %prefetch_path% 路径不存在，跳过。
)
echo.

:: --- 清理缩略图缓存 (thumbcache_*.db) ---
echo.
echo ## 清理缩略图缓存 (thumbcache_*.db) ##
echo.
set "thumbcache_path=%LocalAppData%\Microsoft\Windows\Explorer"
if exist "%thumbcache_path%\" (
    echo 正在删除缩略图缓存文件："%thumbcache_path%\thumbcache_*.db"
    pushd "%thumbcache_path%" 2>nul
    if %errorlevel% equ 0 (
        del /f /q "thumbcache_*.db" >nul 2>&1
        :: 报告未能删除的文件
        for %%f in ("thumbcache_*.db") do (
            if exist "%%f" (
                echo   跳过占用或无法删除的文件：%%f
            )
        )
        popd
        echo 缩略图缓存清理完成。
    ) else (
        echo   无法访问缩略图缓存目录："%thumbcache_path%"，跳过。
    )
) else (
    echo %thumbcache_path% 路径不存在，跳过。
)
echo.

:: --- 清理其他常见垃圾文件 ---
echo.
echo ## 清理其他常见垃圾文件 ##
echo.

:: 清理 Windows 更新临时文件（SoftwareDistribution\Download）
set "update_download_path=%SystemRoot%\SoftwareDistribution\Download"
if exist "%update_download_path%\" (
    echo 正在删除 Windows 更新临时文件："%update_download_path%\"
    :: 停止BITS和Windows Update服务以确保文件不被锁定
    echo   尝试停止 BITS 和 Windows Update 服务...
    net stop bits >nul 2>&1
    net stop wuauserv >nul 2>&1
    
    :: 为了安全和彻底，尝试删除目录内容
    :: 递归删除所有文件和子目录，忽略错误
    del /f /s /q "%update_download_path%\*" >nul 2>&1
    for /d %%d in ("%update_download_path%\*") do (
        rmdir /s /q "%%d" >nul 2>&1
    )

    :: 检查残留
    if exist "%update_download_path%\*" (
        echo Windows 更新临时文件清理可能不完全，部分文件被占用。
    ) else (
        echo Windows 更新临时文件清理完成。
    )
) else (
    echo %update_download_path% 路径不存在，跳过。
)
echo.

:: 清理系统错误报告队列
set "wer_path=%LocalAppData%\Microsoft\Windows\WER\ReportQueue"
if exist "%wer_path%\" (
    echo 正在删除系统错误报告队列："%wer_path%\"
    :: 递归删除所有内容，忽略错误
    del /f /s /q "%wer_path%\*" >nul 2>&1
    for /d %%d in ("%wer_path%\*") do (
        rmdir /s /q "%%d" >nul 2>&1
    )
    
    :: 检查残留
    if exist "%wer_path%\*" (
        echo 系统错误报告队列清理可能不完全，部分文件被占用。
    ) else (
        echo 系统错误报告队列清理完成。
    )
) else (
    echo %wer_path% 路径不存在，跳过。
)
echo.

echo.
echo =========================================================================
echo                 系统垃圾清理完成！
echo =========================================================================

echo.
echo 感谢使用 Windows 系统垃圾清理工具！
echo.
pause