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

local keyUrl = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/fishit.txt"
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
    Author = "Fish It",
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
    Farming = Window:Tab({ Title = "Farming", Icon = "fish", ShowTabTitle = true }),
    Spawn_Boat = Window:Tab({ Title = "Spawn Boat", Icon = "ship", ShowTabTitle = true }),
    Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true }),
    Buy_Rod = Window:Tab({ Title = "Buy Rod", Icon = "anchor", ShowTabTitle = true }),
    Buy_Weather = Window:Tab({ Title = "Buy Weather", Icon = "cloud", ShowTabTitle = true }),
    Buy_Baits = Window:Tab({ Title = "Buy Baits", Icon = "bug", ShowTabTitle = true }),
    TP_Islands = Window:Tab({ Title = "TP Islands", Icon = "map-pin", ShowTabTitle = true }),
    TP_Shop = Window:Tab({ Title = "TP Shop", Icon = "shopping-cart", ShowTabTitle = true }),
    TP_NPC = Window:Tab({ Title = "Teleport to NPC", Icon = "users", ShowTabTitle = true })
}

if not Tabs.Farming or not Tabs.Spawn_Boat or not Tabs.Movement or not Tabs.Buy_Rod or not Tabs.Buy_Weather or not Tabs.Buy_Baits or not Tabs.TP_Islands or not Tabs.TP_Shop or not Tabs.TP_NPC then
    warn("Gagal membuat satu atau lebih tab.")
    return
end

local featureState = {
    AutoFish = false,
    AutoSell = false,
    WalkSpeed = false,
    InfiniteJump = false,
    NoClip = false
}

do
    Tabs.Farming:Section({ Title = "Auto Features" })
    
    local AutoSellToggle
    AutoSellToggle = Tabs.Farming:Toggle({
        Title = "Auto Sell (Teleport)",
        Desc = "Sells all items every 20 seconds by teleporting to the NPC Alex.",
        Value = false,
        Callback = function(value)
            featureState.AutoSell = value
            if value then
                task.spawn(function()
                    while featureState.AutoSell and player do
                        pcall(function()
                            if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end
                            
                            local npcContainer = replicatedStorage:FindFirstChild("NPC")
                            local alexNpc = npcContainer and npcContainer:FindFirstChild("Alex")
                            
                            if not alexNpc then
                                WindUI:Notify({ Title = "Error", Content = "Sell NPC 'Alex' not found.", Duration = 4, Icon = "alert-triangle" })
                                featureState.AutoSell = false
                                if AutoSellToggle then AutoSellToggle:Set(false) end
                                return
                            end

                            local originalCFrame = player.Character.HumanoidRootPart.CFrame
                            local npcPosition = alexNpc.WorldPivot.Position
                            
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(npcPosition)
                            task.wait(1)
                            
                            replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]:InvokeServer()
                            task.wait(1)
                            
                            player.Character.HumanoidRootPart.CFrame = originalCFrame
                        end)
                        task.wait(20)
                    end
                end)
            end
        end
    })

    local AutoFishToggle
    AutoFishToggle = Tabs.Farming:Toggle({
        Title = "Enable Auto Fish",
        Desc = "Automatically catches fish.",
        Value = false,
        Callback = function(value)
            featureState.AutoFish = value
            
            if value then
                pcall(function()
                    local args = { 1 }
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]:FireServer(unpack(args))
                end)
                
                task.wait(1)
                
                WindUI:Notify({ Title = "Success", Content = "Auto Fishing has started.", Duration = 5, Icon = "check" })
                
                task.spawn(function()
                    while featureState.AutoFish and player do
                        pcall(function()
                            local chargeArgs = { 1752984487.133336 }
                            replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]:InvokeServer(unpack(chargeArgs))
                            
                            task.wait(0.2)
                            
                            local minigameArgs = { -0.7499996423721313, 1 }
                            replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]:InvokeServer(unpack(minigameArgs))
                            
                            task.wait(0.2)
                            
                            local completedArgs = {}
                            replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]:FireServer(unpack(completedArgs))
                        end)
                        task.wait(0.5)
                    end
                end)
            else
                WindUI:Notify({ Title = "Info", Content = "Auto Fishing has stopped.", Duration = 5, Icon = "info" })
            end
        end
    })
end

do
    Tabs.Spawn_Boat:Section({ Title = "Standard Boats" })
    local standard_boats = {
        { Name = "Small Boat", ID = 1, Desc = "Acceleration: 160% | Passengers: 3 | Top Speed: 120%" },
        { Name = "Kayak", ID = 2, Desc = "Acceleration: 180% | Passengers: 1 | Top Speed: 155%" },
        { Name = "Jetski", ID = 3, Desc = "Acceleration: 240% | Passengers: 2 | Top Speed: 280%" },
        { Name = "Highfield Boat", ID = 4, Desc = "Acceleration: 180% | Passengers: 3 | Top Speed: 180%" },
        { Name = "Speed Boat", ID = 5, Desc = "Acceleration: 200% | Passengers: 4 | Top Speed: 220%" },
        { Name = "Fishing Boat", ID = 6, Desc = "Acceleration: 180% | Passengers: 8 | Top Speed: 230%" },
        { Name = "Mini Yacht", ID = 14, Desc = "Acceleration: 140% | Passengers: 10 | Top Speed: 290%" },
        { Name = "Hyper Boat", ID = 7, Desc = "Acceleration: 240% | Passengers: 7 | Top Speed: 400%" },
        { Name = "Frozen Boat", ID = 11, Desc = "Acceleration: 193% | Passengers: 3 | Top Speed: 230%" },
        { Name = "Cruiser Boat", ID = 13, Desc = "Acceleration: 180% | Passengers: 4 | Top Speed: 185%" }
    }
    for _, boatData in ipairs(standard_boats) do
        Tabs.Spawn_Boat:Button({
            Title = boatData.Name,
            Desc = boatData.Desc,
            Callback = function()
                pcall(function()
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/DespawnBoat"]:InvokeServer()
                    task.wait(3)
                    local args = { boatData.ID }
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SpawnBoat"]:InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Spawning Boat", Content = "Replacing existing boat with " .. boatData.Name, Duration = 3, Icon = "ship" })
                end)
            end
        })
    end

    Tabs.Spawn_Boat:Section({ Title = "Other Boats" })
    local other_boats = {
        { Name = "Alpha Floaty", ID = 8 },
        { Name = "DEV Evil Duck 9000", ID = 9 },
        { Name = "Festive Duck", ID = 10 },
        { Name = "Santa Sleigh", ID = 12 }
    }
    for _, boatData in ipairs(other_boats) do
        Tabs.Spawn_Boat:Button({
            Title = boatData.Name,
            Callback = function()
                pcall(function()
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/DespawnBoat"]:InvokeServer()
                    task.wait(3)
                    local args = { boatData.ID }
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SpawnBoat"]:InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Spawning Boat", Content = "Replacing existing boat with " .. boatData.Name, Duration = 3, Icon = "ship" })
                end)
            end
        })
    end
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

do
    Tabs.Buy_Rod:Section({ Title = "Purchase Rods" })
    local rods = {
        { Name = "Luck Rod", Price = "350 Coins", ID = 79, Desc = "Luck: 50% | Speed: 2% | Weight: 15 kg" },
        { Name = "Carbon Rod", Price = "900 Coins", ID = 76, Desc = "Luck: 30% | Speed: 4% | Weight: 20 kg" },
        { Name = "Grass Rod", Price = "1.50k Coins", ID = 85, Desc = "Luck: 55% | Speed: 5% | Weight: 250 kg" },
        { Name = "Demascus Rod", Price = "3k Coins", ID = 77, Desc = "Luck: 80% | Speed: 4% | Weight: 400 kg" },
        { Name = "Ice Rod", Price = "5k Coins", ID = 78, Desc = "Luck: 60% | Speed: 7% | Weight: 750 kg" },
        { Name = "Lucky Rod", Price = "15k Coins", ID = 4, Desc = "Luck: 130% | Speed: 7% | Weight: 5k kg" },
        { Name = "Midnight Rod", Price = "50k Coins", ID = 80, Desc = "Luck: 100% | Speed: 10% | Weight: 10k kg" },
        { Name = "Steampunk Rod", Price = "215k Coins", ID = 6, Desc = "Luck: 175% | Speed: 19% | Weight: 25k kg" },
        { Name = "Chrome Rod", Price = "437k Coins", ID = 7, Desc = "Luck: 229% | Speed: 23% | Weight: 250k kg" },
        { Name = "Astral Rod", Price = "1M Coins", ID = 5, Desc = "Luck: 350% | Speed: 43% | Weight: 550k kg" }
    }
    for _, rodData in ipairs(rods) do
        Tabs.Buy_Rod:Button({
            Title = rodData.Name .. " (" .. rodData.Price .. ")",
            Desc = rodData.Desc,
            Callback = function()
                pcall(function()
                    local args = { rodData.ID }
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]:InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Purchase Attempt", Content = "Buying " .. rodData.Name, Duration = 3, Icon = "info" })
                end)
            end
        })
    end
end

do
    Tabs.Buy_Weather:Section({ Title = "Purchase Weather Events" })
    local weathers = {
        { Name = "Wind", Price = "10k Coins", Desc = "Increases Rod Speed" },
        { Name = "Snow", Price = "15k Coins", Desc = "Adds Frozen Mutations" },
        { Name = "Cloudy", Price = "20k Coins", Desc = "Increases Luck" },
        { Name = "Storm", Price = "35k Coins", Desc = "Increase Rod Speed And Luck" },
        { Name = "Shark Hunt", Price = "300k Coins", Desc = "Shark Hunt" }
    }
    for _, weatherData in ipairs(weathers) do
        Tabs.Buy_Weather:Button({
            Title = weatherData.Name .. " (" .. weatherData.Price .. ")",
            Desc = weatherData.Desc,
            Callback = function()
                pcall(function()
                    local args = { weatherData.Name }
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]:InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Purchase Attempt", Content = "Buying " .. weatherData.Name .. " event", Duration = 3, Icon = "info" })
                end)
            end
        })
    end
end

do
    Tabs.Buy_Baits:Section({ Title = "Purchase Baits" })
    local baits = {
        { Name = "Topwater Bait", Price = "100 Coins", ID = 10, Desc = "Luck: 8%" },
        { Name = "Luck Bait", Price = "1k Coins", ID = 2, Desc = "Luck: 10%" },
        { Name = "Midnight Bait", Price = "3k Coins", ID = 3, Desc = "Luck: 20%" },
        { Name = "Chroma Bait", Price = "290k Coins", ID = 6, Desc = "Luck: 100%" },
        { Name = "Dark Mater Bait", Price = "630k Coins", ID = 8, Desc = "Luck: 175%" },
        { Name = "Corrupt Bait", Price = "1.15M Coins", ID = 15, Desc = "Luck: 200% | Mutation Chance: 10% | Shiny Chance: 10%" }
    }
    for _, baitData in ipairs(baits) do
        Tabs.Buy_Baits:Button({
            Title = baitData.Name .. " (" .. baitData.Price .. ")",
            Desc = baitData.Desc,
            Callback = function()
                pcall(function()
                    local args = { baitData.ID }
                    replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]:InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Purchase Attempt", Content = "Buying " .. baitData.Name, Duration = 3, Icon = "info" })
                end)
            end
        })
    end
end

do
    Tabs.TP_Islands:Section({ Title = "Island Locations" })
    
    local locations = {
        "Coral Reefs", "Crater Island", "Esoteric Depths", "Kohana",
        "Kohana Volcano", "Stingray Shores", "Tropical Grove"
    }
    
    for _, name in ipairs(locations) do
        Tabs.TP_Islands:Button({
            Title = name,
            Callback = function()
                if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                    return
                end
                
                local islandContainer = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
                local islandPart = islandContainer and islandContainer:FindFirstChild(name)
                
                if islandPart then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(islandPart.Position)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. name, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "Location '" .. name .. "' not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end
end

do
    Tabs.TP_Shop:Section({ Title = "Shop Locations" })

    local shop_npcs = {
        { Name = "Boats Shop", Path = "Boat Expert" },
        { Name = "Rod Shop", Path = "Joe" },
        { Name = "Bobber Shop", Path = "Seth" }
    }

    for _, npc_data in ipairs(shop_npcs) do
        Tabs.TP_Shop:Button({
            Title = npc_data.Name,
            Callback = function()
                if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                    return
                end

                local npcContainer = replicatedStorage:FindFirstChild("NPC")
                local npc_model = npcContainer and npcContainer:FindFirstChild(npc_data.Path)

                if npc_model and npc_model:IsA("Model") and npc_model.WorldPivot then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(npc_model.WorldPivot.Position)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. npc_data.Name, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "NPC for '" .. npc_data.Name .. "' not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end

    Tabs.TP_Shop:Button({
        Title = "Weather Machine",
        Callback = function()
            if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                return
            end
            
            local islandContainer = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
            local islandPart = islandContainer and islandContainer:FindFirstChild("Weather Machine")
            
            if islandPart then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(islandPart.Position)
                WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to Weather Machine", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Location 'Weather Machine' not found.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })
end

do
    Tabs.TP_NPC:Section({ Title = "NPC Locations" })
    local npc_names = {
        "Alex", "Billy Bob", "Boat Expert", "Burt", "Esoteric Gatekeeper", "Jed", 
        "Jeffery", "Jess", "Joe", "Jones", "Lava Fisherman", "Lonely Fisherman", 
        "McBoatson", "Ram", "Sam", "Santa", "Scientist", "Scott", "Seth", 
        "Silly Fisherman", "Spokesperson", "Tim"
    }
    table.sort(npc_names)

    for _, npc_name in ipairs(npc_names) do
        Tabs.TP_NPC:Button({
            Title = npc_name,
            Callback = function()
                if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                    WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
                    return
                end

                local npcContainer = replicatedStorage:FindFirstChild("NPC")
                local npc_model = npcContainer and npcContainer:FindFirstChild(npc_name)

                if npc_model and npc_model:IsA("Model") and npc_model.WorldPivot then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(npc_model.WorldPivot.Position)
                    WindUI:Notify({ Title = "Teleported", Content = "Successfully teleported to " .. npc_name, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "NPC '" .. npc_name .. "' not found.", Duration = 4, Icon = "alert-triangle" })
                end
            end
        })
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if Window and Window.Destroyed then break end
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.WalkSpeed ~= 16 then
                 player.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
end)

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
        Content = "All features have been loaded for Fish It.",
        Duration = 8,
        Icon = "check-circle"
    })
end
