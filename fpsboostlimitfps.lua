-- SETTINGS
local FPS_LIMIT = 10 

-- 1. FPS CAP & DISABLE RENDERING
if setfpscap then setfpscap(FPS_LIMIT) end
game:GetService("RunService"):Set3dRenderingEnabled(false)

-- 2. HARD MUTE & MEMORY CLEANER
local function CleanGame()
    UserSettings():GetService("UserGameSettings").MasterVolume = 0
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Sound") then
            v:Stop()
            v:Destroy()
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") or v:IsA("Explosion") then
            v:Destroy()
        elseif v:IsA("MeshPart") or v:IsA("SpecialMesh") then
            v:Destroy() 
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        end
    end
end

CleanGame()

game.DescendantAdded:Connect(function(v)
    if v:IsA("Sound") then
        v.Volume = 0
        v:Stop()
        v:Destroy()
    elseif v:IsA("Texture") or v:IsA("Decal") then
        v:Destroy()
    end
end)

-- 3. MATIKAN EFEK LIGHTING
game:GetService("Lighting"):ClearAllChildren()
settings().Rendering.QualityLevel = 1

-- 4. FPS & RAM COUNTER ONLY (Tanpa Background Full Screen)
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "PerformanceOverlay"

-- Label FPS & RAM (Dibuat agak transparan agar tidak mengganggu)
local infoLabel = Instance.new("TextLabel", screenGui)
infoLabel.Size = UDim2.new(0, 180, 0, 30)
infoLabel.Position = UDim2.new(0, 10, 0, 10) 
infoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
infoLabel.BackgroundTransparency = 0.5 -- Transparan setengah
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 14
infoLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Update Stats
local lastTime = os.clock()
local frames = 0
game:GetService("RunService").Heartbeat:Connect(function()
    frames = frames + 1
    if os.clock() - lastTime >= 1 then
        local mem = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
        infoLabel.Text = "FPS: " .. frames .. " | RAM: " .. mem .. "MB"
        frames = 0
        lastTime = os.clock()
    end
end)

print("------------------------------------------")
print("OPTIMIZER RUNNING")
print("- Background: Transparent")
print("- Indicator: Active")
print("------------------------------------------")
