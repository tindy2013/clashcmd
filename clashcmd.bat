@echo off
chcp 936>nul
setlocal enabledelayedexpansion

:init
set version=V1.1.1
set gen_ini_path=App\subconverter\generate.ini
set pref_ini_path=pref.ini
set PATH="%~dp0";"%~dp0App";%PATH%
cd /d %~dp0
call :readpref
if "!locale!" == "" set locale=zh-cn
call Locale\!locale!.bat :localeinit
call Locale\!locale!.bat :initoptions
call misc.bat :substitute "loc_title" "title" "version" "version"
mode con cols=80 lines=40
color f1
mkdir Profile\selection>nul 2>&1
title !title!


:main
call :readsub
call :mainmenu
goto :eof

:readsub
call inireader.bat :inireader_init "sub"
call inireader.bat :inireader_parse "!gen_ini_path!"
goto :eof

:readpref
call inireader.bat :inireader_init "pref"
call inireader.bat :inireader_parse "!pref_ini_path!"
call :getprefopts
goto :eof

:getprefopts
set apply_on_startup=
set apply_on_select=
set apply_on_update=
set update_on_select=
call inireader.bat :inireader_setinstance "pref"
call inireader.bat :inireader_get "common" "locale" "locale"
call inireader.bat :inireader_get "common" "controller_url" "controller_url"
call inireader.bat :inireader_get "common" "current_profile" "current_profile"
call inireader.bat :inireader_get "common" "current_applied" "current_applied"
call inireader.bat :inireader_get "common" "apply_on_startup" "apply_on_startup"
call inireader.bat :inireader_get "common" "apply_on_select" "apply_on_select"
call inireader.bat :inireader_get "common" "apply_on_update" "apply_on_update"
call inireader.bat :inireader_get "common" "update_on_select" "update_on_select"
call inireader.bat :inireader_get "common" "update_on_add" "update_on_add"
call inireader.bat :inireader_get "common" "apply_on_add" "apply_on_add"
call inireader.bat :inireader_get "common" "enable_proxy_on_startup" "enable_proxy_on_startup"
call inireader.bat :inireader_get "common" "disable_proxy_on_stop" "disable_proxy_on_stop"
goto :eof

:mainmenu
cls
call misc.bat :makemenu "!title!" "main_options" "CPDSAMX" "!loc_menu_select!"
if "!selection!" == "C" (
  call :coreopt
  goto mainmenu
)
if "!selection!" == "P" (
  call :subopt
  goto mainmenu
)
if "!selection!" == "D" (
  echo.
  echo !loc_open_dashboard!
  call clash_controller.bat :dashboard
  call misc.bat :sleep 1000
  goto mainmenu
)
if "!selection!" == "S" (
  call :setting
  goto mainmenu
)
if "!selection!" == "A" (
  call :advanced
  goto mainmenu
)
if "!selection!" == "M" (
  call :monitor
  goto mainmenu
)
echo.
echo !loc_shutdown!
call misc.bat :sleep 1500
goto :eof

:coreopt
echo !loc_core_getting_status!
call clash_controller.bat :getcurrentconfig
if "!clash_running!" == "1" (
  set clash_running_str=!loc_core_running!
) else (
  set clash_running_str=!loc_core_stopped!
)
cls
call misc.bat :substitute "loc_core_title" "message" "status" "clash_running_str"
call misc.bat :makemenu "!message!" "core_options" "REMAX" "!loc_menu_select!" "!loc_menu_choice!"
if "!selection!" == "R" (
  echo.
  if "!clash_running!" == "1" (
    echo !loc_core_already_running!
    call misc.bat :sleep 1000
    goto coreopt
  )
  echo !loc_core_starting!
  call clash_controller.bat :start-clash
  echo !loc_core_started!
  call :coreclearapplied
  call misc.bat :sleep 2000
  if "!apply_on_startup!" == "true" (
    if not "!current_profile!" == "" (
      call :applysub
    )
  )
  if "!enable_proxy_on_startup!" == "true" (
    call :enable-sysproxy
    call misc.bat :sleep 1000
  )
  goto coreopt
)
if "!selection!" == "E" (
  if "!clash_running!" == "0" (
    echo !loc_core_already_stopped!
    call misc.bat :sleep 1000
    goto coreopt
  )
  if "!disable_proxy_on_stop!" == "true" (
    call :disable-sysproxy
    call misc.bat :sleep 500
  )
  call :coregetselection
  echo.
  echo !loc_core_terminating!
  call clash_controller.bat :stop-clash
  echo !loc_core_terminated!
  call :coreclearapplied
  call misc.bat :sleep 2000
  goto coreopt
)
if "!selection!" == "M" (
  if "!clash_running!" == "0" (
    echo !loc_core_stop_before_start!
    call misc.bat :sleep 1000
  ) else (
    call :coremode
  )
  goto coreopt
)
if "!selection!" == "A" (
  if "!clash_running!" == "0" (
    echo !loc_core_stop_before_start!
    call misc.bat :sleep 1000
  ) else (
    call :coreallowlan
  )
  goto coreopt
)
if "!selection!" == "X" (
  goto :eof
)
goto coreopt

:coreclearapplied
set current_applied=
call inireader.bat :inireader_setinstance "pref"
call inireader.bat :inireader_set "common" "current_applied" ""
call inireader.bat :inireader_write "!pref_ini_path!"
goto :eof

:coregetselection
if not "!current_applied!" == "" (
  call misc.bat :substitute_print "loc_core_saving_selection" "profile" "current_applied"
  call clash_controller.bat :saveselected "!current_applied!"
)
goto :eof

:coremode
echo.
set current_mode_str=
if "!current_mode!" == "" (
  echo !loc_core_fetch_status_failed!
  goto :eof
)
if "!current_mode!" == "Global" (
  set current_mode_str=!loc_core_mode_global!
)
if "!current_mode!" == "Rule" (
  set current_mode_str=!loc_core_mode_rule!
)
if "!current_mode!" == "Direct" (
  set current_mode_str=!loc_core_mode_direct!
)
if "!current_mode_str!" == "" (
  echo !loc_core_fetch_status_failed!
  goto :eof
)
cls
echo.
call misc.bat :substitute "loc_core_mode_current" "message" "mode" "current_mode_str"
call misc.bat :makemenu "!message!" "mode_options" "GRDX" "!loc_core_mode_select!"
echo.
if "!selection!" == "G" (
  call clash_controller.bat :setmode "Global"
  call misc.bat :substitute_print "loc_core_mode_set" "mode" "loc_core_mode_global"
  call misc.bat :sleep 2000
  goto :eof
)
if "!selection!" == "R" (
  call clash_controller.bat :setmode "Rule"
  call misc.bat :substitute_print "loc_core_mode_set" "mode" "loc_core_mode_rule"
  call misc.bat :sleep 2000
  goto :eof
)
if "!selection!" == "G" (
  call clash_controller.bat :setmode "Direct"
  call misc.bat :substitute_print "loc_core_mode_set" "mode" "loc_core_mode_direct"
  call misc.bat :sleep 2000
  goto :eof
)
goto :eof

:coreallowlan
echo.
set current_allow_lan_str=
if "!current_allow_lan!" == "" (
  echo !loc_core_fetch_status_failed!
  goto :eof
)
if "!current_allow_lan!" == "true" (
  set current_allow_lan_str=!loc_core_allowlan_true!
)
if "!current_allow_lan!" == "false" (
  set current_allow_lan_str=!loc_core_allowlan_false!
)
if "!current_allow_lan_str!" == "" (
  echo !loc_core_fetch_status_failed!
  goto :eof
)
cls
echo.
call misc.bat :substitute "loc_core_allowlan_current" "message" "allow" "current_allow_lan_str"
call misc.bat :makemenu "!message!" "allow_options" "EDX" "!loc_core_allowlan_select!"
echo.
if "!selection!" == "E" (
  call clash_controller.bat :setallowlan "true"
  call misc.bat :substitute_print "loc_core_allowlan_set" "allow" "loc_core_allowlan_true"
  call misc.bat :sleep 2000
  goto :eof
)
if "!selection!" == "D" (
  call clash_controller.bat :setallowlan "false"
  call misc.bat :substitute_print "loc_core_allowlan_set" "allow" "loc_core_allowlan_true"
  call misc.bat :sleep 2000
  goto :eof
)
goto :eof

:subopt
if "!current_profile!" == "" (
  set current_profile_str=!loc_profile_not_selected!
) else (
  set current_profile_str=!current_profile!
)
cls
call misc.bat :substitute "loc_profile" "message" "profile" "current_profile_str"
call misc.bat :makemenu "!message!" "sub_options" "ASLUDX" "!loc_menu_select!" "!loc_profile_opt!"
if "!selection!" == "A" (
  call :addsub
  goto subopt
)
if "!selection!" == "S" (
  call :listsub_entry
  goto subopt
)
if "!selection!" == "L" (
  call :applysub
  goto subopt
)
if "!selection!" == "U" (
  call :doupdate
  goto subopt
)
if "!selection!" == "D" (
  call :delsub
  goto subopt
)
if "!selection!" == "X" (
  goto :eof
)
goto subopt

:addsub
cls
echo.
echo   - !loc_profile_add!
echo.
set /p sub_url=!loc_profile_add_suburl!
if "!sub_url!" == "" (
  echo !loc_profile_add_suburl_empty!
  call misc.bat :sleep 1000
  goto :eof
)
echo.
:subname
set /p sub_name=!loc_profile_add_subname!
if "!sub_name!" == "" (
  echo !loc_profile_add_subname_empty!
  call misc.bat :sleep 1000
  goto :eof
)
call inireader.bat :inireader_findsection "!sub_name!"
if !retVal! equ 1 (
  echo !loc_profile_add_subname_dup!
  call misc.bat :sleep 1000
  goto subname
)
call misc.bat :instr "!sub_name!" " "
if !errorlevel! equ 0 (
  echo !loc_profile_add_subname_space!
  call misc.bat :sleep 1000
  goto subname
)
call inireader.bat :inireader_setinstance "sub"
call inireader.bat :inireader_set "!sub_name!" "path" "!sub_name!.yml"
call inireader.bat :inireader_set_alt "!sub_name!" "url" "sub_url"
call misc.bat :substitute "loc_profile_add_convert" "message" "sub" "sub_name"
call misc.bat :makechoice "!message!" "0" "0" "YN"
if !errorlevel! equ 2 (
  call inireader.bat :inireader_set "!sub_name!" "direct" "true"
) else (
  call inireader.bat :inireader_set "!sub_name!" "target" "clashr"
)
call inireader.bat :inireader_write "!gen_ini_path!"
call inireader.bat :inireader_setinstance "pref"
call inireader.bat :inireader_set "common" "current_profile" "!sub_name!"
call inireader.bat :inireader_write "!pref_ini_path!"
call misc.bat :substitute_print "loc_profile_add_success" "sub" "sub_name"
set current_profile=!sub_name!
call misc.bat :sleep 1000
if "!update_on_add!" == "true" (
  if "!apply_on_add!" == "true" ( call :doupdate "noapply" ) else ( call :doupdate )
)
if "!apply_on_add!" == "true" (
    call :applysub
)
goto :eof

:delsub
echo.
if "!current_profile!" == "" (
  echo !loc_profile_select_first!
  call misc.bat :sleep 1000
  goto :eof
)
cls
echo.
echo   - !loc_profile_del!
echo.
call misc.bat :substitute_print "loc_profile_del_sure" "profile" "current_profile"
call misc.bat :makechoice "!loc_choice_YN!" "0" "0" "YN"
if !errorlevel! equ 1 (
  call misc.bat :substitute_print "loc_profile_del_msg" "profile" "current_profile"
  call inireader.bat :inireader_setinstance "sub"
  call inireader.bat :inireader_get "!current_profile!" "path" "filepath"
  del /f /q "%~dp0App\subconverter\!filepath!">nul 2>nul
  del /f /q "%~dp0Profile\selection\!current_profile!.dat">nul 2>nul
  call inireader.bat :inireader_removesection "!current_profile!"
  call inireader.bat :inireader_write "!gen_ini_path!"
  call inireader.bat :inireader_eraseinstance
  call :readsub
  call inireader.bat :inireader_setinstance "pref"
  call inireader.bat :inireader_set "common" "current_profile" ""
  call inireader.bat :inireader_write "!pref_ini_path!"
  set current_profile=
  echo !loc_done_anykey!
  pause>nul
  goto :eof
) else (
  echo !loc_menu_cancel!
  call misc.bat :sleep 500
  goto :eof
)
goto :eof

:listsub_entry
set startindex=0
:listsub
set prev_index=
set next_index=
set back_index=
cls
set /a page=!startindex!/9+1
echo.
call misc.bat :substitute "loc_profile_select" "message" "page" "page"
echo   - !message!
echo.
echo   !loc_profile_select_press_key!
echo.
call inireader.bat :inireader_setinstance "sub"
call inireader.bat :inireader_printsections "!startindex!" "9"
set /a endindex=!startindex!+9
set alloptions=
if not "!startindex!" == "0" (
  set alloptions=!alloptions!P
  set /a prev_index=!retVal!+1
  echo   P: !loc_profile_select_prev!
  echo.
)
if "!retVal!" == "!endindex!" (
  set alloptions=!alloptions!N
  if defined prev_index (
    set /a next_index=!prev_index!+1
  ) else (
    set /a next_index=!retVal!+1
  )
  echo   N: !loc_profile_select_next!
  echo.
)
if defined next_index (
  set /a back_index=!next_index!+1
) else (
  if defined prev_index (
    set /a back_index=!prev_index!+1
  ) else (
    set /a back_index=!retVal!+1
  )
  echo   X: !loc_profile_select_back!
  echo.
)
set alloptions=!alloptions!X
set choiceendindex=!retVal!
call misc.bat :makechoice "!loc_profile_select_choice!" "1" "!choiceendindex!" "!alloptions!"
if !errorlevel! leq !choiceendindex! (
  set /a realindex=!startindex!+!errorlevel!-1
  call inireader.bat :inireader_setinstance "sub"
  call inireader.bat :inireader_get_section_by_index "!realindex!" "current_profile"
  call inireader.bat :inireader_setinstance "pref"
  call inireader.bat :inireader_set "common" "current_profile" "!current_profile!"
  call inireader.bat :inireader_write "!pref_ini_path!"
  call inireader.bat :inireader_setinstance "sub"
  call misc.bat :substitute_print "loc_profile_select_set" "profile" "current_profile"
  call misc.bat :sleep 1000
  if "!update_on_select!" == "true" (
    if "!apply_on_select!" == "true" ( call :doupdate "noapply" ) else ( call :doupdate )
  )
  if "!apply_on_select!" == "true" (
    call :applysub
  )
) else (
  if "!errorlevel!" == "!next_index!" (
    set /a startindex=!startindex!+9
    goto listsub
  )
  if "!errorlevel!" == "!prev_index!" (
    set /a startindex=!startindex!-9
    goto listsub
  )
)
goto :eof

:doupdate
echo.
set last_update_success=0
if "!current_profile!" == "" (
  echo !loc_profile_select_first!
  call misc.bat :sleep 500
  goto :eof
)
cls
echo.
echo   - !loc_profile_update!
echo.
call inireader.bat :inireader_get "!current_profile!" "direct"
if "!retVal!" == "true" (
  call misc.bat :substitute_print "loc_profile_update_direct" "profile" "current_profile"
) else (
  call misc.bat :substitute_print "loc_profile_update_subcon" "profile" "current_profile"
)
cd App\subconverter
subconverter -g --artifact "!current_profile!"
cd ../..
title !title!
if !errorlevel! neq 0 (
  echo !loc_profile_update_failed!
  pause>nul
) else (
  echo !loc_profile_update_success!
  set last_update_success=1
  call misc.bat :sleep 2000
  if "!apply_on_update!" == "true" (
    if not "%~1" == "noapply" (
      if not "!current_profile!" == "" (
        call :applysub
        goto doupdate_end
      )
    )
  )
)
goto :eof

:applysub
echo.
if "!current_profile!" == "" (
  echo !loc_profile_select_first!
  call misc.bat :sleep 500
  goto :eof
)
cls
echo.
echo   - !loc_profile_apply!
echo.
call misc.bat :substitute "loc_profile_apply_sure" "message" "profile" "current_profile"
call misc.bat :makechoice "!message!" "0" "0" "YN"
if !errorlevel! equ 1 (
  echo.
  echo !loc_profile_apply_pre!
  call :coregetselection
  call inireader.bat :inireader_setinstance "sub"
  call inireader.bat :inireader_get "!current_profile!" "path" "filepath"
  echo !loc_profile_apply_on!
  call clash_controller.bat :setprofile "%~dp0App\subconverter\!filepath!"
  if not "!setprofile_success!" == "1" (
    echo !loc_profile_apply_failed!
    pause>nul
    goto :eof
  )
  if not "!current_applied!" == "!current_profile!" (
    set current_applied=!current_profile!
    call inireader.bat :inireader_setinstance "pref"
    call inireader.bat :inireader_set "common" "current_applied" "!current_profile!"
    call inireader.bat :inireader_write "!pref_ini_path!"
  )
  if exist "Profile\selection\!current_profile!.dat" (
    call misc.bat :substitute_print "loc_profile_apply_restore" "profile" "current_profile"
    call clash_controller.bat :restoreselected "!current_profile!"
  )
  echo !loc_profile_apply_done!
  call misc.bat :sleep 2000
  goto :eof
)
echo !loc_profile_apply_cancel!
call misc.bat :sleep 500
goto :eof

:monitor
cls
call misc.bat :makemenu "!loc_monitor!" "mon_options" "LTX" "!loc_menu_select!"
if "!selection!" == "L" (
  call :logs
  goto monitor
)
if "!selection!" == "T" (
  call :traffic
  goto monitor
)
if "!selection!" == "X" (
  goto :eof
)
goto monitor

:logs
start cmd /k "@echo off &title !loc_monitor_logs! &mode con cols=120 lines=28 & color f1 & CHCP 65001>nul & curl http://127.0.0.1:9090/logs"
goto :eof

:traffic
start cmd /k "@echo off &title !loc_monitor_traffic! &mode con cols=120 lines=28 & color f1 & CHCP 65001>nul & curl http://127.0.0.1:9090/traffic"
goto :eof

:setting
call :getprefopts
cls
call misc.bat :makemenu "- !loc_pref!" "setting_options" "12345678X" "!loc_pref_select!"
echo.
if "!selection!" == "1" call :makegenswitch "!loc_pref_apply_on_startup!" "apply_on_startup"
if "!selection!" == "2" call :makegenswitch "!loc_pref_enable_proxy_on_startup!" "enable_proxy_on_startup"
if "!selection!" == "3" call :makegenswitch "!loc_pref_disable_proxy_on_stop!" "disable_proxy_on_stop"
if "!selection!" == "4" call :makegenswitch "!loc_pref_update_on_add!" "update_on_add"
if "!selection!" == "5" call :makegenswitch "!loc_pref_apply_on_add!" "apply_on_add"
if "!selection!" == "6" call :makegenswitch "!loc_pref_update_on_select!" "update_on_select"
if "!selection!" == "7" call :makegenswitch "!loc_pref_apply_on_select!" "apply_on_select"
if "!selection!" == "8" call :makegenswitch "!loc_pref_apply_on_update!" "apply_on_update"
if "!selection!" == "X" goto :eof
goto setting

rem makegenswitch: %1: title %2: var to switch
:makegenswitch
set optionname=%~1
call misc.bat :substitute "loc_pref_switch" "message" "option" "optionname"
call misc.bat :makeswitch "!message!" "%~2" "!loc_pref_switch_enable!" "!loc_pref_switch_disable!" "!loc_pref_switch_back!" "!loc_menu_select!" "!loc_pref_switch_selected!"
call inireader.bat :inireader_setinstance "pref"
call inireader.bat :inireader_set "common" "%~2" "!%~2!"
call inireader.bat :inireader_write "!pref_ini_path!"
call misc.bat :sleep 2000
set selection=
goto :eof

:advanced
cls
call misc.bat :makemenu "- !loc_advanced!" "adv_options" "EDGSX" "!loc_advanced_select!"
echo.
if "!selection!" == "E" (
  call :enable-sysproxy
  call misc.bat :sleep 2000
  goto advanced
)
if "!selection!" == "D" (
  call :disable-sysproxy
  call misc.bat :sleep 2000
  goto advanced
)
if "!selection!" == "G" (
  call :geoipupdate
  goto advanced
)
if "!selection!" == "S" (
  call startup.bat
  goto advanced
)
if "!selection!" == "X" (
  goto :eof
)
goto advanced

:enable-sysproxy
echo.
echo !loc_advanced_enable_sysproxy_on!
call clash_controller.bat :enable-sysproxy
echo !loc_advanced_enable_sysproxy_done!
goto :eof

:disable-sysproxy
echo.
echo !loc_advanced_disable_sysproxy_on!
call clash_controller.bat :disable-sysproxy
echo !loc_advanced_disable_sysproxy_done!
goto :eof

:geoipupdate
cls
cd "%~dp0Profile\" 
echo.
echo !loc_advanced_geoip_updating!
echo.
echo -------------------------------------
echo.
curl -kLo GeoLite2-Country.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=oeEqpP5QI21N&suffix=tar.gz"
7za.exe e GeoLite2-Country.tar.gz
7za e GeoLite2-Country.tar "GeoLite2-Country*\GeoLite2-Country.mmdb" -aoa
del "Country.mmdb" /f /q
del "GeoLite2-Country.tar*" /f /q
ren GeoLite2-Country.mmdb Country.mmdb
echo.
echo -------------------------------------
echo.
echo !loc_advanced_geoip_done!
call misc.bat :sleep 2000
goto :eof
