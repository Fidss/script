import os
import time
import random
import string
import xml.etree.ElementTree as ET

def run_root(command):
    return os.popen(f"su -c '{command}'").read().strip()

def get_element_coords(search_text, search_type="text"):
    """Mengambil koordinat elemen. Mencoba dump hingga 3 kali jika gagal."""
    for attempt in range(3):
        # Dump UI ke file sementara di folder tmp (lebih stabil)
        run_root("uiautomator dump /data/local/tmp/view.xml")
        xml_data = run_root("cat /data/local/tmp/view.xml")
        
        if not xml_data or "xml" not in xml_data:
            time.sleep(2)
            continue
            
        try:
            root = ET.fromstring(xml_data)
            for node in root.iter('node'):
                # Cek teks atau deskripsi (Roblox kadang pakai content-desc)
                if node.get('text') == search_text or node.get('content-desc') == search_text:
                    bounds = node.get('bounds')
                    coords = bounds.replace('[', '').replace(']', ',').split(',')
                    x = (int(coords[0]) + int(coords[2])) // 2
                    y = (int(coords[1]) + int(coords[3])) // 2
                    return x, y
        except Exception as e:
            pass
        time.sleep(1)
    return None

def tap_element(text):
    coords = get_element_coords(text)
    if coords:
        print(f"[*] Mengetuk {text} di {coords}")
        run_root(f"input tap {coords[0]} {coords[1]}")
        return True
    return False

def setup_account():
    # 1. Reset dan Paksa Buka
    print("[*] Membersihkan data lama...")
    run_root("pm clear com.roblox.client")
    time.sleep(2)

    print("[*] Membuka Roblox (Metode Launcher)...")
    # Menggunakan monkey untuk simulasi klik ikon di menu
    run_root("monkey -p com.roblox.client -c android.intent.category.LAUNCHER 1")
    
    # Tunggu loading awal yang biasanya berat
    print("[*] Menunggu aplikasi terbuka (25 detik)...")
    time.sleep(25)

    # 2. Klik Sign Up dengan pengecekan ulang
    if not tap_element("Sign Up"):
        print("[!] Tombol Sign Up tidak ditemukan. Mencoba scroll sedikit...")
        run_root("input swipe 500 1000 500 500 500") # Scroll barangkali tertutup
        time.sleep(2)
        if not tap_element("Sign Up"):
            print("[!] Gagal total menemukan tombol Sign Up.")
            return

    # 3. Proses Pengisian (Gunakan jeda antar input)
    time.sleep(3)
    print("[*] Mengatur Tanggal Lahir...")
    tap_element("Birthday")
    time.sleep(2)
    
    # Swipe tahun ke bawah (ke arah tahun 2000)
    for _ in range(15):
        run_root("input swipe 500 1600 500 1900 150")
    
    tap_element("SET") or tap_element("Confirm")
    time.sleep(2)

    # 4. Data Akun
    user = "Gem" + "".join(random.choices(string.ascii_lowercase + string.digits, k=7))
    pw = "".join(random.choices(string.ascii_letters + string.digits, k=10)) + "A1!"

    print(f"[*] Input Username: {user}")
    tap_element("Username")
    time.sleep(1)
    run_root(f"input text {user}")
    
    time.sleep(2)
    print("[*] Input Password...")
    tap_element("Password")
    time.sleep(1)
    run_root(f"input text {pw}")

    # 5. Gender & Submit
    time.sleep(2)
    # Pilih Male (Biasanya ini ada di content-desc)
    coords_male = get_element_coords("Male")
    if coords_male:
        run_root(f"input tap {coords_male[0]} {coords_male[1]}")
    
    print("[*] Menyelesaikan Pendaftaran...")
    tap_element("Sign Up")

    # Simpan Hasil
    with open("/sdcard/hasil_roblox.txt", "a") as f:
        f.write(f"{user}:{pw}\n")
    print(f"[SUKSES] Akun {user} berhasil dibuat dan disimpan.")

if __name__ == "__main__":
    setup_account()
