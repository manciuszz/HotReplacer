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
#Include <Debugging/JSON>
#Include <HotstringsInterception>

Hotstring("s)~loop\((\d+),(?:\s+)?(.*)\)", "TextFunctions.textLoop", 3)
Hotstring("s)~replace\(([""|'].*[""|']),(?:\s+)?([""|'].*[""|'])\)", "TextFunctions.hotReplacer", 3)

class Utilities {
	SelectAll_Copy() {
		Send, {ctrl down}a{ctrl up}
		Clip()
	}

	StripQuotes(haystack) {
		return RegexReplace(haystack, "[""|'](.*)[""|']", "$1")
	}
}

class TextFunctions {
	textLoop(params) {
		Utilities.SelectAll_Copy()
		
		template := clipboard
		
		; fetch all available variables from clipboard
		MatchedData := { keys: [], vars: {}, _currentPos: 1 }
		while(MatchedData._currentPos := RegExMatch(template, "O)(?<name>\$\w+)(?:\s+)?\=(?:\s+)?``(?<value>[\S\s]*?)``", _matchedVars, MatchedData._currentPos + StrLen(_matchedVars[0]))) {
			MatchedData.keys.Push(_matchedVars["name"])
			MatchedData.vars[_matchedVars["name"]] := [_matchedVars["value"]]
		}
		
		; unwrap variables
		for variableName, contentArr in MatchedData.vars {
			if (InStr(contentArr.1, "$")) {
				newContent := contentArr.1
				for keyIndex, keyName in MatchedData.keys {
					if (InStr(newContent, keyName)) {
						arrValues := StrSplit(RegExReplace(MatchedData.vars[keyName].1, "\[([\S\s]*?)\]", "$1"), ",")
						if (arrValues.Length() == 1) {
							newContent := StrReplace(newContent, keyName, Trim(arrValues.1))
						} else {
							for arrIndex, arrValue in arrValues {
								MatchedData.vars[variableName, arrIndex] := StrReplace(newContent, keyName, Trim(arrValue))
							}
						}
					}
				}
			}
		}
		
		newText := ""
		
		loopCount := params.1
		templateVar := params.2

		templateLength := MatchedData.vars[templateVar].Length()

		if (loopCount > templateLength)
			loopCount := templateLength

		Loop % loopCount {
			newText .= MatchedData.vars[templateVar, A_Index] . "`n"
		}
		
		Clip(newText)
	}

	hotReplacer(params) {	
		Utilities.SelectAll_Copy()

		template := clipboard
		searchedVar := Trim(Utilities.StripQuotes(params.1))
		replacor := Trim(Utilities.StripQuotes(params.2))
				
		newText := StrReplace(template, searchedVar, replacor)
		
		Clip(newText)
	}
}

#If WinActive("ahk_exe notepad++.exe")
^R:: Reload