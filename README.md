# HotReplacer

A proof of concept script which allows to execute custom functions (i.e. replacing words on the fly) on any input fields (i.e web browser address bar, notepad, chat boxes etc..).

# Preview

![Preview](https://giant.gfycat.com/VainAbandonedHornshark.gif)

# Usage

At the moment, there is currently only two text functions (as I'd like to call it) implemented:
- to loop a template N times ***~loop(N, $variableName)***.
- to replace text inside your clipboard ***~replace("str1", "str2")***.

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
$port = `8080`
$type = `tcp`
$my_ips = `[0.0.0.0/0, 1.0.0.1/0]`
$template = `### tuple ### allow $type $port 0.0.0.0/0 any $my_ips
-A ufw-user-input -p $type --dport $port -j ACCEPT`

~loop(2, $template)
```
would result in
```hcl
### tuple ### allow tcp 8080 0.0.0.0/0 any 0.0.0.0/0
-A ufw-user-input -p tcp --dport 8080 -j ACCEPT
### tuple ### allow tcp 8080 0.0.0.0/0 any 1.0.0.1/0
-A ufw-user-input -p tcp --dport 8080 -j ACCEPT
```

Note: It should work with multi-line strings too!

# How it works

It uses enhanced [AHK Hotstrings](https://github.com/menixator/hotstring) to allow REGEX and Functions/Labels operations with hotstrings), [Clip()](https://github.com/berban/Clip) in an attempt to have more reliable clipboard operations and [AutoHotInterception](https://github.com/evilC/AutoHotInterception) libraries, to keep track of what the user is typing on a DRIVER LEVEL, because using [Hotkey API](https://www.autohotkey.com/docs/commands/Hotkey.htm) doesn't seem to work on all applications, such as *Opera Browser*.

# Why not just use built-in editor replacer feature?

Recently, I needed to edit a file where I had this template where one or two places needed to be changed, so I kinda wished I had the ABILITY TO TYPE the action, such as replace this and that without playing with the editors interface whatsoever. I felt that doing something like empowering simple text with the ability to execute functions would allow to do some cool stuff, besides making me a lot faster and more productive.

# TODO / Future IDEAS

- On the fly text translation function