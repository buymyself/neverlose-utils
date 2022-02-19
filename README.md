# documentation
### To get started, simply download utils.lua into your nl folder.
### Example of usage:
```lua
local utils = require "nl/utils"
--ready to use.
 ```
## contains
### parameters:
- v [void]
- t [table]
> return [boolean] true|false

```lua
local foo = {
  a = 1,
  b = 2,
}

print(utils:contains(1, foo))
--true
print(utils:contains(3, foo))
--false
```

## numbertobool
### parameters:
- n [number] int 0-1
> return [boolean] true|false
```lua
print(utils:numbertobool(1))
--true
print(utils:numbertobool(0))
--false
```

## is_module_loaded
### parameters:
- m [string] module
> return [boolean] true|false

```lua
--for example i have client.lua module in my nl folder
print(utils:is_module_loaded("nl/client"))
--true
print(utils:is_module_loaded("nl/client.lua")) -- do not add .lua
--false
print(utils:is_module_loaded("nl/entities")) -- I dont have entities.lua module in the folder
---false
```
## printcolor
### parameters:
- r [number] int 0 - 255
- g [number] int 0 - 255
- b [number] int 0 - 255
- a [number] int 0 - 255
- ... [string]
```lua
utils:printcolor(255, 0, 0, 255, "string")
```
![image](https://cdn.discordapp.com/attachments/926558271236603987/944482617489752064/unknown.png)

## get_nearest_player
### parameters:
- enemy_only [boolean] true|false
> return [userdata]
```lua
print(utils:get_nearest_player(true):GetName())
--Bob
```

## get_all_teammates
> return [table] table of userdatas
```lua
local teammates = utils:get_all_teammates()
for _, teammate in pairs(teammates) do
    print("userdata = " .. tostring(teammate) .. " name = " .. teammate:GetName())
end
--[[
userdata = userdata: 0x477012d0 name = pred
userdata = userdata: 0x477012f0 name = Grant
userdata = userdata: 0x47701310 name = Duffy
userdata = userdata: 0x2457f130 name = Will
]]
```
## get_velocity
### parameters:
- entity [userdata]
> return velocity [number] float
```lua
local localplayer = EntityList.GetLocalPlayer()
print(utils:get_velocity(localplayer))
-- 0 <-- standing rn
```
## is_visible
### parameters:
- entity [userdata]
- hitbox [number] int
> return [boolean] true|false
```lua
local function draw()
    local players = EntityList.GetPlayers()
    local localplayer = EntityList.GetLocalPlayer()
    for _, v in pairs(players) do
        if v == localplayer then
            goto skip
        end
        local head = 0
        local playerhbcenter = v:GetHitboxCenter(head)
        local hbcenter2d = Render.WorldToScreen(playerhbcenter)
        local isvisible = utils:is_visible(v, head)
        local r, g, b = 240, 70, 70
        if isvisible then
            r, g, b = 70, 240, 70
        end
        Render.CircleFilled(Vector2.new(hbcenter2d.x, hbcenter2d.y), 8, 20, Color.RGBA(r, g, b, 255))
        ::skip::
    end
end
Cheat.RegisterCallback("draw", draw)
```
![image](https://cdn.discordapp.com/attachments/913755528809836545/944488542078402590/unknown.png)

## extrapolate
### parameters:
- entity [number]
- tick [number]
> return [userdata] vector3
```lua
local localplayer = EntityList.GetLocalPlayer()
local position = localplayer:GetProp("m_vecOrigin")
local extrapolated = utils:extrapolate(localplayer, 1)
--position: -45.610904693604 1752.3875732422 1.03125 | extrapolated: -49.103141784668 1753.75390625 1.03125
```

## play_sound
### parameters:
- path [string]
- volume [number] int 0 - 1
```lua
utils:play_sound("buttons/switch_press_arena_02", 1)
```

## draw_text_outline
### parameters:
- x [number] vector2
- y [number] vector2
- r [number] int 0 - 255 red
- g [number] int 0 - 255 green
- b [number] int 0 - 255 blue
- a [number] int 0 - 255 alpha
- fs [number] int font size
- f [userdata] font
- c [boolean] true|false centered
- ... [string]
```lua
local FONT_CALIBRI = Render.InitFont("calibri", 18, {"b"})
local function draw()
    utils:draw_text_outline(1000, 500, 255, 255, 255, 255, 18, FONT_CALIBRI, false, "Hello World!")
end
Cheat.RegisterCallback("draw", draw)
```
![image](https://cdn.discordapp.com/attachments/913755528809836545/944494085341839401/unknown.png)

## vtable_entry
### parameters:
- instance [void]
- i [number] int
- ct [string] ctype

## vtable_bind
### parameters:
- instance [void]
- i [number] int
- ct [string] ctype

## vtable_thunk
### parameters:
- i [number] int
- ct [string] ctype

## **Attention!**
###### **Please do not sell this or claim this script as yours.** 
###### @pred14 / pred#2448
