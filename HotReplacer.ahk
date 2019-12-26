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

#Include <Clip>
#Include <Translate>
#Include <Debugging/JSON>
#Include <HotstringsInterception>

; Utilities.Run_AsAdmin()

; global debugTypingDetection := true ; uncomment to see what is being stored inside the typing buffer...

; ~loop(number, $variable)
Hotstring("sS)~loop\((\d+),(?:\s+)?(.*)\)", "TextFunctions.textLoop", 3) 

; ~replace("str1", "str2") or ~replace('str1', 'str2') or ~replace(`str1`, `str2`)
Hotstring("sSU)~replace\(([""|'|``].*[""|'|``]),(?:\s+)?((?1))\)", "TextFunctions.hotReplacer", 3)

; ~translate("str1", "str2", "str3") or ~translate("str1", "str2")
Hotstring("sSU)~translate\(([""|'|``].*[""|'|``]),(?:\s+)?((?1))(?:,(?:\s+)?((?1)))?\)", "TextFunctions.translateText", 3) 

class Utilities {
	SelectAll_Copy() {
		Send, {ctrl down}a{ctrl up}
		Clip()
	}
	
	Paste(text) {
		Clip(text)
	}

	StripQuotes(haystack) {
		return RegexReplace(haystack, "[""|'|``](.*)[""|'|``]", "$1")
	}
	
	Run_AsAdmin() {
		if not A_IsAdmin {
		   Run *RunAs "%A_ScriptFullPath%"
		   ExitApp
		}
	}
	
	Unwrap(variableName, byRef newContent, byRef MatchedData, isRecursing := false) {
		for keyIndex, keyName in MatchedData.keys {
			if (InStr(newContent, keyName)) {
				arrValues := StrSplit(RegExReplace(MatchedData.vars[keyName].1, "\[([\S\s]*?)\]", "$1"), ",")
				if (arrValues.Length() > 1) {
					for arrIndex, arrValue in arrValues {
						if (isRecursing) {
							MatchedData.vars[variableName, arrIndex] := StrReplace(MatchedData.vars[variableName, arrIndex], keyName, Trim(arrValue))
						} else {
							MatchedData.vars[variableName, arrIndex] := StrReplace(newContent, keyName, Trim(arrValue))
						}
					}
				} else { 
					newContent := StrReplace(newContent, keyName, Trim(MatchedData.vars[keyName].1))
					MatchedData.vars[variableName, 1] := newContent
										
					if (variableName == keyName || RegExMatch(newContent, StrReplace(keyName, "$", "\$") . "\b")) {
						newContent := StrReplace(newContent, keyName, "")
					}
						
					if (InStr(newContent, "$")) {
						this.Unwrap(variableName, newContent, MatchedData)
					}
				}
			}
		}
		
		if (!isRecursing && InStr(newContent, "$")) {
			this.Unwrap(variableName, newContent, MatchedData, true)
		}
	}
}

class TextFunctions {
	translateText(params) {
		textToTranslate := params.1
		if (params.3) {
			fromLanguage := params.2
			toLanguage := params.3
		} else {
			fromLanguage := "auto"
			toLanguage := params.2
		}
		
		translationRequestData := GoogleTranslate(Utilities.StripQuotes(textToTranslate), Utilities.StripQuotes(fromLanguage), Utilities.StripQuotes(toLanguage))
		if (translationRequestData.2 == "Success")
			Utilities.Paste(translationRequestData.1)
	}

	textLoop(params) {
		Utilities.SelectAll_Copy()
		
		template := clipboard
		
		; fetch all available variables from clipboard
		MatchedData := { keys: [], vars: {}, _currentPos: 1 }
		while(MatchedData._currentPos := RegExMatch(template, "O)(?<name>\$+\w+)(?:\s+)?\=(?:\s+)?``(?<value>[\S\s]*?)``", _matchedVars, MatchedData._currentPos + StrLen(_matchedVars[0]))) {
			MatchedData.keys.Push(_matchedVars["name"])
			MatchedData.vars[_matchedVars["name"]] := [_matchedVars["value"]]
		}
		
		; unwrap variables
		for variableName, contentArr in MatchedData.vars {
			variableValue := contentArr.1
			if (InStr(variableValue, "$")) {
				Utilities.Unwrap(variableName, variableValue, MatchedData)
			}
		}
		
		newText := ""
		
		loopCount := params.1
		templateVar := params.2

		templateLength := MatchedData.vars[templateVar].Length()

		Loop % loopCount {
			newText .= MatchedData.vars[templateVar, 1 + Mod(A_Index - 1, templateLength)] . "`n"
		}
		
		Utilities.Paste(newText)
	}

	hotReplacer(params) {
		Utilities.SelectAll_Copy()

		template := clipboard
		searchedVar := Trim(Utilities.StripQuotes(params.1))
		replacor := Trim(Utilities.StripQuotes(params.2))
				
		if (InStr(params.1, "``"))
			newText := RegExReplace(template, searchedVar, replacor)
		else
			newText := StrReplace(template, searchedVar, replacor)
		
		Utilities.Paste(newText)
	}
}

#If WinActive("ahk_exe notepad++.exe")
^R:: Reload