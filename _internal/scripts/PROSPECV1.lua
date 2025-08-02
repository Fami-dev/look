local WindUI = loadstring(game:HttpGet("https://github.com/Fami-dev/WindUI/releases/download/1.7.0.0/main.txt"))()
if not WindUI then return end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
if not player or not replicatedStorage or not VirtualUser then return end

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

function walkTo(position)
    if not (player and player.Character and player.Character:FindFirstChild("Humanoid")) then return end
    local humanoid = player.Character.Humanoid
    local success, message = pcall(function()
        humanoid:MoveTo(position)
        humanoid.MoveToFinished:Wait()
    end)
    if not success then
        warn("ArcvourHUB: Failed to walk to location - " .. tostring(message))
    end
end

function findEquippedPan()
    if not player.Character then return nil end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Pan") then
            return tool
        end
    end
    return nil
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

local keyUrl = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/prospecting.txt"
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
    Author = "Prospecting",
    Size = UDim2.fromOffset(500, 300),
    Folder = "Prospecting_Config",
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
    Farming = Window:Tab({ Title = "Farming", Icon = "pickaxe", ShowTabTitle = true }),
    Crafting = Window:Tab({ Title = "Crafting", Icon = "hammer", ShowTabTitle = true }),
    BuyPan = Window:Tab({ Title = "Buy Pan", Icon = "shopping-cart", ShowTabTitle = true }),
    BuySluice = Window:Tab({ Title = "Buy Sluice", Icon = "shopping-cart", ShowTabTitle = true }),
    BuyShovel = Window:Tab({ Title = "Buy Shovel", Icon = "shopping-cart", ShowTabTitle = true }),
    BuyPotions = Window:Tab({ Title = "Buy Potions", Icon = "flask-conical", ShowTabTitle = true }),
    BuyTotem = Window:Tab({ Title = "Buy Totem", Icon = "gem", ShowTabTitle = true }),
    Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true })
}

if not Tabs.Farming or not Tabs.Crafting or not Tabs.Movement or not Tabs.BuyPan or not Tabs.BuySluice or not Tabs.BuyShovel or not Tabs.BuyPotions or not Tabs.BuyTotem then
    warn("Gagal membuat satu atau lebih tab.")
    return
end

local featureState = {
    AutoFarm = false,
    AutoSell = false,
    WalkSpeed = false,
    InfiniteJump = false,
    NoClip = false
}

do
    local sandPosition = nil
    local waterPosition = nil
    local movementMode = "Walk"
    local sellInterval = 15
    local sellPosition = Vector3.new(-5, 25, 57)

    local function moveToLocation(targetPosition, isWaterLocation)
        if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end
        if movementMode == "Walk" then
            walkTo(targetPosition)
        elseif movementMode == "Teleport" then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            if isWaterLocation then
                task.wait(0.5)
            else
                task.wait(0.2)
            end
        end
    end

    Tabs.Farming:Section({ Title = "Auto Features" })

    local autoFarmToggle
    autoFarmToggle = Tabs.Farming:Toggle({
        Title = "Auto Farm",
        Desc = "Automatically digs for resources and pans them.",
        Value = false,
        Callback = function(value)
            featureState.AutoFarm = value
            local controls = require(player.PlayerScripts.PlayerModule):GetControls()

            if value then
                if not sandPosition or not waterPosition then
                    WindUI:Notify({ Title = "Error", Content = "Please save both sand and water positions first.", Duration = 5, Icon = "alert-triangle" })
                    featureState.AutoFarm = false
                    if autoFarmToggle then autoFarmToggle:Set(false) end
                    return
                end

                controls:Disable()

                task.spawn(function()
                    while featureState.AutoFarm and player and player.Character do
                        pcall(function()
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            if not rootPart then return end

                            local playerGui = player:WaitForChild("PlayerGui")
                            local toolUI = playerGui:WaitForChild("ToolUI")
                            local fillingPan = toolUI:WaitForChild("FillingPan")
                            local fillText = fillingPan:WaitForChild("FillText")
                            local contextActionGui = playerGui:WaitForChild("ContextActionGui")
                            local contextButton = contextActionGui:WaitForChild("ContextButtonFrame"):WaitForChild("ContextActionButton")
                            
                            local currentFill, maxFill = string.match(fillText.Text, "([%d%.]+)/([%d%.]+)")
                            currentFill, maxFill = tonumber(currentFill), tonumber(maxFill)

                            if not currentFill or not maxFill then return end

                            if currentFill == maxFill and maxFill > 0 then
                                moveToLocation(waterPosition, true)
                                local equippedPan = findEquippedPan()
                                if not equippedPan then
                                    WindUI:Notify({ Title = "Error", Content = "No pan equipped.", Duration = 4, Icon = "alert-triangle" })
                                    task.wait(1)
                                    return
                                end
                                
                                local shakeEvent = equippedPan:WaitForChild("Scripts"):WaitForChild("Shake")
                                local panEvent = equippedPan:WaitForChild("Scripts"):WaitForChild("Pan")

                                while featureState.AutoFarm and tonumber(string.match(fillText.Text, "([%d%.]+)/")) > 0 do
                                    rootPart.CFrame = CFrame.new(waterPosition)
                                    shakeEvent:FireServer()
                                    panEvent:InvokeServer()
                                    task.wait(0.2)
                                end
                            else
                                moveToLocation(sandPosition, false)
                                
                                while featureState.AutoFarm and tonumber(string.match(fillText.Text, "([%d%.]+)/")) < maxFill do
                                    rootPart.CFrame = CFrame.new(sandPosition)
                                    local clickPosition = contextButton.AbsolutePosition + (contextButton.AbsoluteSize / 2)
                                    VirtualUser:Button1Down(clickPosition)
                                    task.wait(0.85)
                                    VirtualUser:Button1Up(clickPosition)
                                    task.wait(0.85)
                                end
                            end
                        end)
                        task.wait(0.2)
                    end
                    controls:Enable()
                end)
            else
                controls:Enable()
            end
        end
    })

    Tabs.Farming:Toggle({
        Title = "Auto Sell Items",
        Desc = "Teleports to sell all items and returns.",
        Value = false,
        Callback = function(value)
            featureState.AutoSell = value
            if value then
                task.spawn(function()
                    while featureState.AutoSell do
                        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local originalCFrame = rootPart.CFrame
                            
                            rootPart.CFrame = CFrame.new(sellPosition)
                            task.wait(0.2)
                            
                            pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("SellAll"):InvokeServer()
                            end)
                            
                            task.wait(0.5)
                            
                            rootPart.CFrame = originalCFrame
                        end
                        task.wait(sellInterval)
                    end
                end)
            end
        end
    })
    
    Tabs.Farming:Slider({
        Title = "Sell Interval (s)",
        Value = { Min = 5, Max = 30, Default = 15 },
        Step = 1,
        Callback = function(value)
            sellInterval = tonumber(value) or 15
        end
    })
    
    Tabs.Farming:Section({ Title = "Positions & Mode" })

    Tabs.Farming:Button({
        Title = "Save Sand Position",
        Callback = function()
            if player and player.Character and player.Character.HumanoidRootPart then
                sandPosition = player.Character.HumanoidRootPart.Position
                WindUI:Notify({ Title = "Success", Content = "Sand position saved.", Duration = 4, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })

    Tabs.Farming:Button({
        Title = "Save Water Position",
        Callback = function()
            if player and player.Character and player.Character.HumanoidRootPart then
                waterPosition = player.Character.HumanoidRootPart.Position
                WindUI:Notify({ Title = "Success", Content = "Water position saved.", Duration = 4, Icon = "check" })
            else
                WindUI:Notify({ Title = "Error", Content = "Character not found.", Duration = 4, Icon = "alert-triangle" })
            end
        end
    })

    Tabs.Farming:Dropdown({
        Title = "Movement Mode",
        Values = { "Walk", "Teleport" },
        Value = "Walk",
        Callback = function(mode)
            movementMode = mode
        end
    })
end

do
    local craftingButtons = {}
    local backpack = player:WaitForChild("Backpack")

    local craftingRecipes = {
        { Name = "Gold Ring", ItemRefName = "Gold Ring", Materials = { Gold = 5 } },
        { Name = "Amethyst Pendant", ItemRefName = "Amethyst Pendant", Materials = { Platinum = 8, Amethyst = 2 } },
        { Name = "Garden Glove", ItemRefName = "Garden Glove", Materials = { Pyrite = 5, Titanium = 1, Gold = 5 } },
        { Name = "Titanium Ring", ItemRefName = "Titanium Ring", Materials = { Titanium = 5 } },
        { Name = "Smoke Ring", ItemRefName = "Smoke Ring", Materials = { ["Smoky Quartz"] = 4 } },
        { Name = "Pearl Necklace", ItemRefName = "Pearl Necklace", Materials = { Pearl = 8 } },
        { Name = "Jade Armband", ItemRefName = "Jade Armband", Materials = { Jade = 4 } },
        { Name = "Topaz Necklace", ItemRefName = "Topaz Necklace", Materials = { Titanium = 3, Topaz = 1 } },
        { Name = "Ruby Ring", ItemRefName = "Ruby Ring", Materials = { Platinum = 5, Ruby = 1 } },
        { Name = "Lapis Armband", ItemRefName = "Lapis Armband", Materials = { ["Lapis Lazuli"] = 2, Gold = 4 } },
        { Name = "Speed Coil", ItemRefName = "Speed Coil", Materials = { ["Meteoric Iron"] = 1, Neodymium = 3, Titanium = 5 } },
        { Name = "Meteor Ring", ItemRefName = "Meteor Ring", Materials = { ["Meteoric Iron"] = 3 } },
        { Name = "Opal Amulet", ItemRefName = "Opal Amulet", Materials = { Opal = 1, Jade = 3 } },
        { Name = "Moon Ring", ItemRefName = "Moon Ring", Materials = { Moonstone = 1, Iridium = 1 } },
        { Name = "Gravity Coil", ItemRefName = "Gravity Coil", Materials = { Aurorite = 1, Moonstone = 1, Osmium = 1 } },
        { Name = "Heart of the Ocean", ItemRefName = "Heart of the Ocean", Materials = { Coral = 10, ["Silver Clamshell"] = 5, ["Golden Pearl"] = 3 } },
        { Name = "Guiding Light", ItemRefName = "Guiding Light", Materials = { Catseye = 1, ["Golden Pearl"] = 2 } },
        { Name = "Lightkeeper's Ring", ItemRefName = "Lightkeeper's Ring", Materials = { Opal = 2, Luminum = 1 } },
        { Name = "Mass Accumulator", ItemRefName = "Mass Accumulator", Materials = { Aurorite = 1, Uranium = 1, Osmium = 2 } },
        { Name = "Crown", ItemRefName = "Crown", Materials = { Ruby = 3, Gold = 8, Emerald = 2, Diamond = 1, Sapphire = 3 } },
        { Name = "Royal Federation Crown", ItemRefName = "Royal Federation Crown", Materials = { ["Rose Gold"] = 3, ["Golden Pearl"] = 5, ["Pink Diamond"] = 1 } },
        { Name = "Phoenix Heart", ItemRefName = "Phoenix Heart", Materials = { Uranium = 3, Inferlume = 1, Starshine = 2 } },
        { Name = "Celestial Rings", ItemRefName = "Celestial Rings", Materials = { Vortessence = 1, ["Meteoric Iron"] = 8, Moonstone = 5, Catseye = 2 } },
        { Name = "Apocalypse Bringer", ItemRefName = "Apocalypse Bringer", Materials = { Ashvein = 4, Ruby = 10, Palladium = 2, Painite = 1 } },
        { Name = "Phoenix Wings", ItemRefName = "Phoenix Wings", Materials = { Flarebloom = 1, Cinnabar = 2, ["Fire Opal"] = 2 } },
        { Name = "Prismatic Star", ItemRefName = "Prismatic Star", Materials = { Diamond = 1, Prismara = 1, ["Pink Diamond"] = 1, Borealite = 5, Luminum = 1, Starshine = 1 } }
    }

    local function checkMaterials(materials)
        if not backpack then return false end
        
        local currentItemCounts = {}
        for _, item in ipairs(backpack:GetChildren()) do
            currentItemCounts[item.Name] = (currentItemCounts[item.Name] or 0) + 1
        end

        for materialName, requiredCount in pairs(materials) do
            local haveCount = currentItemCounts[materialName] or 0
            if haveCount < requiredCount then
                return false
            end
        end
        return true
    end

    local function updateCraftingButtons()
        for _, data in ipairs(craftingButtons) do
            if checkMaterials(data.recipe.Materials) then
                data.button:Unlock()
            else
                data.button:Lock()
            end
        end
    end

    local function setupBackpackMonitoring()
        backpack.ChildAdded:Connect(updateCraftingButtons)
        backpack.ChildRemoved:Connect(updateCraftingButtons)
    end
    
    Tabs.Crafting:Section({ Title = "Equipment Crafting" })

    for _, recipe in ipairs(craftingRecipes) do
        local desc = ""
        for material, count in pairs(recipe.Materials) do
            desc = desc .. "• " .. material .. ": " .. count .. "\n"
        end
        desc = desc:sub(1, -2)

        local craftButton = Tabs.Crafting:Button({
            Title = recipe.Name,
            Desc = desc,
            Locked = true,
            Callback = function()
                local itemToCraft = replicatedStorage:WaitForChild("Items"):WaitForChild("Equipment"):FindFirstChild(recipe.ItemRefName)
                if not itemToCraft then
                    WindUI:Notify({ Title = "Error", Content = "Could not find item to craft: " .. recipe.Name, Duration = 4, Icon = "alert-triangle" })
                    return
                end

                if not checkMaterials(recipe.Materials) then
                    WindUI:Notify({ Title = "Error", Content = "Insufficient materials for " .. recipe.Name, Duration = 4, Icon = "alert-triangle" })
                    return
                end

                local materialArgs = {}
                local usedInstances = {}

                for materialName, requiredCount in pairs(recipe.Materials) do
                    materialArgs[materialName] = {}
                    local foundCount = 0
                    for _, item in ipairs(backpack:GetChildren()) do
                        if item.Name == materialName and not usedInstances[item] then
                            table.insert(materialArgs[materialName], item)
                            usedInstances[item] = true
                            foundCount = foundCount + 1
                            if foundCount >= requiredCount then
                                break
                            end
                        end
                    end
                end

                local args = { itemToCraft, materialArgs }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Crafting"):WaitForChild("CraftEquipment"):InvokeServer(unpack(args))
                    WindUI:Notify({ Title = "Success", Content = "Attempted to craft " .. recipe.Name, Duration = 4, Icon = "check" })
                end)
            end
        })
        table.insert(craftingButtons, { button = craftButton, recipe = recipe })
    end

    setupBackpackMonitoring()
    updateCraftingButtons()
end

do
    local pans = {
        { Title = "Plastic Pan ($500)", Desc = "Luck: 1.5 | Capacity: 10 | Shake Strength: 0.4 | Shake Speed: 80%", Location = "StarterTown", ItemName = "Plastic Pan" },
        { Title = "Metal Pan ($12,000)", Desc = "Luck: 2 | Capacity: 20 | Shake Strength: 0.5 | Shake Speed: 80%", Location = "StarterTown", ItemName = "Metal Pan" },
        { Title = "Silver Pan ($55,000)", Desc = "Luck: 4 | Capacity: 30 | Shake Strength: 0.8 | Shake Speed: 90%", Location = "StarterTown", ItemName = "Silver Pan" },
        { Title = "Golden Pan ($333,000)", Desc = "Luck: 10 | Capacity: 35 | Shake Strength: 1 | Shake Speed: 80%", Location = "RiverTown", ItemName = "Golden Pan" },
        { Title = "Magnetic Pan ($1,000,000)", Desc = "Luck: 15 | Capacity: 50 | Shake Strength: 1 | Shake Speed: 75% | Size Boost: 25%", Location = "RiverTown", ItemName = "Magnetic Pan" },
        { Title = "Meteoric Pan ($3,500,000)", Desc = "Luck: 22 | Capacity: 70 | Shake Strength: 2 | Shake Speed: 100% | Modifier Boost: 25%", Location = "RiverTown", ItemName = "Meteoric Pan" },
        { Title = "Diamond Pan ($10,000,000)", Desc = "Luck: 35 | Capacity: 100 | Shake Strength: 3 | Shake Speed: 100% | Modifier Boost: 10% | Size Boost: 10%", Location = "RiverTown", ItemName = "Diamond Pan" },
    }
    Tabs.BuyPan:Section({ Title = "Pans" })
    for _, itemData in ipairs(pans) do
        Tabs.BuyPan:Button({
            Title = itemData.Title,
            Desc = itemData.Desc,
            Callback = function()
                local args = { workspace:WaitForChild("Purchasable"):WaitForChild(itemData.Location):WaitForChild(itemData.ItemName):WaitForChild("ShopItem") }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
                WindUI:Notify({ Title = "Purchase Attempted", Content = "Attempted to buy " .. itemData.Title, Duration = 4, Icon = "info" })
            end
        })
    end
end

do
    local sluices = {
        { Title = "Wood Sluice Box ($5,000)", Desc = "Luck: 30 | Capacity: 30 | Toughness: 1 | Efficiency: 1", Location = "StarterTown", ItemName = "Wood Sluice Box" },
        { Title = "Steel Sluice Box ($100,000)", Desc = "Luck: 75 | Capacity: 60 | Toughness: 2 | Efficiency: 1.5", Location = "StarterTown", ItemName = "Steel Sluice Box" },
        { Title = "Gold Sluice Box ($655,000)", Desc = "Luck: 150 | Capacity: 75 | Toughness: 3 | Efficiency: 2", Location = "StarterTown", ItemName = "Gold Sluice Box" },
    }
    Tabs.BuySluice:Section({ Title = "Sluice Boxes" })
    for _, itemData in ipairs(sluices) do
        Tabs.BuySluice:Button({
            Title = itemData.Title,
            Desc = itemData.Desc,
            Callback = function()
                local args = { workspace:WaitForChild("Purchasable"):WaitForChild(itemData.Location):WaitForChild(itemData.ItemName):WaitForChild("ShopItem") }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
                WindUI:Notify({ Title = "Purchase Attempted", Content = "Attempted to buy " .. itemData.Title, Duration = 4, Icon = "info" })
            end
        })
    end
end

do
    local shovels = {
        { Title = "Iron Shovel ($3,000)", Desc = "Dig Strength: 2 | Dig Speed: 80% | Toughness: 1", Location = "StarterTown", ItemName = "Iron Shovel" },
        { Title = "Steel Shovel ($25,000)", Desc = "Dig Strength: 3 | Dig Speed: 80% | Toughness: 2", Location = "StarterTown", ItemName = "Steel Shovel" },
        { Title = "Silver Shovel ($75,000)", Desc = "Dig Strength: 4 | Dig Speed: 110% | Toughness: 2", Location = "StarterTown", ItemName = "Silver Shovel" },
        { Title = "Reinforced Shovel ($135,000)", Desc = "Dig Strength: 5 | Dig Speed: 90% | Toughness: 3", Location = "StarterTown", ItemName = "Reinforced Shovel" },
        { Title = "The Excavator ($320,000)", Desc = "Dig Strength: 7 | Dig Speed: 70% | Toughness: 3", Location = "RiverTown", ItemName = "The Excavator" },
        { Title = "Golden Shovel ($1,333,000)", Desc = "Dig Strength: 8 | Dig Speed: 100% | Toughness: 3", Location = "RiverTown", ItemName = "Golden Shovel" },
        { Title = "Meteoric Shovel ($4,000,000)", Desc = "Dig Strength: 7 | Dig Speed: 150% | Toughness: 4", Location = "RiverTown", ItemName = "Meteoric Shovel" },
        { Title = "Diamond Shovel ($12,500,000)", Desc = "Dig Strength: 12 | Dig Speed: 100% | Toughness: 4", Location = "RiverTown", ItemName = "Diamond Shovel" },
    }
    Tabs.BuyShovel:Section({ Title = "Shovels" })
    for _, itemData in ipairs(shovels) do
        Tabs.BuyShovel:Button({
            Title = itemData.Title,
            Desc = itemData.Desc,
            Callback = function()
                local args = { workspace:WaitForChild("Purchasable"):WaitForChild(itemData.Location):WaitForChild(itemData.ItemName):WaitForChild("ShopItem") }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
                WindUI:Notify({ Title = "Purchase Attempted", Content = "Attempted to buy " .. itemData.Title, Duration = 4, Icon = "info" })
            end
        })
    end
end

do
    local potions = {
        { Title = "Basic Capacity Potion ($40,000)", Desc = "Duration: 600 | Capacity: 25%", Location = "RiverTown", ItemName = "Basic Capacity Potion" },
        { Title = "Basic Luck Potion ($50,000)", Desc = "Luck: 5 | Duration: 600", Location = "RiverTown", ItemName = "Basic Luck Potion" },
        { Title = "Greater Capacity Potion (20 Shards)", Desc = "Duration: 1200 | Capacity: 50", Location = "RiverTown", ItemName = "Greater Capacity Potion" },
        { Title = "Greater Luck Potion (30 Shards)", Desc = "Luck: 10 | Duration: 1200", Location = "RiverTown", ItemName = "Greater Luck Potion" },
        { Title = "Merchant's Potion (200 Shards)", Desc = "Duration: 1200 | Sell Boost: 100%", Location = "RiverTown", ItemName = "Merchant's Potion" },
    }
    Tabs.BuyPotions:Section({ Title = "Potions" })
    for _, itemData in ipairs(potions) do
        Tabs.BuyPotions:Button({
            Title = itemData.Title,
            Desc = itemData.Desc,
            Callback = function()
                local args = { workspace:WaitForChild("Purchasable"):WaitForChild(itemData.Location):WaitForChild(itemData.ItemName):WaitForChild("ShopItem") }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
                WindUI:Notify({ Title = "Purchase Attempted", Content = "Attempted to buy " .. itemData.Title, Duration = 4, Icon = "info" })
            end
        })
    end
end

do
    local totems = {
        { Title = "Strength Totem (180 Shards)", Desc = "Duration: 1800", Location = "RiverTown", ItemName = "Strength Totem" },
        { Title = "Luck Totem (300 Shards)", Desc = "Duration: 1800", Location = "RiverTown", ItemName = "Luck Totem" },
    }
    Tabs.BuyTotem:Section({ Title = "Totems" })
    for _, itemData in ipairs(totems) do
        Tabs.BuyTotem:Button({
            Title = itemData.Title,
            Desc = itemData.Desc,
            Callback = function()
                local args = { workspace:WaitForChild("Purchasable"):WaitForChild(itemData.Location):WaitForChild(itemData.ItemName):WaitForChild("ShopItem") }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
                WindUI:Notify({ Title = "Purchase Attempted", Content = "Attempted to buy " .. itemData.Title, Duration = 4, Icon = "info" })
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
        Content = "All features have been loaded for Prospecting.",
        Duration = 8,
        Icon = "check-circle"
    })
end
