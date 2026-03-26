import os
import sys
import time
import subprocess

# Path penyimpanan data rekaman
RECORD_PATH = "/data/local/tmp/roblox_event.rec"

def run_shell(command):
    return subprocess.run(f"su -c '{command}'", shell=True)

def record_mode():
    print("\n" + "="*40)
    print(" [!] MODE REKAM AKTIF")
    print("="*40)
    print("1. Segera pindah ke aplikasi Roblox.")
    print("2. Lakukan pendaftaran sampai LOGOUT.")
    print("3. Jika sudah selesai, kembali ke Termux.")
    print("4. Tekan CTRL+C untuk berhenti merekam.")
    print("="*40 + "\n")
    
    # Menghapus rekaman lama jika ada
    run_shell(f"rm {RECORD_PATH}")
    
    try:
        # Merekam event input secara mentah (Binary)
        # getevent -t memberikan timestamp agar jeda antar klik terekam presisi
        os.system(f"su -c 'getevent -t /dev/input/event1 > {RECORD_PATH}'")
    except KeyboardInterrupt:
        print("\n\n[OK] Rekaman berhasil disimpan di " + RECORD_PATH)
        print("[*] Jalankan script lagi untuk memutar ulang.")

def replay_mode():
    print("\n" + "="*40)
    print(" [►] MODE OTOMATIS (REPLAY)")
    print("="*40)
    print("[*] Menjalankan gerakan sesuai rekaman...")
    
    # Mengambil data dari file rekaman dan mengirimnya kembali ke sistem input
    # Kita menggunakan awk untuk membersihkan output getevent agar bisa dibaca sendevent
    cmd = (
        "su -c \"awk '{ "
        "gsub(/\\[|\\/dev\\/input\\/event1:|\\]/, \\\"\\\"); "
        "print \\\"sendevent /dev/input/event1 \\\" $2 \\\" \\\" $3 \\\" \\\" $4 "
        "}' " + RECORD_PATH + " | sh\""
    )
    
    try:
        os.system(cmd)
        print("\n[OK] Selesai memutar ulang gerakan.")
    except Exception as e:
        print(f"\n[!] Gagal memutar: {e}")

if __name__ == "__main__":
    # Cek apakah file rekaman sudah ada
    if not os.path.exists(RECORD_PATH) or os.path.getsize(RECORD_PATH) == 0:
        record_mode()
    else:
        print("[+] File rekaman ditemukan.")
        pilihan = input("Putar rekaman sekarang? (y) atau Rekam ulang? (r): ").lower()
        
        if pilihan == 'y':
            replay_mode()
        elif pilihan == 'r':
            record_mode()
        else:
            print("Dibatalkan.")
