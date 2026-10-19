-- Regalia loader. Upload as loader.lua; each game's script lives in "<PlaceId>.lua".
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- PlaceId -> HUB file. Anime Mysterious' match place uses the lobby's file.
local scripts = {
    [117949143041402] = "117949143041402.lua", -- Anime Mysterious lobby
    [107610426295102] = "117949143041402.lua", -- Anime Mysterious match
}

local fileName = scripts[game.PlaceId]
if not fileName then
    print("[Regalia] Game not supported: " .. tostring(game.PlaceId))
    return
end

local BASE = "https://raw.githubusercontent.com/Byoel/Games/refs/heads/main/"
local env = (getgenv and getgenv()) or _G
if env.AMLoaderBusy then
    warn("[Regalia] The script is already loading.")
    return
end
env.AMLoaderBusy = true

local ok, err = pcall(function()
    local source = game:HttpGet(BASE .. fileName, true)
    assert(type(source) == "string" and #source > 0, "The script download was empty.")
    local scriptFunction, compileError = loadstring(source, "@" .. fileName)
    assert(scriptFunction, "Script could not compile: " .. tostring(compileError))
    scriptFunction()
end)

env.AMLoaderBusy = nil
if not ok then
    warn("[Regalia] Loader failed: " .. tostring(err))
end
