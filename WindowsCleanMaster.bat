@echo off
title Windows ϵͳ����������

color 0A
mode con cols=80 lines=30

echo.
echo =========================================================================
echo                 ��ӭʹ�� Windows ϵͳ����������
echo =========================================================================
echo.

:: ��鲢��ȡ����ԱȨ��
:: �����ǰ���ǹ���ԱȨ�ޣ������Թ���Ա����������д��������ļ�
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO ע�⣺�˽ű�δ�Թ���ԱȨ�����С�
    ECHO ���ڳ����Թ���Ա������������ű�...
    ECHO.
    goto UACPrompt
)

goto MainScript

:UACPrompt
    :: ���� PowerShell �Թ���ԱȨ���������е�ǰ�������ļ�
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs"
    exit /b

:MainScript
echo ���棺�˽ű�������ϵͳ�е���ʱ�ļ�������ͻ���վ��
set /p "confirm_start=�Ƿ������(Y/N): "
if /i "%confirm_start%" neq "Y" (
    echo ������ȡ����
    goto END
)

echo.
echo ����׼������...�����ĵȴ���
echo.

:: --- �����û���ʱ�ļ� (%TEMP%) ---
echo.
echo ## �����û���ʱ�ļ� (%%TEMP%%) ##
echo.
set "user_temp_path=%TEMP%"
if exist "%user_temp_path%\" (
    echo ���������û���ʱ�ļ���"%user_temp_path%\"
    :: ����ɾ��Ŀ¼�������ļ�����Ŀ¼�����Դ��������ļ�ռ���ǳ�̬��
    del /f /s /q "%user_temp_path%\*" >nul 2>&1
    for /d %%d in ("%user_temp_path%\*") do (
        rmdir /s /q "%%d" >nul 2>&1
    )
    
    :: �ٴγ���ɾ�������ļ����������Ƿ�����ж��Ƿ�����
    pushd "%user_temp_path%" 2>nul
    if %errorlevel% equ 0 (
        for %%f in (*) do (
            if exist "%%f" (
                echo   ����ռ�û��޷�ɾ�����ļ���%%f
            )
        )
        for /d %%d in (*) do (
            if exist "%%d" (
                echo   ����ռ�û��޷�ɾ����Ŀ¼��%%d
            )
        )
        popd
        echo �û���ʱ�ļ���������ɡ�
    ) else (
        echo   �޷����ʻ������û���ʱĿ¼��"*%user_temp_path%"������Ȩ�ޡ�
    )
) else (
    echo **%user_temp_path%** ·�������ڣ�������
)
echo.

:: --- ����ϵͳ��ʱ�ļ� (C:\Windows\Temp) ---
echo.
echo ## ����ϵͳ��ʱ�ļ� (C:\Windows\Temp) ##
echo.
set "system_temp_path=%SystemRoot%\Temp"
if exist "%system_temp_path%\" (
    echo ��������ϵͳ��ʱ�ļ���"%system_temp_path%\"
    echo **ע�⣺�˲�����Ҫ����ԱȨ�ޣ������ļ�������ϵͳռ�ö��޷�ɾ����**
    :: ���Խ���Ŀ¼��ɾ������
    pushd "%system_temp_path%" 2>nul
    if %errorlevel% equ 0 (
        :: �����ļ����ԣ��Ա�ɾ��ֻ���������ļ�
        attrib -h -r -s "%system_temp_path%\*" /s /d >nul 2>&1
        
        :: ����ɾ��Ŀ¼�е������ļ�����Ŀ¼
        del /f /s /q "%system_temp_path%\*" >nul 2>&1
        for /d %%d in ("%system_temp_path%\*") do (
            rmdir /s /q "%%d" >nul 2>&1
        )

        :: �ٴα���������δ��ɾ�����ļ�/Ŀ¼
        for %%f in (*) do (
            if exist "%%f" (
                echo   ����ռ�û��޷�ɾ�����ļ���%%f
            )
        )
        for /d %%d in (*) do (
            if exist "%%d" (
                echo   ����ռ�û��޷�ɾ����Ŀ¼��%%d
            )
        )
        popd
        echo ϵͳ��ʱ�ļ���������ɡ�
    ) else (
        echo   �޷�����ϵͳ��ʱĿ¼��"%system_temp_path%"����ȷ�����������ԱȨ�ޡ�
    )
) else (
    echo **%system_temp_path%** ·�������ڣ�������
)
echo.

:: --- ��ջ���վ ---
echo.
echo ## ��ջ���վ ##
echo.
set /p "confirm_recycle=�Ƿ���������û��Ļ���վ���ݣ�(Y/N): "
if /i "%confirm_recycle%"=="Y" (
    echo ������ջ���վ...
    :: ʹ�� PowerShell ������л���վ�������ȫ���ɿ��ҷǽ���ʽ�ķ�����
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
    if %errorlevel% equ 0 (
        echo ����վ�����ɡ�
    ) else (
        echo ��ջ���վʧ�ܻ��������⣬��ȷ�����������ԱȨ�ޡ�
    )
) else (
    echo ������ջ���վ��
)
echo.

:: --- ������������� (����ʾ����·������ǿ��ɾ��) ---
echo.
echo ## ������������� (����ʾ����·������ǿ��ɾ��) ##
echo.
echo �����������������������·����������ͨ����������ý��������������պ��ֶ�ɾ����
echo   - Google Chrome: "%%LocalAppData%%\Google\Chrome\User Data\Default\Cache"
echo   - Microsoft Edge: "%%LocalAppData%%\Microsoft\Edge\User Data\Default\Cache"
echo   - Mozilla Firefox: "%%AppData%%\Mozilla\Firefox\Profiles\*.default-release\cache2" (�����ļ�������ͬ)
echo.
echo ����ֱ��ɾ�����ܵ���������������⣬���ű����Զ�����
echo.

:: --- �������������װ�����ļ� (*.tmp, *.bak, *.old) ---
echo.
echo ## �������������װ�����ļ� (*.tmp, *.bak, *.old) ##
echo.
echo ����������ɾ�����������ļ���
echo   - *.tmp
echo   - *.bak
echo   - *.old
echo.

:: ������ɾ�����������ļ��������ض��û���غ�ϵͳ��ʱĿ¼�н��С�
set "search_paths=%TEMP% %SystemRoot%\Temp %UserProfile%\Downloads %UserProfile%\AppData\Local\Temp"

for %%p in (%search_paths%) do (
    if exist "%%p\" (
        echo ���� "%%p\" Ŀ¼������...
        pushd "%%p" 2>nul
        if %errorlevel% equ 0 (
            :: ɾ���ļ����������Ƿ�����ж��Ƿ�����
            for %%f in (*.tmp *.bak *.old) do (
                del /f /q "%%f" >nul 2>&1
                if exist "%%f" (
                    echo   ����ռ�û��޷�ɾ�����ļ���%%f
                )
            )
            popd
        ) else (
            echo   �޷�����Ŀ¼ "%%p"��������
        )
    )
)
echo.

:: --- ������־�ļ� (*.log) ---
echo.
echo ## ������־�ļ� (*.log) ##
echo.
echo ���棺ɾ����־�ļ����ܵ���ĳЩӦ�ó����ϵͳ������Ų�����ʱʧȥ��Ҫ����ʷ���ݡ�
echo ���ű�������ɾ�������Ŀ�������־�ļ�������������ʹ�õ��ļ���
echo.

:: ��չ��־�ļ�����·��
set "log_search_paths=%TEMP% %SystemRoot%\Temp %UserProfile%\Downloads %UserProfile%\AppData\Local\Temp %SystemRoot%\Logs %ProgramData%"

for %%p in (%log_search_paths%) do (
    if exist "%%p\" (
        echo ���� "%%p\" Ŀ¼��������ɾ�� *.log �ļ�...
        pushd "%%p" 2>nul
        if %errorlevel% equ 0 (
            for %%f in (*.log) do (
                del /f /q "%%f" >nul 2>&1
                if exist "%%f" (
                    echo   ����ռ�û��޷�ɾ������־�ļ���%%f
                )
            )
            popd
        ) else (
            echo   �޷�����Ŀ¼ "%%p"��������
        )
    )
)
echo.

:: --- ����Ԥȡ�ļ� (C:\Windows\Prefetch) ---
echo.
echo ## ����Ԥȡ�ļ� (C:\Windows\Prefetch) ##
echo.
set "prefetch_path=%SystemRoot%\Prefetch"
if exist "%prefetch_path%\" (
    echo ����ɾ��Ԥȡ�ļ���"%prefetch_path%\"
    :: ���� Prefetch Ŀ¼����ֻɾ�������ݣ���Ҫ�� .pf �ļ��� .tmp �ļ�
    pushd "%prefetch_path%" 2>nul
    if %errorlevel% equ 0 (
        del /f /q "*.pf" >nul 2>&1
        del /f /q "*.tmp" >nul 2>&1
        :: ����δ��ɾ�����ļ�
        for %%f in ("*.pf" "*.tmp") do (
            if exist "%%f" (
                echo   ����ռ�û��޷�ɾ�����ļ���%%f
            )
        )
        popd
        echo Ԥȡ�ļ�������ɡ�
    ) else (
        echo   �޷�����ԤȡĿ¼��"%prefetch_path%"����ȷ���Թ���Ա������нű���
    )
) else (
    echo %prefetch_path% ·�������ڣ�������
)
echo.

:: --- ��������ͼ���� (thumbcache_*.db) ---
echo.
echo ## ��������ͼ���� (thumbcache_*.db) ##
echo.
set "thumbcache_path=%LocalAppData%\Microsoft\Windows\Explorer"
if exist "%thumbcache_path%\" (
    echo ����ɾ������ͼ�����ļ���"%thumbcache_path%\thumbcache_*.db"
    pushd "%thumbcache_path%" 2>nul
    if %errorlevel% equ 0 (
        del /f /q "thumbcache_*.db" >nul 2>&1
        :: ����δ��ɾ�����ļ�
        for %%f in ("thumbcache_*.db") do (
            if exist "%%f" (
                echo   ����ռ�û��޷�ɾ�����ļ���%%f
            )
        )
        popd
        echo ����ͼ����������ɡ�
    ) else (
        echo   �޷���������ͼ����Ŀ¼��"%thumbcache_path%"��������
    )
) else (
    echo %thumbcache_path% ·�������ڣ�������
)
echo.

:: --- �����������������ļ� ---
echo.
echo ## �����������������ļ� ##
echo.

:: ���� Windows ������ʱ�ļ���SoftwareDistribution\Download��
set "update_download_path=%SystemRoot%\SoftwareDistribution\Download"
if exist "%update_download_path%\" (
    echo ����ɾ�� Windows ������ʱ�ļ���"%update_download_path%\"
    :: ֹͣBITS��Windows Update������ȷ���ļ���������
    echo   ����ֹͣ BITS �� Windows Update ����...
    net stop bits >nul 2>&1
    net stop wuauserv >nul 2>&1
    
    :: Ϊ�˰�ȫ�ͳ��ף�����ɾ��Ŀ¼����
    :: �ݹ�ɾ�������ļ�����Ŀ¼�����Դ���
    del /f /s /q "%update_download_path%\*" >nul 2>&1
    for /d %%d in ("%update_download_path%\*") do (
        rmdir /s /q "%%d" >nul 2>&1
    )

    :: ������
    if exist "%update_download_path%\*" (
        echo Windows ������ʱ�ļ�������ܲ���ȫ�������ļ���ռ�á�
    ) else (
        echo Windows ������ʱ�ļ�������ɡ�
    )
) else (
    echo %update_download_path% ·�������ڣ�������
)
echo.

:: ����ϵͳ���󱨸����
set "wer_path=%LocalAppData%\Microsoft\Windows\WER\ReportQueue"
if exist "%wer_path%\" (
    echo ����ɾ��ϵͳ���󱨸���У�"%wer_path%\"
    :: �ݹ�ɾ���������ݣ����Դ���
    del /f /s /q "%wer_path%\*" >nul 2>&1
    for /d %%d in ("%wer_path%\*") do (
        rmdir /s /q "%%d" >nul 2>&1
    )
    
    :: ������
    if exist "%wer_path%\*" (
        echo ϵͳ���󱨸����������ܲ���ȫ�������ļ���ռ�á�
    ) else (
        echo ϵͳ���󱨸����������ɡ�
    )
) else (
    echo %wer_path% ·�������ڣ�������
)
echo.

echo.
echo =========================================================================
echo                 ϵͳ����������ɣ�
echo =========================================================================

echo.
echo ��лʹ�� Windows ϵͳ���������ߣ�
echo.
pause