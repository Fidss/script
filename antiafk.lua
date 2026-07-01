-- Pesan pemberitahuan di konsol bahwa script mulai berjalan
print("Anti-AFK Script Aktif!")

-- Mengakses VirtualUser untuk mensimulasikan input pemain
local vu = game:GetService("VirtualUser")

-- Menangkap event saat pemain terdeteksi Idle (AFK)
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    -- Mensimulasikan klik/pergerakan tanpa mengganggu kontrol aslimu
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    print("Mencegah AFK pada: " .. os.date("%X"))
end)
