local gameScripts = {
    [123921593837160] = "https://look-pearl.vercel.app/scripts/CAJT.lua",
    [121864768012064] = "https://look-pearl.vercel.app/scripts/FI.lua",
    [89343390950953] = "https://look-pearl.vercel.app/scripts/MSB.lua",
    [110931811137535] = "https://look-pearl.vercel.app/scripts/CAFAB.lua",
    [129827112113663] = "https://look-pearl.vercel.app/scripts/PROSPEC.lua"
}

local scriptUrl = gameScripts[game.PlaceId]

if scriptUrl then
    pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
end
