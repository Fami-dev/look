local WindUI = loadstring(game:HttpGet("https://github.com/Fami-dev/WindUI/releases/download/1.7.0.0/main.txt"))()
if not WindUI then return end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
if not player or not replicatedStorage then return end

function gradient(text, startColor, endColor)
    if not text or not startColor or not endColor then return "" end
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

local keyUrl = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/climbandslide.txt"
local fetchedKey

local success, response = pcall(function()
    return game:HttpGet(keyUrl, true)
end)

if success and response and type(response) == "string" then
    fetchedKey = response:match("^%s*(.-)%s*$")
else
    warn("ArcvourHUB: Gagal mengambil kunci dari URL. Akses skrip mungkin gagal.", response)
    fetchedKey = "FAILED_TO_FETCH_KEY_" .. math.random(1000, 9999)
end

local Window = WindUI:CreateWindow({
    Title = gradient("ArcvourHUB", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
    Icon = "rbxassetid://90566677928169",
    Author = "Climb and Slide",
    Size = UDim2.fromOffset(500, 320),
    Folder = "ArcvourHUB_Config",
    Transparent = false,
    Theme = "Arcvour",
    ToggleKey = Enum.KeyCode.K,
    SideBarWidth = 160,
    KeySystem = {
        Key = fetchedKey,
        URL = "https://t.me/arcvourscript",
        Note = "Enter the key provided to access the script.",
        SaveKey = false
    }
})

if not Window then return end
Window:DisableTopbarButtons({"Close"})

local Tabs = {
    Pets = Window:Tab({ Title = "Pets", Icon = "paw-print", ShowTabTitle = true }),
    Coins = Window:Tab({ Title = "Coins", Icon = "coins", ShowTabTitle = true }),
    Trophy = Window:Tab({ Title = "Trophy", Icon = "trophy", ShowTabTitle = true }),
    Potions = Window:Tab({ Title = "Potions", Icon = "flask-conical", ShowTabTitle = true }),
    Stamina = Window:Tab({ Title = "Stamina", Icon = "battery-charging", ShowTabTitle = true }),
    Gamepass = Window:Tab({ Title = "Gamepass", Icon = "gem", ShowTabTitle = true }),
    Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true })
}

local featureState = {
    WalkSpeed = false,
    InfiniteJump = false,
    NoClip = false,
    AllGamepasses = false
}

do
    Tabs.Pets:Section({ Title = "Pet Settings" })

    Tabs.Pets:Input({
        Title = "Max Equip Pets",
        Placeholder = "Enter a number",
        Type = "Input",
        Callback = function(value)
            local amount = tonumber(value)
            if amount then
                pcall(function()
                    player.Stats.Gameplay.MaxEquipped.Value = amount
                    WindUI:Notify({ Title = "Success", Content = "Max Equip Pets set to " .. tostring(amount), Duration = 3, Icon = "check" })
                end)
            else
                WindUI:Notify({ Title = "Error", Content = "Invalid number entered.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })

    Tabs.Pets:Input({
        Title = "Max Storage",
        Placeholder = "Enter a number",
        Type = "Input",
        Callback = function(value)
            local amount = tonumber(value)
            if amount then
                pcall(function()
                    player.Stats.Gameplay.MaxStorages.Value = amount
                    WindUI:Notify({ Title = "Success", Content = "Max Storage set to " .. tostring(amount), Duration = 3, Icon = "check" })
                end)
            else
                WindUI:Notify({ Title = "Error", Content = "Invalid number entered.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })
    
    Tabs.Pets:Section({ Title = "Best Pets" })

    local function getTopPets()
        local petsData = {}
        local petsFolder = replicatedStorage:FindFirstChild("Pets_X_Coins")
        if not petsFolder then return {} end

        for _, petFolder in ipairs(petsFolder:GetChildren()) do
            local maxStat = petFolder:FindFirstChild("Max")
            if maxStat and maxStat:IsA("NumberValue") then
                table.insert(petsData, { name = petFolder.Name, max = maxStat.Value })
            end
        end

        table.sort(petsData, function(a, b)
            return a.max > b.max
        end)

        local topPets = {}
        for i = 1, math.min(10, #petsData) do
            table.insert(topPets, petsData[i])
        end
        return topPets
    end

    local topPets = getTopPets()

    for _, petInfo in ipairs(topPets) do
        local petDisplayName = petInfo.name:gsub("_", " ")
        Tabs.Pets:Button({
            Title = petDisplayName,
            Desc = "Power: " .. tostring(petInfo.max),
            Callback = function()
                pcall(function()
                    local args = { "Give_Pet", petInfo.name }
                    replicatedStorage:WaitForChild("R_Pets"):FireServer(unpack(args))
                    WindUI:Notify({ Title = "Success", Content = "Attempting to give " .. petDisplayName, Duration = 3, Icon = "check" })
                end)
            end
        })
    end
end

do
    Tabs.Coins:Section({ Title = "Currency" })
    
    Tabs.Coins:Input({
        Title = "Set Coins Amount",
        Placeholder = "Enter a number",
        Type = "Input",
        Callback = function(value)
            local amount = tonumber(value)
            if amount then
                pcall(function()
                    player.Stats.Gameplay.Money.Value = amount
                    WindUI:Notify({ Title = "Success", Content = "Coins set to " .. tostring(amount), Duration = 3, Icon = "check" })
                end)
            else
                WindUI:Notify({ Title = "Error", Content = "Invalid number entered.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })
end

do
    Tabs.Trophy:Section({ Title = "Trophies" })

    Tabs.Trophy:Input({
        Title = "Set Trophy Amount",
        Placeholder = "Enter a number",
        Type = "Input",
        Callback = function(value)
            local amount = tonumber(value)
            if amount then
                pcall(function()
                    player.Stats.Gameplay.Trophy.Value = amount
                    WindUI:Notify({ Title = "Success", Content = "Trophies set to " .. tostring(amount), Duration = 3, Icon = "check" })
                end)
            else
                WindUI:Notify({ Title = "Error", Content = "Invalid number entered.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })
end

do
    Tabs.Potions:Section({ Title = "Potion Amounts" })

    local function createPotionInput(potionName, potionId)
        Tabs.Potions:Input({
            Title = potionName,
            Placeholder = "Enter amount",
            Type = "Input",
            Callback = function(value)
                local amount = tonumber(value)
                if amount then
                    pcall(function()
                        player.Stats.Potions.UsePotions[potionId].Value = amount
                        WindUI:Notify({ Title = "Success", Content = potionName .. " set to " .. tostring(amount), Duration = 3, Icon = "check" })
                    end)
                else
                    WindUI:Notify({ Title = "Error", Content = "Invalid number for " .. potionName, Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end

    createPotionInput("Coins Potions", "P_Coins_1.5")
    createPotionInput("Speed Potions", "P_Speed_1.5")
    createPotionInput("Stamina Potions", "P_Stamina_1.5")
    createPotionInput("Trophy Potions", "P_Trophy_1.5")
end

do
    Tabs.Stamina:Section({ Title = "Stamina Settings" })

    Tabs.Stamina:Input({
        Title = "Set Max Stamina",
        Placeholder = "Enter a number",
        Type = "Input",
        Callback = function(value)
            local amount = tonumber(value)
            if amount then
                pcall(function()
                    player.Stats.Gameplay.MaxStamina.Value = amount
                    WindUI:Notify({ Title = "Success", Content = "Max Stamina set to " .. tostring(amount), Duration = 3, Icon = "check" })
                end)
            else
                WindUI:Notify({ Title = "Error", Content = "Invalid number entered.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })
end

do
    Tabs.Gamepass:Section({ Title = "GamePass Activation" })

    Tabs.Gamepass:Toggle({
        Title = "Enable All Gamepasses",
        Value = featureState.AllGamepasses,
        Callback = function(value)
            featureState.AllGamepasses = value
            pcall(function()
                local gamepasses = player.Stats.Gamepass
                gamepasses.MoreEquip.Value = value
                gamepasses.MoreStorages.Value = value
                gamepasses.SuperAuto.Value = value
                gamepasses.TripleHatch.Value = value
                gamepasses.VipRank.Value = value
                gamepasses.x2Coins.Value = value
                gamepasses.x2Speed.Value = value
                gamepasses.x2Trophy.Value = value
                
                local message = value and "All gamepasses have been activated." or "All gamepasses have been deactivated."
                WindUI:Notify({ Title = "GamePass", Content = message, Duration = 4, Icon = "check" })
            end)
        end
    })
end

do
    local WalkSpeedSlider
    
    Tabs.Movement:Section({ Title = "Movement Exploits" })

    local WalkSpeedToggle
    WalkSpeedToggle = Tabs.Movement:Toggle({
        Title = "Enable WalkSpeed",
        Value = false,
        Callback = function(state)
            featureState.WalkSpeed = state
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = state and (tonumber(WalkSpeedSlider.Value.Default) or 16) or 16
            end
        end
    })
    WalkSpeedSlider = Tabs.Movement:Slider({
        Title = "WalkSpeed Value",
        Value = { Min = 16, Max = 200, Default = 100 },
        Step = 1,
        Callback = function(value)
            if featureState.WalkSpeed and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = tonumber(value) or 16
            end
        end
    })

    Tabs.Movement:Toggle({
        Title = "Enable Infinite Jump",
        Value = false,
        Callback = function(v) featureState.InfiniteJump = v end
    })
    local UserInputService = game:GetService("UserInputService")
    if UserInputService then
        UserInputService.JumpRequest:Connect(function()
            if featureState.InfiniteJump and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    local NoClipToggle
    NoClipToggle = Tabs.Movement:Toggle({
        Title = "Enable No Clip",
        Value = false,
        Callback = function(state)
            featureState.NoClip = state
            if not state and player and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    })
    task.spawn(function()
        while task.wait(0.1) do
            if Window and Window.Destroyed then break end
            if featureState.NoClip and player and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
    end)

    if player then
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if featureState.WalkSpeed and humanoid then
                humanoid.WalkSpeed = tonumber(WalkSpeedSlider.Value.Default) or 16
            end
        end)
    end
end

local VirtualUser = game:GetService("VirtualUser")
if player and VirtualUser then
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

if Window then
    Window:SelectTab(1)
    WindUI:Notify({
        Title = "Arcvour Script Ready",
        Content = "All features have been loaded for Climb and Slide.",
        Duration = 8,
        Icon = "check-circle"
    })
end
