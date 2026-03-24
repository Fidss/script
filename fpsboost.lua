-- SETTINGS
local FPS_LIMIT = 15
local ShowFPS = true

-- 1. FPS CAP (Membatasi FPS ke 15)
if setfpscap then
    setfpscap(FPS_LIMIT)
else
    -- Fallback jika executor tidak support setfpscap
    local runService = game:GetService("RunService")
    runService.Stepped:Connect(function()
        local startTime = os.clock()
        while os.clock() - startTime < 1/FPS_LIMIT do
            -- Loop kosong untuk menunda frame (Brute force method)
        end
    end)
end

-- 2. DISABLE 3D RENDERING (Bikin GPU Adem)
-- Catatan: Layar akan terlihat "freeze" atau hitam, tapi script farming tetap jalan!
game:GetService("RunService"):Set3dRenderingEnabled(false)

-- 3. FPS COUNTER UI
if ShowFPS then
    local screenGui = Instance.new("ScreenGui")
    local fpsLabel = Instance.new("TextLabel")

    screenGui.Parent = game:GetService("CoreGui")
    fpsLabel.Parent = screenGui
    fpsLabel.Size = UDim2.new(0, 100, 0, 30)
    fpsLabel.Position = UDim2.new(0, 10, 0, 10)
    fpsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    fpsLabel.TextColor3 = Color3.new(0, 1, 0)
    fpsLabel.TextSize = 18
    fpsLabel.Font = Enum.Font.Code
    fpsLabel.BackgroundTransparency = 0.5

    local lastTime = os.clock()
    local frames = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        frames = frames + 1
        local currentTime = os.clock()
        if currentTime - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. tostring(frames)
            frames = 0
            lastTime = currentTime
        end
    end)
end

-- 4. CLEANUP (Hapus Partikel & Tekstur yang tersisa)
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then
        v:Destroy()
    end
end

print("Extreme Farming Mode Active: FPS Limited to " .. FPS_LIMIT)

