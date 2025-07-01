# 🎵 FiveM Engine Sound System by MrJujuri

Sistem *custom engine sound* untuk kendaraan di FiveM, dengan dukungan **kategori mobil & motor**, **whitelist per suara**, serta **proteksi kendaraan listrik & polisi**. Dibuat untuk server yang ingin memberikan pengalaman realistis dan eksklusif kepada pemainnya.

---

## 🔧 Fitur Utama

- 🔊 Ganti suara mesin kendaraan secara *live* (real-time).
- 🚗 Dukungan kategori: **mobil** dan **motor**.
- 📁 Sistem kategori & pencarian suara berdasarkan nama.
- 🔐 Sistem izin berbasis ACE:
  - `admin` & `donator`
  - Whitelist per suara berdasarkan Steam Hex
- ⚡ Proteksi otomatis untuk kendaraan **listrik** & **kendaraan polisi**.
- 🧰 Animasi mekanik dan progress bar saat penggantian suara.
- 🔄 Fitur reset suara ke *default stock*.
- 🎯 Dukungan `ox_target` – interaksi langsung dari luar kendaraan.
- 🌐 Sinkronisasi suara antar pemain dengan **StateBag**.

---

## 📁 Struktur File

- `client.lua` – UI, validasi kendaraan, pemrosesan suara, integrasi `ox_target`.
- `server.lua` – pengecekan izin dan pemrosesan perubahan suara (via state).
- `config.lua` – daftar suara mesin per kategori, whitelist, dan pengaturan izin.

---

## 📌 Requirements

- [ox_lib](https://overextended.dev/ox_lib/)
- [ox_target](https://overextended.dev/ox_target/)
- ACE Permissions:
  - `mrjujuri.enginesound.admin`
  - `mrjujuri.enginesound.donator`

---

## 🧾 Contoh ACE Permissions

Tambahkan pada `server.cfg`:

```cfg
add_ace identifier.steam:123456789ABC123 mrjujuri.enginesound.admin allow
add_ace identifier.steam:123456789ABC123 mrjujuri.enginesound.donator allow
```

---

## 🕹️ Commands

```lua
/enginemenu
```

> Membuka menu engine sound jika pemain berada di dalam kendaraan.

---

## ⚙️ Konfigurasi Suara

`config.lua`:

```lua
Config.EngineSounds = {
  car = {
    ['Mazda RX7 13B Whitelist'] = {
      sound = 'aq31maz13btune',
      vehicles = { 'sultan' },
      category = 'JDM',
      whitelist = {
        ['steam:123456789ABC123'] = true,
      }
    },
    ['Mazda RX7 13B Bukan Whitelist'] = {
      sound = 'aq31maz13btune',
      category = 'JDM',
      vehicles = false,
      whitelist = false
    }
  },
  bike = {
    ['Ducati V4R'] = {
      sound = 'kc32ducavr4',
      vehicles = { 'r6' },
      category = 'JDM',
      whitelist = {
        ['steam:123456789ABC123'] = true
      }
    }
  }
}
```

> 🔒 Suara bisa dibatasi untuk kendaraan tertentu atau dibuka untuk semua.

---

## ⛔ Pembatasan

- ❌ **Kendaraan listrik** tidak bisa diganti suaranya.
- 🚓 **Kendaraan polisi** (Vehicle Class 18) juga diblokir.

---

## 🧪 Preview 

![Preview](https://r2.fivemanage.com/UVI9rHtiT1qXpTharDhSF/Screenshot2025-07-01194717.png)


---

## 👨‍🔧 Credits

Script dibuat oleh **MrJujuri**  
Kontribusi dan masukan sangat diterima!

---

## 📜 Lisensi

Script ini dilindungi dengan lisensi "All Rights Reserved".

🔒 Anda hanya diperbolehkan menggunakan script ini *apa adanya* di server Anda.  
🚫 Tidak diperbolehkan memodifikasi, mengupload ulang, atau mendistribusikan kembali tanpa izin tertulis dari pemilik.

Copyright (c) 2025 MrJujuri

All rights reserved.

This script is provided for use only. You may use this script as-is in your FiveM server, but you may not copy, modify, distribute, sublicense, or sell any part of this script without explicit written permission from the author.

Unauthorized usage, redistribution, or modification is strictly prohibited.

---

Original base script by: https://github.com/JnKTechstuff/ParadoxEngineSounds
Credits to JnKTechstuff for the foundational engine sound implementation.
