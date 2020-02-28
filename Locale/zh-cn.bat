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

rem ///locale initializer///

:localeinit
rem main
set loc_title=ClashCMD 控制台 ?version?
set loc_menu_select=选择：
set loc_menu_choice=请选择需要的操作：
set loc_choice_YN=确定请按Y，取消请按N
set loc_done_anykey=已完成！按任意键返回...
set loc_menu_cancel=你选择了取消！
set loc_open_dashboard=正在浏览器中打开面板...
set loc_shutdown=正在关闭控制台...

rem core
set loc_core_getting_status=正在获取 Clash 核心状态...
set loc_core_running=运行中
set loc_core_stopped=未运行
set loc_core_title=Clash 核心管理 当前核心状态：?status?
set loc_core_already_running=Clash 核心已经在运行了。
set loc_core_starting=正在启动 Clash 核心...
set loc_core_started=Clash 核心已启动。
set loc_core_already_stopped=Clash 核心还未运行。
set loc_core_terminating=正在关闭 Clash 核心...
set loc_core_terminated=Clash 核心已关闭。
set loc_core_stop_before_start=当前核心未运行！请先启动！

set loc_core_saving_selection=正在尝试保存 ?profile? 配置文件的策略组选项
set loc_core_fetch_status_failed=无法读取 Clash 运行模式！请检查核心运行情况后重试！

set loc_core_mode_global=全局
set loc_core_mode_rule=规则
set loc_core_mode_direct=直连
set loc_core_mode_current=当前 Clash 核心模式：?mode?
set loc_core_mode_select=请选择要切换到的模式：
set loc_core_mode_set=已设置为 ?mode? 模式...

set loc_core_allowlan_current=当前 Clash 核心 ?allow? 局域网设备接入。
set loc_core_allowlan_true=允许
set loc_core_allowlan_false=不允许
set loc_core_allowlan_select=请选择要切换到的状态：
set loc_core_allowlan_set=已设置为 ?allow? 局域网设备接入。

set loc_profile_not_selected=未选择
set loc_profile_select_first=请先选择配置文件！

rem profile
set loc_profile=配置文件管理  当前配置文件：?profile?
set loc_profile_opt=请选择对配置文件的操作：

set loc_profile_add=新增配置文件
set loc_profile_add_suburl=请输入订阅地址或单链接，多个请用 "|" 隔开：
set loc_profile_add_suburl_empty=未输入配置文件，返回中...
set loc_profile_add_subname=请命名配置文件，不可与已有配置文件重名：
set loc_profile_add_subname_empty=未输入配置文件名，返回中...
set loc_profile_add_subname_dup=与现有配置文件重名！请重新输入。
set loc_profile_add_subname_space=名称中不能含有空格！
set loc_profile_add_convert=是否使用 SubConverter 对配置文件 ?sub? 进行转化？注意如不使用，您输入的订阅必须是 Clash 订阅。使用请按Y，不使用请按N 
set loc_profile_add_success=新增配置文件：?sub? 已完成！

set loc_profile_del=删除配置文件
set loc_profile_del_sure=你确定要删除配置文件 ?profile? 吗？
set loc_profile_del_msg=正在删除配置文件 ?profile?...

set loc_profile_select=选择配置文件 第?page?页
set loc_profile_select_press_key=请按下选项前面的数字或字母选择：
set loc_profile_select_prev=上一页
set loc_profile_select_next=下一页
set loc_profile_select_back=返回上级菜单
set loc_profile_select_choice=你选择的选项是：
set loc_profile_select_set=你选择了 ?profile? 配置文件！

set loc_profile_update=更新配置文件
set loc_profile_update_direct=正在更新 ?profile? 配置文件...
set loc_profile_update_subcon=正在通过 SubConverter 转化并更新 ?profile? 配置文件...
set loc_profile_update_failed=更新失败！请检查订阅！按任意键继续...
set loc_profile_update_success=更新完成！

set loc_profile_apply=应用配置文件
set loc_profile_apply_sure=是否确定将配置文件 ?profile? 应用到 Clash 核心？确定请按Y，取消请按N 
set loc_profile_apply_pre=设置中...
set loc_profile_apply_on=正在应用配置文件...
set loc_profile_apply_failed=应用配置文件失败！请检查生成的配置文件！按任意键继续...
set loc_profile_apply_restore=正在尝试恢复 ?profile? 的策略组选项...
set loc_profile_apply_done=设置完成！
set loc_profile_apply_cancel=已取消...

set loc_monitor=监控窗口管理
set loc_monitor_logs=Clash 日志
set loc_monitor_traffic=Clash 流量

rem pref
set loc_pref=偏好设置
set loc_pref_select=请选择要调整的项目：
set loc_pref_apply_on_startup=运行 Clash 核心时自动应用配置文件
set loc_pref_enable_proxy_on_startup=运行 Clash 核心时自动开启系统代理
set loc_pref_disable_proxy_on_stop=停止 Clash 核心时自动关闭系统代理
set loc_pref_update_on_add=新增配置文件后自动更新
set loc_pref_apply_on_add=新增配置文件后自动应用
set loc_pref_update_on_select=选择配置文件后自动更新
set loc_pref_apply_on_select=选择配置文件后自动应用
set loc_pref_apply_on_update=更新配置文件后自动应用
set loc_pref_switch=?option?  当前为 ?sel?
set loc_pref_switch_enable=启用
set loc_pref_switch_disable=禁用
set loc_pref_switch_back=返回上级菜单
set loc_pref_switch_selected=已选择 ?sel?。

rem advanced
set loc_advanced=高级选项
set loc_advanced_select=请选择要调整的项目：
set loc_advanced_enable_sysproxy_on=正在开启系统代理...
set loc_advanced_enable_sysproxy_done=系统代理已开启。
set loc_advanced_disable_sysproxy_on=正在关闭系统代理...
set loc_advanced_disable_sysproxy_done=系统代理已关闭。
set loc_advanced_geoip_updating=正在更新 GeoIP 数据库...
set loc_advanced_geoip_done=更新成功！
goto :eof

:initoptions
call :arrinit "main_options"
call :arrinit "core_options"
call :arrinit "mode_options"
call :arrinit "allow_options"
call :arrinit "sub_options"
call :arrinit "mon_options"
call :arrinit "adv_options"
call :arrinit "setting_options"
call :arrappend "main_options" "Clash 核心管理"
call :arrappend "main_options" "配置文件管理"
call :arrappend "main_options" "打开控制面板"
call :arrappend "main_options" "偏好设置"
call :arrappend "main_options" "高级选项"
call :arrappend "main_options" "监控窗口"
call :arrappend "main_options" "关闭 ClashCMD"
call :arrappend "core_options" "启动 Clash"
call :arrappend "core_options" "停止 Clash"
call :arrappend "core_options" "切换代理模式"
call :arrappend "core_options" "切换允许局域网连接"
call :arrappend "core_options" "返回上级菜单"
call :arrappend "mode_options" "全局"
call :arrappend "mode_options" "规则"
call :arrappend "mode_options" "直连"
call :arrappend "mode_options" "返回上级菜单"
call :arrappend "sub_options"  "新增配置文件"
call :arrappend "sub_options"  "选择配置文件"
call :arrappend "sub_options"  "应用配置文件"
call :arrappend "sub_options"  "更新配置文件"
call :arrappend "sub_options"  "删除配置文件"
call :arrappend "sub_options"  "返回上级菜单"
call :arrappend "mon_options"  "打开日志窗口"
call :arrappend "mon_options"  "打开流量窗口"
call :arrappend "mon_options"  "返回上级菜单"
call :arrappend "adv_options"  "启用系统代理"
call :arrappend "adv_options"  "禁用系统代理"
call :arrappend "adv_options"  "更新 GeoIP 数据库"
call :arrappend "adv_options"  "设置开机自启"
call :arrappend "adv_options"  "返回上级菜单"
call :arrappend "allow_options" "允许局域网设备接入"
call :arrappend "allow_options" "不允许局域网设备接入"
call :arrappend "allow_options" "返回上级菜单"
call :arrappend "setting_options" "运行 Clash 核心时自动应用配置文件"
call :arrappend "setting_options" "运行 Clash 核心时自动开启系统代理"
call :arrappend "setting_options" "停止 Clash 核心时自动关闭系统代理"
call :arrappend "setting_options" "新增配置文件后自动更新"
call :arrappend "setting_options" "新增配置文件后自动应用"
call :arrappend "setting_options" "选择配置文件后自动更新"
call :arrappend "setting_options" "选择配置文件后自动应用"
call :arrappend "setting_options" "更新配置文件后自动应用"
call :arrappend "setting_options" "返回上级菜单"
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
