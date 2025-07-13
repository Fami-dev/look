-- DIUBAH: Pindahkan WindUI loadstring ke atas agar bisa digunakan segera
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local proMgsRemote = replicatedStorage:WaitForChild("ProMgs"):WaitForChild("RemoteEvent")

-- DIUBAH: Pengaturan tema sekarang ada di sini, di bagian atas skrip
-- Ini memastikan semua notifikasi, termasuk notifikasi verifikasi, menggunakan tema kustom Anda.
WindUI:AddTheme({
    Name = "Arcvour",
    Accent = "#4B2D82",
    Dialog = "#1E142D",
    Outline = "#46375A",
    Text = "#E5DCEA",
    Placeholder = "#A898C2",
    Background = "#221539",
    Button = "#8C46FF",
    Icon = "#A898C2"
})
WindUI:SetTheme("Arcvour") -- Langsung aktifkan temanya

-- KONFIGURASI ANDA
local SUPABASE_URL = "https://hakurkwyniyhstypnsqp.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhha3Vya3d5bml5aHN0eXBuc3FwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzODMyOTQsImV4cCI6MjA2Nzk1OTI5NH0.j37uzHpjPFH_a3I4e4AnO8cpp-tTZjWBaTACsJC07g0"
local SUPABASE_TABLE_NAME = "kunci"
local KEY_LIST_URL = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/test.txt"

-- FUNGSI UTAMA (SEMUA FITUR UI ANDA ADA DI SINI)
local function InitializeMainScript()
    local capturedRandom1 = nil
    local capturedRandom2 = nil

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if self == proMgsRemote and method == "FireServer" and args[1] then
            if args[1] == "\232\181\183\232\183\179" then
                capturedRandom1 = args[2]
            elseif args[1] == "\232\144\189\229\156\176" then
                capturedRandom2 = args[2]
            end
        end
        
        return oldNamecall(self, ...)
    end)

    function gradient(text, startColor, endColor)
        local result = ""
        local length = #text
        for i = 1, length do
            local t = (i - 1) / math.max(length - 1, 1)
            local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
            local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
            local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
            local char = text:sub(i, i)
            result = result .. "<font color=\"rgb(" .. r .. ", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
        end
        return result
    end

    -- Kode AddTheme dipindahkan ke atas
    -- WindUI:AddTheme({...})

    local Window = WindUI:CreateWindow({
        Title = gradient("ArcvourHUB", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
        Icon = "rbxassetid://110866274282768",
        Author = "Climb And Jump Tower",
        Size = UDim2.fromOffset(500, 320),
        Folder = "ArcvourHUB_Config",
        Transparent = false,
        Theme = "Arcvour", -- Ini tetap penting untuk window utama
        ToggleKey = Enum.KeyCode.K,
        SideBarWidth = 160
    })

    Window:DisableTopbarButtons({"Close"})

    -- KODE UI DARI script4.txt DITEMPELKAN DI SINI
    local Tabs = {
        Farming = Window:Tab({ Title = "Farming", Icon = "dollar-sign", ShowTabTitle = true }),
        Hatching = Window:Tab({ Title = "Hatching", Icon = "egg", ShowTabTitle = true }),
        Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true }),
        Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin", ShowTabTitle = true }),
        Visuals = Window:Tab({ Title = "Visuals", Icon = "eye", ShowTabTitle = true }),
        AntiAFK = Window:Tab({ Title = "Anti Afk", Icon = "shield", ShowTabTitle = true })
    }
    
    -- ... (Sisa kode UI Anda tetap di sini)
    
    Window:SelectTab(1)
    WindUI:Notify({
        Title = "Arcvour Script Ready",
        Content = "All features have been loaded.",
        Duration = 8,
        Icon = "check-circle"
    })
end

-- FUNGSI VALIDASI
local SUPABASE_API_URL = SUPABASE_URL .. "/rest/v1/" .. SUPABASE_TABLE_NAME

local function SupabaseRequest(method, url, body)
    local headers = {
        ["apikey"] = SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }
    
    if method == "POST" then
        headers.Prefer = "return=representation"
    end
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({Url = url, Method = method, Headers = headers, Body = body})
    end)
    
    if success and response.Success then
        if response.Body and response.Body ~= "" then
            return HttpService:JSONDecode(response.Body)
        else
            return true
        end
    else
        return nil, response and response.Body or "Request failed"
    end
end

local function ProcessKey(key)
    WindUI:Notify({Title = "Memverifikasi Kunci...", Content = "Harap tunggu sebentar.", Duration = 3, Icon = "loader"})

    local success_get, all_keys_string = pcall(game.HttpGet, game, KEY_LIST_URL)
    if not success_get or not all_keys_string or not all_keys_string:find(key) then
        return false, "Kunci tidak terdaftar atau tidak valid."
    end

    local filterUrl = SUPABASE_API_URL .. "?key_value=eq." .. HttpService:UrlEncode(key) .. "&select=*"
    local existingRecord, err = SupabaseRequest("GET", filterUrl)
    
    if not existingRecord then
        return false, "Gagal menghubungi server validasi. Coba lagi nanti."
    end

    if type(existingRecord) == "table" and #existingRecord > 0 then
        local record = existingRecord[1]
        if record.user_id == tostring(player.UserId) then
            return true, "Selamat datang kembali! Kepemilikan kunci terverifikasi."
        else
            return false, "Kunci ini telah digunakan oleh pengguna lain: " .. (record.user_name or "Unknown")
        end
    else
        local newRecordBody = HttpService:JSONEncode({
            key_value = key,
            user_id = tostring(player.UserId),
            user_name = player.Name
        })
        
        local creationResponse, creationErr = SupabaseRequest("POST", SUPABASE_API_URL, newRecordBody)
        if creationResponse then
            return true, "Kunci berhasil diklaim! Selamat datang."
        else
            return false, "Gagal mengklaim kunci di server. " .. tostring(creationErr)
        end
    end
end

-- ALUR EKSEKUSI UTAMA
local userKey = ArcvourKey

if not userKey or type(userKey) ~= "string" or userKey == "" then
    WindUI:Notify({
        Title = "Gagal Memuat Skrip",
        Content = "Kunci tidak ditemukan. Harap sediakan kunci di atas loadstring.",
        Duration = 10,
        Icon = "alert-triangle"
    })
    return
end

local success, message = ProcessKey(userKey)

WindUI:Notify({
    Title = success and "Verifikasi Berhasil" or "Verifikasi Gagal",
    Content = message,
    Duration = 8,
    Icon = success and "check-circle" or "alert-triangle"
})

if success then
    InitializeMainScript()
end
