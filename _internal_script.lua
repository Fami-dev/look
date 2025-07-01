local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Arcvour Script (CLIMB AND JUMP TOWER)",
   LoadingTitle = "Arcvour Script",
   LoadingSubtitle = "Climb & Jump",
   Theme = "Amethyst",
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FileName = "ArcvourConfig"
   },
   KeySystem = true,
   KeySettings = {
      Title = "Arcvour Script",
      Subtitle = "Key System",
      Note = "Order key 1$, telegram @Arcvour",
      FileName = "ArcvourKey",
      SaveKey = true,
      Key = {"Hello"}
   }
})

local FarmTab = Window:CreateTab("Farming", "dollar-sign")
local HatchTab = Window:CreateTab("Hatching", "egg")
local MovementTab = Window:CreateTab("Movement", "footprints")
local VisualsTab = Window:CreateTab("Visuals", "eye")

FarmTab:CreateSection("Auto Farm Coins")
FarmTab:CreateLabel("Number is tower height. Higher number = slower. Buy better wings to go faster.") 
local isAutoCoining,coinAmount=false,14400
FarmTab:CreateInput({Name="Height Amount",PlaceholderText="e.g. 14400",NumbersOnly=true,Callback=function(t)local n=tonumber(t)if n then coinAmount=n;print("COINS: Set height to > "..coinAmount)end end})
FarmTab:CreateToggle({Name="Auto Coins",Callback=function(s)isAutoCoining=s;if s then print("COINS: ON")spawn(function()while isAutoCoining do local a,b=pcall(function()game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\232\181\183\232\183\179",coinAmount);game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\232\144\189\229\156\176")end)if not a then warn(b)isAutoCoining=false;break end task.wait(0.1)end print("COINS: OFF")end)else print("COINS: OFF")end end})

FarmTab:CreateSection("Auto Farm Wins & Magic Token")
FarmTab:CreateLabel("Teleport to tower top, wait 0.5s for request, wait 0.5s, teleport to z=0, wait 0.1s, return with y+5.")
local isAutoWinning,isAutoMagicking,selectedMap,isWinLoopRunning,isTeleportMode=false,false,"Eiffel Tower",false,false
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
FarmTab:CreateDropdown({
    Name="Select Tower",
    Options={"Eiffel Tower","Empire State Building","Oriental Pearl Tower","Big Ben","Obelisk","Leaning Tower","Burj Khalifa Tower","Pixel World","Tokyo Tower"},
    Default="Eiffel Tower",
    Callback=function(t)selectedMap=t[1];print("WINS/MAGIC: Selected Tower > "..selectedMap)end
})
local function ManageWinLoop()
    if (isAutoWinning or isAutoMagicking) and not isWinLoopRunning then
        isWinLoopRunning=true;print("WINS/MAGIC: Loop ON. Interval: "..(isTeleportMode and "12.6s" or "13s"))
        spawn(function()
            while isWinLoopRunning do
                local s,e=pcall(function()
                    local player = game.Players.LocalPlayer
                    if isTeleportMode and player.Character and player.Character.HumanoidRootPart then
                        local originalPosition = player.Character.HumanoidRootPart.CFrame
                        local returnPosition = CFrame.new(originalPosition.X, originalPosition.Y + 5, originalPosition.Z)
                        print("WINS/MAGIC: Current position saved, return position y+5")
                        if towerCoordinates[selectedMap] then
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(towerCoordinates[selectedMap])
                            print("WINS/MAGIC: Teleported to "..selectedMap)
                        end
                        task.wait(0.5)
                        if isAutoWinning then 
                            game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182wins")
                            print("WINS/MAGIC: Wins requested")
                        end
                        if isAutoMagicking then 
                            game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182MagicToken")
                            print("WINS/MAGIC: Magic Token requested")
                        end
                        task.wait(0.5)
                        if towerCoordinates[selectedMap] then
                            local towerPos = towerCoordinates[selectedMap]
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(towerPos.X, towerPos.Y, 0)
                            print("WINS/MAGIC: Teleported to z=0 position")
                        end
                        task.wait(0.1)
                        player.Character.HumanoidRootPart.CFrame = returnPosition
                        print("WINS/MAGIC: Returned to current position with y+5")
                        task.wait(12.6 - 1.1)
                    else
                        if isAutoWinning then 
                            game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182wins")
                            print("WINS/MAGIC: Wins requested")
                        end
                        if isAutoMagicking then 
                            game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\233\162\134\229\143\150\230\165\188\233\161\182MagicToken")
                            print("WINS/MAGIC: Magic Token requested")
                        end
                        task.wait(13)
                    end
                end)
                if not s then warn("WINS/MAGIC Error:",e);isWinLoopRunning=false;break end
            end
            print("WINS/MAGIC: Loop OFF.")
        end)
    elseif not isAutoWinning and not isAutoMagicking then
        isWinLoopRunning=false
    end
end
FarmTab:CreateToggle({Name="Auto Wins",Callback=function(s)isAutoWinning=s;print("WINS: Status >",tostring(s));ManageWinLoop()end})
FarmTab:CreateToggle({Name="Auto Magic Token",Callback=function(s)isAutoMagicking=s;print("MAGIC TOKEN: Status >",tostring(s));ManageWinLoop()end})
FarmTab:CreateToggle({
    Name="Enable Teleport Mode",
    CurrentValue=false,
    Flag="TeleportMode",
    Callback=function(s)isTeleportMode=s;print("WINS/MAGIC: Teleport Mode >",tostring(s));ManageWinLoop()end
})

HatchTab:CreateSection("Auto Hatch Eggs")
local orderedEggNames = {"Egg 1 (Eiffel Tower)", "Egg 2 (Eiffel Tower)", "Egg 3 (Eiffel Tower)","Egg 1 (Empire State Bulding)", "Egg 2 (Empire State Bulding)", "Egg 3 (Empire State Bulding)","Egg 1 (Oriental Pearl Tower)", "Egg 2 (Oriental Pearl Tower)","Egg 1 (Big Ben)", "Egg 2 (Big Ben)","Egg 1 (Obelisk)", "Egg 2 (Obelisk)","Egg 1 (Leaning Tower)", "Egg 2 (Leaning Tower)","Egg 1 (Burj Khalifa Tower)", "Egg 2 (Burj Khalifa Tower)", "Egg 3 (Burj Khalifa Tower)","Egg 1 (Pixel World)", "Egg 2 (Pixel World)", "Egg 3 (Pixel World)","Egg 1 (Tokyo Tower)", "Egg 2 (Tokyo Tower)", "Egg 3 (Tokyo Tower)"}
local eggLookupTable = {["Egg 1 (Eiffel Tower)"] = 7000001, ["Egg 2 (Eiffel Tower)"] = 7000002, ["Egg 3 (Eiffel Tower)"] = 7000003,["Egg 1 (Empire State Bulding)"] = 7000004, ["Egg 2 (Empire State Bulding)"] = 7000005, ["Egg 3 (Empire State Bulding)"] = 7000006,["Egg 1 (Oriental Pearl Tower)"] = 7000007, ["Egg 2 (Oriental Pearl Tower)"] = 7000008,["Egg 1 (Big Ben)"] = 7000009, ["Egg 2 (Big Ben)"] = 7000010,["Egg 1 (Obelisk)"] = 7000011, ["Egg 2 (Obelisk)"] = 7000012,["Egg 1 (Leaning Tower)"] = 7000013, ["Egg 2 (Leaning Tower)"] = 7000014,["Egg 1 (Burj Khalifa Tower)"] = 7000015, ["Egg 2 (Burj Khalifa Tower)"] = 7000016, ["Egg 3 (Burj Khalifa Tower)"] = 7000017,["Egg 1 (Pixel World)"] = 7000018, ["Egg 2 (Pixel World)"] = 7000019, ["Egg 3 (Pixel World)"] = 7000020,["Egg 1 (Tokyo Tower)"] = 7000021, ["Egg 2 (Tokyo Tower)"] = 7000022, ["Egg 3 (Tokyo Tower)"] = 7000023}
local isAutoHatching = false
local selectedEggID = eggLookupTable[orderedEggNames[1]]
HatchTab:CreateDropdown({Name="Select Egg",Options=orderedEggNames,Default=orderedEggNames[1],Callback=function(t) local actualName=t[1];selectedEggID=eggLookupTable[actualName];print("HATCH: ID > "..tostring(selectedEggID))end})
HatchTab:CreateToggle({Name="Auto Hatch",Callback=function(s)isAutoHatching=s;if s then print("HATCH: ON")spawn(function()while isAutoHatching do local a,b=pcall(function()game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer("\230\138\189\232\155\139\229\188\149\229\175\188\231\187\147\230\157\159");game:GetService("ReplicatedStorage").Tool.DrawUp.Msg.DrawHero:InvokeServer(selectedEggID,1)end)if not a then warn(b)isAutoHatching=false;break end task.wait(0.1)end print("HATCH: OFF")end)else print("HATCH: OFF")end end})

MovementTab:CreateSection("Climb Settings")
MovementTab:CreateToggle({Name = "Auto Climb",Callback = function(state)if state then game:GetService("Players").LocalPlayer.Setting.isAutoOn.Value = 1; print("PLAYER: Auto Climb ON") else game:GetService("Players").LocalPlayer.Setting.isAutoOn.Value = 0; print("PLAYER: Auto Climb OFF") end end})
MovementTab:CreateToggle({Name = "Auto Super Climb",Callback = function(state)if state then game:GetService("Players").LocalPlayer.Setting.isAutoCllect.Value = 1; print("PLAYER: Auto Super Climb ON") else game:GetService("Players").LocalPlayer.Setting.isAutoCllect.Value = 0; print("PLAYER: Auto Super Climb OFF") end end})
MovementTab:CreateSection("Movement Exploits")
local isSpeedEnabled = false
local isInfJumpEnabled = false
local isNoClipEnabled = false
local speedValue = 100
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
MovementTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeed",
    Callback = function(Value)
        isSpeedEnabled = Value
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if isSpeedEnabled then
                humanoid.WalkSpeed = speedValue
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
})
MovementTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 100,
    Flag = "SpeedValue",
    Callback = function(Value)
        speedValue = Value
        if isSpeedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = speedValue
        end
    end
})
MovementTab:CreateToggle({
    Name = "Enable Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        isInfJumpEnabled = Value
        if isInfJumpEnabled then
            userInputService.JumpRequest:Connect(function()
                if isInfJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})
MovementTab:CreateToggle({
    Name = "Enable No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        isNoClipEnabled = Value
        if isNoClipEnabled then
            while isNoClipEnabled do
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                wait(0.1)
            end
        else
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})
player.CharacterAdded:Connect(function(character)
    if isSpeedEnabled then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = speedValue
    end
    if isNoClipEnabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

VisualsTab:CreateSection("Display Settings")
VisualsTab:CreateToggle({Name = "Hide Pets",Callback = function(state)if state then game:GetService("Players").LocalPlayer.Setting.ShowPets.Value = 0; print("PLAYER: Hide Pets ON") else game:GetService("Players").LocalPlayer.Setting.ShowPets.Value = 1; print("PLAYER: Hide Pets OFF") end end})
VisualsTab:CreateToggle({Name = "Hide JumpPals",Callback = function(state)if state then game:GetService("Players").LocalPlayer.Setting.ShowJumpPal.Value = 0; print("PLAYER: Hide JumpPals ON") else game:GetService("Players").LocalPlayer.Setting.ShowJumpPal.Value = 1; print("PLAYER: Hide JumpPals OFF") end end})

Rayfield:Notify({Title="Arcvour Script Ready",Content="All features have been loaded.",Duration=8})
