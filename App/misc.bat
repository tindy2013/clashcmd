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

rem /////string splitter/////

rem splitter_init: %1: var to split %2: delimiter
:splitter_init
set splitter_current_pos=0
set splitter_target_var=%~1
set splitter_delim=%~2
goto :eof

rem splitter_next: %1: var to save
:splitter_next
call :clearvar "%~1"
call :getvalue "!splitter_target_var!" "tmpstr"
set splitter_next_pos=!splitter_current_pos!
:splitter_next_loop
set char=!tmpstr:~%splitter_next_pos%,1!
if "!char!" == "!splitter_delim!" (
  call :getvarpart "tmpstr" "%~1" "!splitter_current_pos!" "!splitter_next_pos!"
  set /a splitter_current_pos=!splitter_next_pos!+1
  goto :eof
)
if "!char!" == "" goto :eof
set /a splitter_next_pos=!splitter_next_pos!+1
goto :splitter_next_loop

rem /////BASIC FUNCTIONS/////

rem sleep: %1: time in msec
:sleep
cscript /B /Nologo "%~dp0\sleep.vbs" %1
goto :eof

rem trim: %1: var to trim
:trim
set space= 
call :trim_of "%~1" "space"
goto :eof

rem trim_quote: %1: var to trim
:trim_quote
set quote="
call :trim_of "%~1" "quote"
goto :eof

rem trim_of: %1: var to trim %2: trim what
:trim_of
set trim_begin=0
set trim_end=-1
set target_var=%~1
set trim_target_var=%~2
call :getvalue "!trim_target_var!" "trim_target"
call :getvalue "!target_var!" "tmpstr"
:trim_of_begin_loop
set char=!tmpstr:~%trim_begin%,1!
if not "!char!" == "!trim_target!" goto trim_of_end_loop
set /a trim_begin=!trim_begin!+1
goto trim_of_begin_loop
:trim_of_end_loop
set char=!tmpstr:~%trim_end%,1!
if not "!char!" == "!trim_target!" goto trim_of_result
set /a trim_end=!trim_end!-1
goto trim_of_end_loop
:trim_of_result
set /a trim_end=!trim_end!+1
call :getvarpart "!target_var!" "!target_var!" "!trim_begin!" "!trim_end!"
goto :eof

rem getcmdret: %1: command var %2: var to save
:getcmdret
::call :getvalue "%~1" "cmdval"
set cmdval=%~1
set outval=%~2
for /f %%X in ('!cmdval!') do set !outval!=%%X
goto :eof

rem getvalue: %1: var name %2: write target ret: %2
:getvalue
set key=%~1
set out=%~2
set !out!=!%key%!
goto :eof

rem getvarpart: %1: var name %2: var to save %3: from %4: to
:getvarpart
set key=%~1
set out=%~2
set from=%~3
set to=%~4
if !to! lss 0 (
  set /a cnt=!to!
) else (
  set /a cnt=!to!-!from!
)
if !cnt! equ 0 (
  set !out!=!%key%:~%from%!
  goto :eof
)
set !out!=!%key%:~%from%,%cnt%!
goto :eof

rem replace: %1: var name %2: search var %3: replace var %4: var to save
:replace
set src=%~1
set save=%~4
call :getvalue "%~2" "search"
call :getvalue "%~3" "replace"
set !save!=!%src%:%search%=%replace%!
goto :eof

rem replace_self: %1: var name %2: search var %3: replace var
:replace_self
call :replace "%~1" "%~2" "%~3" "%~1"
goto :eof

rem substitute: %1: var name %2: var to save %3: sub1 find %4: sub1 replace %5: sub2 find %6: sub2 replace %7: sub3 find %8: sub3 replace 
:substitute
set sub1=?%~3?
call :replace "%~1" "sub1" "%~4" "%~2"
if not "%~5" == "" (
  set sub2=?%~5?
  call :replace_self "%~2" "sub2" "%~6"
  if not "%~7" == "" (
    set sub3=?%~7?
    call :replace_self "%~2" "sub3" "%~8"
  )
)
goto :eof

:substitute_print
call :substitute "%~1" "message" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7"
echo !message!
goto :eof

rem clearvar: %1: var name
:clearvar
set clearvar=%~1
set !clearvar!=
set clearvar=
goto :eof

rem instr: %1: target %2: source ret: %retval% 0:found 1:not found
:instr
echo "%~2"|find "%~1">nul
set retval=!errorlevel!
goto :eof

rem split: %1: source %2: delimiter ret: %first%, %second%
:split2
set split2_target=
call :getvalue "%~1" "split2_target"
for /f "delims=%~2 tokens=1,*" %%x in ("!split2_target!") do (
  set first=%%x
  set second=%%y
)
goto :eof

rem makechoice: %1: info %2: start %3: end %4: other options
:makechoice
set options=
if %~2 equ 0 (
  if %~3 equ 0 (
    set options=%~4
    goto launchchoice
  )
)
for /l %%a in (%~2,1,%~3) do (
  set options=!options!%%a
)
set options=!options!%~4
:launchchoice
set errorlevel=
choice /C !options! /M "%~1"
goto :eof

rem makemenu: %1: title %2: options arr name %3: option keys %4: choice msg %5: subtitle(optional)
:makemenu
set index=0
set /a end=!_count_%~2!
set opts=%~3
echo -------------------------------------
echo.
echo   %~1
echo.
if not "%~5" == "" (
  echo   %~5
  echo.
)
for /l %%a in (0,1,!end!) do (
  if defined %~2%%a (
    set /a index1=!index!+1
    call :getvarpart "opts" "opt" "!index!" "!index1!"
    echo   [!opt!] !%~2%%a!
  ) else (
    goto :eof
  )
  set /a index=!index!+1
  echo.
)
echo -------------------------------------
echo.
call :makechoice "%~4" "0" "0" "!opts!"
set /a index=!errorlevel!-1
set /a index1=!index!+1
call :getvarpart "opts" "selection" "!index!" "!index1!"
goto :eof

rem makeswitch: %1: title %2: var to switch %3: true text %4: false text %5: cancel text %6: choice msg %7: selected msg %~8: subtitle(optional)
:makeswitch
if "%~7" == "" (
  set msg= 
) else (
  set msg=%~7
)
set sel=?sel?
set switch_title=%~1
set switch_var=%~2
set switch_true=%~3
set switch_false=%~4
set switch_cancel=%~5
call :getvalue "%~2" "switch_orig"
if not "!switch_orig!" == "true" (
  set switch_orig=!switch_false!
) else (
  set switch_orig=!switch_true!
)
call :replace_self "switch_title" "sel" "switch_orig"
call :arrinit "switch_options"
call :arrappend "switch_options" "%~3"
call :arrappend "switch_options" "%~4"
call :arrappend "switch_options" "%~5"
cls
call :makemenu "!switch_title!" "switch_options" "YNX" "%~6" "%~8"
if "!selection!" == "Y" (
  set !switch_var!=true
  call :replace_self "msg" "sel" "switch_true"
)
if "!selection!" == "N" (
  set !switch_var!=false
  call :replace_self "msg" "sel" "switch_false"
)
if "!selection!" == "X" (
  call :replace_self "msg" "sel" "switch_cancel"
)
echo.
echo !msg!
goto :eof

rem arrinit: %1: name
:arrinit
set arrname=%~1
set _count_!arrname!=-1
goto :eof

rem arrappend: %1: arrname %2: value
:arrappend
set arrname=%~1
set arrcount=!_count_%arrname%!
set /a arrcount=!arrcount!+1
set !arrname!!arrcount!=%~2
set _count_!arrname!=!arrcount!
goto :eof

rem arrappendalt: %1: arrname, %2: value var
:arrappendalt
set arrname=%~1
set arrcount=!_count_%arrname%!
set /a arrcount=!arrcount!+1
set !arrname!!arrcount!=!%~2!
set _count_!arrname!=!arrcount!
goto :eof

rem arrfind: %1: arrname %2: value
:arrfind
set retVal=0
rem call :arrlength "%~1"
if !_count_%~1! equ -1 goto :eof
for /l %%a in (0,1,!_count_%~1!) do (
  if "!%~1%%a!" == "%~2" (
    set retVal=1
    goto :eof
  )
)
goto :eof

rem arrlength: %1: arrname
:arrlength
set retVal=!_count_%~1!
goto :eof

rem arrlength: %1: arrname
:__deprecated_arrlength
set i=0
set arrname=%~1
:arrlengthloop
if defined !arrname!!i! (set /a i=!i!+1&&goto arrlengthloop)
set /a _count_!arrname!=!i!-1
goto :eof

rem arrprint: %1: arrname %2: start %3: count
:arrprint
set index=1
set /a end=%~2+%~3-1
for /l %%a in (%~2,1,!end!) do (
  if defined %~1%%a (
    echo   !index!: [%%a] !%~1%%a!
  ) else (
    echo --END--
    set /a retVal=!index!-1
    goto :eof
  )
  set /a index=!index!+1
)
set /a retVal=!index!-1
echo --END--
goto :eof

rem arrerase: %!: arrname
:arrerase
set retVal=0
if !_count_%~1! neq -1 (
  for /l %%a in (0,1,!_count_%~1!) do (
     set %~1%%a=
  )
)
set _count_%~1=
goto :eof

:placeholder
goto :eof
