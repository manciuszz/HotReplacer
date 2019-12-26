# HotReplacer

A proof of concept script which allows to execute custom functions (i.e. replacing words on the fly) on any input fields (i.e web browser address bar, notepad, chat boxes etc..).

# Preview - Tested on AutoHotkey v1.1.28.00

![Preview](https://giant.gfycat.com/VainAbandonedHornshark.gif)

# Usage

At the moment, there are currently only three text functions (as I'd like to call it) implemented:
- to loop a template N times ***~loop(N, $variableName)***.
- to replace text inside your clipboard ***~replace("str1", "str2")***.
- to translate input text via Google Translate ***~translate("input text", "from_language", "to_language")***.

### Replace text function example:
```js
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sed risus pretium, feugiat nulla sit amet.
~replace("amet", "YOLO")
```
would result in
```js
Lorem ipsum dolor sit YOLO, consectetur adipiscing elit. Maecenas sed risus pretium, feugiat nulla sit YOLO.
```

The key here is typing **~replace(*"string_to_search_for"*, *"will_be_replaced_with_this"*)** on the fly.

*This function also accepts REGEX:*
```js
Lorem ipsum dolor sit am t, consectetur adipiscing elit. Maecenas sed risus pretium, feugiat nulla sit am t.
~replace(`am\st`, "YOLO")
```
would result in
```js
Lorem ipsum dolor sit YOLO, consectetur adipiscing elit. Maecenas sed risus pretium, feugiat nulla sit YOLO.
```
Notice that in order to use REGEX you have to encase your query in back-tic's like so ``` `my regex syntax` ```

### Loop text function example:
```hcl
$port2 = `8080`
$port = `$port2`
$type = `tcp`
$importantIP = `1.0.0.1/0`
$my_ips = `[0.0.0.0/0, $importantIP]`
$my_ports = `[$port, 9090]`
$template = `### tuple ### allow $type $my_ports 0.0.0.0/0 any $my_ips
-A ufw-user-input -p $type --dport $my_ports -j ACCEPT`

~loop(3, $template)
```
would result in
```hcl
### tuple ### allow tcp 8080 0.0.0.0/0 any 0.0.0.0/0
-A ufw-user-input -p tcp --dport 8080 -j ACCEPT
### tuple ### allow tcp 9090 0.0.0.0/0 any 1.0.0.1/0
-A ufw-user-input -p tcp --dport 9090 -j ACCEPT
### tuple ### allow tcp 8080 0.0.0.0/0 any 0.0.0.0/0
-A ufw-user-input -p tcp --dport 8080 -j ACCEPT
```

### Translate text function example:
```hcl
~translate("Hello world", "auto", "fr") ; would result in "Bonjour le monde"
~translate("Hello world", "fr") ; same as above, second parameter is default "auto" and would result in "Bonjour le monde"
```

Note: It should work with multi-line strings too!

# How it works

It uses enhanced [AHK Hotstrings](https://github.com/menixator/hotstring) to allow REGEX and Functions/Labels operations with hotstrings), [Clip()](https://github.com/berban/Clip) in an attempt to have more reliable clipboard operations, [Translate.ahk](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63835&p=293119&hilit=translate.ahk#p293119) to take advantage of Google Translate service and [AutoHotInterception](https://github.com/evilC/AutoHotInterception) libraries, to keep track of what the user is typing on a DRIVER LEVEL, because using [Hotkey API](https://www.autohotkey.com/docs/commands/Hotkey.htm) doesn't seem to work on all applications, such as *Opera Browser*.

# Why not just use built-in editor replacer feature?

Recently, I needed to edit a file where I had this template where one or two places needed to be changed, so I kinda wished I had the ABILITY TO TYPE the action, such as replace this and that without playing with the editors interface whatsoever. I felt that doing something like empowering simple text with the ability to execute functions would allow to do some cool stuff, besides making me a lot faster and more productive.

# TODO / Future IDEAS

- Implement variable recognition to translate text function
- 'Eval' text function that would evaluate AHK code dynamically to bring more power to the table?