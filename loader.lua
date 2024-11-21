local function LoadScript()
    local success, result = pcall(function()
        -- Load the custom UI library
        local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/DynamicModz/2/refs/heads/main/luaguard_custom_lib.lua'))()
        
        -- Load the main script
        local UniversalScript = loadstring(game:HttpGet('https://raw.githubusercontent.com/DynamicModz/2/refs/heads/main/universal_script.lua'))()
        
        -- Create main window
        local Window = Library:CreateWindow("Universal Script")
        
        -- ESP Tab
        local ESPTab = Window:CreateTab("ESP")
        ESPTab:CreateToggle("Enable ESP", UniversalScript.ESP.Enabled, function(value)
            UniversalScript.ESP.Enabled = value
        end)
        ESPTab:CreateToggle("Boxes", UniversalScript.ESP.Boxes, function(value)
            UniversalScript.ESP.Boxes = value
        end)
        ESPTab:CreateToggle("Tracers", UniversalScript.ESP.Tracers, function(value)
            UniversalScript.ESP.Tracers = value
        end)
        ESPTab:CreateToggle("Names", UniversalScript.ESP.Names, function(value)
            UniversalScript.ESP.Names = value
        end)
        ESPTab:CreateToggle("Health", UniversalScript.ESP.Health, function(value)
            UniversalScript.ESP.Health = value
        end)
        ESPTab:CreateToggle("Team Check", UniversalScript.ESP.TeamCheck, function(value)
            UniversalScript.ESP.TeamCheck = value
        end)
        ESPTab:CreateSlider("Max Distance", 100, 5000, UniversalScript.ESP.MaxDistance, function(value)
            UniversalScript.ESP.MaxDistance = value
        end)
        
        -- Aimbot Tab
        local AimbotTab = Window:CreateTab("Aimbot")
        AimbotTab:CreateToggle("Enable Aimbot", UniversalScript.Aimbot.Enabled, function(value)
            UniversalScript.Aimbot.Enabled = value
        end)
        AimbotTab:CreateToggle("Silent Aim", UniversalScript.Aimbot.Silent, function(value)
            UniversalScript.Aimbot.Silent = value
        end)
        AimbotTab:CreateDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, function(value)
            UniversalScript.Aimbot.TargetPart = value
        end)
        AimbotTab:CreateToggle("Team Check", UniversalScript.Aimbot.TeamCheck, function(value)
            UniversalScript.Aimbot.TeamCheck = value
        end)
        AimbotTab:CreateToggle("Show FOV", UniversalScript.Aimbot.ShowFOV, function(value)
            UniversalScript.Aimbot.ShowFOV = value
        end)
        AimbotTab:CreateSlider("FOV", 10, 500, UniversalScript.Aimbot.FOV, function(value)
            UniversalScript.Aimbot.FOV = value
        end)
        AimbotTab:CreateSlider("Smoothness", 1, 10, UniversalScript.Aimbot.Smoothness, function(value)
            UniversalScript.Aimbot.Smoothness = value
        end)
        
        -- Combat Tab
        local CombatTab = Window:CreateTab("Combat")
        CombatTab:CreateToggle("No Recoil", UniversalScript.Combat.NoRecoil, function(value)
            UniversalScript.Combat.NoRecoil = value
        end)
        CombatTab:CreateToggle("No Spread", UniversalScript.Combat.NoSpread, function(value)
            UniversalScript.Combat.NoSpread = value
        end)
        CombatTab:CreateToggle("Rapid Fire", UniversalScript.Combat.RapidFire, function(value)
            UniversalScript.Combat.RapidFire = value
        end)
        CombatTab:CreateToggle("Infinite Ammo", UniversalScript.Combat.InfiniteAmmo, function(value)
            UniversalScript.Combat.InfiniteAmmo = value
        end)
        
        -- Visuals Tab
        local VisualsTab = Window:CreateTab("Visuals")
        VisualsTab:CreateToggle("Full Bright", UniversalScript.Visuals.FullBright, function(value)
            UniversalScript.Visuals.FullBright = value
        end)
        VisualsTab:CreateToggle("No Fog", UniversalScript.Visuals.NoFog, function(value)
            UniversalScript.Visuals.NoFog = value
        end)
        VisualsTab:CreateToggle("Custom Time", UniversalScript.Visuals.CustomTime, function(value)
            UniversalScript.Visuals.CustomTime = value
        end)
        VisualsTab:CreateSlider("Time", 0, 24, UniversalScript.Visuals.TimeValue, function(value)
            UniversalScript.Visuals.TimeValue = value
        end)
        
        -- Misc Tab
        local MiscTab = Window:CreateTab("Misc")
        MiscTab:CreateSlider("Walk Speed", 16, 500, UniversalScript.Misc.WalkSpeed, function(value)
            UniversalScript.Misc.WalkSpeed = value
        end)
        MiscTab:CreateSlider("Jump Power", 50, 500, UniversalScript.Misc.JumpPower, function(value)
            UniversalScript.Misc.JumpPower = value
        end)
        MiscTab:CreateToggle("Infinite Jump", UniversalScript.Misc.InfJump, function(value)
            UniversalScript.Misc.InfJump = value
        end)
        MiscTab:CreateToggle("No Clip", UniversalScript.Misc.NoClip, function(value)
            UniversalScript.Misc.NoClip = value
        end)
    end)
    
    if not success then
        warn("Failed to load script:", result)
    end
end

-- Return the loader function
return LoadScript
