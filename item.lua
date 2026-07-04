local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- URL Endpoint Vercel kamu
local VERCEL_API_URL = "https://roblox-script-item.vercel.app/api/track" 

-------------------------------------------------------------------------------
-- 1. FUNGSI INISIALISASI USER (Dipanggil saat script pertama kali jalan)
-------------------------------------------------------------------------------
local function inisialisasiUser()
    -- Mengirim item dummy ("Init") agar backend membuatkan row baru dengan nilai 0
    local payload = HttpService:JSONEncode({
        username = LocalPlayer.Name,
        items = {"Init"} 
    })

    local success, response = pcall(function()
        return request({
            Url = VERCEL_API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    end)

    if success then
        print("[GemstonesHub] Akun " .. LocalPlayer.Name .. " berhasil terdaftar di database (Item: 0).")
    else
        warn("[GemstonesHub] Gagal menghubungkan akun ke database.")
    end
end

-- Jalankan inisialisasi secara asinkron agar tidak membuat game lag saat loading
task.spawn(inisialisasiUser)


-------------------------------------------------------------------------------
-- 2. FUNGSI GUI NOTIFIKASI
-------------------------------------------------------------------------------
local function tampilkanNotifikasi(isiPesan)
    task.spawn(function()
        local CoreGui = game:GetService("CoreGui")
        
        if CoreGui:FindFirstChild("WebhookDetectorUI") then
            CoreGui.WebhookDetectorUI:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "WebhookDetectorUI"
        screenGui.Parent = CoreGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 400, 0, 100)
        frame.Position = UDim2.new(0.5, -200, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
        frame.Parent = screenGui

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.Code
        titleLabel.Text = "⚠️ NOTIFIKASI DISCORD TERDETEKSI ⚠️"
        titleLabel.Parent = frame

        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(1, -20, 1, -40)
        contentLabel.Position = UDim2.new(0, 10, 0, 35)
        contentLabel.BackgroundTransparency = 1
        contentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        contentLabel.TextSize = 14
        contentLabel.Font = Enum.Font.Code
        contentLabel.TextWrapped = true
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.Text = "Dikirim:\n" .. tostring(isiPesan)
        contentLabel.Parent = frame

        task.delay(7, function()
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
        end)
    end)
end

-------------------------------------------------------------------------------
-- 3. FUNGSI KIRIM DATA ITEM KE DATABASE
-------------------------------------------------------------------------------
local function kirimKeDatabase(ditemukanItems)
    local payload = HttpService:JSONEncode({
        username = LocalPlayer.Name,
        items = ditemukanItems
    })

    local success, response = pcall(function()
        return request({
            Url = VERCEL_API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    end)

    if success then
        print("[GemstonesHub] Berhasil update item untuk: ", LocalPlayer.Name)
    else
        warn("[GemstonesHub] Gagal update item ke database.")
    end
end

-------------------------------------------------------------------------------
-- 4. HOOK HTTP REQUEST (Tangkep Webhook Discord)
-------------------------------------------------------------------------------
local oldRequest
oldRequest = hookfunction(request, function(options)
    -- Pastikan request valid dan mengarah ke Discord
    if type(options) == "table" and type(options.Url) == "string" then
        if string.find(options.Url, "discord.com/api/webhooks") or string.find(options.Url, "discordapp.com/api/webhooks") then
            
            local teksDikirim = "Kosong/File"
            local itemDitemukan = {}
            
            if options.Body then
                local sukses, hasilDecode = pcall(function()
                    return HttpService:JSONDecode(options.Body)
                end)
                
                if sukses and type(hasilDecode) == "table" then
                    -- Gabungkan konten teks dan embed agar semua data terbaca
                    local fullText = ""
                    if hasilDecode.content then
                        fullText = fullText .. hasilDecode.content .. " "
                    end
                    
                    if hasilDecode.embeds then
                        for _, embed in pairs(hasilDecode.embeds) do
                            if embed.title then fullText = fullText .. embed.title .. " " end
                            if embed.description then fullText = fullText .. embed.description .. " " end
                            if embed.fields then
                                for _, field in pairs(embed.fields) do
                                    fullText = fullText .. (field.name or "") .. " " .. (field.value or "") .. " "
                                end
                            end
                        end
                    end
                    
                    teksDikirim = fullText ~= "" and fullText or "[Format JSON tidak ada teks]"
                    
                    -- Deteksi Item dari teks yang akan dikirim ke Discord
                    if string.find(fullText, "Elshark Gran Maja") then
                        table.insert(itemDitemukan, "Elshark Gran Maja")
                    end
                    if string.find(fullText, "Gladiator Shark") then
                        table.insert(itemDitemukan, "Gladiator Shark")
                    end
                    if string.find(fullText, "Evolved Enchant Stone") then
                        table.insert(itemDitemukan, "Evolved Enchant Stone")
                    end
                    
                else
                    teksDikirim = tostring(options.Body)
                end
            end
            
            -- Tampilkan UI Notifikasi di layar
            tampilkanNotifikasi(teksDikirim)

            -- Jika ada item yang terdeteksi, update ke Vercel (Supabase)
            if #itemDitemukan > 0 then
                task.spawn(function()
                    kirimKeDatabase(itemDitemukan)
                end)
            end
            
            -- Biarkan webhook asli tetap terkirim ke Discord
            return oldRequest(options)
        end
    end

    -- Kembalikan request normal jika bukan ke Discord
    return oldRequest(options)
end)

print("[GemstonesHub] Script Tracker Webhook Berhasil Berjalan!")
