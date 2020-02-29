@echo off
rem must call "setlocal enabledelayedexpansion" in main function

:main
rem this is a utility function file, don't run directly
if "%~1" == "" goto :eof
call :chkdelayexp
if !delayed! equ 0 goto :eof
call %1 %2 %3 %4 %5 %6 %7 %8 %9
goto :eof

:chkdelayexp
set exc=!
if "!!" == "!exc!!exc!" (
  set delayed=1
) else (
  set delayed=0
)
goto :eof

rem /////Clash core controllers/////

rem constructjson: %1: key %2: value %3: var to save
:constructjson
set outval=%~3
set !outval!={"%~1": "%~2"}
set !outval!=!%outval%:\=\\!
set !outval!=!%outval%:"=\"!
set !outval!="!%outval%!"
goto :eof

:constructjson_noqoute
set outval=%~3
set !outval!={"%~1": %~2}
set !outval!=!%outval%:\=\\!
set !outval!=!%outval%:"=\"!
set !outval!="!%outval%!"
goto :eof

rem getfromjson: %1: jsondata var %2: key %3: var to save
:getfromjson
call misc.bat :getcmdret "cmdutils --jsonget %~1 %~2" "%~3"
goto :eof

rem getlistfromjson: %1: jsondata var %2: path %3: var to save
:__deprecated_getlistfromjson
call misc.bat :getcmdret "cmdutils --jsongetlist %~1 %~2" "%~2"
goto :eof

rem getfromjson: %1: jsondata var %2: key %3: var to save
:__deprecated_getfromjson
set left_br={
set right_br=}
call misc.bat :trim_of "data" "left_br"
call misc.bat :trim_of "data" "right_br"
set outvar=%~3
call :splitter_init "data" ","
:getfromjson_loop
call :splitter_next "retVal"
if "!retVal!" == "" goto :eof
call misc.bat :split2 "retVal" ":"
call misc.bat :trim_quote "first"
if "!first!" == "%~2" (
  call misc.bat :trim_quote "second"
  set !outvar!=!second!
  goto :eof
)
if "!first!" == "" goto :eof
goto getfromjson_loop

rem getfromjson: %1: jsondata var %2: key1 %3: var1 to save %4: key2 %5: var2 to save %6: key3 %7: var3 to save %8: key4 %9: var4 to save
:getfromjson4
set left_br={
set right_br=}
call misc.bat :trim_of "%~1" "left_br"
call misc.bat :trim_of "%~1" "right_br"
call misc.bat :splitter_init "%~1" ","
:getfromjson4_loop
call misc.bat :splitter_next "retVal"
if "!retVal!" == "" goto :eof
call misc.bat :split2 "retVal" ":"
call misc.bat :trim_quote "first"
if "!first!" == "" goto :eof
if "!first!" == "%~2" (
  call misc.bat :trim_quote "second"
  set outvar=%~3
  set !outvar!=!second!
)
if "!first!" == "%~4" (
  call misc.bat :trim_quote "second"
  set outvar=%~5
  set !outvar!=!second!
)
if "!first!" == "%~6" (
  call misc.bat :trim_quote "second"
  set outvar=%~7
  set !outvar!=!second!
)
if "!first!" == "%~8" (
  call misc.bat :trim_quote "second"
  set outvar=%~9
  set !outvar!=!second!
)
goto getfromjson4_loop

rem getcurrentmode: save to current_mode
:getcurrentconfig
set clash_running=0
set data=
call misc.bat :getcmdret "curl -s -m 1 !controller_url!/configs" "data"
if not "!data!" == "" (
  set clash_running=1
  rem call :getfromjson4 "data" "mode" "current_mode" "allow-lan" "current_allow_lan" "port" "current_port" "_" "_"
  call :getfromjson "data" "mode" "current_mode"
  call :getfromjson "data" "allow-lan" "current_allow_lan"
  call :getfromjson "data" "port" "current_port"
) else (
  set current_mode=
  set current_allow_lan=
  set current_port=
)
goto :eof

:__deprecated_getallgroup
set url=!controller_url!/proxies
call :getlistfromjson "!url!" "proxies" "proxies"
call misc.bat :splitter_init "proxies" ","
set groups=
:__deprecated_getallgroup_loop
call misc.bat :splitter_next "proxy_name"
if "!proxy_name!" == "" goto :eof
call :getfromjson "!url!" "proxies/!proxy_name!/type" "proxy_type"
if "!proxy_type!" == "Selector" (
  set groups=!groups!,!proxy_name!
)
goto __deprecated_getallgroup_loop
:__deprecated_getallgroup_end
call misc.bat :getvarpart "groups" "groups" "1" "0"
goto :eof

rem setmode: %1: mode
:setmode
call :constructjson "mode" "%~1" "data"
curl -X PATCH -d !data! !controller_url!/configs
goto :eof

rem setallowlan: %1: allow-lan
:setallowlan
call :constructjson_noqoute "allow-lan" "%~1" "data"
curl -X PATCH -d !data! !controller_url!/configs
goto :eof

rem setprofile: %1: profile path
:setprofile
call :constructjson "path" "%~1" "data"
call misc.bat :arrinit "curl_retdata"
set setprofile_success=0
for /f "tokens=*" %%i in ('curl -s -X PUT -d !data! --write-out %%{http_code} !controller_url!/configs') do (
  set strLine=%%i
  call misc.bat :arrappendalt "curl_retdata" "strLine"
)
if not "!_count_curl_retdata!" == "-1" (
  if !_count_curl_retdata! gtr 0 (
    echo !curl_retdata0! | cmdutils --utf8toacp
  )
  call misc.bat :getvalue "curl_retdata!_count_curl_retdata!" "retcode"
  if "!retcode!" == "204" (
    set setprofile_success=1
  )
)
goto :eof

:saveselected
curl -s !controller_url!/proxies | cmdutils --getselected > "Profile\selection\%~1.dat"
goto :eof

:restoreselected
set curLine=1
for /f "tokens=*" %%i in ('type "Profile\selection\%~1.dat" ^| cmdutils --useselected') do (
  if "!curLine!" == "1" (
    set group=%%i
    set curLine=2
  ) else (
    echo %%i | curl -X PUT -s -o NUL -H "Content-Type: application/json;charset=UTF-8" --data-binary @- --no-buffer "!controller_url!/proxies/!group!"
    set curLine=1
  )
)
goto :eof

:dashboard
start !controller_url!/ui/#/proxies
goto :eof

:start-clash
taskkill /IM clash-win64.exe >NUL 2>NUL
cscript /B /Nologo "%~dp0\start-clash.vbs"
goto :eof

:enable-sysproxy
sysproxy global 127.0.0.1:7890 localhost;127.*;10.*
goto :eof

:disable-sysproxy
sysproxy set 1
goto :eof

:stop-clash
taskkill /IM clash-win64.exe >NUL 2>NUL
call :disable-sysproxy
goto :eof
