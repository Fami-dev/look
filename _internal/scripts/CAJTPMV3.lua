local WindUI = loadstring(game:HttpGet("https://github.com/Fami-dev/WindUI/releases/download/1.7.0.0/main.txt"))()
if not WindUI then return end

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

local HttpService = game:GetService("HttpService")
local player = game:GetService("Players").LocalPlayer

local function InitializeMainScript()
    local Players = game:GetService("Players")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if not player or not replicatedStorage then return end

    local proMgsRemote = replicatedStorage:WaitForChild("ProMgs", 5) and replicatedStorage.ProMgs:WaitForChild("RemoteEvent", 5)
    local msgRemote = replicatedStorage:WaitForChild("Msg", 5) and replicatedStorage.Msg:WaitForChild("RemoteEvent", 5)
    if not proMgsRemote or not msgRemote then
        warn("Failed to find required RemoteEvents. Script may not function fully.")
        return
    end

    local capturedJumpRandom = nil
    local capturedLandingRandom = nil
    local capturedWinsRandom = nil
    local capturedCrystalRandom = nil
    local coinEventFormat = nil

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if self == proMgsRemote and method == "FireServer" and args[1] then
            local eventId = args[1]
            if eventId == "JumpResults" then
                if args[2] and args[3] then
                    capturedJumpRandom = args[2]
                    coinEventFormat = 1
                end
            elseif eventId == "LandingResults" then
                capturedLandingRandom = args[2]
            elseif eventId == "ClaimRooftopWinsReward" then
                capturedWinsRandom = args[2]
            elseif eventId == "ClaimRooftopMagicToken" then
                capturedCrystalRandom = args[2]
            end
        end
        return oldNamecall(self, ...)
    end)

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

    local Window = WindUI:CreateWindow({
        Title = gradient("ArcvourHUB", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
        Icon = "rbxassetid://90566677928169",
        Author = "Climb And Jump Tower V3 (PREMIUM)",
        Size = UDim2.fromOffset(500, 300),
        Folder = "ArcvourHUB_Config",
        Transparent = false,
        Theme = "Arcvour",
        ToggleKey = Enum.KeyCode.K,
        SideBarWidth = 160
    })

    if not Window then return end
    Window:DisableTopbarButtons({"Close"})

    local Tabs = {
        Farming = Window:Tab({ Title = "Farming", Icon = "dollar-sign", ShowTabTitle = true }),
        Hatching = Window:Tab({ Title = "Hatching", Icon = "egg", ShowTabTitle = true }),
        AutoFuse = Window:Tab({ Title = "Auto Fuse (BETA)", Icon = "combine", ShowTabTitle = true }),
        Misc = Window:Tab({ Title = "Misc", Icon = "gift", ShowTabTitle = true }),
        UI = Window:Tab({ Title = "UI", Icon = "layout-template", ShowTabTitle = true }),
        Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true }),
        Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin", ShowTabTitle = true }),
        Visuals = Window:Tab({ Title = "Visuals", Icon = "eye", ShowTabTitle = true }),
        Event = Window:Tab({ Title = "Angels vs Demons", Icon = "swords", ShowTabTitle = true })
    }

    if not Tabs.Farming or not Tabs.Hatching or not Tabs.AutoFuse or not Tabs.Misc or not Tabs.UI or not Tabs.Movement or not Tabs.Teleport or not Tabs.Visuals or not Tabs.Event then
        warn("Failed to create one or more tabs.")
        return
    end

    local coinAmount = nil
    local WalkSpeedSlider
    local farmDelayValue = 2
    local winsClaimDelay = 15

    local autoFarmState = {
        AutoCoins = false,
        AutoWins = false,
        AutoCrystal = false,
        AutoHatch = false,
        WalkSpeed = false,
        InfiniteJump = false,
        NoClip = false,
        AutoClaimGift = false,
        AutoDailySpin = false,
        AutoClaimIndex = false,
        AutoBuyWings = false,
        AutoBuySneakyPet = false,
        AutoLevelUpTokens = false,
        AutoClaimAFKRewards = false,
        AutoClaimPotions = false,
        AutoClaimEventTokens = false,
        AutoFuse = false
    }
    
    local autoFuseSettings = {
        PetNames = {},
        Rarities = {},
        Sizes = {},
        FuseTypes = {},
        Interval = 5,
        EnableNotifications = true
    }

    do
        Tabs.Farming:Section({ Title = "Auto Farm Coins" })
        Tabs.Farming:Paragraph({ Title = "Note", Desc = "A faster delay requires a lower height setting, while a slower delay allows for a greater height. Purchase better wings to increase your maximum height." })

        Tabs.Farming:Input({
            Title = "Height Amount",
            Placeholder = "Enter height",
            Callback = function(text)
                local num = tonumber(text)
                coinAmount = (num and num > 0) and num or 119.5846266746521
            end
        })

        Tabs.Farming:Slider({
            Title = "Auto Coins Delay (s)",
            Value = { Min = 1, Max = 15, Default = 2 },
            Step = 1,
            Callback = function(value)
                farmDelayValue = tonumber(value) or 2
            end
        })

        local AutoCoinsToggle
        AutoCoinsToggle = Tabs.Farming:Toggle({
            Title = "Auto Coins",
            Desc = "Requires Height",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoCoins = value
                if value and player and coinAmount ~= nil then
                    if not coinAmount or type(coinAmount) ~= "number" or coinAmount <= 0 then
                        WindUI:Notify({ Title = "Action Required", Content = "Please enter a valid height amount before starting.", Duration = 6, Icon = "alert-triangle" })
                        if AutoCoinsToggle then AutoCoinsToggle:Set(false) end
                        autoFarmState.AutoCoins = false
                        return
                    end

                    WindUI:Notify({ Title = "Success", Content = "Auto farming main loop has started.", Duration = 5, Icon = "check" })

                    task.spawn(function()
                        local winsTokenTimer = 0
                        while autoFarmState.AutoCoins and player do
                            local canProceed = capturedJumpRandom and capturedLandingRandom
                            if canProceed and proMgsRemote then
                                pcall(function()
                                    local jumpArgs = {"JumpResults", capturedJumpRandom, coinAmount}
                                    proMgsRemote:FireServer(unpack(jumpArgs))
                                    local landingArgs = {"LandingResults", capturedLandingRandom}
                                    proMgsRemote:FireServer(unpack(landingArgs))
                                end)
                            else
                                WindUI:Notify({ Title = "Waiting...", Content = "Capturing game data. Please move your character to start.", Duration = 3, Icon = "loader" })
                                task.wait(1)
                            end

                            task.wait(farmDelayValue)
                            winsTokenTimer = winsTokenTimer + farmDelayValue

                            if not autoFarmState.AutoCoins or not player then break end

                            if winsTokenTimer >= winsClaimDelay and proMgsRemote then
                                if autoFarmState.AutoWins and capturedWinsRandom then
                                    task.wait(1)
                                    pcall(function()
                                        local winsArgs = {"ClaimRooftopWinsReward", capturedWinsRandom}
                                        proMgsRemote:FireServer(unpack(winsArgs))
                                    end)
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
        Tabs.Farming:Section({ Title = "Auto Farm Wins & Crystal" })
        Tabs.Farming:Paragraph({ Title = "Note", Desc = "Auto Coins must be enabled for this to work. You must be at the top of a tower for Auto Wins. Auto Crystal depends on server value." })

        Tabs.Farming:Dropdown({
            Title = "Claim Delay",
            Values = {"10 Seconds", "15 Seconds", "20 Seconds", "25 Seconds", "30 Seconds"},
            Value = "15 Seconds",
            Callback = function(selection)
                if selection == "10 Seconds" then
                    winsClaimDelay = 10
                elseif selection == "15 Seconds" then
                    winsClaimDelay = 15
                elseif selection == "20 Seconds" then
                    winsClaimDelay = 20
                elseif selection == "25 Seconds" then
                    winsClaimDelay = 25
                elseif selection == "30 Seconds" then
                    winsClaimDelay = 30
                end
            end
        })

        Tabs.Farming:Toggle({ Title = "Auto Wins", Desc = "Requires Auto Coins", Value = false, Callback = function(v) autoFarmState.AutoWins = v end })
        Tabs.Farming:Toggle({ Title = "Auto Crystal", Desc = "Requires Auto Coins", Value = false, Callback = function(v) autoFarmState.AutoCrystal = v end })
    end

    do
        Tabs.Hatching:Section({ Title = "Auto Hatch Eggs" })

        local orderedEggNames = {"Egg 1 (Eiffel Tower)", "Egg 2 (Eiffel Tower)", "Egg 3 (Eiffel Tower)","Egg 1 (Empire State Bulding)", "Egg 2 (Empire State Bulding)", "Egg 3 (Empire State Bulding)","Egg 1 (Oriental Pearl Tower)", "Egg 2 (Oriental Pearl Tower)","Egg 1 (Big Ben)", "Egg 2 (Big Ben)","Egg 1 (Obelisk)", "Egg 2 (Obelisk)","Egg 1 (Leaning Tower)", "Egg 2 (Leaning Tower)","Egg 1 (Burj Khalifa Tower)", "Egg 2 (Burj Khalifa Tower)", "Egg 3 (Burj Khalifa Tower)","Egg 1 (Pixel World)", "Egg 2 (Pixel World)", "Egg 3 (Pixel World)","Egg 1 (Tokyo Tower)", "Egg 2 (Tokyo Tower)", "Egg 3 (Tokyo Tower)", "Egg 1 (Petronas Towers)", "Egg 2 (Petronas Towers)", "Egg 3 (Petronas Towers)", "Egg 1 (Mount Everest)", "Egg 2 (Mount Everest)", "Egg 1 (CN Tower)", "Egg 2 (CN Tower)", "Egg 3 (CN Tower)"}
        local eggLookupTable = {["Egg 1 (Eiffel Tower)"]=7000001,["Egg 2 (Eiffel Tower)"]=7000002,["Egg 3 (Eiffel Tower)"]=7000003,["Egg 1 (Empire State Bulding)"]=7000004,["Egg 2 (Empire State Bulding)"]=7000005,["Egg 3 (Empire State Bulding)"]=7000006,["Egg 1 (Oriental Pearl Tower)"]=7000007,["Egg 2 (Oriental Pearl Tower)"]=7000008,["Egg 1 (Big Ben)"]=7000009,["Egg 2 (Big Ben)"]=7000010,["Egg 1 (Obelisk)"]=7000011,["Egg 2 (Obelisk)"]=7000012,["Egg 1 (Leaning Tower)"]=7000013,["Egg 2 (Leaning Tower)"]=7000014,["Egg 1 (Burj Khalifa Tower)"]=7000015,["Egg 2 (Burj Khalifa Tower)"]=7000016,["Egg 3 (Burj Khalifa Tower)"]=7000017,["Egg 1 (Pixel World)"]=7000018,["Egg 2 (Pixel World)"]=7000019,["Egg 3 (Pixel World)"]=7000020,["Egg 1 (Tokyo Tower)"]=7000021,["Egg 2 (Tokyo Tower)"]=7000022,["Egg 3 (Tokyo Tower)"]=7000023, ["Egg 1 (Petronas Towers)"]=7000026, ["Egg 2 (Petronas Towers)"]=7000027, ["Egg 3 (Petronas Towers)"]=7000028, ["Egg 1 (Mount Everest)"]=7000029, ["Egg 2 (Mount Everest)"]=7000030, ["Egg 1 (CN Tower)"]=7000031, ["Egg 2 (CN Tower)"]=7000032, ["Egg 3 (CN Tower)"]=7000033}
        local selectedEggID = eggLookupTable[orderedEggNames[1]]
        local hatchAmount = 1

        Tabs.Hatching:Dropdown({
            Title = "Select Egg",
            Values = orderedEggNames,
            Value = orderedEggNames[1],
            Callback = function(selectedEggName) selectedEggID = eggLookupTable[selectedEggName] or eggLookupTable[orderedEggNames[1]] end
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
                if value and player and selectedEggID and hatchAmount then
                    if not selectedEggID or not hatchAmount then
                        WindUI:Notify({ Title = "Action Required", Content = "Please select an egg and a hatch amount first.", Duration = 6, Icon = "alert-triangle" })
                        if AutoHatchToggle then AutoHatchToggle:Set(false) end
                        autoFarmState.AutoHatch = false
                        return
                    end
                    WindUI:Notify({ Title = "Success", Content = "Auto Hatching has started.", Duration = 5, Icon = "check" })
                    task.spawn(function()
                        while autoFarmState.AutoHatch and player do
                            if msgRemote and replicatedStorage:FindFirstChild("Tool") and replicatedStorage.Tool:FindFirstChild("DrawUp") and replicatedStorage.Tool.DrawUp:FindFirstChild("Msg") then
                                pcall(function()
                                    msgRemote:FireServer("\230\138\189\232\155\139\229\188\149\229\175\188\231\187\147\230\157\159")
                                    replicatedStorage.Tool.DrawUp.Msg.DrawHero:InvokeServer(selectedEggID, hatchAmount)
                                end)
                            end
                            task.wait(0.1)
                        end
                    end)
                end
            end
        })
    end
    
    do
        Tabs.AutoFuse:Section({ Title = "Fuse Configuration" })

        Tabs.AutoFuse:Input({
            Title = "Pet Names (comma-separated) (Opsional)",
            Placeholder = "e.g., bird pet,jawara pet",
            Callback = function(text)
                local names = {}
                for name in string.gmatch(text, "([^,]+)") do
                    local trimmedName = name:match("^%s*(.-)%s*$"):lower()
                    if trimmedName ~= "" then
                        table.insert(names, trimmedName)
                    end
                end
                autoFuseSettings.PetNames = names
            end
        })

        Tabs.AutoFuse:Dropdown({
            Title = "Select Rarity",
            Values = {"Rare", "Epic", "Legendary", "Mysterious", "Immortal", "Secret"},
            Multi = true,
            AllowNone = true,
            Callback = function(selection)
                autoFuseSettings.Rarities = selection
            end
        })

        Tabs.AutoFuse:Dropdown({
            Title = "Select Size",
            Values = {"Normal", "Big", "Huge"},
            Multi = true,
            AllowNone = true,
            Callback = function(selection)
                autoFuseSettings.Sizes = selection
            end
        })

        Tabs.AutoFuse:Dropdown({
            Title = "Select Fuse Type",
            Values = {"Normal -> Shiny", "Shiny -> Rainbow"},
            Multi = true,
            AllowNone = true,
            Callback = function(selection)
                autoFuseSettings.FuseTypes = selection
            end
        })

        Tabs.AutoFuse:Slider({
            Title = "Fuse Loop Interval (s)",
            Value = { Min = 5, Max = 60, Default = 5 },
            Step = 1,
            Callback = function(value)
                autoFuseSettings.Interval = tonumber(value) or 5
            end
        })

        Tabs.AutoFuse:Toggle({ Title = "Enable Notifications", Value = true, Callback = function(v) autoFuseSettings.EnableNotifications = v end })

        Tabs.AutoFuse:Toggle({
            Title = "Enable Auto Fuse",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoFuse = value
                if value then
                    if autoFuseSettings.EnableNotifications then
                        WindUI:Notify({ Title = "Auto Fuse Started", Content = "Scanning and fusing pets based on your configuration.", Duration = 5, Icon = "check-circle" })
                    end
                    
                    task.spawn(function()
                        local playerGui = player:WaitForChild("PlayerGui")
                        local screenGui = playerGui:WaitForChild("ScreenGui")
                        local petOpenButton = screenGui:WaitForChild("Main"):WaitForChild("Right"):WaitForChild("SubButtons2"):WaitForChild("Pet"):WaitForChild("Button")
                        local petsUIFrame = screenGui:WaitForChild("Pets")
                        
                        local petsFrame = petsUIFrame:WaitForChild("Frame")
                        local scrollPetFrame = petsFrame:WaitForChild("ScrollPet")
                        local petDetailFrame = petsFrame:WaitForChild("\229\189\147\229\137\141\233\128\137\228\184\173\231\154\132\230\173\166\229\153\168")
                        local remoteFunction = replicatedStorage:WaitForChild("Msg"):WaitForChild("RemoteFunction")

                        local onlyIDObject = petDetailFrame and petDetailFrame:FindFirstChild("OnlyID")
                        local itemNameObject = petDetailFrame and petDetailFrame:FindFirstChild("itemName")
                        local rarityObject = petDetailFrame and petDetailFrame:FindFirstChild("Level")
                        
                        if not (petOpenButton and petsUIFrame and onlyIDObject and itemNameObject and rarityObject and remoteFunction) then
                            if autoFuseSettings.EnableNotifications then
                                WindUI:Notify({ Title = "Error", Content = "Could not find necessary UI components for Auto Fuse.", Duration = 6, Icon = "alert-triangle" })
                            end
                            autoFarmState.AutoFuse = false
                            return
                        end

                        local function sanitizeText(text)
                            if type(text) ~= "string" then return "" end
                            return text:gsub("<[^<>]+>", ""):match("^%s*(.-)%s*$") or ""
                        end
                        
                        local function checkPetPassesFilter(petData)
                            local nameLower = petData.name:lower()
                            
                            if #autoFuseSettings.PetNames > 0 then
                                local nameMatch = false
                                for _, targetName in ipairs(autoFuseSettings.PetNames) do
                                    if nameLower:find(targetName, 1, true) then
                                        nameMatch = true
                                        break
                                    end
                                end
                                if not nameMatch then return false end
                            end

                            if #autoFuseSettings.Rarities > 0 and not table.find(autoFuseSettings.Rarities, petData.rarity) then
                                return false
                            end

                            local isShiny = nameLower:find("^shiny ", 1, true)
                            local isBig = nameLower:find("^big ", 1, true)
                            local isHuge = nameLower:find("^huge ", 1, true)
                            
                            local isNormalSize = not isBig and not isHuge

                            local passesSize = #autoFuseSettings.Sizes == 0 or
                                (table.find(autoFuseSettings.Sizes, "Normal") and isNormalSize) or
                                (table.find(autoFuseSettings.Sizes, "Big") and isBig) or
                                (table.find(autoFuseSettings.Sizes, "Huge") and isHuge)

                            if not passesSize then return false end

                            local passesFuseType = #autoFuseSettings.FuseTypes == 0 or
                                (table.find(autoFuseSettings.FuseTypes, "Normal -> Shiny") and not isShiny) or
                                (table.find(autoFuseSettings.FuseTypes, "Shiny -> Rainbow") and isShiny)
                            
                            if not passesFuseType then return false end

                            return true
                        end

                        while autoFarmState.AutoFuse and player do
                            local isPetUIVisible = petsUIFrame.Visible
                            local clickCount = isPetUIVisible and 3 or 2
                            for i = 1, clickCount do
                                if not autoFarmState.AutoFuse then break end
                                pcall(function() firesignal(petOpenButton.MouseButton1Click) end)
                                task.wait(0.25)
                            end

                            if not autoFarmState.AutoFuse then break end

                            local petIconsToScan = {}
                            for _, petIcon in ipairs(scrollPetFrame:GetChildren()) do
                                if petIcon.Name == "Temp" and petIcon:IsA("ImageButton") then
                                    table.insert(petIconsToScan, petIcon)
                                end
                            end

                            if #petIconsToScan == 0 then
                                if autoFuseSettings.EnableNotifications then
                                    WindUI:Notify({ Title = "Info", Content = "No pets found in UI to scan.", Duration = 4, Icon = "info" })
                                end
                                task.wait(autoFuseSettings.Interval)
                                continue
                            end

                            local allPetsData = {}
                            local seenIDs_ThisCycle = {}

                            for _, petIcon in ipairs(petIconsToScan) do
                                if not autoFarmState.AutoFuse then break end
                                
                                pcall(function() firesignal(petIcon.MouseButton1Click) end)
                                task.wait(0.01)
                                
                                local currentID = onlyIDObject.Value
                                if currentID and not seenIDs_ThisCycle[currentID] then
                                    seenIDs_ThisCycle[currentID] = true
                                    local petDataItem = {
                                        name = sanitizeText(itemNameObject.Text),
                                        rarity = sanitizeText(rarityObject.Text),
                                        id = currentID
                                    }
                                    table.insert(allPetsData, petDataItem)
                                end
                            end

                            if not autoFarmState.AutoFuse then break end

                            local filteredPets = {}
                            for _, petData in ipairs(allPetsData) do
                                if checkPetPassesFilter(petData) then
                                    table.insert(filteredPets, petData)
                                end
                            end

                            local groupedPets = {}
                            for _, petData in ipairs(filteredPets) do
                                local key = petData.name
                                if not groupedPets[key] then groupedPets[key] = {} end
                                table.insert(groupedPets[key], petData.id)
                            end

                            local didFuse = false
                            for petName, ids in pairs(groupedPets) do
                                while #ids >= 5 do
                                    if not autoFarmState.AutoFuse then break end
                                    didFuse = true
                                    local mainPetID = table.remove(ids, 1)
                                    local fuseList = { table.remove(ids, 1), table.remove(ids, 1), table.remove(ids, 1), table.remove(ids, 1) }
                                    
                                    local args = { "MergePet", { mainOnlyID = mainPetID, FusePetVt = fuseList } }
                                    local success, result = pcall(function() return remoteFunction:InvokeServer(unpack(args)) end)

                                    if autoFuseSettings.EnableNotifications then
                                        if success then
                                            WindUI:Notify({Title = "Fuse Success", Content = "Fused 5x " .. petName, Duration = 3, Icon="check"})
                                        else
                                            WindUI:Notify({Title = "Fuse Failed", Content = "Failed to fuse " .. petName, Duration = 3, Icon="x"})
                                        end
                                    end
                                    task.wait(1.5)
                                end
                                if not autoFarmState.AutoFuse then break end
                            end
                            
                            if not didFuse and autoFuseSettings.EnableNotifications then
                                WindUI:Notify({Title = "Auto Fuse", Content = "No fusable pets found in this cycle.", Duration = 4, Icon = "info"})
                            end

                            task.wait(autoFuseSettings.Interval)
                        end
                    end)
                else
                    if autoFuseSettings.EnableNotifications then
                        WindUI:Notify({ Title = "Auto Fuse Stopped", Content = "The process has been terminated.", Duration = 4, Icon = "x-circle" })
                    end
                end
            end
        })
    end


    do
        Tabs.Misc:Section({ Title = "Auto Claim" })
        Tabs.Misc:Toggle({
            Title = "Auto Claim Gifts",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoClaimGift = value
                if value and player and msgRemote then
                    task.spawn(function()
                        while autoFarmState.AutoClaimGift and player do
                            for i = 1, 12 do
                                pcall(function()
                                    local args = {"GetOnlineAward", i}
                                    msgRemote:FireServer(unpack(args))
                                end)
                                task.wait(0.1)
                            end
                            task.wait(5)
                        end
                    end)
                end
            end
        })

        Tabs.Misc:Section({ Title = "Daily Spin" })
        Tabs.Misc:Toggle({
            Title = "Auto Daily Spin",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoDailySpin = value
                if value and player then
                    task.spawn(function()
                        local dailySpinRemote = replicatedStorage:WaitForChild("System", 5) and replicatedStorage.System:WaitForChild("SystemDailyLottery", 5) and replicatedStorage.System.SystemDailyLottery:WaitForChild("Spin", 5)
                        if not dailySpinRemote then
                            WindUI:Notify({ Title = "Error", Content = "Daily Spin remote not found.", Duration = 5, Icon = "alert-triangle" })
                            return
                        end
                        while autoFarmState.AutoDailySpin and player do
                            pcall(function()
                                dailySpinRemote:InvokeServer()
                            end)
                            task.wait(300)
                        end
                    end)
                end
            end
        })
        
        Tabs.Misc:Section({ Title = "Pet Index" })
        Tabs.Misc:Toggle({
            Title = "Auto Claim Index Rewards",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoClaimIndex = value
                if value and player and msgRemote then
                    task.spawn(function()
                        while autoFarmState.AutoClaimIndex and player do
                            for i = 1, 11 do
                                if not autoFarmState.AutoClaimIndex then break end
                                pcall(function()
                                    local args = {"GetIndexReward", i}
                                    msgRemote:FireServer(unpack(args))
                                end)
                                task.wait(0.2)
                            end
                            task.wait(300)
                        end
                    end)
                end
            end
        })
    end

    do
        Tabs.UI:Section({ Title = "Quick UI Access" })
        
        local uiLoadStatus = {}

        local function teleportAndOpenUI(locationName, targetPosition, uiName)
            task.spawn(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local rootPart = char.HumanoidRootPart
                local originalCFrame = rootPart.CFrame

                if not uiLoadStatus[uiName] then
                    uiLoadStatus[uiName] = true
                    
                    local originalAnchored = rootPart.Anchored
                    rootPart.Anchored = true
                    rootPart.CFrame = CFrame.new(targetPosition)
                    task.wait(3)
                    rootPart.Anchored = originalAnchored
                    rootPart.CFrame = originalCFrame
                    task.wait(0.5)
                end
                
                pcall(function()
                    rootPart.CFrame = CFrame.new(targetPosition)
                    task.wait()
                    
                    local uiElement = player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild(uiName, 5)
                    
                    rootPart.CFrame = originalCFrame

                    if uiElement then
                        uiElement.Visible = true
                        
                        local visibilityConnection
                        visibilityConnection = uiElement:GetPropertyChangedSignal("Visible"):Connect(function()
                            if not uiElement.Visible then
                                uiElement.Visible = true
                            end
                        end)
                        
                        task.delay(2, function()
                            if visibilityConnection then
                                visibilityConnection:Disconnect()
                            end
                        end)
                    end
                end)
            end)
        end

        Tabs.UI:Button({
            Title = "Open Wing Shop",
            Callback = function()
                teleportAndOpenUI("Wing Shop", Vector3.new(-69, 5, -5004), "WingShop")
            end
        })

        Tabs.UI:Button({
            Title = "Open Wing Enchant",
            Callback = function()
                teleportAndOpenUI("Wing Enchant", Vector3.new(-6, 10, -4998), "WingEnchantment")
            end
        })

        Tabs.UI:Button({
            Title = "Open Titan Machine",
            Callback = function()
                teleportAndOpenUI("Titan Machine", Vector3.new(9984, 3, -3), "Titan Pet")
            end
        })

        Tabs.UI:Button({
            Title = "Open Enchant UI",
            Callback = function()
                teleportAndOpenUI("Enchant UI", Vector3.new(5017, 5, 23), "MagicPet")
            end
        })

        Tabs.UI:Button({
            Title = "Reset All UIs",
            Callback = function()
                local uiNames = {"WingShop", "WingEnchantment", "Titan Pet", "MagicPet"}
                local screenGui = player.PlayerGui:FindFirstChild("ScreenGui")
                if not screenGui then return end

                for _, uiName in ipairs(uiNames) do
                    local uiElement = screenGui:FindFirstChild(uiName)
                    if uiElement then
                        uiElement.Visible = false
                    end
                end
                WindUI:Notify({Title = "Success", Content = "All UIs have been hidden.", Duration = 3, Icon = "check"})
            end
        })
    end

    do
        Tabs.Movement:Section({ Title = "Climb Settings" })
        Tabs.Movement:Toggle({ Title = "Auto Climb", Value = false, Callback = function(state)
            if player and player.Setting and player.Setting:FindFirstChild("isAutoOn") then
                player.Setting.isAutoOn.Value = state and 1 or 0
            end
        end })
        Tabs.Movement:Toggle({ Title = "Auto Super Climb", Value = false, Callback = function(state)
            if player and player.Setting and player.Setting:FindFirstChild("isAutoCllect") then
                player.Setting.isAutoCllect.Value = state and 1 or 0
            end
        end })

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

    do
        Tabs.Teleport:Section({ Title = "Tower Locations" })

        local teleportLocations = {
            { Name = "Eiffel Tower", WorldID = 1 },
            { Name = "Empire State Building", WorldID = 2 },
            { Name = "Oriental Pearl Tower", WorldID = 3 },
            { Name = "Big Ben", WorldID = 4 },
            { Name = "Obelisk", WorldID = 5 },
            { Name = "Leaning Tower", WorldID = 6 },
            { Name = "Burj Khalifa Tower", WorldID = 7 },
            { Name = "Pixel World", WorldID = 8 },
            { Name = "Tokyo Tower", WorldID = 9 },
            { Name = "Petronas Towers", WorldID = 10 },
            { Name = "Mount Everest", WorldID = 11 },
            { Name = "CN Tower", WorldID = 12 }
        }

        for _, location in ipairs(teleportLocations) do
            Tabs.Teleport:Button({
                Title = location.Name,
                Callback = function()
                    if msgRemote then
                        local args = { "TeleportToTargetWorld", location.WorldID }
                        msgRemote:FireServer(unpack(args))
                        WindUI:Notify({ Title = "Teleporting...", Content = "Attempting to teleport to " .. location.Name, Duration = 3, Icon = "send" })
                    else
                        WindUI:Notify({ Title = "Error", Content = "Teleport remote not found.", Duration = 4, Icon = "alert-triangle" })
                    end
                end
            })
        end
    end

    do
        Tabs.Visuals:Section({ Title = "Display Settings" })
        Tabs.Visuals:Toggle({ Title = "Hide Pets", Value = false, Callback = function(state)
            if player and player.Setting and player.Setting:FindFirstChild("ShowPets") then
                player.Setting.ShowPets.Value = state and 0 or 1
            end
        end })
        Tabs.Visuals:Toggle({ Title = "Hide JumpPals", Value = false, Callback = function(state)
            if player and player.Setting and player.Setting:FindFirstChild("ShowJumpPal") then
                player.Setting.ShowJumpPal.Value = state and 0 or 1
            end
        end })
    end

    do
        Tabs.Event:Section({ Title = "Event Features" })

        Tabs.Event:Toggle({
            Title = "Auto Buy Wings",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoBuyWings = value
                if value then
                    task.spawn(function()
                        while autoFarmState.AutoBuyWings and player do
                            if msgRemote then
                                for wingId = 13000, 13011 do
                                    if not autoFarmState.AutoBuyWings then break end
                                    pcall(function()
                                        local args = {"BuyWing", wingId}
                                        msgRemote:FireServer(unpack(args))
                                    end)
                                    task.wait(0.1)
                                end
                            else
                                autoFarmState.AutoBuyWings = false
                                break
                            end
                            if not autoFarmState.AutoBuyWings then break end
                            task.wait(10)
                        end
                    end)
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Buy Sneaky Pet",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoBuySneakyPet = value
                if value then
                    task.spawn(function()
                        while autoFarmState.AutoBuySneakyPet and player do
                            if msgRemote then
                                pcall(function()
                                    local args = {"\229\141\135\231\186\167\229\174\160\231\137\169"}
                                    msgRemote:FireServer(unpack(args))
                                end)
                            else
                                autoFarmState.AutoBuySneakyPet = false
                                break
                            end
                            if not autoFarmState.AutoBuySneakyPet then break end
                            task.wait(10)
                        end
                    end)
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Level Up Tokens",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoLevelUpTokens = value
                if value then
                    task.spawn(function()
                        while autoFarmState.AutoLevelUpTokens and player do
                            if msgRemote then
                                pcall(function()
                                    msgRemote:FireServer("LvlUp_Tokens")
                                end)
                            else
                                autoFarmState.AutoLevelUpTokens = false
                                break
                            end
                            task.wait(10)
                        end
                    end)
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Claim Event AFK Rewards",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoClaimAFKRewards = value
                if value then
                    task.spawn(function()
                        local afkRemote = replicatedStorage:WaitForChild("Msg", 5) and replicatedStorage.Msg:WaitForChild("RemoteFunction", 5)
                        if not afkRemote then
                             autoFarmState.AutoClaimAFKRewards = false
                             return
                        end
                        
                        while autoFarmState.AutoClaimAFKRewards and player do
                            pcall(function()
                                afkRemote:InvokeServer("ClaimEventAFKReward")
                            end)
                            task.wait(10)
                        end
                    end)
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Claim Potions",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoClaimPotions = value
                if value then
                    task.spawn(function()
                        while autoFarmState.AutoClaimPotions and player do
                            local buffsFolder = workspace:FindFirstChild("EventEssentials") and workspace.EventEssentials:FindFirstChild("Buffs")
                            if buffsFolder and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local rootPart = player.Character.HumanoidRootPart
                                for _, buff in ipairs(buffsFolder:GetChildren()) do
                                    if not autoFarmState.AutoClaimPotions then break end
                                    local potionPart = buff:FindFirstChild("Cylinder004") or buff:FindFirstChild("Hitbox")
                                    if potionPart then
                                        pcall(firetouchinterest, rootPart, potionPart, 0)
                                        task.wait(0.1)
                                    end
                                end
                            end
                            task.wait(10)
                        end
                    end)
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Claim Event Tokens",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoClaimEventTokens = value
                if value then
                    task.spawn(function()
                        while autoFarmState.AutoClaimEventTokens and player do
                            local tokensFolder = workspace:FindFirstChild("EventEssentials") and workspace.EventEssentials:FindFirstChild("CollectableTokens")
                            if tokensFolder and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local rootPart = player.Character.HumanoidRootPart
                                for _, tokenModel in ipairs(tokensFolder:GetChildren()) do
                                    if not autoFarmState.AutoClaimEventTokens then break end
                                    local tokenPart = tokenModel:FindFirstChild("EventToken")
                                    if tokenPart then
                                        pcall(firetouchinterest, rootPart, tokenPart, 0)
                                        task.wait(0.1)
                                    end
                                end
                            end
                            task.wait(10)
                        end
                    end)
                end
            end
        })
    end

    local VirtualUser = game:GetService("VirtualUser")
    if player and VirtualUser then
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    local function setupAutoCrystalLogic()
        local magicTokenValue = player and player:FindFirstChild("Whether_MagicToken_appears_nextTime")
        if not magicTokenValue then
            WindUI:Notify({ Title = "Info", Content = "Auto Crystal value not found, checking periodically...", Duration = 5, Icon = "info" })
            task.spawn(function()
                while not magicTokenValue and player do
                    magicTokenValue = player and player:FindFirstChild("Whether_MagicToken_appears_nextTime")
                    if magicTokenValue then break end
                    task.wait(1)
                end
                if magicTokenValue and player then
                    WindUI:Notify({ Title = "Success", Content = "Auto Crystal value detected, enabling logic.", Duration = 5, Icon = "check" })
                    local lastValue = magicTokenValue.Value
                    local crystalTask = nil

                    magicTokenValue.Changed:Connect(function(newValue)
                        if autoFarmState.AutoCoins and autoFarmState.AutoCrystal and capturedCrystalRandom and proMgsRemote and player then
                            if newValue == 1 and lastValue == 0 then
                                if crystalTask then
                                    task.cancel(crystalTask)
                                end
                                crystalTask = task.spawn(function()
                                    while magicTokenValue.Value == 1 and autoFarmState.AutoCoins and autoFarmState.AutoCrystal and player do
                                        pcall(function()
                                            local crystalArgs = {"ClaimRooftopMagicToken", capturedCrystalRandom}
                                            proMgsRemote:FireServer(unpack(crystalArgs))
                                        end)
                                        task.wait(0.5)
                                    end
                                end)
                            end
                            lastValue = newValue
                        end
                    end)
                end
            end)
        else
            local lastValue = magicTokenValue.Value
            local crystalTask = nil

            magicTokenValue.Changed:Connect(function(newValue)
                if autoFarmState.AutoCoins and autoFarmState.AutoCrystal and capturedCrystalRandom and proMgsRemote and player then
                    if newValue == 1 and lastValue == 0 then
                        if crystalTask then
                            task.cancel(crystalTask)
                        end
                        crystalTask = task.spawn(function()
                            while magicTokenValue.Value == 1 and autoFarmState.AutoCoins and autoFarmState.AutoCrystal and player do
                                pcall(function()
                                    local crystalArgs = {"ClaimRooftopMagicToken", capturedCrystalRandom}
                                    proMgsRemote:FireServer(unpack(crystalArgs))
                                end)
                                task.wait(0.5)
                            end
                        end)
                    end
                    lastValue = newValue
                end
            end)
        end
    end

    setupAutoCrystalLogic()

    if Window then
        Window:SelectTab(1)
        WindUI:Notify({
            Title = "Arcvour Script Ready",
            Content = "All features have been loaded.",
            Duration = 8,
            Icon = "check-circle"
        })
    end
end

local SUPABASE_URL = "https://uoltcakjgecpljfwgpqx.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVvbHRjYWtqZ2VjcGxqZndncHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0ODEyNzksImV4cCI6MjA2OTA1NzI3OX0.eW3shM2Y4AXxL9PXf6gWcEbOF5Kp-CPtu6Pg0txngUY"
local SUPABASE_TABLE_NAME = "ArcvourKey"
local KEY_LIST_URL = "https://raw.githubusercontent.com/Fami-dev/rawkey/refs/heads/main/ArcvourKey.txt"
local KEY_SAVE_FILE = "arcvour_key.txt"
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
    if isfile and isfile(KEY_SAVE_FILE) then
        if deletefile then
            deletefile(KEY_SAVE_FILE)
        end
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
            if writefile then
                writefile(KEY_SAVE_FILE, keyToValidate)
            end
            return true, "Welcome back! Key ownership verified."
        else
            return false, "This key is already claimed by another user."
        end
    else
        PurgeUser(player.UserId)
        
        local newRecordBody = HttpService:JSONEncode({key_value = keyToValidate, user_id = tostring(player.UserId), user_name = player.Name})
        local creationResponse = SupabaseRequest("POST", SUPABASE_API_URL, newRecordBody)
        if creationResponse then
            if writefile then
                writefile(KEY_SAVE_FILE, keyToValidate)
            end
            return true, "Key claimed successfully! Welcome."
        else
            return false, "Failed to claim the new key on the server."
        end
    end
end

local keyToUse = ArcvourKey
if not keyToUse then
    if isfile and isfile(KEY_SAVE_FILE) then
        if readfile then
            keyToUse = readfile(KEY_SAVE_FILE)
        end
    end
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
