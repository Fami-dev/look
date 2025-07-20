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

local keyUrl = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/climbandjumpv6.txt"
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
    Icon = "rbxassetid://110866274282768",
    Author = "Catch and Feed a Brainrot",
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
    Farming = Window:Tab({ Title = "Farming", Icon = "dollar-sign", ShowTabTitle = true }),
    Upgrade = Window:Tab({ Title = "Upgrade", Icon = "chevrons-up", ShowTabTitle = true }),
    Buy = Window:Tab({ Title = "Buy", Icon = "shopping-cart", ShowTabTitle = true }),
    Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true })
}

if not Tabs.Farming or not Tabs.Upgrade or not Tabs.Buy or not Tabs.Movement then
    warn("Failed to create one or more tabs.")
    return
end

local WalkSpeedSlider

local autoFarmState = {
    AutoCollectCash = false,
    AutoPumpFood = false,
    AutoClickFight = false,
    AutoUpgradeLasso = false,
    AutoUpgradeFarm1 = false,
    AutoUpgradeFarm2 = false,
    AutoUpgradeFarm3 = false,
    AutoUpgradeFarm4 = false,
    AutoBuyRelics = false,
    AutoBuyPotions = false,
    WalkSpeed = false,
    InfiniteJump = false,
    NoClip = false
}

do
    Tabs.Farming:Section({ Title = "Auto Collect Cash" })
    Tabs.Farming:Toggle({
        Title = "Auto Collect Cash",
        Value = false,
        Callback = function(value)
            autoFarmState.AutoCollectCash = value
            if value then
                task.spawn(function()
                    while autoFarmState.AutoCollectCash and player do
                        local char = player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local playerPlot = workspace.PlayerPlots:FindFirstChild(player.Name .. "_Plot")
                        
                        if hrp and playerPlot then
                            local originalCFrame = hrp.CFrame
                            for i = 1, 6 do
                                if not autoFarmState.AutoCollectCash then break end
                                local plot = playerPlot:FindFirstChild("Plot" .. i)
                                if plot then
                                    local plotPad = plot:FindFirstChild("Plot" .. i .. "Pad")
                                    if plotPad then
                                        local moneyCollect = plotPad:FindFirstChild("MoneyCollect")
                                        if moneyCollect then
                                            pcall(function()
                                                hrp.CFrame = CFrame.new(moneyCollect.Position)
                                                task.wait(0.05)
                                            end)
                                        end
                                    end
                                end
                            end
                            if hrp and hrp.Parent then
                                hrp.CFrame = originalCFrame
                            end
                        end
                        task.wait(30)
                    end
                end)
            end
        end
    })

    Tabs.Farming:Section({ Title = "Auto Pump Food" })
    Tabs.Farming:Toggle({
        Title = "Auto Pump Food",
        Desc = "You must be near the button to activate.",
        Value = false,
        Callback = function(value)
            autoFarmState.AutoPumpFood = value
            if value then
                task.spawn(function()
                    while autoFarmState.AutoPumpFood and player do
                        pcall(function()
                            local char = player.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local playerPlot = workspace.PlayerPlots:FindFirstChild(player.Name .. "_Plot")

                            if hrp and playerPlot then
                                local farm1Folder = playerPlot:FindFirstChild("Farm1Folder")
                                if farm1Folder then
                                    local button = farm1Folder:FindFirstChild("Button")
                                    if button then
                                        local clickPart = button:FindFirstChild("Click")
                                        if clickPart then
                                            local distance = (hrp.Position - clickPart.Position).Magnitude
                                            if distance <= 15 then
                                                local prompt = clickPart:FindFirstChildOfClass("ProximityPrompt")
                                                if prompt then
                                                    fireproximityprompt(prompt)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(0.2)
                    end
                end)
            end
        end
    })

    Tabs.Farming:Section({ Title = "Auto Fight" })
    Tabs.Farming:Toggle({
        Title = "Auto Click Fight",
        Value = false,
        Callback = function(value)
            autoFarmState.AutoClickFight = value
            if value then
                task.spawn(function()
                    while autoFarmState.AutoClickFight and player do
                        pcall(function()
                            local remote = replicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LassoBattle"):WaitForChild("Click")
                            remote:FireServer()
                        end)
                        task.wait(0.2)
                    end
                end)
            end
        end
    })

    Tabs.Farming:Section({ Title = "Brainrot Notifier" })
    local selectedRarities = {}
    Tabs.Farming:Dropdown({
        Title = "Notify on Rarity",
        Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical" },
        Multi = true,
        AllowNone = true,
        Callback = function(options)
            selectedRarities = options or {}
        end
    })

    task.spawn(function()
        local stampedeFolder = workspace:WaitForChild("StampedeCharacters")
        local notifiedCharacters = {}

        local function handleNewCharacter(character)
            if notifiedCharacters[character] then return end
            notifiedCharacters[character] = true

            task.spawn(function()
                local guiFrame
                local success, err = pcall(function()
                    guiFrame = character:WaitForChild("StampedeGui", 5):WaitForChild("Frame", 5)
                end)

                if not success or not guiFrame then return end

                local rarityLabel = guiFrame:FindFirstChild("Rarity")
                local nameLabel = guiFrame:FindFirstChild("Name")
                local moneyLabel = guiFrame:FindFirstChild("Money")

                if not (rarityLabel and nameLabel and moneyLabel) then return end

                local rarity = rarityLabel.Text
                local shouldNotify = false
                for _, selected in ipairs(selectedRarities) do
                    if rarity == selected then
                        shouldNotify = true
                        break
                    end
                end

                if shouldNotify then
                    local name = nameLabel.Text
                    local money = moneyLabel.Text
                    WindUI:Notify({
                        Title = "Brainrot Found: " .. name,
                        Content = "Rarity: " .. rarity .. "\nMoney: " .. money,
                        Icon = "bell",
                        Duration = 10
                    })
                end
            end)
        end

        stampedeFolder.ChildAdded:Connect(handleNewCharacter)
        stampedeFolder.ChildRemoved:Connect(function(character)
            if notifiedCharacters[character] then
                notifiedCharacters[character] = nil
            end
        end)
        for _, character in ipairs(stampedeFolder:GetChildren()) do
            handleNewCharacter(character)
        end
    end)
end

do
    Tabs.Upgrade:Section({ Title = "Auto Upgrade" })

    Tabs.Upgrade:Toggle({
        Title = "Auto Upgrade Lasso",
        Value = false,
        Callback = function(value)
            autoFarmState.AutoUpgradeLasso = value
            if value then
                task.spawn(function()
                    while autoFarmState.AutoUpgradeLasso and player do
                        pcall(function()
                            local remote = replicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LassoUpgrade")
                            remote:FireServer()
                        end)
                        task.wait(0.2)
                    end
                end)
            end
        end
    })

    local function createUpgradeToggle(title, farmId, stateKey)
        Tabs.Upgrade:Toggle({
            Title = title,
            Value = false,
            Callback = function(value)
                autoFarmState[stateKey] = value
                if value then
                    task.spawn(function()
                        while autoFarmState[stateKey] and player do
                            pcall(function()
                                local mainRemote = replicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BaseFarmUpgrade")
                                local mainArgs = {farmId}
                                mainRemote:FireServer(unpack(mainArgs))
                            end)

                            local specialUpgrades = {"MutationChance", "Cooldown", "Multiplier", "MutationRate"}
                            local specialRemote = replicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BaseSpecialUpgrade")

                            for _, upgradeType in ipairs(specialUpgrades) do
                                for level = 1, 10 do
                                    if not autoFarmState[stateKey] then break end
                                    pcall(function()
                                        local specialArgs = {farmId, upgradeType, level}
                                        specialRemote:FireServer(unpack(specialArgs))
                                    end)
                                    task.wait(0.1)
                                end
                                if not autoFarmState[stateKey] then break end
                            end
                        end
                    end)
                end
            end
        })
    end

    createUpgradeToggle("Auto Upgrade Food Pump", "Farm1", "AutoUpgradeFarm1")
    createUpgradeToggle("Auto Upgrade Plant Farm", "Farm2", "AutoUpgradeFarm2")
    createUpgradeToggle("Auto Upgrade Greenhouse", "Farm3", "AutoUpgradeFarm3")
    createUpgradeToggle("Auto Upgrade Golden Sprinkle", "Farm4", "AutoUpgradeFarm4")
end

do
    Tabs.Buy:Section({ Title = "Auto Buy Relics" })

    local relicDisplayNames = { "Champion Statue", "Peace Pond", "Sakura Blossom", "Honey Haven", "Legend Statue", "Ancient Prism", "Eternal Ember", "Chained Galaxy" }
    local relicInternalNames = {
        ["Champion Statue"] = "ChampionStatue",
        ["Peace Pond"] = "PeacePond",
        ["Sakura Blossom"] = "SakuraBlossom",
        ["Honey Haven"] = "HoneyHaven",
        ["Legend Statue"] = "LegendStatue",
        ["Ancient Prism"] = "AncientPrism",
        ["Eternal Ember"] = "EternalEmber",
        ["Chained Galaxy"] = "ChainedGalaxy"
    }
    local selectedRelics = {}

    Tabs.Buy:Dropdown({
        Title = "Select Relics to Buy",
        Values = relicDisplayNames,
        Multi = true,
        AllowNone = true,
        Callback = function(options)
            selectedRelics = options or {}
        end
    })

    Tabs.Buy:Toggle({
        Title = "Auto Buy Selected Relics",
        Value = false,
        Callback = function(value)
            autoFarmState.AutoBuyRelics = value
            if value then
                task.spawn(function()
                    while autoFarmState.AutoBuyRelics and player do
                        if #selectedRelics > 0 then
                            for _, relicDisplayName in ipairs(selectedRelics) do
                                if not autoFarmState.AutoBuyRelics then break end
                                local internalName = relicInternalNames[relicDisplayName]
                                if internalName then
                                    pcall(function()
                                        local remote = replicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PurchaseRelic")
                                        remote:FireServer(internalName)
                                    end)
                                end
                                task.wait(0.1)
                            end
                        else
                            task.wait(0.1)
                        end
                    end
                end)
            end
        end
    })

    Tabs.Buy:Section({ Title = "Auto Buy Potions" })

    local potionNames = { "Wet", "Lightning", "Bloodrot", "Glitch", "Rainbow" }
    local selectedPotions = {}

    Tabs.Buy:Dropdown({
        Title = "Select Potions to Buy",
        Values = potionNames,
        Multi = true,
        AllowNone = true,
        Callback = function(options)
            selectedPotions = options or {}
        end
    })

    Tabs.Buy:Toggle({
        Title = "Auto Buy Selected Potions",
        Value = false,
        Callback = function(value)
            autoFarmState.AutoBuyPotions = value
            if value then
                task.spawn(function()
                    while autoFarmState.AutoBuyPotions and player do
                        if #selectedPotions > 0 then
                            for _, potionName in ipairs(selectedPotions) do
                                if not autoFarmState.AutoBuyPotions then break end
                                pcall(function()
                                    local remote = replicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PurchasePotion")
                                    remote:FireServer(potionName)
                                end)
                                task.wait(0.1)
                            end
                        else
                            task.wait(0.1)
                        end
                    end
                end)
            end
        end
    })
end

do
    Tabs.Movement:Section({ Title = "Movement Exploits" })

    local WalkSpeedToggle
    WalkSpeedToggle = Tabs.Movement:Toggle({
        Title = "Enable WalkSpeed",
        Value = false,
        Callback = function(state)
            autoFarmState.WalkSpeed = state
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
            if autoFarmState.WalkSpeed and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = tonumber(value) or 16
            end
        end
    })

    Tabs.Movement:Toggle({
        Title = "Enable Infinite Jump",
        Value = false,
        Callback = function(v) autoFarmState.InfiniteJump = v end
    })
    local UserInputService = game:GetService("UserInputService")
    if UserInputService then
        UserInputService.JumpRequest:Connect(function()
            if autoFarmState.InfiniteJump and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    local NoClipToggle
    NoClipToggle = Tabs.Movement:Toggle({
        Title = "Enable No Clip",
        Value = false,
        Callback = function(state)
            autoFarmState.NoClip = state
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
            if autoFarmState.NoClip and player and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
    end)

    if player then
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if autoFarmState.WalkSpeed and humanoid then
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
        Content = "All features have been loaded.",
        Duration = 8,
        Icon = "check-circle"
    })
end
