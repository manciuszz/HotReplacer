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

if not A_IsAdmin {
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

#Include <Debugging\JSON>
#Include <HotstringsInterception>

Hotstring("~replace\((.*)\)", "hotReplacer", 3)

SelectAll_Copy() {
	clipboard := ""
	Send, {ctrl down}a{ctrl up}
	Send, {ctrl down}c{ctrl up}
	ClipWait
}

StripQuotes(haystack) {
    return StrReplace(haystack, chr(34), "") ;RegexReplace(haystack, "(\D)[""|']", "$1")
}

hotReplacer(params) {
	args := StrSplit(params.1, ",")
	
	SelectAll_Copy()

	template := StrReplace(clipboard, triggerString, "")
	
	searchedVar := Trim(StripQuotes(args.1))
	replacor := Trim(StripQuotes(args.2))
	
	newText := StrReplace(template, searchedVar, replacor)
	
	clipboard := newText
	Sleep, 100
	Send, ^v
	Sleep, 100
}

#If WinActive("ahk_exe notepad++.exe")
^R:: Reload