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

---Fetches all teammates
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

---Check if a module missing or not
---@param m string module [path]
---@return boolean
function utils:is_module_exists(m)
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

---Plays sound
---@param path string
---@param volume number 0-1 float
function utils:play_sound(path, volume)
    if type(path) ~= "string" or type(volume) ~= "number" or path == nil or path == nil then
        error("[utils] Invalid arguments. Expected string and number.")
    end
    EngineClient.ExecuteClientCmd("playvol " .. path .. " " .. volume)
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

---Get entity is visible or not
---@param entity userdata
---@param hitbox number int
---@return boolean
function utils:is_visible(entity, hitbox)
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