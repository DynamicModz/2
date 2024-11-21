--[[
    LuaGuard Custom UI Library
    Version: 2.0.0
    Author: OpenHands
    Features: License System, Enhanced UI, API Integration
]]

-- HTTP Service for API calls
local HttpService = game:GetService("HttpService")

local LuaGuard = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- UI Settings
LuaGuard.Settings = {
    Theme = {
        Background = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        Error = Color3.fromRGB(255, 75, 75),
        Success = Color3.fromRGB(75, 255, 75),
        Warning = Color3.fromRGB(255, 255, 75)
    },
    Animation = {
        Duration = 0.3,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },
    License = {
        Enabled = false,
        API = {
            Endpoint = "",
            Key = "",
            ValidateEndpoint = "/validate",
            RegisterEndpoint = "/register",
            RevokeEndpoint = "/revoke"
        }
    }
}

-- License System
LuaGuard.License = {}

function LuaGuard.License:SetEndpoint(endpoint)
    LuaGuard.Settings.License.API.Endpoint = endpoint
end

function LuaGuard.License:ValidateKey(key, callback)
    if not LuaGuard.Settings.License.Enabled then
        if callback then callback(true, "License system disabled") end
        return
    end
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = LuaGuard.Settings.License.API.Endpoint .. LuaGuard.Settings.License.API.ValidateEndpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                key = key,
                hwid = game:GetService("RbxAnalyticsService"):GetClientId()
            })
        })
    end)
    
    if success and response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if callback then callback(data.valid, data.message) end
        return data.valid
    else
        if callback then callback(false, "Failed to validate key") end
        return false
    end
end

function LuaGuard.License:RegisterKey(key, callback)
    if not LuaGuard.Settings.License.Enabled then
        if callback then callback(true, "License system disabled") end
        return
    end
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = LuaGuard.Settings.License.API.Endpoint .. LuaGuard.Settings.License.API.RegisterEndpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                key = key,
                hwid = game:GetService("RbxAnalyticsService"):GetClientId()
            })
        })
    end)
    
    if success and response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if callback then callback(data.success, data.message) end
        return data.success
    else
        if callback then callback(false, "Failed to register key") end
        return false
    end
end

-- Notification System
LuaGuard.Notifications = {}

function LuaGuard.Notifications:Show(title, message, type, duration)
    duration = duration or 3
    type = type or "info"
    
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "LuaGuardNotification"
    NotifGui.Parent = game:GetService("CoreGui")
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 80)
    NotifFrame.Position = UDim2.new(1, 10, 0.8, 0)
    NotifFrame.BackgroundColor3 = LuaGuard.Settings.Theme.Background
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifGui
    
    local TypeColor = Instance.new("Frame")
    TypeColor.Size = UDim2.new(0, 4, 1, 0)
    TypeColor.BackgroundColor3 = type == "error" and LuaGuard.Settings.Theme.Error 
        or type == "success" and LuaGuard.Settings.Theme.Success 
        or type == "warning" and LuaGuard.Settings.Theme.Warning 
        or LuaGuard.Settings.Theme.Accent
    TypeColor.BorderSizePixel = 0
    TypeColor.Parent = NotifFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 15, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = LuaGuard.Settings.Theme.TextColor
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifFrame
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -20, 0, 40)
    MessageLabel.Position = UDim2.new(0, 15, 0, 30)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = LuaGuard.Settings.Theme.TextColor
    MessageLabel.TextSize = 14
    MessageLabel.Font = Enum.Font.SourceSans
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = NotifFrame
    
    -- Animation
    NotifFrame:TweenPosition(
        UDim2.new(1, -260, 0.8, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true
    )
    
    task.delay(duration, function()
        NotifFrame:TweenPosition(
            UDim2.new(1, 10, 0.8, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true,
            function()
                NotifGui:Destroy()
            end
        )
    end)
end

-- Keybind System
LuaGuard.Keybinds = {}
local activeKeybinds = {}

function LuaGuard.Keybinds:Bind(key, callback)
    activeKeybinds[key] = callback
end

function LuaGuard.Keybinds:Unbind(key)
    activeKeybinds[key] = nil
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        for key, callback in pairs(activeKeybinds) do
            if input.KeyCode == Enum.KeyCode[key] then
                callback()
            end
        end
    end
end)

-- Tab System
LuaGuard.Tabs = {}

function LuaGuard.Tabs:Create(name)
    local tab = {}
    tab.Elements = {}
    tab.Name = name
    return tab
end

-- Save/Load System
LuaGuard.SaveSystem = {}

function LuaGuard.SaveSystem:SaveConfig(name, data)
    if not isfolder("LuaGuard") then
        makefolder("LuaGuard")
    end
    writefile("LuaGuard/" .. name .. ".json", HttpService:JSONEncode(data))
end

function LuaGuard.SaveSystem:LoadConfig(name)
    if isfile("LuaGuard/" .. name .. ".json") then
        return HttpService:JSONDecode(readfile("LuaGuard/" .. name .. ".json"))
    end
    return nil
end

-- Analytics System
LuaGuard.Analytics = {
    Events = {}
}

function LuaGuard.Analytics:TrackEvent(eventName, data)
    table.insert(self.Events, {
        name = eventName,
        data = data,
        timestamp = os.time()
    })
    
    -- You can implement API calls here to track events
end

function LuaGuard.Analytics:GetEvents()
    return self.Events
end

-- Watermark System
LuaGuard.Watermark = {
    Enabled = false,
    Text = "LuaGuard",
    Position = "TopRight"
}

function LuaGuard.Watermark:SetText(text)
    self.Text = text
    -- Update watermark if visible
    if self.Enabled and self.WatermarkLabel then
        self.WatermarkLabel.Text = text
    end
end

function LuaGuard.Watermark:SetPosition(position)
    self.Position = position
    -- Update position if visible
    if self.Enabled and self.WatermarkFrame then
        local frame = self.WatermarkFrame
        if position == "TopRight" then
            frame.Position = UDim2.new(1, -210, 0, 10)
        elseif position == "TopLeft" then
            frame.Position = UDim2.new(0, 10, 0, 10)
        elseif position == "BottomRight" then
            frame.Position = UDim2.new(1, -210, 1, -40)
        elseif position == "BottomLeft" then
            frame.Position = UDim2.new(0, 10, 1, -40)
        end
    end
end

-- Performance Monitoring
LuaGuard.Performance = {
    Enabled = false,
    FPS = 0,
    Ping = 0,
    Memory = 0
}

function LuaGuard.Performance:StartMonitoring()
    self.Enabled = true
    local lastTime = os.clock()
    local frameCount = 0
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if not self.Enabled then return end
        
        frameCount = frameCount + 1
        local currentTime = os.clock()
        local deltaTime = currentTime - lastTime
        
        if deltaTime >= 1 then
            self.FPS = frameCount
            frameCount = 0
            lastTime = currentTime
            
            -- Update ping
            self.Ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            
            -- Update memory usage
            self.Memory = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
            
            -- Update performance display if visible
            if self.PerformanceFrame then
                self.PerformanceLabel.Text = string.format(
                    "FPS: %d | Ping: %dms | Memory: %dMB",
                    self.FPS,
                    self.Ping,
                    self.Memory
                )
            end
        end
    end)
end

-- Radar System
LuaGuard.Radar = {
    Enabled = false,
    Size = 200,
    Range = 100,
    ShowTeam = true,
    Position = UDim2.new(1, -220, 0, 10)
}

function LuaGuard.Radar:CreateRadar()
    local RadarFrame = Instance.new("Frame")
    RadarFrame.Size = UDim2.new(0, self.Size, 0, self.Size)
    RadarFrame.Position = self.Position
    RadarFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    RadarFrame.BorderSizePixel = 0
    
    local RadarCenter = Instance.new("Frame")
    RadarCenter.Size = UDim2.new(0, 4, 0, 4)
    RadarCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
    RadarCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RadarCenter.BorderSizePixel = 0
    RadarCenter.Parent = RadarFrame
    
    self.RadarFrame = RadarFrame
    self.Points = {}
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if not self.Enabled then return end
        self:UpdateRadar()
    end)
    
    return RadarFrame
end

function LuaGuard.Radar:UpdateRadar()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer.Character then return end
    
    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                local point = self.Points[player]
                if not point then
                    point = Instance.new("Frame")
                    point.Size = UDim2.new(0, 4, 0, 4)
                    point.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    point.BorderSizePixel = 0
                    point.Parent = self.RadarFrame
                    self.Points[player] = point
                end
                
                local relativePos = (playerRoot.Position - rootPart.Position) * Vector3.new(1, 0, 1)
                local angle = math.atan2(relativePos.Z, relativePos.X)
                local distance = relativePos.Magnitude
                
                if distance <= self.Range then
                    local x = (math.cos(angle) * distance / self.Range) * (self.Size/2) + self.Size/2
                    local y = (math.sin(angle) * distance / self.Range) * (self.Size/2) + self.Size/2
                    point.Position = UDim2.new(0, x-2, 0, y-2)
                    point.Visible = true
                else
                    point.Visible = false
                end
            end
        end
    end
end

-- Spectator List
LuaGuard.Spectators = {
    Enabled = false,
    Position = UDim2.new(1, -210, 0.5, -100)
}

function LuaGuard.Spectators:Update()
    if not self.Enabled or not self.SpectatorList then return end
    
    local spectators = {}
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if not character or not character:FindFirstChild("Humanoid") then
                local camera = workspace.CurrentCamera
                if camera and camera.CameraSubject and camera.CameraSubject:IsDescendantOf(LocalPlayer.Character) then
                    table.insert(spectators, player.Name)
                end
            end
        end
    end
    
    self.SpectatorList.Text = "Spectators:\n" .. table.concat(spectators, "\n")
end

-- Target Info
LuaGuard.TargetInfo = {
    Enabled = false,
    Target = nil,
    Position = UDim2.new(0.5, -100, 0, 10)
}

function LuaGuard.TargetInfo:UpdateInfo()
    if not self.Enabled or not self.InfoFrame then return end
    
    if self.Target and self.Target.Character then
        local humanoid = self.Target.Character:FindFirstChild("Humanoid")
        if humanoid then
            self.HealthLabel.Text = string.format("Health: %.0f", humanoid.Health)
            -- Add more info updates here
        end
    end
end

-- Particle System
LuaGuard.Particles = {
    Enabled = false,
    ParticleList = {},
    Settings = {
        Amount = 50,
        Speed = 1,
        Size = {min = 2, max = 5},
        Colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255)
        },
        Direction = "Up",
        Lifetime = 2
    }
}

function LuaGuard.Particles:CreateParticle(position)
    local particle = Drawing.new("Square")
    particle.Size = Vector2.new(
        math.random(self.Settings.Size.min, self.Settings.Size.max),
        math.random(self.Settings.Size.min, self.Settings.Size.max)
    )
    particle.Position = position
    particle.Filled = true
    particle.Color = self.Settings.Colors[math.random(1, #self.Settings.Colors)]
    particle.Transparency = 1
    particle.Visible = true
    
    table.insert(self.ParticleList, {
        particle = particle,
        velocity = Vector2.new(
            math.random(-100, 100) / 100 * self.Settings.Speed,
            self.Settings.Direction == "Up" and -self.Settings.Speed or self.Settings.Speed
        ),
        created = tick()
    })
end

function LuaGuard.Particles:Update()
    if not self.Enabled then return end
    
    for i = #self.ParticleList, 1, -1 do
        local p = self.ParticleList[i]
        local elapsed = tick() - p.created
        
        if elapsed > self.Settings.Lifetime then
            p.particle:Remove()
            table.remove(self.ParticleList, i)
        else
            p.particle.Position = p.particle.Position + p.velocity
            p.particle.Transparency = 1 - (elapsed / self.Settings.Lifetime)
        end
    end
end

-- Sound System
LuaGuard.Sounds = {
    Enabled = false,
    Volume = 0.5,
    Sounds = {
        Click = "rbxassetid://6895079853",
        Hover = "rbxassetid://6895079733",
        Switch = "rbxassetid://6895079980",
        Alert = "rbxassetid://6895079626"
    }
}

function LuaGuard.Sounds:Play(soundName)
    if not self.Enabled then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = self.Sounds[soundName]
    sound.Volume = self.Volume
    sound.Parent = game:GetService("CoreGui")
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Animation System
LuaGuard.Animations = {
    Enabled = true,
    Speed = 0.3,
    Style = Enum.EasingStyle.Quad,
    Direction = Enum.EasingDirection.Out
}

function LuaGuard.Animations:Tween(object, properties)
    if not self.Enabled then
        for property, value in pairs(properties) do
            object[property] = value
        end
        return
    end
    
    local tween = game:GetService("TweenService"):Create(
        object,
        TweenInfo.new(self.Speed, self.Style, self.Direction),
        properties
    )
    tween:Play()
    return tween
end

-- Dragging System
LuaGuard.Dragging = {
    Enabled = true,
    DragSpeed = 0.1,
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

function LuaGuard.Dragging:Enable(frame, dragFrame)
    if not self.Enabled then return end
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                end
            end)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.Dragging then
            local delta = input.Position - self.DragStart
            LuaGuard.Animations:Tween(frame, {
                Position = UDim2.new(
                    self.StartPos.X.Scale,
                    self.StartPos.X.Offset + delta.X,
                    self.StartPos.Y.Scale,
                    self.StartPos.Y.Offset + delta.Y
                )
            })
        end
    end)
end

-- Theme System
LuaGuard.Themes = {
    Current = "Default",
    List = {
        Default = {
            Background = Color3.fromRGB(25, 25, 25),
            Accent = Color3.fromRGB(0, 170, 255),
            TextColor = Color3.fromRGB(255, 255, 255),
            ElementBackground = Color3.fromRGB(35, 35, 35)
        },
        Dark = {
            Background = Color3.fromRGB(15, 15, 15),
            Accent = Color3.fromRGB(90, 90, 90),
            TextColor = Color3.fromRGB(255, 255, 255),
            ElementBackground = Color3.fromRGB(25, 25, 25)
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 240),
            Accent = Color3.fromRGB(0, 150, 255),
            TextColor = Color3.fromRGB(0, 0, 0),
            ElementBackground = Color3.fromRGB(220, 220, 220)
        },
        Discord = {
            Background = Color3.fromRGB(54, 57, 63),
            Accent = Color3.fromRGB(114, 137, 218),
            TextColor = Color3.fromRGB(255, 255, 255),
            ElementBackground = Color3.fromRGB(47, 49, 54)
        },
        Spotify = {
            Background = Color3.fromRGB(25, 20, 20),
            Accent = Color3.fromRGB(30, 215, 96),
            TextColor = Color3.fromRGB(255, 255, 255),
            ElementBackground = Color3.fromRGB(40, 40, 40)
        }
    }
}

function LuaGuard.Themes:Apply(themeName)
    local theme = self.List[themeName]
    if not theme then return end
    
    self.Current = themeName
    LuaGuard.Settings.Theme = theme
    
    -- Update all UI elements with new theme
    if LuaGuard.UpdateTheme then
        LuaGuard.UpdateTheme()
    end
end

-- Create base GUI
function LuaGuard.new(title)
    local gui = {}
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LuaGuardUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = LuaGuard.Settings.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Create title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = LuaGuard.Settings.Theme.Accent
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    -- Create title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(1, -30, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title or "LuaGuard UI"
    TitleText.TextColor3 = LuaGuard.Settings.Theme.TextColor
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.SourceSansBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Create content frame
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, -20, 1, -40)
    ContentFrame.Position = UDim2.new(0, 10, 0, 35)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = LuaGuard.Settings.Theme.Accent
    ContentFrame.Parent = MainFrame
    
    -- Make UI draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- UI Elements Creation Functions
    function gui:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = text
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.Position = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 35)
        Button.BackgroundColor3 = LuaGuard.Settings.Theme.ElementBackground
        Button.BorderSizePixel = 0
        Button.Text = text
        Button.TextColor3 = LuaGuard.Settings.Theme.TextColor
        Button.TextSize = 14
        Button.Font = Enum.Font.SourceSans
        Button.Parent = ContentFrame
        
        Button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        
        return Button
    end
    
    function gui:AddToggle(text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = text
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.Position = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 35)
        ToggleFrame.BackgroundColor3 = LuaGuard.Settings.Theme.ElementBackground
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = ContentFrame
        
        local ToggleText = Instance.new("TextLabel")
        ToggleText.Size = UDim2.new(1, -50, 1, 0)
        ToggleText.Position = UDim2.new(0, 10, 0, 0)
        ToggleText.BackgroundTransparency = 1
        ToggleText.Text = text
        ToggleText.TextColor3 = LuaGuard.Settings.Theme.TextColor
        ToggleText.TextSize = 14
        ToggleText.Font = Enum.Font.SourceSans
        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
        ToggleText.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
        ToggleButton.BackgroundColor3 = default and LuaGuard.Settings.Theme.Accent or Color3.fromRGB(100, 100, 100)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame
        
        local enabled = default or false
        
        ToggleButton.MouseButton1Click:Connect(function()
            enabled = not enabled
            ToggleButton.BackgroundColor3 = enabled and LuaGuard.Settings.Theme.Accent or Color3.fromRGB(100, 100, 100)
            if callback then callback(enabled) end
        end)
        
        return ToggleFrame
    end
    
    -- Add a license key input
    function gui:AddLicenseKeyInput(callback)
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Name = "LicenseKeyInput"
        KeyFrame.Size = UDim2.new(1, 0, 0, 60)
        KeyFrame.Position = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 65)
        KeyFrame.BackgroundColor3 = LuaGuard.Settings.Theme.ElementBackground
        KeyFrame.BorderSizePixel = 0
        KeyFrame.Parent = ContentFrame
        
        local KeyLabel = Instance.new("TextLabel")
        KeyLabel.Size = UDim2.new(1, -20, 0, 20)
        KeyLabel.Position = UDim2.new(0, 10, 0, 5)
        KeyLabel.BackgroundTransparency = 1
        KeyLabel.Text = "License Key"
        KeyLabel.TextColor3 = LuaGuard.Settings.Theme.TextColor
        KeyLabel.TextSize = 14
        KeyLabel.Font = Enum.Font.SourceSansBold
        KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
        KeyLabel.Parent = KeyFrame
        
        local KeyInput = Instance.new("TextBox")
        KeyInput.Size = UDim2.new(1, -120, 0, 25)
        KeyInput.Position = UDim2.new(0, 10, 0, 30)
        KeyInput.BackgroundColor3 = LuaGuard.Settings.Theme.Background
        KeyInput.BorderSizePixel = 0
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "Enter your license key..."
        KeyInput.TextColor3 = LuaGuard.Settings.Theme.TextColor
        KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        KeyInput.TextSize = 14
        KeyInput.Font = Enum.Font.SourceSans
        KeyInput.Parent = KeyFrame
        
        local ValidateButton = Instance.new("TextButton")
        ValidateButton.Size = UDim2.new(0, 80, 0, 25)
        ValidateButton.Position = UDim2.new(1, -90, 0, 30)
        ValidateButton.BackgroundColor3 = LuaGuard.Settings.Theme.Accent
        ValidateButton.BorderSizePixel = 0
        ValidateButton.Text = "Validate"
        ValidateButton.TextColor3 = LuaGuard.Settings.Theme.TextColor
        ValidateButton.TextSize = 14
        ValidateButton.Font = Enum.Font.SourceSansBold
        ValidateButton.Parent = KeyFrame
        
        ValidateButton.MouseButton1Click:Connect(function()
            local key = KeyInput.Text
            if callback then
                callback(key)
            end
        end)
        
        return KeyFrame
    end
    
    -- Add a dropdown
    function gui:AddDropdown(text, options, default, callback)
        local DropFrame = Instance.new("Frame")
        DropFrame.Name = text
        DropFrame.Size = UDim2.new(1, 0, 0, 60)
        DropFrame.Position = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 65)
        DropFrame.BackgroundColor3 = LuaGuard.Settings.Theme.ElementBackground
        DropFrame.BorderSizePixel = 0
        DropFrame.Parent = ContentFrame
        
        local DropLabel = Instance.new("TextLabel")
        DropLabel.Size = UDim2.new(1, -20, 0, 20)
        DropLabel.Position = UDim2.new(0, 10, 0, 5)
        DropLabel.BackgroundTransparency = 1
        DropLabel.Text = text
        DropLabel.TextColor3 = LuaGuard.Settings.Theme.TextColor
        DropLabel.TextSize = 14
        DropLabel.Font = Enum.Font.SourceSansBold
        DropLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropLabel.Parent = DropFrame
        
        local DropButton = Instance.new("TextButton")
        DropButton.Size = UDim2.new(1, -20, 0, 25)
        DropButton.Position = UDim2.new(0, 10, 0, 30)
        DropButton.BackgroundColor3 = LuaGuard.Settings.Theme.Background
        DropButton.BorderSizePixel = 0
        DropButton.Text = default or "Select..."
        DropButton.TextColor3 = LuaGuard.Settings.Theme.TextColor
        DropButton.TextSize = 14
        DropButton.Font = Enum.Font.SourceSans
        DropButton.TextXAlignment = Enum.TextXAlignment.Left
        DropButton.Parent = DropFrame
        
        local DropList = Instance.new("Frame")
        DropList.Size = UDim2.new(1, -20, 0, #options * 25)
        DropList.Position = UDim2.new(0, 10, 0, 60)
        DropList.BackgroundColor3 = LuaGuard.Settings.Theme.Background
        DropList.BorderSizePixel = 0
        DropList.Visible = false
        DropList.ZIndex = 10
        DropList.Parent = DropFrame
        
        local isOpen = false
        
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Size = UDim2.new(1, 0, 0, 25)
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
            OptionButton.BackgroundColor3 = LuaGuard.Settings.Theme.Background
            OptionButton.BorderSizePixel = 0
            OptionButton.Text = option
            OptionButton.TextColor3 = LuaGuard.Settings.Theme.TextColor
            OptionButton.TextSize = 14
            OptionButton.Font = Enum.Font.SourceSans
            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
            OptionButton.ZIndex = 10
            OptionButton.Parent = DropList
            
            OptionButton.MouseButton1Click:Connect(function()
                DropButton.Text = option
                DropList.Visible = false
                isOpen = false
                if callback then callback(option) end
            end)
        end
        
        DropButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            DropList.Visible = isOpen
        end)
        
        return DropFrame
    end
    
    -- Add a color picker
    function gui:AddColorPicker(text, default, callback)
        local ColorFrame = Instance.new("Frame")
        ColorFrame.Name = text
        ColorFrame.Size = UDim2.new(1, 0, 0, 60)
        ColorFrame.Position = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 65)
        ColorFrame.BackgroundColor3 = LuaGuard.Settings.Theme.ElementBackground
        ColorFrame.BorderSizePixel = 0
        ColorFrame.Parent = ContentFrame
        
        local ColorLabel = Instance.new("TextLabel")
        ColorLabel.Size = UDim2.new(1, -20, 0, 20)
        ColorLabel.Position = UDim2.new(0, 10, 0, 5)
        ColorLabel.BackgroundTransparency = 1
        ColorLabel.Text = text
        ColorLabel.TextColor3 = LuaGuard.Settings.Theme.TextColor
        ColorLabel.TextSize = 14
        ColorLabel.Font = Enum.Font.SourceSansBold
        ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
        ColorLabel.Parent = ColorFrame
        
        local ColorDisplay = Instance.new("Frame")
        ColorDisplay.Size = UDim2.new(0, 30, 0, 30)
        ColorDisplay.Position = UDim2.new(0, 10, 0, 25)
        ColorDisplay.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
        ColorDisplay.BorderSizePixel = 0
        ColorDisplay.Parent = ColorFrame
        
        local R = Instance.new("TextBox")
        R.Size = UDim2.new(0, 40, 0, 20)
        R.Position = UDim2.new(0, 50, 0, 30)
        R.BackgroundColor3 = LuaGuard.Settings.Theme.Background
        R.BorderSizePixel = 0
        R.Text = tostring(math.floor(ColorDisplay.BackgroundColor3.R * 255))
        R.TextColor3 = LuaGuard.Settings.Theme.TextColor
        R.TextSize = 14
        R.Font = Enum.Font.SourceSans
        R.Parent = ColorFrame
        
        local G = Instance.new("TextBox")
        G.Size = UDim2.new(0, 40, 0, 20)
        G.Position = UDim2.new(0, 100, 0, 30)
        G.BackgroundColor3 = LuaGuard.Settings.Theme.Background
        G.BorderSizePixel = 0
        G.Text = tostring(math.floor(ColorDisplay.BackgroundColor3.G * 255))
        G.TextColor3 = LuaGuard.Settings.Theme.TextColor
        G.TextSize = 14
        G.Font = Enum.Font.SourceSans
        G.Parent = ColorFrame
        
        local B = Instance.new("TextBox")
        B.Size = UDim2.new(0, 40, 0, 20)
        B.Position = UDim2.new(0, 150, 0, 30)
        B.BackgroundColor3 = LuaGuard.Settings.Theme.Background
        B.BorderSizePixel = 0
        B.Text = tostring(math.floor(ColorDisplay.BackgroundColor3.B * 255))
        B.TextColor3 = LuaGuard.Settings.Theme.TextColor
        B.TextSize = 14
        B.Font = Enum.Font.SourceSans
        B.Parent = ColorFrame
        
        local function updateColor()
            local r = tonumber(R.Text) or 0
            local g = tonumber(G.Text) or 0
            local b = tonumber(B.Text) or 0
            
            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)
            
            local color = Color3.fromRGB(r, g, b)
            ColorDisplay.BackgroundColor3 = color
            
            if callback then callback(color) end
        end
        
        R.FocusLost:Connect(updateColor)
        G.FocusLost:Connect(updateColor)
        B.FocusLost:Connect(updateColor)
        
        return ColorFrame
    end

    function gui:AddSlider(text, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = text
        SliderFrame.Size = UDim2.new(1, 0, 0, 45)
        SliderFrame.Position = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 50)
        SliderFrame.BackgroundColor3 = LuaGuard.Settings.Theme.ElementBackground
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = ContentFrame
        
        local SliderText = Instance.new("TextLabel")
        SliderText.Size = UDim2.new(1, -10, 0, 20)
        SliderText.Position = UDim2.new(0, 10, 0, 0)
        SliderText.BackgroundTransparency = 1
        SliderText.Text = text
        SliderText.TextColor3 = LuaGuard.Settings.Theme.TextColor
        SliderText.TextSize = 14
        SliderText.Font = Enum.Font.SourceSans
        SliderText.TextXAlignment = Enum.TextXAlignment.Left
        SliderText.Parent = SliderFrame
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Size = UDim2.new(1, -20, 0, 4)
        SliderBar.Position = UDim2.new(0, 10, 0, 30)
        SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SliderBar.BorderSizePixel = 0
        SliderBar.Parent = SliderFrame
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = LuaGuard.Settings.Theme.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBar
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Size = UDim2.new(0, 10, 0, 10)
        SliderButton.Position = UDim2.new((default - min)/(max - min), -5, 0.5, -5)
        SliderButton.BackgroundColor3 = LuaGuard.Settings.Theme.TextColor
        SliderButton.BorderSizePixel = 0
        SliderButton.Text = ""
        SliderButton.Parent = SliderBar
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local relativePos = mousePos.X - SliderBar.AbsolutePosition.X
                local percentage = math.clamp(relativePos / SliderBar.AbsoluteSize.X, 0, 1)
                local value = min + ((max - min) * percentage)
                
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                SliderButton.Position = UDim2.new(percentage, -5, 0.5, -5)
                
                if callback then callback(value) end
            end
        end)
        
        return SliderFrame
    end
    
    return gui
end

return LuaGuard