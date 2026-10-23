-- Minecraft Elytra loader
local MainScriptUrl = "https://raw.githubusercontent.com/newbutif12/Elytra/main/Elytra.lua"
local AssetImageUrl = "https://raw.githubusercontent.com/newbutif12/Elytra/main/Assets.png"
-- PNG resource decoding is not implemented in this version.
local source = game:HttpGet(MainScriptUrl)
assert(type(loadstring) == "function", "Executor does not support loadstring")
local fn, err = loadstring(source)
assert(fn, err)
return fn()
