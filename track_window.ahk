#SingleInstance Force
#Persistent
#InstallKeybdHook
#InstallMouseHook

$file := "window-activity.2015.csv"
$idle_log := ""
$idle := 1
$active_at = A_TickCount
$prev_active_window := "RESTART"
$prev_active_process := "RESTART"

FileAppend, % "R," . A_YYYY "-" A_MM "-" A_DD
  . "," A_Hour ":" A_Min ":" A_Sec 
  . ",0,""RESTART"",""RESTART""`r`n"
  , %$file%

$watch_interval := 1000 * 15
$idle_threshold := 1000 * 60

SetTimer, Watch, % $watch_interval

return

Watch:
  $idle_time := A_TimeIdlePhysical
  $cur_time := A_TickCount
  WinGetActiveTitle, $active_window
  WinGet, $active_process, ProcessName, A
  if ($prev_active_window != $active_window
      || $prev_active_process != $active_process) {
    if ($idle) {
      if ($idle_log) {
	FileAppend, %$idle_log%, %$file%
	$idle_log := ""
      }
    } else {
      FileAppend, % "E," . A_YYYY "-" A_MM "-" A_DD
	. "," A_Hour ":" A_Min ":" A_Sec 
	. "," ($cur_time - $idle_time - $active_at)
	. ",""" $prev_active_process """"
	. ",""" $prev_active_window """"
	. "`r`n"
	, %$file%
    }
    FileAppend, % "S," . A_YYYY "-" A_MM "-" A_DD
      . "," A_Hour ":" A_Min ":" A_Sec 
      . "," $idle_time
      . ",""" $active_process """"
      . ",""" $active_window """"
      . "`r`n"
      , %$file%
    $idle := 0
    $active_at := $cur_time - $idle_time
    $prev_active_window := $active_window
    $prev_active_process := $active_process
  } else {
    $was_idle := $idle
    $idle := $idle_time > $idle_threshold
    $became_active := !$idle && $was_idle
    if ($idle) {
      $idle_log := "I," . A_YYYY "-" A_MM "-" A_DD
	. "," A_Hour ":" A_Min ":" A_Sec 
	. "," $idle_time
	. ",""" $active_process """"
	. ",""" $active_window """"
	. "`r`n"
    } else if ($became_active) {
      FileAppend, %$idle_log%, %$file%
      $idle_log := ""
      FileAppend, % "S," . A_YYYY "-" A_MM "-" A_DD
	. "," A_Hour ":" A_Min ":" A_Sec 
	. "," $idle_time
	. ",""" $active_process """"
	. ",""" $active_window """"
	. "`r`n"
	, %$file%
      $active_at := $cur_time - $idle_time
    }
  }
return
