﻿/*
Hotstring(
	trigger:
		A string or a regular expression to trigger the hotstring. (If you use a regex here, the mode should be 3 for the regex to work)
	
	label:  	
		A string to replace the trigger / A label to go to / A function to call when the hotstring is triggered.
		If you used a regular expression as the trigger and mode was set to three, backreferences like $0, $1 would work.
		If a function name was passed, the function will be called with the phrase that triggered the hotstring(If the trigger was a string)
			or the Match object(If the trigger was a regex & mode equals 3).
		If this parameter was a label, the global variable '$' will contain the string/match object.
		If you wish to remove a hotstring, Pass the trigger with this parameter empty.
	
	Mode:	
		A number between 1 and 3 that determines the properties of the hotstring.
		If Mode == 1 then the hotstring is case insensitive.
		If Mode == 2 then the hostrings is case sensitive.
		If Mode == 3 then you can use regex in the trigger.
		
		1 is the defualt.
	
	clearTrigger:
			Determines if the trigger is erased after the hotstring is triggered.
	
	cond:
			A name of a function that allows the conditional trigerring of the hotstring.
	
)
*/

#Include <Interception\AutoHotInterception>
#Include <KeyMappings\Mappings>

__KeyEvents(clearTrigger, cond, code, state) { 
	global Mappings 
	static modifiers := { lastActive: {}, active: "", keys: { "LShift": "+", "RShift": "+", "LControl": "^", "RControl": "^", "CapsLock": "+" }, states: {}, remap: "", shortcuts: "^a,^c,^v" }
		
	if (!modifiers.remap)
		modifiers.remap := Mappings
	
	scanCode := Format("{:x}", code)
	keyName := GetKeyName("SC" scanCode)
	
	currentModifier := modifiers.keys[keyName]
	if (currentModifier) {
		modifiers.states[keyName] := state
		modifiers.lastActive := { key: keyName, alias: currentModifier }
		
		if (state = 0)
			modifiers.active := StrReplace(modifiers.active, modifiers.lastActive.alias, "")
		else if (state = 1 && !InStr(modifiers.active, modifiers.lastActive.alias) && GetKeyState(modifiers.lastActive.key, "P")) {
			modifiers.active .= modifiers.lastActive.alias
		}
	}
	
	if (state = 1 && !currentModifier) {
		S_ThisHotkey := (!currentModifier ? modifiers.active : "") . keyName
		
		if ((modifiers.states["LControl"] || modifiers.states["RControl"]) && !InStr(modifiers.shortcuts, S_ThisHotkey))
			return
		
		RemappedKey := modifiers.remap[S_ThisHotkey]
		if (!RemappedKey)
			RemappedKey := modifiers.remap[keyName]
		
		; This is a random ass bug fix of +0 to +9 remapping ! Apparently accessing the object array via variable for strings +0 to +9 in AHK v1.1.28.00 doesn't work??? in this area and it has to be done directly...
		if (S_ThisHotkey == "+1")
			RemappedKey := modifiers.remap["+1"]
		else if (S_ThisHotkey == "+2")
			RemappedKey := modifiers.remap["+2"]
		else if (S_ThisHotkey == "+3")
			RemappedKey := modifiers.remap["+3"]
		else if (S_ThisHotkey == "+4")
			RemappedKey := modifiers.remap["+4"]	
		else if (S_ThisHotkey == "+5")
			RemappedKey := modifiers.remap["+5"]	
		else if (S_ThisHotkey == "+6")
			RemappedKey := modifiers.remap["+6"]	
		else if (S_ThisHotkey == "+7")
			RemappedKey := modifiers.remap["+7"]	
		else if (S_ThisHotkey == "+8")
			RemappedKey := modifiers.remap["+8"]
		else if (S_ThisHotkey == "+9")
			RemappedKey := modifiers.remap["+9"]
		else if (S_ThisHotkey == "+0")
			RemappedKey := modifiers.remap["+0"]
		
		if (RemappedKey)
			S_ThisHotkey := RemappedKey
		
		; ToolTip % "Code: " S_ThisHotkey ", State: " state
		Hotstring("", "", "CALLBACK", clearTrigger, cond, S_ThisHotkey)
	}
}

Hotstring(trigger, label, mode := 1, clearTrigger := 1, cond := "", S_ThisHotkey := ""){
	global $
	static keysBound := false,hotkeyPrefix := "~$", hotstrings := {}, typed := "", keys := {"symbols": "!""#$%&'()*+,-./:;<=>?@[\]^_``{|}~", "num": "0123456789", "alpha":"abcdefghijklmnopqrstuvwxyz", "other": "BS,Return,Tab,Space", "specialKeys":"^a,^c,^v,Left,Right,Up,Down,Home,End,RButton,LButton,LControl,RControl,LAlt,RAlt,AppsKey,Lwin,Rwin,WheelDown,WheelUp,f1,f2,f3,f4,f5,f6,f7,f8,f9,f6,f7,f9,f10,f11,f12", "numpad":"Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter" }, effect := {"Return" : "`n", "Tab":A_Tab, "Space": A_Space, "Enter":"`n", "Dot": ".", "Div":"/", "Mult":"*", "Add":"+", "Sub":"-"}
	
	if (!keysBound){
		AHI := new AutoHotInterception()
		KeyboardId := AHI.GetDeviceList().1.Handle
		AHI.SubscribeKeyboard(AHI.GetKeyboardIdFromHandle(KeyboardId), false, Func("__KeyEvents").Bind(clearTrigger, cond))
		
		/* ; Apparently 'Hotkey' doesn't work in some applications like Opera browser..
		;Binds the keys to watch for triggers.
		for k,v in ["symbols", "num", "alpha"]
		{
			;alphanumeric/symbols
			v := keys[v]
			Loop,Parse, v
				Hotkey,%hotkeyPrefix%%A_LoopField%,__hotstring
		}
		
		v := keys.alpha
		Loop,Parse, v
			Hotkey, %hotkeyPrefix%+%A_Loopfield%,__hotstring
		for k,v in ["other", "breakKeys", "numpad"]
		{
			;comma separated values
			v := keys[v]
			Loop,Parse, v,`,
				Hotkey,%hotkeyPrefix%%A_LoopField%,__hotstring
		}
		*/
		keysBound := true ;keysBound is a static varible. Now, the keys won't be bound twice.
	}
	if (mode == "CALLBACK"){
		; Callback for the hotkey.

		Hotkey := S_ThisHotkey
		; Hotkey := SubStr(A_ThisHotkey,3)
		; Tooltip, % Hotkey

		if (StrLen(Hotkey) == 2 && Substr(Hotkey,1,1) == "+" && Instr(keys.alpha, Substr(Hotkey, 2,1))){
			Hotkey := Substr(Hotkey,2)
			if (!GetKeyState("Capslock", "T")){
				StringUpper, Hotkey,Hotkey
			}
		}
		
		shiftState := GetKeyState("Shift", "P")
		uppercase :=  GetKeyState("Capslock", "T") ? !shiftState : shiftState 
		;If capslock is down, shift's function is reversed.(ie pressing shift and a key while capslock is on will provide the lowercase key)
		if (uppercase && Instr(keys.alpha, Hotkey)){
			StringUpper, Hotkey,Hotkey
		}
	
		if (Instr("," . keys.specialKeys . ",", "," . Hotkey . ",")) {
			if (Hotkey == "^c") {
				Sleep, 1
			} else if (Hotkey == "^v") {
				Sleep, 250
				if (StrLen(Clipboard) <= 256) {
					typed .= Clipboard
				}
			} else if (Hotkey == "Left" || Hotkey == "Right") {
				Sleep, 1
			} else {
				typed := ""
				return
			}
		} else if Hotkey in Return,Tab,Space
		{
			typed .= effect[ Hotkey ]
		} else if (Hotkey == "BS"){
			; trim typed var if Backspace was pressed.
			StringTrimRight,typed,typed,1
			return
		} else if (RegExMatch(Hotkey, "Numpad(.+?)", numKey)) {
			if (numkey1 ~= "\d"){
				typed .= numkey1
			} else {
				typed .= effect[numKey1]
			}
		} else {
			typed .= Hotkey
		}
		
		matched := false
		for k,v in hotstrings
		{
			matchRegex := (v.mode == 1 ? "Oi)" : "")  . (v.mode == 3 ? RegExReplace(v.trigger, "\$$", "") : "\Q" . v.trigger . "\E") . "$"
			
			if (v.mode == 3){
				if (matchRegex ~= "^[^\s\)\(\\]+?\)"){
					matchRegex := "O" . matchRegex
				} else {
					matchRegex := "O)" . matchRegex
				}
			}
			; ToolTip, % typed
			if (RegExMatch(typed, matchRegex, local$)){
				matched := true
				if (v.cond != "" && IsFunc(v.cond)){
					; If hotstring has a condition function.
					A_LoopCond := Func(v.cond)
					if (A_LoopCond.MinParams >= 1){
						; If the function has atleast 1 parameters.
						A_LoopRetVal := A_LoopCond.(v.mode == 3 ? local$ : local$.Value(0))
					} else {
						A_LoopRetVal := A_LoopCond.()
					}
					if (!A_LoopRetVal){
						; If the function returns a non-true value.
						matched := false
						continue
					}
				}
				if (v.clearTrigger){
					;Delete the trigger
					SendInput % "{BS " . StrLen(local$.Value(0))  . "}"
				}
				if (IsLabel(v.label)){
					$ := v.mode == 3 ? local$ : local$.Value(0)
					gosub, % v.label
				} else if (IsFunc(v.label)){
					callbackFunc := Func(v.label)
					if (callbackFunc.MinParams >= 1){
						callbackFunc.(v.mode == 3 ? local$ : local$.Value(0))
					} else {
						callbackFunc.()
					}
				} else {
					toSend := v.label
				
					;Working out the backreferences
					Loop, % local$.Count()
						StringReplace, toSend,toSend,% "$" . A_Index,% local$.Value(A_index),All
					toSend := RegExReplace(toSend,"([!#\+\^\{\}])","{$1}") ;Escape modifiers
					SendInput,%toSend%
				}
				
			}
		}
		if (matched){
			typed := ""
		} else if (StrLen(typed) > 350){
			StringTrimLeft,typed,typed,200
		}
	} else {
		if (hotstrings.HasKey(trigger) && label == ""){
			; Removing a hotstring.
			hotstrings.remove(trigger)
		} else {
			; Add to hotstrings object.
			hotstrings[trigger] := {"trigger" : trigger, "label":label, "mode":mode, "clearTrigger" : clearTrigger, "cond": cond}
		}
		
	}
	return

	__hotstring:
	; This label is triggered every time a key is pressed.
	Hotstring("", "", "CALLBACK")
	return
}