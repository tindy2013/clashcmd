@echo off
chcp 936>nul
>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%*", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>NUL
    Exit /b
)

:init
title 添加 Clash 开机启动
cd /d "%~dp0"
setlocal enabledelayedexpansion

:startup_menu
call misc.bat :arrinit "startup_options"
call misc.bat :arrappend "startup_options" "添加开机启动"
call misc.bat :arrappend "startup_options" "删除开机启动"
call misc.bat :arrappend "startup_options" "关闭"
call misc.bat :makemenu "- 开机启动" "startup_options" "EDX" "请选择："
if "!selection!" == "E" (
  call :add-startup
  goto startup_menu
)
if "!selection!" == "D" (
  call :del-startup
  goto startup_menu
)
goto :eof

:add-startup
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "clash-web" /t REG_SZ /d "\"%~DP0start-clash.vbs\"" /f
echo 添加成功！
call misc.bat :sleep 2000
goto :eof

:del-startup
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "clash-web"  /f>NUL 2>NUL
echo 删除成功！
call misc.bat :sleep 2000
goto :eof
