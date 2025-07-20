local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local player = game.Players.LocalPlayer
local PathfindingService = game:GetService("PathfindingService")
local virtualUser = game:GetService("VirtualUser")
local teleports = game:GetService("TeleportService")
local http = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)

if player and virtualUser then
    player.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end

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

local keyUrl = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/singingbrainrotkey.txt"
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
    Author = "My Singing Brainrot",
    Size = UDim2.fromOffset(500, 360),
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

Window:DisableTopbarButtons({
    "Close"
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "dollar-sign", ShowTabTitle = true }),
    BuyEgg = Window:Tab({ Title = "Buy Egg", Icon = "shopping-cart", ShowTabTitle = true }),
    Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true })
}

local farmState = {
    AutoCollectCash = false,
    AutoHatchEgg = false,
    AutoBuyEggEnabled = false,
    SelectedEggNames = {},
    SelectedEggFilters = {}
}

local movementState = {
    WalkSpeed = false,
    InfiniteJump = false,
    NoClip = false
}

local purchaseCooldownList = {}
local hatchCoroutine = nil
local collectCoroutine = nil
local buyCoroutine = nil

function findMyPlot()
    local plotsFolder = workspace:FindFirstChild("Main") and workspace.Main:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local plotBillboard = plot:FindFirstChild("PlotBillboard")
        if plotBillboard then
            local plotSign = plotBillboard:FindFirstChild("PlotSign")
            if plotSign then
                local frame = plotSign:FindFirstChild("Frame")
                if frame then
                    local playerNameLabel = frame:FindFirstChild("PlayerName")
                    if playerNameLabel and playerNameLabel:IsA("TextLabel") and playerNameLabel.ContentText == "Your Plot" then
                        return plot
                    end
                end
            end
        end
    end
    return nil
end

function findPromptInDescendants(instance)
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            return descendant
        end
    end
    return nil
end

function parseCost(costString)
    if type(costString) ~= "string" then return nil end
    local cleanedString = costString:gsub("[$,]", "")
    return tonumber(cleanedString)
end

function HatchLoop()
    while farmState.AutoHatchEgg do
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not (character and rootPart) then task.wait(1); continue end

        local myPlot = findMyPlot()
        if not myPlot then task.wait(1); continue end
        
        local itemsFolder = myPlot:FindFirstChild("Items")
        if not itemsFolder then task.wait(1); continue end
        
        local readyToHatchQueue = {}
        for _, item in ipairs(itemsFolder:GetChildren()) do
            if string.match(item.Name, "^Egg") then
                local config = item:FindFirstChild("Configuration")
                if config and config:GetAttribute("timeRemaining") ~= nil and tonumber(config:GetAttribute("timeRemaining")) <= 0 then
                    table.insert(readyToHatchQueue, item)
                end
            end
        end
        
        if #readyToHatchQueue > 0 then
            local originalCFrame = rootPart.CFrame
            for _, eggToHatch in ipairs(readyToHatchQueue) do
                if eggToHatch and eggToHatch.Parent then
                    local centerPart = eggToHatch:FindFirstChild("CENTER")
                    local prompt = findPromptInDescendants(eggToHatch)
                    if centerPart and prompt then
                        rootPart.CFrame = CFrame.new(centerPart.Position + Vector3.new(0, 3, 0))
                        task.wait()
                        fireproximityprompt(prompt)
                    end
                end
            end
            rootPart.CFrame = originalCFrame
        end
        task.wait(1)
    end
end

function CollectLoop()
    while farmState.AutoCollectCash do
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not (character and rootPart) then task.wait(10); continue end

        local myPlot = findMyPlot()
        if not myPlot then task.wait(10); continue end

        local itemsFolder = myPlot:FindFirstChild("Items")
        if itemsFolder then
            local collectibles = {}
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if not string.match(item.Name, "^Egg") and item:FindFirstChild("HITPART") then
                    table.insert(collectibles, item)
                end
            end
            
            if #collectibles > 0 then
                for _, item in ipairs(collectibles) do
                    if item and item.Parent then
                        local hitPart = item:FindFirstChild("HITPART")
                        if hitPart and hitPart.Parent then
                            firetouchinterest(rootPart, hitPart, 0)
                            firetouchinterest(rootPart, hitPart, 1)
                        end
                    end
                end
            end
        end
        task.wait(10)
    end
end

function isTargetEgg(egg, eggNames, eggFilters)
    local billboard = egg:FindFirstChild("Billboard")
    if not billboard then return false end

    local itemNameLabel = billboard:FindFirstChild("ItemName")
    if not itemNameLabel then return false end

    local eggName = itemNameLabel.ContentText
    if #eggNames > 0 and not table.find(eggNames, eggName) then
        return false
    end

    if #eggFilters == 0 then return true end

    local isGolden = billboard:FindFirstChild("Golden")
    local isDiamond = billboard:FindFirstChild("Diamond")
    local isNormal = not isGolden and not isDiamond

    local allowedNormal = table.find(eggFilters, "Normal")
    local allowedGolden = table.find(eggFilters, "Golden")
    local allowedDiamond = table.find(eggFilters, "Diamond")

    if (isNormal and allowedNormal) or (isGolden and allowedGolden) or (isDiamond and allowedDiamond) then
        return true
    end

    return false
end

function BuyLoop()
    local notifiedAboutEmptyFilters = false
    while farmState.AutoBuyEggEnabled do
        if #farmState.SelectedEggNames == 0 and #farmState.SelectedEggFilters == 0 then
            if not notifiedAboutEmptyFilters then
                WindUI:Notify({ Title = "Auto Buy Menunggu", Content = "Pilih setidaknya satu nama telur atau filter untuk memulai.", Duration = 6, Icon = "info"})
                notifiedAboutEmptyFilters = true
            end
            task.wait(1)
            continue
        end
        notifiedAboutEmptyFilters = false

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not (character and rootPart) then task.wait(1); continue end
        
        local myPlot = findMyPlot()
        if not myPlot then task.wait(1); continue end

        local eggsFolder = myPlot:FindFirstChild("Eggs")
        if not eggsFolder then task.wait(1); continue end
        
        local targetEgg = nil
        for _, egg in ipairs(eggsFolder:GetChildren()) do
            if isTargetEgg(egg, farmState.SelectedEggNames, farmState.SelectedEggFilters) and not purchaseCooldownList[egg] then
                local costLabel = egg.Billboard and egg.Billboard:FindFirstChild("Cost")
                if costLabel then
                    local eggCost = parseCost(costLabel.ContentText)
                    if eggCost and player.leaderstats.Money.Value >= eggCost then
                        targetEgg = egg
                        break
                    end
                end
            end
        end
        
        if targetEgg then
            local originalCFrame = rootPart.CFrame
            rootPart.CFrame = CFrame.new(targetEgg.WorldPivot.Position + Vector3.new(0, 3, 0))
            task.wait()
            
            local prompt = findPromptInDescendants(targetEgg)
            if prompt then
                local billboard = targetEgg.Billboard
                local notifyContent = "Membeli: " .. (billboard.ItemName and billboard.ItemName.ContentText or "N/A")
                notifyContent = notifyContent .. "\nHarga: " .. (billboard.Cost and billboard.Cost.ContentText or "N/A")
                notifyContent = notifyContent .. "\nKelangkaan: " .. (billboard.Rarity and billboard.Rarity.ContentText or "N/A")

                local goldenLabel = billboard:FindFirstChild("Golden")
                if goldenLabel and goldenLabel.ContentText then
                    notifyContent = notifyContent .. "\nSpesial: " .. goldenLabel.ContentText
                end

                local diamondLabel = billboard:FindFirstChild("Diamond")
                if diamondLabel and diamondLabel.ContentText then
                     notifyContent = notifyContent .. "\nSpesial: " .. diamondLabel.ContentText
                end
                
                WindUI:Notify({ Title = "Pembelian Berhasil", Content = notifyContent, Duration = 6, Icon = "shopping-cart"})

                fireproximityprompt(prompt)
                purchaseCooldownList[targetEgg] = true
                task.delay(5, function() purchaseCooldownList[targetEgg] = nil end)
            end
            
            rootPart.CFrame = originalCFrame
        end
        task.wait(0.25)
    end
end

do
    Tabs.Main:Section({ Title = "Farming" })
    Tabs.Main:Toggle({
        Title = "Enable Auto Collect Cash",
        Desc = "Automatically collects cash from all non-egg items.",
        Value = false,
        Callback = function(value)
            farmState.AutoCollectCash = value
            if value then
                if collectCoroutine then task.cancel(collectCoroutine) end
                collectCoroutine = task.spawn(CollectLoop)
            else
                if collectCoroutine then
                    task.cancel(collectCoroutine)
                    collectCoroutine = nil
                end
            end
        end
    })
    
    Tabs.Main:Toggle({
        Title = "Enable Auto Hatch Egg",
        Desc = "Automatically hatches eggs when they are ready.",
        Value = false,
        Callback = function(value)
            farmState.AutoHatchEgg = value
            if value then
                if hatchCoroutine then task.cancel(hatchCoroutine) end
                hatchCoroutine = task.spawn(HatchLoop)
            else
                if hatchCoroutine then
                    task.cancel(hatchCoroutine)
                    hatchCoroutine = nil
                end
            end
        end
    })
end

do
    local selectedGrassEggs = {}
    local selectedDessertEggs = {}

    local function combineSelectedEggs()
        farmState.SelectedEggNames = {}
        for _, egg in ipairs(selectedGrassEggs) do table.insert(farmState.SelectedEggNames, egg) end
        for _, egg in ipairs(selectedDessertEggs) do table.insert(farmState.SelectedEggNames, egg) end
    end

    Tabs.BuyEgg:Section({ Title = "Grass Island" })
    Tabs.BuyEgg:Dropdown({
        Title = "Select Egg Names",
        Values = {"Basic Egg", "Rare Egg", "Epic Egg", "Shard Egg", "Flame Egg", "Pixel Egg", "Angel Egg", "sPiKe EgG"},
        Multi = true,
        AllowNone = true,
        Callback = function(value)
            selectedGrassEggs = value
            combineSelectedEggs()
        end
    })

    Tabs.BuyEgg:Section({ Title = "Dessert Island" })
    Tabs.BuyEgg:Dropdown({
        Title = "Select Egg Names",
        Values = {"Sand Egg", "Scorched Egg", "Rock Egg", "Bush Egg", "Tumbleweed Egg", "Cactus Egg", "Fossil Egg", "SERPENT EGG"},
        Multi = true,
        AllowNone = true,
        Callback = function(value)
            selectedDessertEggs = value
            combineSelectedEggs()
        end
    })

    Tabs.BuyEgg:Section({ Title = "Filters & Control" })
    Tabs.BuyEgg:Dropdown({
        Title = "Select Special Filters",
        Values = {"Normal", "Golden", "Diamond"},
        Multi = true,
        AllowNone = true,
        Callback = function(value)
            farmState.SelectedEggFilters = value
        end
    })

    Tabs.BuyEgg:Toggle({
        Title = "Enable Auto Buy Egg",
        Value = false,
        Callback = function(value)
            farmState.AutoBuyEggEnabled = value
            if value then
                if buyCoroutine then task.cancel(buyCoroutine) end
                buyCoroutine = task.spawn(BuyLoop)
            else
                if buyCoroutine then
                    task.cancel(buyCoroutine)
                    buyCoroutine = nil
                end
            end
        end
    })
end

do
    local WalkSpeedSlider

    Tabs.Movement:Section({ Title = "Movement Exploits" })
    Tabs.Movement:Toggle({
        Title = "Enable WalkSpeed",
        Value = false,
        Callback = function(state)
            movementState.WalkSpeed = state
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
            if movementState.WalkSpeed and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = tonumber(value) or 16
            end
        end
    })

    Tabs.Movement:Toggle({
        Title = "Enable Infinite Jump",
        Value = false,
        Callback = function(v)
            movementState.InfiniteJump = v
        end
    })

    if UserInputService then
        UserInputService.JumpRequest:Connect(function()
            if movementState.InfiniteJump and player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    Tabs.Movement:Toggle({
        Title = "Enable No Clip",
        Value = false,
        Callback = function(state)
            movementState.NoClip = state
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
            if movementState.NoClip and player and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
    end)

    if player then
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                if movementState.WalkSpeed then
                    humanoid.WalkSpeed = tonumber(WalkSpeedSlider.Value.Default) or 16
                end
            end
        end)
    end
end

Window:SelectTab(1)

WindUI:Notify({
    Title = "ArcvourHUB Script Ready",
    Content = "All features have been loaded for Singing Brainrot.",
    Duration = 8,
    Icon = "check-circle"
})
