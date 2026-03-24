-- SETTINGS
local FPS_LIMIT = 15

-- 1. FPS CAP & DISABLE RENDERING (Gabungan dari sebelumnya)
if setfpscap then setfpscap(FPS_LIMIT) end
game:GetService("RunService"):Set3dRenderingEnabled(false)

-- 2. MEMORY CLEANER (Hapus objek berat dari RAM)
local function CleanRAM()
    for _, v in pairs(game:GetDescendants()) do
        -- Hapus Tekstur & Decal (Penyumbang RAM terbesar)
        if v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        -- Hapus Suara (Audio buffer memakan RAM)
        elseif v:IsA("Sound") then
            v:Stop()
            v:Destroy()
        -- Hapus Partikel & Trail
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") then
            v:Destroy()
        -- Ubah Part menjadi sangat sederhana
        elseif v:IsA("MeshPart") or v:IsA("SpecialMesh") then
            -- Jika bukan part utama farming, bisa dihilangkan detailnya
            v:Destroy() 
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        end
    end
end

-- Jalankan pembersihan awal
CleanRAM()

-- 3. MATIKAN ANIMASI & EFEK POST-PROCESSING
game:GetService("Lighting"):ClearAllChildren() -- Hapus Bloom, Blur, Sunrays, dll.
settings().Rendering.QualityLevel = 1

-- 4. FPS COUNTER (Tetap ada buat pantau)
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Size = UDim2.new(0, 120, 0, 30)
fpsLabel.Position = UDim2.new(0, 10, 0, 10)
fpsLabel.BackgroundColor3 = Color3.new(0,0,0)
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.BackgroundTransparency = 0.5

local lastTime = os.clock()
local frames = 0
game:GetService("RunService").RenderStepped:Connect(function()
    frames = frames + 1
    if os.clock() - lastTime >= 1 then
        fpsLabel.Text = "FPS: " .. frames .. " | RAM: " .. math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb()) .. "MB"
        frames = 0
        lastTime = os.clock()
    end
end)

print("RAM & FPS Optimizer Active!")
