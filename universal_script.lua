--[[
    Universal Roblox Script
    Version: 1.0.0
    Compatible with all executors
    Features: ESP, Aimbot, Combat Mods, Visuals
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local Config = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Tracers = false,
        Names = false,
        Distance = false,
        Health = false,
        Skeletons = false,
        TeamCheck = false,
        TeamColor = false,
        BotESP = false,
        MaxDistance = 1000,
        TextSize = 13,
        BoxColor = Color3.fromRGB(255, 255, 255),
        TracerColor = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        HealthColor = Color3.fromRGB(0, 255, 0)
    },
    Aimbot = {
        Enabled = false,
        Silent = false,
        TargetPart = "Head",
        TeamCheck = false,
        VisibilityCheck = false,
        Smoothness = 1,
        FOV = 100,
        ShowFOV = false,
        Prediction = false,
        HitChance = 100,
        AutoShoot = false,
        TriggerBot = false
    },
    Combat = {
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        InfiniteAmmo = false,
        AutoReload = false,
        WallBang = false,
        InstantHit = false,
        BulletTP = false
    },
    Visuals = {
        FullBright = false,
        NoFog = false,
        CustomTime = false,
        TimeValue = 14,
        Brightness = 1,
        Contrast = 1,
        Saturation = 1
    },
    Misc = {
        WalkSpeed = 16,
        JumpPower = 50,
        NoClip = false,
        InfJump = false,
        AutoJump = false,
        Fly = false,
        FlySpeed = 50
    }
}

-- ESP Components
local ESP = {
    Boxes = {},
    Tracers = {},
    Labels = {},
    HealthBars = {},
    Skeletons = {}
}

-- Create Drawing Objects Safely
local function CreateDrawing(type, properties)
    local success, drawing = pcall(function()
        local d = Drawing.new(type)
        for property, value in pairs(properties) do
            d[property] = value
        end
        return d
    end)
    
    if success then
        return drawing
    end
    return nil
end

-- Create ESP Components
local function CreateESPComponents()
    local components = {
        Box = CreateDrawing("Square", {
            Thickness = 1,
            Color = Config.ESP.BoxColor,
            Transparency = 1,
            Visible = false
        }),
        Tracer = CreateDrawing("Line", {
            Thickness = 1,
            Color = Config.ESP.TracerColor,
            Transparency = 1,
            Visible = false
        }),
        Name = CreateDrawing("Text", {
            Size = Config.ESP.TextSize,
            Center = true,
            Outline = true,
            Color = Config.ESP.TextColor,
            Transparency = 1,
            Visible = false
        }),
        Distance = CreateDrawing("Text", {
            Size = Config.ESP.TextSize,
            Center = true,
            Outline = true,
            Color = Config.ESP.TextColor,
            Transparency = 1,
            Visible = false
        }),
        HealthBar = CreateDrawing("Square", {
            Thickness = 1,
            Color = Config.ESP.HealthColor,
            Transparency = 1,
            Visible = false
        })
    }
    
    return components
end

-- FOV Circle
local FOVCircle = CreateDrawing("Circle", {
    Thickness = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 1,
    Visible = false,
    Radius = Config.Aimbot.FOV
})

-- Update FOV Circle
local function UpdateFOVCircle()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Config.Aimbot.FOV
        FOVCircle.Visible = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled
    end
end

-- Get Closest Player
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local part = character:FindFirstChild(Config.Aimbot.TargetPart)
        if not part then continue end
        
        local pos, visible = Camera:WorldToViewportPoint(part.Position)
        if not visible then continue end
        
        local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        if distance < shortestDistance then
            closestPlayer = player
            shortestDistance = distance
        end
    end
    
    return closestPlayer
end

-- Silent Aim Implementation
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Config.Aimbot.Silent and method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
        local player = GetClosestPlayer()
        if player and player.Character and player.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            if math.random(1, 100) <= Config.Aimbot.HitChance then
                args[1] = Ray.new(Camera.CFrame.Position, 
                    (player.Character[Config.Aimbot.TargetPart].Position - Camera.CFrame.Position).Unit * 1000)
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Update ESP
local function UpdateESP()
    for player, components in pairs(ESP.Boxes) do
        if not player.Character or not player:FindFirstChild("Humanoid") then
            for _, drawing in pairs(components) do
                drawing.Visible = false
            end
            continue
        end
        
        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid then
            for _, drawing in pairs(components) do
                drawing.Visible = false
            end
            continue
        end
        
        local pos, visible = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if not visible then
            for _, drawing in pairs(components) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Update Box ESP
        if Config.ESP.Boxes then
            local size = (Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(2, 3, 0)).Y - Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-2, -3, 0)).Y) / 2
            components.Box.Size = Vector2.new(size * 1.5, size * 2)
            components.Box.Position = Vector2.new(pos.X - size * 1.5 / 2, pos.Y - size)
            components.Box.Visible = true
            components.Box.Color = Config.ESP.TeamCheck and player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Config.ESP.BoxColor
        else
            components.Box.Visible = false
        end
        
        -- Update Tracers
        if Config.ESP.Tracers then
            components.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            components.Tracer.To = Vector2.new(pos.X, pos.Y)
            components.Tracer.Visible = true
            components.Tracer.Color = Config.ESP.TeamCheck and player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Config.ESP.TracerColor
        else
            components.Tracer.Visible = false
        end
        
        -- Update Name ESP
        if Config.ESP.Names then
            components.Name.Position = Vector2.new(pos.X, pos.Y - size * 2 - 15)
            components.Name.Text = player.Name
            components.Name.Visible = true
            components.Name.Color = Config.ESP.TeamCheck and player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Config.ESP.TextColor
        else
            components.Name.Visible = false
        end
        
        -- Update Health Bar
        if Config.ESP.Health then
            local healthBarSize = Vector2.new(2, size * 2)
            local healthBarPos = Vector2.new(pos.X - size * 1.5 / 2 - 5, pos.Y - size)
            local healthPercentage = humanoid.Health / humanoid.MaxHealth
            
            components.HealthBar.Size = Vector2.new(healthBarSize.X, healthBarSize.Y * healthPercentage)
            components.HealthBar.Position = Vector2.new(healthBarPos.X, healthBarPos.Y + healthBarSize.Y * (1 - healthPercentage))
            components.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercentage), 255 * healthPercentage, 0)
            components.HealthBar.Visible = true
        else
            components.HealthBar.Visible = false
        end
    end
end

-- Initialize ESP for new players
local function InitializeESP(player)
    if player == LocalPlayer then return end
    ESP.Boxes[player] = CreateESPComponents()
end

-- Clean up ESP for leaving players
local function CleanupESP(player)
    if ESP.Boxes[player] then
        for _, drawing in pairs(ESP.Boxes[player]) do
            drawing:Remove()
        end
        ESP.Boxes[player] = nil
    end
end

-- Player Events
Players.PlayerAdded:Connect(InitializeESP)
Players.PlayerRemoving:Connect(CleanupESP)

-- Initialize existing players
for _, player in pairs(Players:GetPlayers()) do
    InitializeESP(player)
end

-- Combat Modifications
local function ApplyCombatMods()
    if Config.Combat.NoRecoil then
        -- Implement no recoil logic here
        -- This varies depending on the game
    end
    
    if Config.Combat.NoSpread then
        -- Implement no spread logic here
        -- This varies depending on the game
    end
end

-- Visual Modifications
local function ApplyVisuals()
    if Config.Visuals.FullBright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    
    if Config.Visuals.NoFog then
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").FogStart = 0
    end
    
    if Config.Visuals.CustomTime then
        game:GetService("Lighting").ClockTime = Config.Visuals.TimeValue
    end
end

-- Movement Modifications
local function ApplyMovementMods()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Config.Misc.WalkSpeed ~= 16 then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.Misc.WalkSpeed
        end
        
        if Config.Misc.JumpPower ~= 50 then
            LocalPlayer.Character.Humanoid.JumpPower = Config.Misc.JumpPower
        end
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    UpdateESP()
    ApplyCombatMods()
    ApplyVisuals()
    ApplyMovementMods()
    
    -- Aimbot
    if Config.Aimbot.Enabled and not Config.Aimbot.Silent then
        local target = GetClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
            if part then
                local pos = Camera:WorldToViewportPoint(part.Position)
                local targetPos = Vector2.new(pos.X, pos.Y)
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local delta = (targetPos - mousePos) / Config.Aimbot.Smoothness
                
                mousemoverel(delta.X, delta.Y)
                
                if Config.Aimbot.AutoShoot then
                    mouse1press()
                    wait()
                    mouse1release()
                end
            end
        end
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.End then
            Config.ESP.Enabled = not Config.ESP.Enabled
        elseif input.KeyCode == Enum.KeyCode.RightAlt then
            Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.Misc.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Return Configuration for UI Integration
return Config
