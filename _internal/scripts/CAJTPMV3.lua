local WindUI = loadstring(game:HttpGet("https://github.com/Fami-dev/WindUI/releases/download/1.7.0.0/main.txt"))()
if not WindUI then return end

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

    local Window = WindUI:CreateWindow({
        Title = gradient("ArcvourHUB (PREMIUM)", Color3.fromHex("#8C46FF"), Color3.fromHex("#BE78FF")),
        Icon = "rbxassetid://110866274282768",
        Author = "Climb And Jump Tower",
        Size = UDim2.fromOffset(500, 320),
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
        Misc = Window:Tab({ Title = "Misc", Icon = "gift", ShowTabTitle = true }),
        Movement = Window:Tab({ Title = "Movement", Icon = "send", ShowTabTitle = true }),
        Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin", ShowTabTitle = true }),
        Visuals = Window:Tab({ Title = "Visuals", Icon = "eye", ShowTabTitle = true }),
        Event = Window:Tab({ Title = "Angels vs Demons", Icon = "swords", ShowTabTitle = true })
    }

    if not Tabs.Farming or not Tabs.Hatching or not Tabs.Misc or not Tabs.Movement or not Tabs.Teleport or not Tabs.Visuals or not Tabs.Event then
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
        AutoBuyWings = false,
        AutoBuySneakyPet = false,
        AutoLevelUpTokens = false,
        AutoClaimAFKRewards = false
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
            Values = {"15 Seconds", "30 Seconds"},
            Value = "15 Seconds",
            Callback = function(selection)
                if selection == "15 Seconds" then
                    winsClaimDelay = 15
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

        local orderedEggNames = {"Egg 1 (Eiffel Tower)", "Egg 2 (Eiffel Tower)", "Egg 3 (Eiffel Tower)","Egg 1 (Empire State Bulding)", "Egg 2 (Empire State Bulding)", "Egg 3 (Empire State Bulding)","Egg 1 (Oriental Pearl Tower)", "Egg 2 (Oriental Pearl Tower)","Egg 1 (Big Ben)", "Egg 2 (Big Ben)","Egg 1 (Obelisk)", "Egg 2 (Obelisk)","Egg 1 (Leaning Tower)", "Egg 2 (Leaning Tower)","Egg 1 (Burj Khalifa Tower)", "Egg 2 (Burj Khalifa Tower)", "Egg 3 (Burj Khalifa Tower)","Egg 1 (Pixel World)", "Egg 2 (Pixel World)", "Egg 3 (Pixel World)","Egg 1 (Tokyo Tower)", "Egg 2 (Tokyo Tower)", "Egg 3 (Tokyo Tower)", "Egg 1 (Petronas Towers)", "Egg 2 (Petronas Towers)", "Egg 3 (Petronas Towers)", "Egg 1 (Mount Everest)", "Egg 2 (Mount Everest)"}
        local eggLookupTable = {["Egg 1 (Eiffel Tower)"]=7000001,["Egg 2 (Eiffel Tower)"]=7000002,["Egg 3 (Eiffel Tower)"]=7000003,["Egg 1 (Empire State Bulding)"]=7000004,["Egg 2 (Empire State Bulding)"]=7000005,["Egg 3 (Empire State Bulding)"]=7000006,["Egg 1 (Oriental Pearl Tower)"]=7000007,["Egg 2 (Oriental Pearl Tower)"]=7000008,["Egg 1 (Big Ben)"]=7000009,["Egg 2 (Big Ben)"]=7000010,["Egg 1 (Obelisk)"]=7000011,["Egg 2 (Obelisk)"]=7000012,["Egg 1 (Leaning Tower)"]=7000013,["Egg 2 (Leaning Tower)"]=7000014,["Egg 1 (Burj Khalifa Tower)"]=7000015,["Egg 2 (Burj Khalifa Tower)"]=7000016,["Egg 3 (Burj Khalifa Tower)"]=7000017,["Egg 1 (Pixel World)"]=7000018,["Egg 2 (Pixel World)"]=7000019,["Egg 3 (Pixel World)"]=7000020,["Egg 1 (Tokyo Tower)"]=7000021,["Egg 2 (Tokyo Tower)"]=7000022,["Egg 3 (Tokyo Tower)"]=7000023, ["Egg 1 (Petronas Towers)"]=7000026, ["Egg 2 (Petronas Towers)"]=7000027, ["Egg 3 (Petronas Towers)"]=7000028, ["Egg 1 (Mount Everest)"]=7000029, ["Egg 2 (Mount Everest)"]=7000030}
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
            { Name = "Mount Everest", WorldID = 11 }
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
            Desc = "Cycles through buying all event wings.",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoBuyWings = value
                if value then
                    WindUI:Notify({ Title = "Started", Content = "Auto buying event wings.", Duration = 4, Icon = "check" })
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
                                WindUI:Notify({ Title = "Error", Content = "RemoteEvent not found for buying wings.", Duration = 4, Icon = "alert-triangle" })
                                autoFarmState.AutoBuyWings = false
                                break
                            end
                            if not autoFarmState.AutoBuyWings then break end
                            task.wait(10)
                        end
                    end)
                else
                    WindUI:Notify({ Title = "Stopped", Content = "Auto buying event wings has been stopped.", Duration = 4, Icon = "x" })
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Buy Sneaky Pet",
            Desc = "Spams the buy event for the Sneaky Pet.",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoBuySneakyPet = value
                if value then
                    WindUI:Notify({ Title = "Started", Content = "Auto buying Sneaky Pet.", Duration = 4, Icon = "check" })
                    task.spawn(function()
                        while autoFarmState.AutoBuySneakyPet and player do
                            if msgRemote then
                                pcall(function()
                                    local args = {"\229\141\135\231\186\167\229\174\160\231\137\169"}
                                    msgRemote:FireServer(unpack(args))
                                end)
                            else
                                WindUI:Notify({ Title = "Error", Content = "RemoteEvent not found for buying pet.", Duration = 4, Icon = "alert-triangle" })
                                autoFarmState.AutoBuySneakyPet = false
                                break
                            end
                            if not autoFarmState.AutoBuySneakyPet then break end
                            task.wait(10)
                        end
                    end)
                else
                    WindUI:Notify({ Title = "Stopped", Content = "Auto buying Sneaky Pet has been stopped.", Duration = 4, Icon = "x" })
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Level Up Tokens",
            Desc = "Spams the level up event every 10 seconds.",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoLevelUpTokens = value
                if value then
                    WindUI:Notify({ Title = "Started", Content = "Auto leveling up tokens.", Duration = 4, Icon = "check" })
                    task.spawn(function()
                        while autoFarmState.AutoLevelUpTokens and player do
                            if msgRemote then
                                pcall(function()
                                    msgRemote:FireServer("LvlUp_Tokens")
                                end)
                            else
                                WindUI:Notify({ Title = "Error", Content = "RemoteEvent not found for leveling tokens.", Duration = 4, Icon = "alert-triangle" })
                                autoFarmState.AutoLevelUpTokens = false
                                break
                            end
                            task.wait(10)
                        end
                    end)
                else
                    WindUI:Notify({ Title = "Stopped", Content = "Auto leveling up tokens has been stopped.", Duration = 4, Icon = "x" })
                end
            end
        })

        Tabs.Event:Toggle({
            Title = "Auto Claim Event AFK Rewards",
            Desc = "Claims AFK rewards every 10 seconds.",
            Value = false,
            Callback = function(value)
                autoFarmState.AutoClaimAFKRewards = value
                if value then
                    WindUI:Notify({ Title = "Started", Content = "Auto claiming AFK rewards.", Duration = 4, Icon = "check" })
                    task.spawn(function()
                        local afkRemote = replicatedStorage:WaitForChild("Msg", 5) and replicatedStorage.Msg:WaitForChild("RemoteFunction", 5)
                        if not afkRemote then
                             WindUI:Notify({ Title = "Error", Content = "AFK Reward remote not found.", Duration = 5, Icon = "alert-triangle" })
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
                else
                    WindUI:Notify({ Title = "Stopped", Content = "Auto claiming AFK rewards has been stopped.", Duration = 4, Icon = "x" })
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
