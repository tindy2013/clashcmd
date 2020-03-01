@echo off
setlocal enabledelayedexpansion

:init
cd "%~dp0.."
set PATH="%~dp0";"%~dp0..\";%PATH%
set gen_ini_path=App\subconverter\generate.ini
set pref_ini_path=pref.ini
title Clash Startup Agent

:main
rem get settings
call inireader.bat :inireader_init "pref"
call inireader.bat :inireader_parse "!pref_ini_path!"
call inireader.bat :inireader_get "common" "controller_url" "controller_url"
call inireader.bat :inireader_get "common" "current_applied" "current_applied"
call inireader.bat :inireader_get "common" "enable_proxy_on_startup" "enable_proxy_on_startup"
rem then start up
call clash_controller.bat :start-clash
if not "!current_applied!" == "" (
  rem restore last applied
  call inireader.bat :inireader_init "sub"
  call inireader.bat :inireader_parse "!gen_ini_path!"
  call inireader.bat :inireader_get "!current_applied!" "path" "filepath"
  call clash_controller.bat :setprofile "%~dp0subconverter\!filepath!"
  rem restore selections
  if exist "Profile\selection\!current_applied!.dat" (
    call clash_controller.bat :restoreselected "!current_applied!"
  )
)
rem set system proxy
if "!enable_proxy_on_startup!" == "true" (
  call clash_controller.bat :enable-sysproxy
)
goto :eof
