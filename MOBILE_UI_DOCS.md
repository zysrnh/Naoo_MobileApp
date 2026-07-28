# 📱 Naoo Mobile — UI/UX Wireframe & Design System Specification

Dokumen ini berisi spesifikasi layout visual, wireframe per layar, dan aturan mikro-interaksi agar aplikasi **Naoo Mobile** tidak terkesan generic/AI-slop, melainkan memiliki estetika **Neo-Brutalism murni** yang presisi, unik, dan konsisten dengan portofolio web Naoo.id.

---

## 📐 1. Prinsip Desain Neo-Brutalism Murni (Non-AI Slop Rules)

1. **Thick Structural Borders**: Semua container, button, avatar, dan input field WAJIB menggunakan border tegas `3px` hingga `4px` solid (`Color(0xFF0B1957)`).
2. **Hard Offsetting Shadows**: Menggunakan bayangan tegas tanpa blur (`BoxShadow(color: Color(0xFF0B1957), offset: Offset(4, 4), blurRadius: 0)`). Tidak ada soft shadow / blur berlebihan.
3. **High-Contrast Micro-Badges**: Penggunaan badge status (`LIVE`, `HOSTED`, `PLANNING`, `MEMBER`) dalam bentuk kotak tegas berlatar kontras dengan teks huruf kapital.
4. **Bold Typography Hierarchy**: Judul section dan tombol aksi menggunakan **HURUF KAPITAL (UPPERCASE)** tebal (*Weight 900*).

---

## 🖼️ 2. Blueprint Wireframe Layar per Layar

### A. Layar 1: Dashboard Overview (`DashboardScreen`)
- **Top Header Bar**:
  - Logo `NAOO.MOBILE` di kiri (Teks tebal berkotak `#0B1957`).
  - Tombol `Palette Icon` di kanan untuk membuka **Theme Swatch Drawer**.
- **Welcome Hero Card**:
  - Avatar User berkotak shadow + Status `MEMBER AKUN`.
  - Teks sapaan: `"HALO, ZAKI YUSRON!"`.
- **Live Traffic Status Card**:
  - Indikator dot hijau berkedip `● REAL-TIME VISITORS`.
  - Grid 2 kolom digital counter: `VISITORS` & `PAGEVIEWS`.
- **Quick Action Grid (2x2)**:
  - 4 Kartu Aksi Tegas: `POST PROJECT`, `USER CHAT`, `AI HELPER`, `COLOR PALETTES`.
- **Recent Projects Feed**:
  - List card project dengan tag status (`HOSTED` / `LIVE`) dan tombol detail.

---

### B. Layar 2: Quick Post Project (`QuickPostScreen`)
- **Header**: `"POST PROJECT BARU"`.
- **Form Fields (Neo-Brutalist Input Box)**:
  - Input `JUDUL PROJECT` (Teks tebal, border 2px solid).
  - Input `DESKRIPSI PROJECT` (Multiline 3 baris).
  - Input `LIVE DEMO URL` & `GITHUB REPO URL`.
  - Selector `STATUS PROJECT` (`Hosted`, `Live`, `In Progress`, `Planning`).
- **Live Card Preview**:
  - Komponen preview kartu yang otomatis terupdate secara real-time memperlihatkan tampilan project sebelum di-publish!
- **Submit Button**:
  - Tombol penuh warna `#0B1957` dengan teks `#9ECCFA`: `"PUBLISH PROJECT SEKARANG →"`.

---

### C. Layar 3: Direct User Chat (`UserChatScreen`)
- **User List Panel**: Daftar pengguna terdaftar dengan avatar berkotak & badge unread chat.
- **Chat Container**: Bubble pesan Neo-Brutalist (User = Accent Color `#9ECCFA`, Contact = Light Background `#F8F3EA`).
- **Timestamp & Pure SVG Copy**: Timestamp halus + ikon copy SVG.

---

### D. Layar 4: AI Naoo Helper (`AiAssistantScreen`)
- **Header**: `"AI NAOO HELPER ASSISTANT"`.
- **Chat Window**:
  - Support format Markdown, blok kode program berlatar gelap, dan tombol reset chat.
- **Input Bar**: Field input bertuliskan `"Tanya Naoo Helper AI..."` + tombol kirim.

---

## 🎨 3. Multi-Theme Swatch Drawer Specs

Saat tombol Palette diklik, akan muncul **Bottom Sheet Drawer** dari bawah dengan 7 pilihan warna tema:
1. **Classic Blue** (`#F8F3EA` / `#0B1957`)
2. **Deep Sea Dark** (`#0A0E14` / `#1E3A46`)
3. **Retro Vintage** (`#E8D8C9` / `#4B607F`)
4. **Christmas** (`#F6E8DD` / `#193564`)
5. **Luxe Caramel** (`#F7ECE6` / `#0D0D0F`)
6. **Euro Retro** (`#F4E5B2` / `#253054`)
7. **Cold Ice** (`#EBEDE0` / `#31394C`)
