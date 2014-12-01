
;#########################################################################
;         FishBOT optimized by Jelle Hanssens by Psycosis taken from Foobie who adapted Pantless Krab's
;              original version. Additional scripting by Yorkfire
;
;                        Version 1.4.8beta
;
;  Note - By using the Fishing bot designed for World of Warcraft
;  You understand the risks and agree that you will take all
;  responsibility for this code. THe creater takes no responsibility
;  for whatever happens to users who use and/or modify this code
;#########################################################################


;#######################################
; Values read from the Settings.ini file
;#######################################
   $HotKey = IniRead ("Settings.ini", "HotKey", "HotKey", "1")
   $CatchAmount = IniRead ("Settings.ini", "CatchAmount", "CatchAmount", "250")
   $bobber_search_tolerance = IniRead ("Settings.ini", "Bobber","BobberSearchTolerance", "22")
   $bobber_search_step = IniRead ("Settings.ini", "Bobber","BobberSearchStep", "1")
   $color_choice = IniRead ("Settings.ini", "colorchoice", "colorchoice", "15")

; Color Definitions
   $1 = IniRead ("Settings.ini", "Color", "1", "0xA72C0B")
   $2 = IniRead ("Settings.ini", "Color", "2", "0xA72C0B")
   $3 = IniRead ("Settings.ini", "Color", "3", "0xA72C0B")
   $4 = IniRead ("Settings.ini", "Color", "4", "0xA72C0B")
   $5 = IniRead ("Settings.ini", "Color", "5", "0xA72C0B")
   $6 = IniRead ("Settings.ini", "Color", "6", "0xA72C0B")
   $7 = IniRead ("Settings.ini", "Color", "7", "0xA72C0B")
   $8 = IniRead ("Settings.ini", "Color", "8", "0xA72C0B")
   $9 = IniRead ("Settings.ini", "Color", "9", "0xA72C0B")
   $10 = IniRead ("Settings.ini", "Color", "10", "0xA72C0B")
   $11 = IniRead ("Settings.ini", "Color", "11", "0xA72C0B")
   $12 = IniRead ("Settings.ini", "Color", "12", "0xA72C0B")
   $13 = IniRead ("Settings.ini", "Color", "13", "0xA72C0B")
   $14 = IniRead ("Settings.ini", "Color", "14", "0xA72C0B")
   $15 = IniRead ("Settings.ini", "Color", "15", "0xA389AA")
   $16 = iniRead ("Settings.ini", "Color", "16", "0xEDD9EE")


;###########
; Globals
;###########
$title = "BANK"
$win_title = "World of Warcraft"

; Sets up the Borders to fish in
$top_border_height = 23
$left_border_width = 4

; Sets up the Screen resolution $ make sure its in windowed mode
$screen_width = 800
$screen_height = 600

; Just a simple Timer
$time_to_wait = Random(30000, 35000, 1)

dim $start_time
dim $color_to_use
dim $catch_counter = 0

;#########################################################################
;                   Hot Keys Section
;
; Set up a Hot key to be used later to end the script
;#########################################################################

HotKeySet("{PAUSE}", "request_end")

;#########################################################################
;                     Fish Bot View Paremeters
;
;  Sets up the boundaries of the fishbot on the screen and returns
;  some visual confirmation by moving the mouse in a square showing
;  where the bot will be searching for the fishing bobber
;#########################################################################

if not WinExists($win_title, "") then
	msg($win_title & " window must be open.")
	Exit
endif

WinActivate($win_title, "")
WinSetOnTop($win_title, "", 0)
Sleep(500)

check_window()

$win_pos = WinGetPos($win_title, "")
$win_x = $win_pos[0] + $left_border_width
$win_y = $win_pos[1] + $top_border_height

$top = $win_y + (.25 * $screen_height)
$bottom = $top + (.35 * $screen_height) - 1
$left = $win_x + (.15 * $screen_width)
$right = $left + $screen_width - (.15 * 2.0 * $screen_width) - 1

Start_Bot()
IniWrite("Settings.ini", "HotKey", "HotKey", " " & $HotKey)

;###########################
; Visual confirmation
; Area scanned for bobber
;###########################

MouseMove($left, $top, 0)
MouseMove($right, $top, 5)
MouseMove($right, $bottom, 5)
MouseMove($left, $bottom, 5)
MouseMove($left, $top, 5)
cast_pole()
find_float()

;#########################################################################
;
;                       Function find_float
;
;  Once bobber has been cast the bobber needs to be found via colors
;  The most prominent color is the red so by default that is enabled
;  More colors have been defined and you may switch them if you want
;  The only reason to switch them is when fishing in Stormwind or at
;  night when colors are all very diffrent.
;#########################################################################

func find_float()

;##################################################################
; This is the search tolerance. In areas where the bobber
; colors really stand out, you can use a fairly high threshold.
; In areas where the bobber colors are fairly muted in with
; the background, you will have to lower the values considerably.
;##################################################################

	$bobber_search_tolerance = IniRead ("Settings.ini", "Bobber", "BobberSearchTolerance", "22")

;########################################################################
; It's better to use lower values here in favor of accurate searching.
; This will take more time for it to detect the bobber, but usually
; the splash doesn't occur until at least 30% of the time has run out,
; and by that time, it should have detected the bobber (assuming the
; color values and tolerance are correct).
;########################################################################

	$bobber_search_step = IniRead ("Settings.ini", "Bobber", "BobberSearchStep", "1")

;#########################################################################
; Search for float. In certain lighting, the part of the float may look
; more purple than blue. In this case, using $color_red tends to work
; the best with a tolerance of 20.
;#########################################################################

    send(2)
    $lureTimer = TimerInit()
	while 1
        if TimerDiff($lureTimer) >= 300000
            send(2)
            $lureTimer = TimerInit()
        endif
        
        if TimerDiff($start_time) >= $time_to_wait then
            cast_pole()
        endif

        $pos = PixelSearch($left, $top, $right, $bottom, $color_to_use, $bobber_search_tolerance, $bobber_search_step)
        if @error then
            SetError(0)
        else
            MouseMove($pos[0], $pos[1], 2)
            find_splash($pos[0], $pos[1] )
        endif
        Sleep(10)
    wend
endfunc

; ############################################################################
func find_splash($float_x, $float_y)
	; Wait for splash
	sleep(7000)
	$firstColor = PixelGetColor($float_x,$float_y)
	while TimerDiff($start_time) < $time_to_wait
		$newColor = PixelGetColor($float_x,$float_y)
		If (($newColor < ($firstColor - 3500000)) Or ($newColor > ($firstColor + 3000000 ))) Then
			;Msg("First  " + $firstColor)
			;Msg("New: " + $newColor)
			; Click on the splash
			$RandomClick = Random(800, 3000, 1)
			;send("{SHIFTDOWN}")
			MouseClick("right");, $pos[0], $pos[1], 1, 2)
			Sleep($RandomClick)
			;send("{ShiftUP}")
			Sleep(1000)
			$catch_counter = $catch_counter + 1
			if $catch_counter = $catchamount then
				Send("{Esc}")
				Sleep(1500)
				MouseClick("left", 405, 345, 1, 3)
				exit
			endif
		ExitLoop
		endif
	Sleep(10)
	wend

	; Cast pole and start all over again.
	cast_pole()
endfunc

; ##############################################################################
func cast_pole()
	$RandomNum = Random(1000, 3000, 1)
	$start_time = TimerInit()
	Send($HotKey)
	Sleep($RandomNum)
endfunc

; ##############################################################################
func check_window()
	$dimensions = WinGetClientSize($win_title, "")
	if $dimensions[0] <> $screen_width or $dimensions[1] <> $screen_height then
		msg("Invalid window size. You must use " & $screen_width & "x" & $screen_height & " resolution in window mode.")
		Exit
    endif
endfunc

; ##############################################################################
func msg($text)
    MsgBox(0, $title, $text)
endfunc



; ##########################################################
func request_end()
    $MB_YESNO = 4
    $MB_YES = 6

    if MsgBox($MB_YESNO, $title, "End script?") == $MB_YES then
        Exit
    endif
endfunc

;###########################################################
func Start_Bot()
	$MB_YESNO = 4
    $MB_YES = 6

    if MsgBox($MB_YESNO, $title, "Make sure you have done the following before you begin." & @CRLF & _
        @CRLF & "1: Face your character away from the sun or moon." & @CRLF & _
		"2: Set your character view to first person mode." & @CRLF & _
		"3: Adjust your horizon line so that it is" & @CRLF & _
		"    approximately 2 inches from the top of the screen." & @CRLF & _
		"4: Equip your fishing pole." & @CRLF & @CRLF & @CRLF & _
		"                    Press Yes to continue." & @CRLF & _
		"                    Press No to exit.") == $MB_Yes then
		if MsgBox($MB_YESNO, $title, "Do you want to Run Setup?") == $MB_Yes then
			RunSetup()
		endif
	else
		Exit
    endif
endfunc

; ##########################################################
func drain_timer()
    Msg("Restart")
    $start_time = $start_time - $time_to_wait
endfunc

; ##########################################################
func choose_color()
    ;#########################################################
    ; This is the color used to pixelsearch for the bobber.
    ; Select a good color on the bobber that
    ; is prominent on the screen
    ;#########################################################

	$color_choice = InputBox($title, "Enter a number for the color you wish to use." _
	& @CRLF & "1: Dark Purple" & @CRLF & "2: Dark Blue" & @CRLF & "3: Red" & @CRLF & _
	"4: Stormwind Daylight Blue" & @CRLF & "5: Stormwind Daylight Red" & @CRLF &  _
	"6: Beige" & @CRLF & "7: Night Blue" & @CRLF & "8: Wailing Caverns" & @CRLF & _
	"15: bobber grey" & @CRLF & "16: float red ",""& $color_choice, "", 251, 244)

	Select
		Case $color_choice = 1
			$color_to_use = $1
		Case $color_choice = 2
			$color_to_use = $2
		Case $color_choice = 3
			$color_to_use = $3
		Case $color_choice = 4
			$color_to_use = $4
		Case $color_choice = 5
			$color_to_use = $5
		Case $color_choice = 6
			$color_to_use = $6
		Case $color_choice = 7
			$color_to_use = $7
		Case $color_choice = 8
			$color_to_use = $8
		Case $color_choice = 9
			$color_to_use = $9
		Case $color_choice = 10
			$color_to_use = $10
		Case $color_choice = 11
			$color_to_use = $11
		Case $color_choice = 12
			$color_to_use = $12
		Case $color_choice = 13
			$color_to_use = $13
		Case $color_choice = 14
			$color_to_use = $14
		Case $color_choice = 15
			$color_to_use = $15
		Case $color_choice = 16
			$color_to_use = $16
		Case Else
			ErrorMsg()
			$color_to_use = $3
			$color_choice = 3
	EndSelect
	IniWrite("Settings.ini", "ColorChoice", "ColorChoice", " " & $color_choice)
endfunc

; ##########################################################
func RunSetup()
	$MB_YESNO = 4
	$MB_YES = 6

	$CatchAmount = InputBox($title, "How many items do you want the bot to find?" _
	& @CRLF & "Enter a value higher than 1", "" & $CatchAmount, "", 251, 244)
	If $CatchAmount >= 1  then
		IniWrite("Settings.ini", "CatchAmount", "CatchAmount", " " & $CatchAmount)
	Else
		ErrorMsg()
		IniWrite("Settings.ini", "CatchAmount", "CatchAmount", " 50")
	endif

	$HotKey = InputBox($title, "Enter which hotkey you use for casting your fishing pole." _
	& @CRLF & "Example: 1", "" & $HotKey, "", 251, 244)
	If $HotKey <> "" then
		IniWrite("Settings.ini", "HotKey", "HotKey", " " & $HotKey)
	Else
		$HotKey = 1
		ErrorMsg()
		IniWrite("Settings.ini", "HotKey", "HotKey", " 1")
	endif

	choose_color()

    if MsgBox($MB_YESNO, $title, "Do you want to setup advanced settings?") == $MB_Yes then
		AdvancedSetup()
    endif
endfunc

; ##########################################################
func AdvancedSetup()

	$Bobber_Search_Tolerance = InputBox($title, "Enter tolerance value for the bobber?" _
	& @CRLF & "Value should be between 0 and 30", "" & $Bobber_Search_tolerance, "", 251, 244)
	If $Bobber_Search_Tolerance <> "" AND $Bobber_Search_Tolerance <= 255 then
		IniWrite("Settings.ini", "Bobber", "BobberSearchTolerance", " " & $Bobber_Search_tolerance)
	Else
		ErrorMsg()
		IniWrite("Settings.ini", "Bobber", "BobberSearchTolerance", " 20")
	endif

	$Bobber_Search_Step = InputBox($title, "Enter step value for the bobber?" _
	& @CRLF & "Value should be between 1 and 5", "" & $Bobber_Search_Step, "", 251, 244)
	If $Bobber_Search_Step >= 1 AND $Bobber_Search_Step <= 5 then
		IniWrite("Settings.ini", "Bobber", "BobberSearchStep", " " & $Bobber_Search_Step)
	Else
		ErrorMsg()
		IniWrite("Settings.ini", "Bobber", "BobberSearchStep", " 2")
	endif
endfunc

; ##########################################################
func ErrorMsg()
	MsgBox(0, $title, "Incorrect value entered or the user pressed cancel. Default value will be used!")
endfunc

; ##########################################################
