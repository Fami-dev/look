local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local proMgsRemote = replicatedStorage:WaitForChild("ProMgs"):WaitForChild("RemoteEvent")

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
WindUI:SetTheme("Arcvour")

local SUPABASE_URL = "https://hakurkwyniyhstypnsqp.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhha3Vya3d5bml5aHN0eXBuc3FwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzODMyOTQsImV4cCI6MjA2Nzk1OTI5NH0.j37uzHpjPFH_a3I4e4AnO8cpp-tTZjWBaTACsJC07g0"
local SUPABASE_TABLE_NAME = "kunci"
local KEY_LIST_URL = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/test.txt"
local KEY_SAVE_FILE = "arcvour_key.txt"

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

    local Window = WindUI:CreateWindow({
        Title = gradient("ArcvourHUB", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
        Icon = "rbxassetid://110866274282768",
        Author = "Climb And Jump Tower",
        Size = UDim2.fromOffset(500, 320),
        Folder = "ArcvourHUB_Config",
        Transparent = false,
        Theme = "Arcvour",
        ToggleKey = Enum.KeyCode.K,
        SideBarWidth = 160
    })

    Window:DisableTopbarButtons({"Close"})

    local Tabs = {
        Farming = Window:Tab({ Title = "Farming", Icon = "dollar-sign", ShowTabTitle = true }),
        Hatching = Window:Tab({ Title = "Hatching", Icon = "egg", ShowTabTitle = true }),
        Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true }),
        Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin", ShowTabTitle = true }),
        Visuals = Window:Tab({ Title = "Visuals", Icon = "eye", ShowTabTitle = true }),
        AntiAFK = Window:Tab({ Title = "Anti AFK", Icon = "shield", ShowTabTitle = true })
    }
    
    local coinAmount = nil
    local selectedMap = "Eiffel Tower"
    local towerCoordinates = {
        ["Eiffel Tower"] = Vector3.new(-4.5, 14406, -86.5),
        ["Empire State Building"] = Vector3.new(5000, 14408.5, -78),
        ["Oriental Pearl Tower"] = Vector3.new(10001, 14408, -58),
        ["Big Ben"] = Vector3.new(14997, 14408.5, -157),
        ["Obelisk"] = Vector3.new(20001, 14408, -108.5),
        ["Leaning Tower"] = Vector3.new(25000, 14010, -60.5),
        ["Burj Khalifa Tower"] = Vector3.new(30001, 14407, -107),
        ["Pixel World"] = Vector3.new(35000, 14409, -64),
        ["Tokyo Tower"] = Vector3.new(39999, 14407, -192)
    }
    local orderedTowerNames = {"Eiffel Tower", "Empire State Building", "Oriental Pearl Tower", "Big Ben", "Obelisk", "Leaning Tower", "Burj Khalifa Tower", "Pixel World", "Tokyo Tower"}
    local WalkSpeedSlider
    local farmDelayValue = 2
    
    local autoFarmState = {
        AutoCoins = false,
        AutoWins = false,
        AutoMagicToken = false,
        TeleportMode = false,
        AutoHatch = false,
        AntiAFK = false,
        WalkSpeed = false,
        InfiniteJump = false,
        NoClip = false
    }
    
    do
        Tabs.Farming:Section({ Title = "Auto Farm Coins" })
        Tabs.Farming:Paragraph({ Title = "Note", Desc = "A faster delay requires a lower height setting, while a slower delay allows for a greater height. Purchase better wings to increase your maximum height." })
    
        Tabs.Farming:Input({
            Title = "Height Amount",
            Placeholder = "Enter height",
            Callback = function(text)
                local num = tonumber(text)
                coinAmount = (num and num > 0) and num or nil
            end
        })
    
        Tabs.Farming:Slider({
            Title = "Auto Coins Delay (s)",
            Value = { Min = 1, Max = 15, Default = 2 },
            Step = 1,
            Callback = function(value)
                farmDelayValue = tonumber(value)
            end
        })
    
        local AutoCoinsToggle
        AutoCoinsToggle = Tabs.Farming:Toggle({
            Title = "Auto Coins",
            Desc = "Requires Height",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoCoins = value
                if value then
                    if coinAmount == nil then
                        coinAmount = 0
                    end
    
                    if not coinAmount or type(coinAmount) ~= "number" or coinAmount <= 0 then
                        WindUI:Notify({ Title = "Action Required", Content = "Please enter a valid height amount before starting.", Duration = 6, Icon = "alert-triangle" })
                        AutoCoinsToggle:SetValue(false)
                        autoFarmState.AutoCoins = false
                        return
                    end
    
                    WindUI:Notify({ Title = "Success", Content = "Auto farming main loop has started.", Duration = 5, Icon = "check" })
    
                    task.spawn(function()
                        local winsTokenTimer = 0
                        while autoFarmState.AutoCoins do
                            if capturedRandom1 and capturedRandom2 then
                                 pcall(function()
                                    local args1 = {
                                        "\232\181\183\232\183\179",
                                        capturedRandom1,
                                        coinAmount
                                    }
                                    proMgsRemote:FireServer(unpack(args1))
    
                                    local args2 = {
                                        "\232\144\189\229\156\176",
                                        capturedRandom2
                                    }
                                    proMgsRemote:FireServer(unpack(args2))
                                end)
                            else
                                WindUI:Notify({ Title = "Waiting...", Content = "Capturing game data. Please move your character to start.", Duration = 3, Icon = "loader" })
                                task.wait(1)
                            end
    
                            task.wait(farmDelayValue)
                            winsTokenTimer = winsTokenTimer + farmDelayValue
    
                            if not autoFarmState.AutoCoins then break end
    
                            if winsTokenTimer >= 15 then
                                if autoFarmState.AutoWins or autoFarmState.AutoMagicToken then
                                    if autoFarmState.TeleportMode then
                                        if player.Character and player.Character.HumanoidRootPart and towerCoordinates[selectedMap] then
                                            local rootPart = player.Character.HumanoidRootPart
                                            local originalCFrame = rootPart.CFrame
                                            local destinationCoords = towerCoordinates[selectedMap]
    
                                            task.wait(0.5)
                                            rootPart.CFrame = CFrame.new(destinationCoords)
                                            task.wait(1)
    
                                            if autoFarmState.AutoWins then pcall(function() game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182wins") end) end
                                            if autoFarmState.AutoMagicToken then pcall(function() game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182MagicToken") end) end
    
                                            task.wait(0.5)
                                            local intermediateCoords = Vector3.new(destinationCoords.X, destinationCoords.Y, 0)
                                            rootPart.CFrame = CFrame.new(intermediateCoords)
                                            task.wait(0.1)
                                            rootPart.CFrame = originalCFrame + Vector3.new(0, 5, 0)
                                        end
                                    else
                                        task.wait(1)
                                        if autoFarmState.AutoWins then pcall(function() game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182wins") end) end
                                        if autoFarmState.AutoMagicToken then pcall(function() game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182MagicToken") end) end
                                    end
                                end
                                winsTokenTimer = 0
                            end
                            task.wait(0.1)
                        end
                    end)
                end
            end
        })
    end
    
    do
        Tabs.Farming:Section({ Title = "Auto Farm Wins & Magic Token" })
        Tabs.Farming:Paragraph({ Title = "Note", Desc = "Auto Coins must be enabled for this to work. If you are not using Teleport Mode, you must be at the top of the tower. With Teleport Mode enabled, you can be anywhere." })
    
        Tabs.Farming:Toggle({ Title = "Auto Wins", Desc = "Requires Auto Coins", Value = false, Callback = function(v) autoFarmState.AutoWins = v end })
        Tabs.Farming:Toggle({ Title = "Auto Magic Token", Desc = "Requires Auto Coins", Value = false, Callback = function(v) autoFarmState.AutoMagicToken = v end })
    
        Tabs.Farming:Dropdown({
            Title = "Select Tower",
            Values = orderedTowerNames,
            Value = "Eiffel Tower",
            Callback = function(towerName) selectedMap = towerName end
        })
    
        Tabs.Farming:Toggle({
            Title = "Enable Teleport Mode",
            Desc = "Requires Auto Wins or Magic Token",
            Value = false,
            Callback = function(value)
                autoFarmState.TeleportMode = value
                if value then
                    WindUI:Notify({ Title = "Reminder", Content = "Teleport Mode activated. Please ensure you have selected the correct tower.", Duration = 6, Icon = "info" })
                end
            end
        })
    end
    
    do
        Tabs.Hatching:Section({ Title = "Auto Hatch Eggs" })
    
        local orderedEggNames = {"Egg 1 (Eiffel Tower)", "Egg 2 (Eiffel Tower)", "Egg 3 (Eiffel Tower)","Egg 1 (Empire State Bulding)", "Egg 2 (Empire State Bulding)", "Egg 3 (Empire State Bulding)","Egg 1 (Oriental Pearl Tower)", "Egg 2 (Oriental Pearl Tower)","Egg 1 (Big Ben)", "Egg 2 (Big Ben)","Egg 1 (Obelisk)", "Egg 2 (Obelisk)","Egg 1 (Leaning Tower)", "Egg 2 (Leaning Tower)","Egg 1 (Burj Khalifa Tower)", "Egg 2 (Burj Khalifa Tower)", "Egg 3 (Burj Khalifa Tower)","Egg 1 (Pixel World)", "Egg 2 (Pixel World)", "Egg 3 (Pixel World)","Egg 1 (Tokyo Tower)", "Egg 2 (Tokyo Tower)", "Egg 3 (Tokyo Tower)", "Egg 1 (Petronas Towers)", "Egg 2 (Petronas Towers)", "Egg 3 (Petronas Towers)"}
        local eggLookupTable = {["Egg 1 (Eiffel Tower)"]=7000001,["Egg 2 (Eiffel Tower)"]=7000002,["Egg 3 (Eiffel Tower)"]=7000003,["Egg 1 (Empire State Bulding)"]=7000004,["Egg 2 (Empire State Bulding)"]=7000005,["Egg 3 (Empire State Bulding)"]=7000006,["Egg 1 (Oriental Pearl Tower)"]=7000007,["Egg 2 (Oriental Pearl Tower)"]=7000008,["Egg 1 (Big Ben)"]=7000009,["Egg 2 (Big Ben)"]=7000010,["Egg 1 (Obelisk)"]=7000011,["Egg 2 (Obelisk)"]=7000012,["Egg 1 (Leaning Tower)"]=7000013,["Egg 2 (Leaning Tower)"]=7000014,["Egg 1 (Burj Khalifa Tower)"]=7000015,["Egg 2 (Burj Khalifa Tower)"]=7000016,["Egg 3 (Burj Khalifa Tower)"]=7000017,["Egg 1 (Pixel World)"]=7000018,["Egg 2 (Pixel World)"]=7000019,["Egg 3 (Pixel World)"]=7000020,["Egg 1 (Tokyo Tower)"]=7000021,["Egg 2 (Tokyo Tower)"]=7000022,["Egg 3 (Tokyo Tower)"]=7000023, ["Egg 1 (Petronas Towers)"]=7000026, ["Egg 2 (Petronas Towers)"]=7000027, ["Egg 3 (Petronas Towers)"]=7000028}
        local selectedEggID = eggLookupTable[orderedEggNames[1]]
        local hatchAmount = 1
    
        Tabs.Hatching:Dropdown({
            Title = "Select Egg",
            Values = orderedEggNames,
            Value = orderedEggNames[1],
            Callback = function(selectedEggName) selectedEggID = eggLookupTable[selectedEggName] end
        })
    
        Tabs.Hatching:Dropdown({
            Title = "Select Hatch Amount",
            Values = {"1x Hatch", "3x Hatch (Gamepass Required)", "10x Hatch (Gamepass Required)"},
            Value = "1x Hatch",
            Callback = function(selectedHatch)
                if selectedHatch == "1x Hatch" then hatchAmount = 1
                elseif selectedHatch == "3x Hatch (Gamepass Required)" then hatchAmount = 3
                elseif selectedHatch == "10x Hatch (Gamepass Required)" then hatchAmount = 10
                end
            end
        })
    
        local AutoHatchToggle
        AutoHatchToggle = Tabs.Hatching:Toggle({
            Title = "Auto Hatch",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoHatch = value
                if value then
                    if not selectedEggID or not hatchAmount then
                        WindUI:Notify({ Title = "Action Required", Content = "Please select an egg and a hatch amount first.", Duration = 6, Icon = "alert-triangle" })
                        AutoHatchToggle:SetValue(false)
                        autoFarmState.AutoHatch = false
                        return
                    end
                    WindUI:Notify({ Title = "Success", Content = "Auto Hatching has started.", Duration = 5, Icon = "check" })
                    task.spawn(function()
                        while autoFarmState.AutoHatch do
                            pcall(function()
                                game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\230\138\189\232\155\139\229\188\149\229\175\188\231\187\147\230\157\159")
                                game:GetService("ReplicatedStorage").Tool.DrawUp.Msg.DrawHero:InvokeServer(selectedEggID, hatchAmount)
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            end
        })
    end
    
    do
        Tabs.Movement:Section({ Title = "Climb Settings" })
        Tabs.Movement:Toggle({ Title = "Auto Climb", Value = false, Callback = function(state) player.Setting.isAutoOn.Value = state and 1 or 0 end })
        Tabs.Movement:Toggle({ Title = "Auto Super Climb", Value = false, Callback = function(state) player.Setting.isAutoCllect.Value = state and 1 or 0 end })
    
        Tabs.Movement:Section({ Title = "Movement Exploits" })
    
        local WalkSpeedToggle
        WalkSpeedToggle = Tabs.Movement:Toggle({
            Title = "Enable WalkSpeed",
            Value = false,
            Callback = function(state)
                autoFarmState.WalkSpeed = state
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = state and tonumber(WalkSpeedSlider:GetValue()) or 16
                end
            end
        })
        WalkSpeedSlider = Tabs.Movement:Slider({
            Title = "WalkSpeed Value",
            Value = { Min = 16, Max = 200, Default = 100 },
            Step = 1,
            Callback = function(value)
                if autoFarmState.WalkSpeed and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = tonumber(value)
                end
            end
        })
    
        Tabs.Movement:Toggle({
            Title = "Enable Infinite Jump",
            Value = false,
            Callback = function(v) autoFarmState.InfiniteJump = v end
        })
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if autoFarmState.InfiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    
        local NoClipToggle
        NoClipToggle = Tabs.Movement:Toggle({
            Title = "Enable No Clip",
            Value = false,
            Callback = function(state)
                autoFarmState.NoClip = state
                if not state and player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        })
        task.spawn(function()
            while task.wait(0.1) do
                if Window.Destroyed then break end
                if autoFarmState.NoClip and player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end
        end)
    
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            if autoFarmState.WalkSpeed then
                humanoid.WalkSpeed = tonumber(WalkSpeedSlider:GetValue())
            end
        end)
    end
    
    do
        Tabs.Teleport:Section({ Title = "Tower Locations" })
    
        local teleportLocations = {
            { Name = "Eiffel Tower", Coords = Vector3.new(3.8, 15, 43.2) },
            { Name = "Empire State Building", Coords = Vector3.new(4999.5, 15, 51.3) },
            { Name = "Oriental Pearl Tower", Coords = Vector3.new(10002, 15, 66.5) },
            { Name = "Big Ben", Coords = Vector3.new(14997, 15, 25.9) },
            { Name = "Obelisk", Coords = Vector3.new(20000, 15, 62.3) },
            { Name = "Leaning Tower", Coords = Vector3.new(25000, 15, 74.3) },
            { Name = "Burj Khalifa Tower", Coords = Vector3.new(30000, 15, 93) },
            { Name = "Pixel World", Coords = Vector3.new(35000, 15, 129.7) },
            { Name = "Tokyo Tower", Coords = Vector3.new(39998, 15, 20.3) }
        }
    
        for _, location in ipairs(teleportLocations) do
            Tabs.Teleport:Button({
                Title = location.Name,
                Callback = function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(location.Coords)
                        WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. location.Name, Duration = 3, Icon = "check" })
                    else
                        WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                    end
                end
            })
        end
    
        Tabs.Teleport:Section({ Title = "Other Locations" })
    
        Tabs.Teleport:Button({
            Title = "Titan",
            Callback = function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(10049, 15, 28.5)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to Titan", Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    
        Tabs.Teleport:Button({
            Title = "Enchant",
            Callback = function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(5019.9, 15, 33.7)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to Enchant", Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end
    
    do
        Tabs.Visuals:Section({ Title = "Display Settings" })
        Tabs.Visuals:Toggle({ Title = "Hide Pets", Value = false, Callback = function(state) player.Setting.ShowPets.Value = state and 0 or 1 end })
        Tabs.Visuals:Toggle({ Title = "Hide JumpPals", Value = false, Callback = function(state) player.Setting.ShowJumpPal.Value = state and 0 or 1 end })
    end
    
    do
        Tabs.AntiAFK:Section({ Title = "Anti AFK" })
    
        local idleConnection = nil
        local virtualUser = game:GetService("VirtualUser")
    
        Tabs.AntiAFK:Toggle({
            Title = "Enable Anti-AFK",
            Value = false,
            Callback = function(value)
                autoFarmState.AntiAFK = value
                if value then
                    if idleConnection then
                        idleConnection:Disconnect()
                    end
                    idleConnection = player.Idled:Connect(function()
                        virtualUser:CaptureController()
                        virtualUser:ClickButton2(Vector2.new())
                    end)
                else
                    if idleConnection then
                        idleConnection:Disconnect()
                        idleConnection = nil
                    end
                end
            end
        })
    end
    
    Window:SelectTab(1)
    WindUI:Notify({
        Title = "Arcvour Script Ready",
        Content = "All features have been loaded.",
        Duration = 8,
        Icon = "check-circle"
    })
end

local SUPABASE_API_URL = SUPABASE_URL .. "/rest/v1/" .. SUPABASE_TABLE_NAME

local function SupabaseRequest(method, url, body)
    local headers = {
        ["apikey"] = SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }
    if method == "POST" or method == "DELETE" then headers.Prefer = "return=representation" end
    local success, response = pcall(function() return HttpService:RequestAsync({Url = url, Method = method, Headers = headers, Body = body}) end)
    if success and response.Success then
        if response.Body and response.Body ~= "" then return HttpService:JSONDecode(response.Body) else return true end
    else
        return nil, response and response.Body or "Request failed"
    end
end

local function PurgeUser(userId)
    local deleteUrl = SUPABASE_API_URL .. "?user_id=eq." .. tostring(userId)
    SupabaseRequest("DELETE", deleteUrl)
    if isfile(KEY_SAVE_FILE) then
        deletefile(KEY_SAVE_FILE)
    end
end

local function ValidateKey(keyToValidate)
    WindUI:Notify({Title = "Verifying Key...", Content = "Please wait...", Duration = 3, Icon = "loader"})

    local success_get, all_keys_string = pcall(game.HttpGet, game, KEY_LIST_URL)
    if not success_get or not all_keys_string then
        return false, "Failed to fetch the master key list. Check your connection."
    end
    
    if not string.find(all_keys_string, keyToValidate, 1, true) then
        PurgeUser(player.UserId)
        return false, "The provided key is invalid or has been revoked. Your previous data (if any) has been cleared."
    end

    local keyCheckUrl = SUPABASE_API_URL .. "?key_value=eq." .. HttpService:UrlEncode(keyToValidate) .. "&select=*"
    local keyRecord = SupabaseRequest("GET", keyCheckUrl)
    if not keyRecord then return false, "Failed to contact validation server." end

    if #keyRecord > 0 then
        if keyRecord[1].user_id == tostring(player.UserId) then
            writefile(KEY_SAVE_FILE, keyToValidate)
            return true, "Welcome back! Key ownership verified."
        else
            return false, "This key is already claimed by another user."
        end
    else
        PurgeUser(player.UserId)
        
        local newRecordBody = HttpService:JSONEncode({key_value = keyToValidate, user_id = tostring(player.UserId), user_name = player.Name})
        local creationResponse = SupabaseRequest("POST", SUPABASE_API_URL, newRecordBody)
        if creationResponse then
            writefile(KEY_SAVE_FILE, keyToValidate)
            return true, "Key claimed successfully! Welcome."
        else
            return false, "Failed to claim the new key on the server."
        end
    end
end

local keyToUse = ArcvourKey
if not keyToUse and isfile(KEY_SAVE_FILE) then
    keyToUse = readfile(KEY_SAVE_FILE)
end

if not keyToUse or type(keyToUse) ~= "string" or keyToUse == "" then
    WindUI:Notify({Title = "Key Not Provided", Content = "Please provide your key via ArcvourKey = '...' to run the script.", Duration = 10, Icon = "alert-triangle"})
    return
end

local success, message = ValidateKey(keyToUse)

WindUI:Notify({Title = success and "Verification Successful" or "Verification Failed", Content = message, Duration = 8, Icon = success and "check-circle" or "alert-triangle"})

if success then
    InitializeMainScript()
end
