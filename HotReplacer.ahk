#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127

ListLines Off
SetKeyDelay,-1, 1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay,-1
SendMode, Input
SetBatchLines,-1

; if not A_IsAdmin {
   ; Run *RunAs "%A_ScriptFullPath%"
   ; ExitApp
; }

#Include <Clip>
#Include <HotstringsInterception>

Hotstring("s)~replace\(("".*""),(?:\s+)?("".*"")\)", "hotReplacer", 3)

SelectAll_Copy() {
	Send, {ctrl down}a{ctrl up}
	Clip()
}

StripQuotes(haystack) {
    return RegexReplace(haystack, """(.*)""", "$1")
}

hotReplacer(params) {	
	SelectAll_Copy()

	template := StrReplace(clipboard, triggerString, "")
	searchedVar := Trim(StripQuotes(params.1))
	replacor := Trim(StripQuotes(params.2))
			
	newText := StrReplace(template, searchedVar, replacor)
	
	Clip(newText)
}

#If WinActive("ahk_exe notepad++.exe")
^R:: Reload