local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local pGui = player:WaitForChild("PlayerGui")

-- --- SETUP GUI DEBUG ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeaderboardDebugger"
screenGui.ResetOnSpawn = false
screenGui.Parent = pGui

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 10, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.CanvasSize = UDim2.new(0, 0, 5, 0)
frame.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.Padding = UDim.new(0, 5)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "AUTO TP & DEBUGGER (180 ROTATION)"
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Parent = frame

local function logToGui(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    -- Auto scroll ke bawah
    frame.CanvasPosition = Vector2.new(0, frame.AbsoluteWindowSize.Y)
end

-- --- FUNGSI TELEPORT DENGAN ROTASI 180 ---
local function teleportKe(coords, lokasiNama)
    logToGui("Teleporting ke: " .. lokasiNama, Color3.fromRGB(255, 255, 255))
    
    -- CFrame.new(coords) menentukan posisi
    -- CFrame.Angles(0, math.rad(180), 0) memutar karakter 180 derajat di sumbu Y
    local targetCFrame = CFrame.new(coords) * CFrame.Angles(0, math.rad(180), 0)
    
    rootPart.CFrame = targetCFrame
end

-- --- PROSES SCANNING & LOGIKA TP ---
logToGui("Memulai Scan Akun: " .. player.Name, Color3.fromRGB(0, 255, 0))

local function scanFolder(obj, depth)
    depth = depth or 0
    local indent = string.rep("  ", depth)
    
    for _, child in pairs(obj:GetChildren()) do
        if child:IsA("ValueBase") then
            local valString = tostring(child.Value)
            logToGui(indent .. "-> " .. child.Name .. ": " .. valString, Color3.fromRGB(200, 200, 255))
            
            -- CEK RAREST FISH UNTUK TELEPORT
            if string.find(child.Name, "Rarest") then
                if valString == "1/50K" or valString == "1/50,000" then
                    logToGui(">>> GHOSTFINN DETECTED! <<<", Color3.fromRGB(0, 255, 255))
                    -- TP ke Patung Lost Isle (Putar 180)
                    teleportKe(Vector3.new(-3751, -136, -1007), "Patung Lost Isle")
                else
                    logToGui("--- BUKAN GHOSTFINN ---", Color3.fromRGB(255, 100, 100))
                    -- TP ke Ancient Ruin (Putar 180)
                    teleportKe(Vector3.new(6046, -589, 4610), "Ancient Ruin")
                end
            end

        elseif child:IsA("Folder") or child:IsA("Configuration") or child:IsA("Model") then
            logToGui(indent .. "[" .. child.Name .. "]", Color3.fromRGB(255, 165, 0))
            scanFolder(child, depth + 1)
        end
    end
end

-- Jalankan Scan
scanFolder(player)

logToGui("--- SCAN & TP SELESAI ---", Color3.fromRGB(0, 255, 0))

