local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GemstonesHub - Fish It",
   LoadingTitle = "Memuat Auto-Resolver...",
   LoadingSubtitle = "by F",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Boat Controls", 4483362458)
local FishingTab = Window:CreateTab("Auto Fishing", 4483362458)
local SellTab = Window:CreateTab("Auto Sell", 4483362458)
local ToolsTab = Window:CreateTab("Tools & Dump", 4483362458)

-- ==========================================
-- UI LOGS & STATUS
-- ==========================================
local RemoteStatus = MainTab:CreateParagraph({
    Title = "📍 Status Remote Boat", 
    Content = "Tekan 'Scan All Remotes' terlebih dahulu."
})

local ResponseLog = MainTab:CreateParagraph({
    Title = "📝 Log Boat", 
    Content = "Menunggu aksi..."
})

local FishingStatus = FishingTab:CreateParagraph({
    Title = "📍 Status Remote Fishing", 
    Content = "Tekan 'Scan All Remotes' terlebih dahulu."
})

local FishingLog = FishingTab:CreateParagraph({
    Title = "📝 Log Fishing", 
    Content = "Menunggu aksi..."
})

local FishingMonitor = FishingTab:CreateParagraph({
    Title = "👀 Monitor Fishing", 
    Content = "Status: Idle"
})

local SellStatus = SellTab:CreateParagraph({
    Title = "📍 Status Remote Sell", 
    Content = "Tekan 'Scan All Remotes' terlebih dahulu."
})

local SellLog = SellTab:CreateParagraph({
    Title = "📝 Log Sell", 
    Content = "Menunggu aksi..."
})

local SellMonitor = SellTab:CreateParagraph({
    Title = "👀 Monitor Sell", 
    Content = "Status: Idle"
})

-- ==========================================
-- VARIABEL
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Remotes = {
    -- Boat
    SpawnBoat = nil,
    DespawnBoat = nil,
    BoatTeleport = nil,
    -- Fishing
    ChargeFishingRod = nil,
    RequestFishingMinigameStarted = nil,
    CatchFishCompleted = nil,
    -- Sell
    SellAllItems = nil,
}

local FishingConfig = {
    AutoFishingEnabled = false,
    CatchDelay = 2,
    FishingLoopRunning = false,
}

local SellConfig = {
    AutoSellEnabled = false,
    SellDelay = 60,
    SellLoopRunning = false,
}

local FPSSettings = {
    FPSLimit = 60,
    FPSLoopRunning = false,
}

-- Koordinat target fishing
local FISHING_SPOT = Vector3.new(6014.79, -585.92, 4635.71)

-- Koordinat di atas bangunan (untuk spawn point)
local SPAWN_POINT = Vector3.new(6014.79, -580, 4635.71) -- 5 studs di atas fishing spot

-- Rotasi karakter (160 derajat)
local CHARACTER_ROTATION = math.rad(215)

-- ==========================================
-- FUNGSI GET NET FOLDER
-- ==========================================
local function GetNetFolder()
    local netModule = ReplicatedStorage:FindFirstChild("Packages")
    if not netModule then return nil end
    
    local idx = netModule:FindFirstChild("_Index")
    if not idx then return nil end
    
    local sl = idx:FindFirstChild("sleitnick_net@0.2.0")
    if not sl then return nil end
    
    local net = sl:FindFirstChild("net")
    return net
end

-- ==========================================
-- FUNGSI AUTO-RESOLVE REMOTE
-- ==========================================
local function FindRemoteByName(readableName, className)
    local net = GetNetFolder()
    if not net then return nil end

    local prefix = (className == "RemoteEvent") and "RE/" or "RF/"
    local dummyName = prefix .. readableName
    local dummy = net:FindFirstChild(dummyName)
    
    if dummy then
        for _, attrValue in pairs(dummy:GetAttributes()) do
            if type(attrValue) == "string" then
                local found = net:FindFirstChild(attrValue)
                if found and found:IsA(className) then
                    return found
                end
            end
        end
        
        for _, child in ipairs(dummy:GetChildren()) do
            if child:IsA("StringValue") then
                local found = net:FindFirstChild(child.Value)
                if found and found:IsA(className) then
                    return found
                end
            end
        end
        
        local allChildren = net:GetChildren()
        local dummyIndex = nil
        
        for i, child in ipairs(allChildren) do
            if child == dummy then
                dummyIndex = i
                break
            end
        end
        
        if dummyIndex then
            for i = dummyIndex + 1, #allChildren do
                if allChildren[i]:IsA(className) then
                    return allChildren[i]
                end
            end
        end
    end
    
    return nil
end

-- ==========================================
-- FUNGSI GET PLAYER POSITION
-- ==========================================
local function GetPlayerPosition()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local pos = humanoidRootPart.Position
    return {pos.X, pos.Y, pos.Z}
end

-- ==========================================
-- FUNGSI NOCLIP
-- ==========================================
local NoclipConnection = nil
local NoclipEnabled = false

local function EnableNoclip()
    if NoclipEnabled then return end
    NoclipEnabled = true
    
    NoclipConnection = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoclip()
    NoclipEnabled = false
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ==========================================
-- FUNGSI JATUH TERARAH (NO CLIP FALL) + ROTASI 160°
-- ==========================================
local function GuidedFall(targetPosition)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    -- Enable noclip agar tidak menabrak bangunan
    EnableNoclip()
    
    ResponseLog:Set({Title = "🕊️ Falling", Content = "NoClip enabled, falling to fishing spot..."})
    
    -- Buat BodyVelocity untuk mengarahkan jatuh
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.P = 10000
    bodyVelocity.Parent = humanoidRootPart
    
    -- Loop untuk mengarahkan jatuh ke target
    local startTime = tick()
    local timeout = 15 -- Timeout 15 detik
    
    while (humanoidRootPart.Position - targetPosition).Magnitude > 2 do
        if tick() - startTime > timeout then
            break -- Timeout
        end
        
        local currentPos = humanoidRootPart.Position
        local direction = (targetPosition - currentPos).Unit
        
        -- Kecepatan jatuh natural dengan kontrol arah
        local fallSpeed = 30 -- Kecepatan jatuh
        local distanceLeft = (targetPosition - currentPos).Magnitude
        
        -- Jika sudah dekat, pelan-pelan
        if distanceLeft < 5 then
            fallSpeed = distanceLeft * 3
        end
        
        bodyVelocity.Velocity = direction * fallSpeed
        
        -- Update log setiap detik
        if math.floor(tick() - startTime) % 1 == 0 then
            ResponseLog:Set({Title = "🕊️ Falling", Content = "Distance left: " .. math.floor(distanceLeft) .. " studs"})
        end
        
        task.wait()
    end
    
    -- Hapus BodyVelocity
    bodyVelocity:Destroy()
    
    -- Set posisi final tepat di target dengan rotasi 160 derajat
    local finalCFrame = CFrame.new(targetPosition) * CFrame.Angles(0, CHARACTER_ROTATION, 0)
    humanoidRootPart.CFrame = finalCFrame
    
    ResponseLog:Set({Title = "✅ Landed", Content = "Reached fishing spot! Rotated 160°"})
    
    -- Kembalikan humanoid ke state normal
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    
    -- Disable noclip setelah delay kecil
    task.wait(0.5)
    DisableNoclip()
    
    return true
end

-- ==========================================
-- FUNGSI JALAN MUNDUR
-- ==========================================
local function WalkBackward(duration)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    humanoid.WalkSpeed = 16
    
    local startTime = tick()
    local backwardDirection = humanoidRootPart.CFrame.LookVector * -1
    
    while tick() - startTime < duration do
        humanoid:Move(backwardDirection, false)
        task.wait()
    end
    
    humanoid:Move(Vector3.new(0, 0, 0), false)
    return true
end

-- ==========================================
-- FUNGSI TELEPORT KARAKTER
-- ==========================================
local function TeleportCharacter(targetCFrame)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    humanoidRootPart.CFrame = targetCFrame
    
    task.wait(0.1)
    if (humanoidRootPart.Position - targetCFrame.Position).Magnitude > 5 then
        humanoidRootPart.CFrame = targetCFrame
    end
    
    return true
end

-- ==========================================
-- FUNGSI BUAT KARAKTER LOMPAT
-- ==========================================
local function MakeCharacterJump()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    return true
end

-- ==========================================
-- FUNGSI LOMPAT KELUAR DARI BOAT
-- ==========================================
local function JumpOutOfBoat()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Loncat untuk lepas dari seat
    humanoid.Jump = true
    task.wait(0.3)
end

-- ==========================================
-- FUNGSI FPS LIMITER
-- ==========================================
local FPSConnection = nil

local function SetFPSLimit(fps)
    if FPSConnection then
        FPSConnection:Disconnect()
        FPSConnection = nil
    end
    
    if fps <= 0 then
        if setfpscap then
            setfpscap(0)
        end
        return
    end
    
    if setfpscap then
        setfpscap(fps)
    else
        local targetFrameTime = 1 / fps
        local lastFrame = tick()
        
        FPSConnection = RunService.RenderStepped:Connect(function()
            local elapsed = tick() - lastFrame
            if elapsed < targetFrameTime then
                local waitTime = targetFrameTime - elapsed
                task.wait(waitTime)
            end
            lastFrame = tick()
        end)
    end
end

-- ==========================================
-- FUNGSI SCAN SEMUA REMOTES
-- ==========================================
local function ScanAllRemotes()
    local net = GetNetFolder()
    if not net then 
        RemoteStatus:Set({Title = "❌ Error", Content = "Folder net tidak ditemukan!"})
        return 
    end
    
    -- Boat Remotes
    Remotes.SpawnBoat = FindRemoteByName("SpawnBoat", "RemoteFunction")
    Remotes.DespawnBoat = FindRemoteByName("DespawnBoat", "RemoteFunction")
    Remotes.BoatTeleport = FindRemoteByName("BoatTeleport", "RemoteEvent")
    
    -- Fishing Remotes
    Remotes.ChargeFishingRod = FindRemoteByName("ChargeFishingRod", "RemoteFunction")
    Remotes.RequestFishingMinigameStarted = FindRemoteByName("RequestFishingMinigameStarted", "RemoteFunction")
    Remotes.CatchFishCompleted = FindRemoteByName("CatchFishCompleted", "RemoteEvent")
    
    -- Sell Remotes
    Remotes.SellAllItems = FindRemoteByName("SellAllItems", "RemoteFunction")
    
    -- Status
    local function getStatus(remoteObj, name)
        if not remoteObj then return "❌ " .. name end
        return "✅ " .. name
    end
    
    local boatStatus = "🚤 " .. getStatus(Remotes.SpawnBoat, "SpawnBoat") .. "\n\n"
    boatStatus = boatStatus .. "🛑 " .. getStatus(Remotes.DespawnBoat, "DespawnBoat") .. "\n\n"
    boatStatus = boatStatus .. "⚡ " .. getStatus(Remotes.BoatTeleport, "BoatTeleport")
    RemoteStatus:Set({Title = "📍 Boat Remotes", Content = boatStatus})
    
    local fishingStatusText = "⚡ " .. getStatus(Remotes.ChargeFishingRod, "ChargeFishingRod") .. "\n\n"
    fishingStatusText = fishingStatusText .. "🎣 " .. getStatus(Remotes.RequestFishingMinigameStarted, "RequestFishing") .. "\n\n"
    fishingStatusText = fishingStatusText .. "🐟 " .. getStatus(Remotes.CatchFishCompleted, "CatchFishCompleted")
    FishingStatus:Set({Title = "📍 Fishing Remotes", Content = fishingStatusText})
    
    local sellStatusText = "💰 " .. getStatus(Remotes.SellAllItems, "SellAllItems")
    SellStatus:Set({Title = "📍 Sell Remotes", Content = sellStatusText})
    
    local foundCount = 0
    for _, v in pairs(Remotes) do
        if v then foundCount = foundCount + 1 end
    end
    
    ResponseLog:Set({Title = "🔍 Scan Complete", Content = foundCount .. " remotes ditemukan."})
    FishingLog:Set({Title = "🔍 Ready", Content = "Fishing remotes siap."})
    SellLog:Set({Title = "🔍 Ready", Content = "Sell remotes siap."})
end

-- ==========================================
-- FUNGSI AUTO FISHING
-- ==========================================
local function CastFishingRod()
    if not Remotes.ChargeFishingRod or not Remotes.RequestFishingMinigameStarted then
        return false
    end
    
    local success, response = pcall(function()
        return Remotes.ChargeFishingRod:InvokeServer()
    end)
    
    if not success then
        FishingLog:Set({Title = "❌ Charge Error", Content = tostring(response)})
        return false
    end
    
    task.wait(0.3)
    
    local pos = GetPlayerPosition()
    if not pos then
        FishingLog:Set({Title = "❌ Error", Content = "Tidak bisa dapat posisi!"})
        return false
    end
    
    local success2, response2 = pcall(function()
        return Remotes.RequestFishingMinigameStarted:InvokeServer(unpack(pos))
    end)
    
    if success2 then
        return true
    else
        FishingLog:Set({Title = "❌ Request Error", Content = tostring(response2)})
        return false
    end
end

local function CatchFish()
    if not Remotes.CatchFishCompleted then return false end
    
    local success, err = pcall(function()
        Remotes.CatchFishCompleted:FireServer()
    end)
    
    return success
end

local function FishingLoop()
    if not FishingConfig.AutoFishingEnabled then
        FishingConfig.FishingLoopRunning = false
        return
    end
    
    FishingConfig.FishingLoopRunning = true
    
    FishingMonitor:Set({Title = "👀 Monitor", Content = "Status: Melempar pancing..."})
    FishingLog:Set({Title = "🎣 Cast", Content = "Melempar pancing..."})
    
    local castSuccess = CastFishingRod()
    if not castSuccess then
        FishingLog:Set({Title = "❌ Error", Content = "Gagal melempar, coba lagi dalam 2 detik..."})
        if FishingConfig.AutoFishingEnabled then
            task.wait(2)
            FishingLoop()
        end
        return
    end
    
    local delay = FishingConfig.CatchDelay
    FishingMonitor:Set({Title = "👀 Monitor", Content = "Status: Menunggu " .. delay .. " detik..."})
    FishingLog:Set({Title = "⏱️ Waiting", Content = "Menunggu " .. delay .. " detik sebelum angkat..."})
    
    for i = delay, 1, -1 do
        if not FishingConfig.AutoFishingEnabled then
            FishingConfig.FishingLoopRunning = false
            return
        end
        FishingMonitor:Set({Title = "👀 Monitor", Content = "Status: Mengangkat ikan dalam " .. i .. " detik..."})
        task.wait(1)
    end
    
    if not FishingConfig.AutoFishingEnabled then
        FishingConfig.FishingLoopRunning = false
        return
    end
    
    FishingMonitor:Set({Title = "👀 Monitor", Content = "Status: Mengangkat ikan!"})
    FishingLog:Set({Title = "🐟 Catch!", Content = "Mengangkat ikan..."})
    
    local caught = CatchFish()
    
    if caught then
        FishingLog:Set({Title = "✅ Caught!", Content = "Ikan berhasil diangkat!"})
    else
        FishingLog:Set({Title = "⚠️ Miss", Content = "Gagal mengangkat ikan."})
    end
    
    if FishingConfig.AutoFishingEnabled then
        FishingMonitor:Set({Title = "👀 Monitor", Content = "Status: Jeda 1 detik..."})
        FishingLog:Set({Title = "⏱️ Jeda", Content = "1 detik sebelum lempar lagi..."})
        task.wait(1)
        FishingLoop()
    else
        FishingConfig.FishingLoopRunning = false
    end
end

local function StartAutoFishing()
    if FishingConfig.AutoFishingEnabled then
        FishingLog:Set({Title = "⚠️ Warning", Content = "Auto fishing sudah berjalan!"})
        return
    end
    
    if not Remotes.ChargeFishingRod or not Remotes.RequestFishingMinigameStarted or not Remotes.CatchFishCompleted then
        FishingLog:Set({Title = "❌ Error", Content = "Scan All Remotes dulu!"})
        return
    end
    
    FishingConfig.AutoFishingEnabled = true
    FishingMonitor:Set({Title = "👀 Monitor", Content = "Status: Memulai auto fishing..."})
    FishingLog:Set({Title = "🎣 Auto Fishing", Content = "Dimulai! Delay angkat: " .. FishingConfig.CatchDelay .. " detik"})
    
    task.spawn(FishingLoop)
end

local function StopAutoFishing()
    FishingConfig.AutoFishingEnabled = false
    FishingMonitor:Set({Title = "👀 Monitor", Content = "Status: Dihentikan"})
    FishingLog:Set({Title = "🛑 Stopped", Content = "Auto fishing dihentikan"})
end

-- ==========================================
-- FUNGSI AUTO SELL
-- ==========================================
local function SellAllItems()
    if not Remotes.SellAllItems then
        SellLog:Set({Title = "❌ Error", Content = "SellAllItems tidak ditemukan!"})
        return false
    end
    
    local success, response = pcall(function()
        return Remotes.SellAllItems:InvokeServer()
    end)
    
    if success then
        SellLog:Set({Title = "💰 Sold!", Content = "Semua item berhasil dijual!\nResponse: " .. tostring(response)})
        return true
    else
        SellLog:Set({Title = "❌ Sell Error", Content = tostring(response)})
        return false
    end
end

local function SellLoop()
    if not SellConfig.AutoSellEnabled then
        SellConfig.SellLoopRunning = false
        return
    end
    
    SellConfig.SellLoopRunning = true
    
    SellMonitor:Set({Title = "👀 Monitor", Content = "Status: Menjual semua item..."})
    SellLog:Set({Title = "💰 Auto Sell", Content = "Menjual semua item..."})
    
    local sold = SellAllItems()
    
    if sold then
        SellMonitor:Set({Title = "👀 Monitor", Content = "Status: Berhasil! Menunggu " .. SellConfig.SellDelay .. " detik..."})
    else
        SellMonitor:Set({Title = "👀 Monitor", Content = "Status: Gagal! Menunggu " .. SellConfig.SellDelay .. " detik..."})
    end
    
    for i = SellConfig.SellDelay, 1, -1 do
        if not SellConfig.AutoSellEnabled then
            SellConfig.SellLoopRunning = false
            return
        end
        SellMonitor:Set({Title = "👀 Monitor", Content = "Status: Sell lagi dalam " .. i .. " detik..."})
        task.wait(1)
    end
    
    if SellConfig.AutoSellEnabled then
        SellLoop()
    else
        SellConfig.SellLoopRunning = false
    end
end

local function StartAutoSell()
    if SellConfig.AutoSellEnabled then
        SellLog:Set({Title = "⚠️ Warning", Content = "Auto sell sudah berjalan!"})
        return
    end
    
    if not Remotes.SellAllItems then
        SellLog:Set({Title = "❌ Error", Content = "Scan All Remotes dulu!"})
        return
    end
    
    SellConfig.AutoSellEnabled = true
    SellMonitor:Set({Title = "👀 Monitor", Content = "Status: Memulai auto sell..."})
    SellLog:Set({Title = "💰 Auto Sell", Content = "Dimulai! Delay: " .. SellConfig.SellDelay .. " detik"})
    
    task.spawn(SellLoop)
end

local function StopAutoSell()
    SellConfig.AutoSellEnabled = false
    SellMonitor:Set({Title = "👀 Monitor", Content = "Status: Dihentikan"})
    SellLog:Set({Title = "🛑 Stopped", Content = "Auto sell dihentikan"})
end

-- ==========================================
-- BOAT CONTROLS TAB
-- ==========================================
MainTab:CreateButton({ 
    Name = "🔍 Scan All Remotes", 
    Callback = function() ScanAllRemotes() end 
})

MainTab:CreateDivider()

-- Tombol utama: SpawnBoat → TeleportBoat → Jalan Mundur 3 detik → Loncat Keluar Boat → Teleport Player + Loncat → Tunggu 3 detik → TeleportBoat → Loncat Keluar → DespawnBoat → Teleport ke atas bangunan → NoClip jatuh terarah
MainTab:CreateButton({
   Name = "🚤 Spawn & Move to Spot",
   Callback = function()
       if not Remotes.SpawnBoat then 
           return ResponseLog:Set({Title = "❌ Error", Content = "Scan All Remotes dulu!"}) 
       end
       if not Remotes.BoatTeleport then 
           return ResponseLog:Set({Title = "❌ Error", Content = "BoatTeleport tidak ditemukan!"}) 
       end
       if not Remotes.DespawnBoat then 
           return ResponseLog:Set({Title = "❌ Error", Content = "DespawnBoat tidak ditemukan!"}) 
       end
       
       -- ==========================================
       -- STEP 1: SPAWN BOAT
       -- ==========================================
       ResponseLog:Set({Title = "🚤 Step 1/10", Content = "Spawning boat..."})
       local s1, r1 = pcall(function() 
           return Remotes.SpawnBoat:InvokeServer(1) 
       end)
       
       if not s1 then 
           return ResponseLog:Set({Title = "❌ Error", Content = "Gagal spawn: " .. tostring(r1)}) 
       end
       
       ResponseLog:Set({Title = "✅ Step 1/10", Content = "Boat spawned!"})
       task.wait(1.5)
       
       -- ==========================================
       -- STEP 2: TELEPORT BOAT PERTAMA (otomatis duduk)
       -- ==========================================
       ResponseLog:Set({Title = "⚡ Step 2/10", Content = "First boat teleport..."})
       
       local tp1Success = false
       for i = 1, 3 do
           local s2, e2 = pcall(function() 
               Remotes.BoatTeleport:FireServer() 
           end)
           if s2 then
               tp1Success = true
               break
           end
           task.wait(0.3)
       end
       
       if tp1Success then
           ResponseLog:Set({Title = "✅ Step 2/10", Content = "Boat teleported & duduk!"})
       else
           return ResponseLog:Set({Title = "❌ Error", Content = "Teleport pertama gagal!"})
       end
       
       task.wait(0.5)
       
       -- ==========================================
       -- STEP 3: JALAN MUNDUR 3 DETIK (sambil di boat)
       -- ==========================================
       ResponseLog:Set({Title = "🚶 Step 3/10", Content = "Walking backward for 3 seconds..."})
       WalkBackward(3)
       ResponseLog:Set({Title = "✅ Step 3/10", Content = "Walked backward!"})
       
       -- ==========================================
       -- STEP 4: LOMPAT KELUAR DARI BOAT
       -- ==========================================
       ResponseLog:Set({Title = "🦘 Step 4/10", Content = "Jumping out of boat..."})
       JumpOutOfBoat()
       task.wait(0.5)
       ResponseLog:Set({Title = "✅ Step 4/10", Content = "Out of boat!"})
       
       -- ==========================================
       -- STEP 5: TELEPORT KARAKTER KE FISHING SPOT + LOMPAT
       -- ==========================================
       local targetPos = CFrame.new(FISHING_SPOT) * CFrame.Angles(0, CHARACTER_ROTATION, 0)
       ResponseLog:Set({Title = "📍 Step 5/10", Content = "Teleporting player & jumping..."})
       
       local charTeleported = TeleportCharacter(targetPos)
       
       if charTeleported then
           MakeCharacterJump()
           ResponseLog:Set({Title = "✅ Step 5/10", Content = "Teleported & jumped!"})
       else
           return ResponseLog:Set({Title = "❌ Error", Content = "Character teleport gagal!"})
       end
       
       -- ==========================================
       -- STEP 6: TUNGGU 3 DETIK
       -- ==========================================
       ResponseLog:Set({Title = "⏱️ Step 6/10", Content = "Waiting 3 seconds..."})
       task.wait(3)
       ResponseLog:Set({Title = "✅ Step 6/10", Content = "Wait complete!"})
       
       -- Reset velocity karakter
       local char = LocalPlayer.Character
       if char and char:FindFirstChild("HumanoidRootPart") then
           char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
           if char:FindFirstChild("Humanoid") then
               char.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
           end
       end
       
       -- ==========================================
       -- STEP 7: TELEPORT BOAT KEDUA (otomatis duduk lagi)
       -- ==========================================
       ResponseLog:Set({Title = "⚡ Step 7/10", Content = "Second boat teleport..."})
       
       -- Cek apakah boat masih ada
       local boatExists = false
       for _, obj in ipairs(workspace:GetChildren()) do
           if obj:IsA("Model") and obj.Name:lower():find("boat") then
               boatExists = true
               break
           end
       end
       
       if boatExists then
           -- Spam teleport boat kedua
           local tp2Success = false
           for i = 1, 5 do
               local s7, e7 = pcall(function()
                   Remotes.BoatTeleport:FireServer()
               end)
               if s7 then
                   tp2Success = true
               end
               task.wait(0.15)
           end
           
           if tp2Success then
               ResponseLog:Set({Title = "✅ Step 7/10", Content = "Second boat teleport done! Otomatis duduk lagi."})
               task.wait(0.3)
               
               -- Loncat keluar lagi
               JumpOutOfBoat()
               task.wait(0.3)
           else
               ResponseLog:Set({Title = "⚠️ Step 7/10", Content = "Second teleport failed, lanjut..."})
           end
       else
           ResponseLog:Set({Title = "⚠️ Step 7/10", Content = "Boat already gone, skipping..."})
       end
       
       -- ==========================================
       -- STEP 8: DESPAWN BOAT
       -- ==========================================
       ResponseLog:Set({Title = "🛑 Step 8/10", Content = "Despawning boat..."})
       task.wait(0.5)
       
       local s8, r8 = pcall(function() 
           return Remotes.DespawnBoat:InvokeServer() 
       end)
       
       if s8 then 
           ResponseLog:Set({Title = "✅ Step 8/10", Content = "Boat despawned!"}) 
       else 
           ResponseLog:Set({Title = "⚠️ Step 8/10", Content = "Despawn: " .. tostring(r8)}) 
       end
       
       -- ==========================================
       -- STEP 9: TELEPORT KE ATAS BANGUNAN
       -- ==========================================
       task.wait(0.5)
       ResponseLog:Set({Title = "📍 Step 9/10", Content = "Teleporting to spawn point above building..."})
       
       local spawnCFrame = CFrame.new(SPAWN_POINT) * CFrame.Angles(0, CHARACTER_ROTATION, 0)
       TeleportCharacter(spawnCFrame)
       
       -- ==========================================
       -- STEP 10: GUIDED FALL KE FISHING SPOT
       -- ==========================================
       task.wait(0.3)
       ResponseLog:Set({Title = "🕊️ Step 10/10", Content = "NoClip & guided fall to fishing spot..."})
       
       GuidedFall(FISHING_SPOT)
       
       ResponseLog:Set({Title = "✅ Complete!", Content = "Ready to fish at (6014.79, -585.92, 4635.71) - 160° rotation"})
   end,
})

MainTab:CreateDivider()

MainTab:CreateButton({
   Name = "📍 Teleport Character Only",
   Callback = function()
       local targetPos = CFrame.new(FISHING_SPOT) * CFrame.Angles(0, CHARACTER_ROTATION, 0)
       if TeleportCharacter(targetPos) then
           MakeCharacterJump()
           ResponseLog:Set({Title = "✅", Content = "Teleported to fishing spot! (160°)"})
       else
           ResponseLog:Set({Title = "❌", Content = "Teleport failed!"})
       end
   end,
})

MainTab:CreateDivider()

-- Toggle NoClip
MainTab:CreateToggle({
   Name = "🕊️ NoClip",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           EnableNoclip()
           ResponseLog:Set({Title = "✅ NoClip", Content = "NoClip enabled!"})
       else
           DisableNoclip()
           ResponseLog:Set({Title = "❌ NoClip", Content = "NoClip disabled!"})
       end
   end,
})

-- ==========================================
-- AUTO FISHING TAB
-- ==========================================
FishingTab:CreateButton({ 
    Name = "🔍 Scan All Remotes", 
    Callback = function() ScanAllRemotes() end 
})

FishingTab:CreateDivider()

FishingTab:CreateInput({
   Name = "Delay Angkat Ikan (detik)",
   PlaceholderText = "Default: 2",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) 
       local num = tonumber(Text)
       if num and num > 0 then
           FishingConfig.CatchDelay = num
           FishingLog:Set({Title = "⏱️ Delay", Content = "Delay angkat: " .. num .. " detik"})
       end
   end,
})

FishingTab:CreateDivider()

FishingTab:CreateButton({
   Name = "🎣 Start Auto Fishing",
   Callback = function()
       if not Remotes.ChargeFishingRod or not Remotes.RequestFishingMinigameStarted or not Remotes.CatchFishCompleted then
           return FishingLog:Set({Title = "❌ Error", Content = "Scan All Remotes dulu!"})
       end
       StartAutoFishing()
   end,
})

FishingTab:CreateButton({
   Name = "🛑 Stop Auto Fishing",
   Callback = function() StopAutoFishing() end,
})

FishingTab:CreateDivider()

FishingTab:CreateButton({
   Name = "🎣 Manual Cast",
   Callback = function()
       if not Remotes.ChargeFishingRod or not Remotes.RequestFishingMinigameStarted then
           return FishingLog:Set({Title = "❌", Content = "Scan dulu!"})
       end
       if CastFishingRod() then
           FishingLog:Set({Title = "✅ Cast!", Content = "Pancing dilempar!"})
       end
   end,
})

FishingTab:CreateButton({
   Name = "🐟 Manual Catch",
   Callback = function()
       if not Remotes.CatchFishCompleted then
           return FishingLog:Set({Title = "❌", Content = "Scan dulu!"})
       end       if CatchFish() then
           FishingLog:Set({Title = "✅ Caught!", Content = "Ikan diangkat!"})
       end
   end,
})

-- ==========================================
-- AUTO SELL TAB
-- ==========================================
SellTab:CreateButton({ 
    Name = "🔍 Scan All Remotes", 
    Callback = function() ScanAllRemotes() end 
})

SellTab:CreateDivider()

SellTab:CreateInput({
   Name = "Delay Sell (detik)",
   PlaceholderText = "Default: 60",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) 
       local num = tonumber(Text)
       if num and num > 0 then
           SellConfig.SellDelay = num
           SellLog:Set({Title = "⏱️ Delay", Content = "Delay sell: " .. num .. " detik"})
       end
   end,
})

SellTab:CreateDivider()

SellTab:CreateButton({
   Name = "💰 Sell All (Once)",
   Callback = function()
       if not Remotes.SellAllItems then
           return SellLog:Set({Title = "❌", Content = "Scan All Remotes dulu!"})
       end
       SellAllItems()
   end,
})

SellTab:CreateDivider()

SellTab:CreateButton({
   Name = "🔄 Start Auto Sell",
   Callback = function()
       if not Remotes.SellAllItems then
           return SellLog:Set({Title = "❌ Error", Content = "Scan All Remotes dulu!"})
       end
       StartAutoSell()
   end,
})

SellTab:CreateButton({
   Name = "🛑 Stop Auto Sell",
   Callback = function() StopAutoSell() end,
})

-- ==========================================
-- TOOLS & DUMP TAB
-- ==========================================
ToolsTab:CreateParagraph({Title = "ℹ️ Info", Content = "Debug & Performance Tools"})

ToolsTab:CreateButton({
   Name = "📋 Dump Semua Remote",
   Callback = function()
       local net = GetNetFolder()
       if not net then return end
       local dumpText = ""
       local count = 0
       local function df(folder, ind)
           ind = ind or ""
           for _, c in ipairs(folder:GetChildren()) do
               if c:IsA("RemoteEvent") or c:IsA("RemoteFunction") then
                   count = count + 1
                   dumpText = dumpText .. ind .. "[" .. c.ClassName .. "] " .. c:GetFullName() .. "\n"
               elseif c:IsA("Folder") then
                   dumpText = dumpText .. ind .. "[Folder] " .. c.Name .. "\n"
                   df(c, ind .. "  ")
               end
           end
       end
       df(net)
       if pcall(function() return writefile end) then
           pcall(function() writefile("RemoteDebug.txt", dumpText) end)
       end
   end,
})

ToolsTab:CreateDivider()

-- FPS Limiter Input
ToolsTab:CreateInput({
   Name = "FPS Limit (0 = Unlimited)",
   PlaceholderText = "Default: 60",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) 
       local num = tonumber(Text)
       if num then
           FPSSettings.FPSLimit = num
           SetFPSLimit(num)
           if num <= 0 then
               ResponseLog:Set({Title = "⚡ FPS", Content = "FPS: Unlimited"})
           else
               ResponseLog:Set({Title = "⚡ FPS", Content = "FPS Limited to: " .. num})
           end
       end
   end,
})

ToolsTab:CreateDivider()

-- FPS Toggle
ToolsTab:CreateToggle({
   Name = "⚡ Enable FPS Limit",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           SetFPSLimit(FPSSettings.FPSLimit)
           ResponseLog:Set({Title = "⚡ FPS", Content = "FPS Limit enabled: " .. FPSSettings.FPSLimit})
       else
           SetFPSLimit(0)
           ResponseLog:Set({Title = "⚡ FPS", Content = "FPS Limit disabled"})
       end
   end,
})

-- ==========================================
-- AUTO-SCAN
-- ==========================================
task.spawn(function()
    task.wait(1)
    ScanAllRemotes()
end)
