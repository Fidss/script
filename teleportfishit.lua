-- ==========================================================
-- CONFIGURATION & COORDINATES
-- ==========================================================
local targetCFrame = CFrame.new(6047.47, -588.60, 4610.02) * CFrame.Angles(0, math.rad(180), 0)
local terbangSpeed = 30 

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local username = player.Name

-- GANTI URL INI DENGAN URL FLASK WEB ANDA YANG SUDAH DEPLOY
local FLASK_URL = "https://roblox-teleport-script.vercel.app/api/poll"

-- Kompatibilitas HTTP Request untuk semua Executor Android/PC
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httprequest then
    player:Kick("Executor Anda tidak mendukung HTTP Requests!")
    return
end

-- Anti-Duplikasi Loop
if _G.NoclipLoop then _G.NoclipLoop:Disconnect() _G.NoclipLoop = nil end
if _G.WebCheckActive then _G.WebCheckActive = false end

-- ==========================================================
-- FITUR BARU: FPS LIMITER & ULTRA FPS BOOST
-- ==========================================================
local function applyFpsBoostAndLimit()
    -- 1. Batasi FPS ke 10
    if setfpscap then
        setfpscap(10)
        print("[GemstonesHub]: FPS berhasil dibatasi ke 10.")
    else
        print("[GemstonesHub]: Executor tidak mendukung setfpscap secara native.")
    end

    -- 2. Matikan Rendering 3D (Metode paling ampuh untuk Cloudphone / Botting)
    local renderSuccess, _ = pcall(function()
        RunService:Set3dRenderingEnabled(false)
    end)

    if renderSuccess then
        print("[GemstonesHub]: 3D Rendering dimatikan. Beban GPU/CPU berkurang drastis!")
    else
        -- Fallback: Jika executor tidak mendukung Set3dRenderingEnabled, bersihkan map secara agresif
        print("[GemstonesHub]: Gagal mematikan 3D Rendering. Menggunakan metode pembersihan objek visual...")
        
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
        
        local function cleanUp(object)
            if object:IsA("Decal") or object:IsA("Texture") or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Sparkles") then
                object:Destroy()
            elseif object:IsA("Part") or object:IsA("MeshPart") or object:IsA("UnionOperation") then
                object.Material = Enum.Material.SmoothPlastic
                object.Reflectance = 0
            elseif object:IsA("Atmosphere") or object:IsA("Sky") or object:IsA("Clouds") then
                object:Destroy()
            end
        end

        for _, v in pairs(game:GetDescendants()) do
            cleanUp(v)
        end

        game.DescendantAdded:Connect(function(descendant)
            task.wait()
            cleanUp(descendant)
        end)
    end
end

-- Jalankan fungsi optimasi di awal eksekusi
task.spawn(applyFpsBoostAndLimit)

-- ==========================================================
-- LOGIKA UTAMA: PERBANGAN (TWEEN + NOCLIP)
-- ==========================================================
local function startFlying(character)
    local hrp = character:WaitForChild("HumanoidRootPart", 10)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not hrp or not humanoid then return end

    if _G.NoclipLoop then _G.NoclipLoop:Disconnect() _G.NoclipLoop = nil end

    -- Aktifkan Noclip & Pengunci State Ragdoll
    _G.NoclipLoop = RunService.Stepped:Connect(function()
        if character and character:Parent() then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        else
            if _G.NoclipLoop then _G.NoclipLoop:Disconnect() _G.NoclipLoop = nil end
        end
    end)

    -- Eksekusi pergerakan translasi mulus ke target koordinat
    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local duration = distance / terbangSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    
    tween.Completed:Connect(function()
        if _G.NoclipLoop then
            _G.NoclipLoop:Disconnect() _G.NoclipLoop = nil
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            print("[GemstonesHub]: Akun telah sampai di koordinat target.")
        end
    end)
end

-- ==========================================================
-- DETEKSI OTOMATIS: AUTO FLY SETELAH RESPRAWN
-- ==========================================================
player.CharacterAdded:Connect(function(newCharacter)
    task.wait(1.5) -- Jeda aman memuat karakter
    print("[GemstonesHub]: Karakter baru terdeteksi (Respawned). Terbang kembali...")
    startFlying(newCharacter)
end)

-- Jalankan langsung saat pertama kali skrip di-inject
if player.Character then
    task.spawn(function() startFlying(player.Character) end)
end

-- ==========================================================
-- BACKGROUND WORKER: POLLING KONEKSI FLASK
-- ==========================================================
local function startWebChecking()
    _G.WebCheckActive = true
    print("[GemstonesHub]: Monitoring terhubung ke Flask Backend untuk: " .. username)

    while _G.WebCheckActive do
        pcall(function()
            local response = httprequest({
                Url = FLASK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({username = username})
            })

            if response and response.Body then
                local data = HttpService:JSONDecode(response.Body)
                
                -- Jika admin menekan tombol Respawn di Website
                if data and data.command == "respawn" then
                    print("[GemstonesHub]: Perintah Respawn diterima dari website!")
                    local char = player.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.Health = 0 -- Trigger kematian (otomatis memicu fungsi re-fly di atas)
                    end
                end
            end
        end)
        task.wait(4) -- Mengirim sinyal online & cek command setiap 4 detik sekali
    end
end

task.spawn(startWebChecking)
