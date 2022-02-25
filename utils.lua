--[[
    utils for neverlose
    [mainly for developers]

    @author pred#2448 / pred14
]]

local ffi = require "ffi"
local utils = {}

ffi.cdef[[
    typedef unsigned char BYTE;
    typedef void *PVOID;
    typedef PVOID HMODULE;
    typedef const char *LPCSTR;
    typedef int *FARPROC;
    
    HMODULE GetModuleHandleA(
        LPCSTR lpModuleName
    );
    
    FARPROC GetProcAddress(
        HMODULE hModule,
        LPCSTR  lpProcName
    );
    
    typedef struct{
        BYTE r, g, b, a;
    } Color;
    
    typedef void(__cdecl *ColorMsgFn)(Color&, const char*);
]]

local colorprint = function(label, r, g, b, a)
    local ConColorMsg = ffi.cast("ColorMsgFn", ffi.C.GetProcAddress(ffi.C.GetModuleHandleA("tier0.dll"), "?ConColorMsg@@YAXABVColor@@PBDZZ"))
    
    local col = ffi.new("Color")
    col.r = r
    col.g = g
    col.b = b
    col.a = a

    ConColorMsg(col, label)
end

---Checks if a value is in a table
---@param v void
---@param t table
---@return boolean
function utils:contains(v, t)
    if type(t) ~= "table" then 
        error("[utils] Invalid arguments. Expected table.")
    end
    for _, value in pairs(t) do
        if value == v then
            return true
        end
    end
    return false
end

---Check if a module missing or not
---@param m string module [path]
---@return boolean
function utils:is_module_loaded(m)
    if type(m) ~= "string" then
        error("[utils] Invalid arguments. Expected string.")
    end
    for _, searcher in pairs(package.loaders) do
        local module = searcher(m)
        if type(module) == "function" then
            return true
        end
    end
    return false
end

---Turn a number to boolean
---@param n number
---@return boolean
function utils:numbertobool(n)
    if type(n) ~= "number" then
        error("[utils] Invalid arguments. Expected number.")
    end
    local truefalse = {
        [0] = false,
        [1] = true,
    }
    return truefalse[n]
end

---Print colored message
---@param r number 0-255 int
---@param g number 0-255 int
---@param b number 0-255 int
---@param a number 0-255 int
---@param ... string
function utils:printcolor(r, g, b, a, ...)
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(a) ~= "number" then
        error("[utils] Invalid arguments. Expected number.")
    end
    if r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255 or a < 0 or a > 255 then
        error("[utils] Invalid arguments. Expected number between 0 and 255.")
    end
    local args = {...}
    for i, v in pairs(args) do
        if type(v) ~= "string" then
            error("[utils] Invalid arguments. Expected string.")
        end
        colorprint(v, r, g, b, a)
    end
end

---Clamp a number between min and max
---@param n number
---@param min number
---@param max number
---@return number
function utils:clamp(n, min, max)
    if n < min then
        return min
    elseif n > max then
        return max
    else
        return n
    end
end 

---Linear interpolation from start to end
---@param n number
---@param a number
---@param b number
---@return number
function utils:lerp(n, a, b)
    if type(n) ~= "number" or type(a) ~= "number" or type(b) ~= "number" then
        error("[utils] Invalid arguments. Expected number.")
    end
    return a + (b - a) * n
end

---Draw a text with outline
---@param x number
---@param y number
---@param r number 0 - 255
---@param g number 0 - 255
---@param b number 0 - 255
---@param a number 0 - 255
---@param fontsize number
---@param font userdata
---@param centered boolean
---@param ... string
function utils:draw_text_outline(x, y, r, g, b, a, fontsize, font, centered, ...)
    Render.Text(..., Vector2.new(x + 1, y + 1), Color.RGBA(0, 0, 0, a), fontsize, font, false, centered)
    Render.Text(..., Vector2.new(x, y), Color.RGBA(r, g, b, a), fontsize, font, false, centered)
end

---Draw a multicolored text
---@author: Invalidcode | invalidcode232
---@param x number
---@param y number
---@param centered boolean
---@param spacing number
---@param fontsize number
---@param font userdata
---@param data table
function utils:mutlicolored_text(x, y, centered, spacing, fontsize, font, data)
    local total_width = 0
    local used_width = 0
    if centered then
        for _, v in pairs(data) do
            local text_width = Render.CalcTextSize(v.text, fontsize, font).x
            total_width = total_width + text_width + spacing
        end
    end
    for _, v in pairs(data) do
        local text = v.text
        local clr = v.clr

        local text_width = Render.CalcTextSize(text, fontsize, font).x
        local cur_x = centered and (x - total_width / 2 + used_width) or x + used_width

        Render.Text(text, Vector2.new(cur_x, y), Color.RGBA(clr[1], clr[2], clr[3], clr[4]), fontsize, font)
        used_width = used_width + text_width + spacing
    end
end

---Change alpha from 0 to 1
---@param speed number
---@return float
function utils:alpha_anim(speed)
    return math.sin(math.abs(-math.pi + (globals.curtime() * speed) % (math.pi * 2)))
end

---Get distance between 2 entity
---@param entity1 userdata
---@param entity2 userdata
---@return number float
function utils:get_distance(entity1, entity2)
    local m_vecOrigin_1 = entity1:GetProp("m_vecOrigin")
    local m_vecOrigin_2 = entity2:GetProp("m_vecOrigin")
    return m_vecOrigin_1:DistTo(m_vecOrigin2)
end

---Plays sound
---@param path string
---@param volume number 0-1 float
function utils:play_sound(path, volume)
    if type(path) ~= "string" or type(volume) ~= "number" or path == nil or path == nil then
        error("[utils] Invalid arguments. Expected string and number.")
    end
    EngineClient.ExecuteClientCmd("playvol " .. path .. " " .. volume)
end

---Check if the entity is onground
---@param entity userdata
---@return boolean
function utils:is_onground(entity)
    local m_fFlags = entity:GetProp("DT_BasePlayer", "m_fFlags")
    return bit.band(m_fFlags, bit.lshift(1, 0)) == 1
end

---Check if the entity is inair
---@param entity userdata
---@return boolean
function utils:is_inair(entity)
    local m_fFlags = entity:GetProp("DT_BasePlayer", "m_fFlags")
    return bit.band(m_fFlags, bit.lshift(1, 0)) ~= 1
end

---Check if the entity is ducking
---@param entity userdata
---@return boolean
function utils:is_ducking(entity)
    local m_fFlags = entity:GetProp("DT_BasePlayer", "m_fFlags")
    return bit.band(m_fFlags,  bit.lshift(1, 1)) == 1
end

---Gets extrapolated position
---@param entity userdata
---@param hitbox number
---@param tick number
---@return userdata vector3
function utils:extrapolate(entity, tick)
    if type(entity) ~= "userdata" or type(tick) ~= "number" then
        error("[utils] Invalid arguments. Expected usedata and number.")
    end
    local m_vecVelocity = entity:GetProp("m_vecVelocity")
    local extrapolated_pos = entity:GetProp("m_vecOrigin")

    extrapolated_pos = extrapolated_pos + (m_vecVelocity * (GlobalVars.interval_per_tick * tick))

    return extrapolated_pos
end

---Check if you can shoot the entity.
---@param entity userdata
---@param hitbox number int
---@return boolean
function utils:is_shootable(entity, hitbox)
    if type(entity) ~= "userdata" or type(hitbox) ~= "number" then
        error("[utils] Invalid arguments. Expected number.")
    end
    if entity == nil then
        return false
    end
    local localplayer = EntityList.GetLocalPlayer()
    local eye_pos = localplayer:GetEyePosition()
    local entity_head_pos = entity:GetHitboxCenter(hitbox)
    local traced = EngineTrace.TraceRay(eye_pos, entity_head_pos, localplayer, 0x000000FF)
    return traced.fraction == 1
end

---Get entity's velocity
---@param entity userdata
---@return number float
function utils:get_velocity(entity)
    if type(entity) ~= "userdata" then
        error("[utils] Invalid arguments. Expected usedata.")
    end
    if entity == nil then
        return 0
    end
    local m_vecVelocity = entity:GetProp("m_vecVelocity")
    return m_vecVelocity:Length2D()
end

---Get nearest player
---@param enemy_only boolean
---@return userdata
function utils:get_nearest_player(enemy_only)
    local players = EntityList.GetPlayers()
    local localplayer = EntityList.GetLocalPlayer()
    local localplayer_pos = localplayer:GetProp("m_vecOrigin")
    local max_dist = 999999
    local nearest_player = nil

    for i, v  in pairs(players) do
        local player_vec = v:GetProp("m_vecOrigin")
        if v == localplayer or v == nil or not v:IsAlive() or v:IsTeamMate() == enemy_only then
            goto skip
        end
        local dist = (player_vec - localplayer_pos):Length()
        if dist < max_dist then
            max_dist = dist
            nearest_player = v
        end
        ::skip::
    end
    return nearest_player
end

---Get all teammates
---@return table userdata
function utils:get_all_teammates()
    local players = EntityList.GetPlayers()
    local teammates = {}
    for _, player in pairs(players) do
        if player:IsTeamMate() then
            table.insert(teammates, player)
        end
    end
    return teammates
end

---@param instance void
---@param i number int
---@param ct string
---@return void
function utils:vtable_entry(instance, i, ct)
    return ffi.cast(ct, ffi.cast(ffi.typeof("void***"), instance)[0][i])
end

---@param instance void
---@param i number int
---@param ct string
---@return void
function utils:vtable_bind(instance, i, ct)
    local t = ffi.typeof(ct)
    local fnptr = self:vtable_entry(instance, i, t)
    return function(...)
        return fnptr(instance, ...)
    end
end

---@param i number int
---@param ct string
---@return void
function utils:vtable_thunk(i, ct)
    local t = ffi.typeof(ct)
    return function(instance, ...)
        return self:vtable_entry(instance, i, t)(instance, ...)
    end
end

return utils
