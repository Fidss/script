import os
import time
import random
import string
import xml.etree.ElementTree as ET

def run_root(command):
    return os.popen(f"su -c '{command}'").read()

def get_element_coords(search_text, search_type="text"):
    """Mencari elemen berdasarkan teks atau deskripsi dan mengembalikan koordinat tengahnya."""
    run_root("uiautomator dump /sdcard/view.xml")
    xml_data = run_root("cat /sdcard/view.xml")
    
    if not xml_data:
        return None
        
    try:
        root = ET.fromstring(xml_data)
        for node in root.iter('node'):
            if node.get(search_type) == search_text:
                bounds = node.get('bounds') # Format: [x1,y1][x2,y2]
                coords = bounds.replace('[', '').replace(']', ',').split(',')
                x = (int(coords[0]) + int(coords[2])) // 2
                y = (int(coords[1]) + int(coords[3])) // 2
                return x, y
    except:
        pass
    return None

def tap_element(text, type="text"):
    coords = get_element_coords(text, type)
    if coords:
        run_root(f"input tap {coords[0]} {coords[1]}")
        return True
    return False

def setup_account():
    # 1. Reset & Buka Roblox
    print("[*] Menyiapkan aplikasi...")
    run_root("pm clear com.roblox.client")
    run_root("am start -n com.roblox.client/com.roblox.client.ActivityMain")
    time.sleep(10)

    # 2. Klik Sign Up
    if not tap_element("Sign Up"):
        print("[!] Gagal menemukan tombol Sign Up")
        return

    # 3. Isi Tanggal Lahir (Set ke Tahun 2000)
    time.sleep(2)
    tap_element("Birthday")
    time.sleep(1)
    
    # Logika Swipe Tahun ke 2000 (Asumsi default tahun sekarang 2026)
    # Kita butuh swipe ke bawah berkali-kali untuk mencapai tahun 2000
    print("[*] Mengatur tahun ke 2000...")
    for _ in range(13): # Sesuaikan jumlah swipe agar sampai ke 2000
        run_root("input swipe 500 1500 500 1800 200") 
    
    tap_element("SET")
    time.sleep(1)

    # 4. Generate Data
    user = "Gemstones" + "".join(random.choices(string.ascii_lowercase + string.digits, k=5))
    pw = "".join(random.choices(string.letters + string.digits, k=10)) + "!"

    # 5. Isi Username & Password
    print(f"[*] Mengisi akun: {user}")
    tap_element("Username")
    run_root(f"input text {user}")
    
    time.sleep(1)
    tap_element("Password")
    run_root(f"input text {pw}")

    # 6. Pilih Gender (Male) & Submit
    time.sleep(1)
    tap_element("Male", "content-desc")
    tap_element("Sign Up")

    # Simpan
    with open("hasil_akun.txt", "a") as f:
        f.write(f"{user}:{pw}\n")
    print(f"[OK] Akun {user} tersimpan.")

if __name__ == "__main__":
    setup_account()
