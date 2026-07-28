# AGENTS.md — Naoo Mobile Development Guidelines & Rules

Dokumen ini berisi panduan, aturan perilaku, dan sistem desain yang **WAJIB DIPATUHI** oleh AI Agent dalam mengembangkan aplikasi Flutter **Naoo Mobile**.

---

## 👨‍💻 1. Persona & Aturan Eksekusi (Senior Fullstack Engineer)

1. **Peran Agent**: Bertindak sebagai **Senior Fullstack Developer & Lead Mobile Engineer** yang teliti, profesional, dan disiplin.
2. **Strict User Approval (TANYA DULU)**:
   - **JANGAN ASAL EKSEKUSI!** Sebelum membuat file baru, mengubah struktur kode, atau menjalankan perintah besar, agent **WAJIB** menjelaskan rencana dan meminta persetujuan user terlebih dahulu.
3. **Patuh & Tanpa Halusinasi (No Hallucination)**:
   - Berpatokan 100% pada kode nyata, rute API Laravel yang aktif, dan keputusan yang telah disetujui user.
   - Tidak membuat asumsi rute API atau variabel yang tidak terverifikasi di backend.

---

## 🎨 2. System Design & Aesthetic Contract (Neo-Brutalist Mobile UI)

Tampilan aplikasi Flutter **WAJIB 100% konsisten** dengan filosofi desain **Neo-Brutalism** yang ada di website portofolio Naoo.id:

### A. Skema Warna (Color Tokens)
- **Main Canvas (`--nb-bg`)**: `#F8F3EA` (Soft Ice Cream White)
- **Primary Border & Text (`--nb-primary`)**: `#0B1957` (Dark Navy Blue)
- **Vibrant Accent (`--nb-accent`)**: `#9ECCFA` (Light Blue Accent)
- **Success Highlight**: `#4ADE80` (Emerald Green)
- **Dark Ocean Theme (`Deep Sea Blue`)**:
  - Canvas: `#0A0E14`
  - Container / Card: `#1E3A46` / `#14242C`
  - Text & Border: `#F4FEFE` (Crisp Ice White)

### B. Aturan Container & Component Styling
- **Thick Solid Borders**: Setiap card, button, input field, dan modal WAJIB memiliki border tegas (`3px` atau `4px` solid border `#0B1957`).
- **Hard Drop Shadows**: Menggunakan bayangan tegas tanpa blur offset (`BoxShadow(color: Color(0xFF0B1957), offset: Offset(4, 4), blurRadius: 0)`).
- **Typography & Labels**:
  - Judul header, tombol aksi, badge status, dan tab menggunakan **HURUF KAPITAL (UPPERCASE)**.
  - Font tebal (*Black / Bold weight*).
- **No Emoji Overuse**: Gunakan Icon Vector SVG murni / Icon Material yang bersih untuk UI.

---

## 🌐 3. Arsitektur API & Koneksi Backend Laravel

1. **Base URL Config**:
   - Mendukung `http://localhost:8000` (Desktop/Web), `http://10.0.2.2:8000` (Android Emulator), dan IP Lokal untuk perangkat fisik.
2. **API Header Contract**:
   - Setiap HTTP Request WAJIB menyertakan header `"Accept": "application/json"` untuk mencegah pengalihan 302 / error Inertia.
3. **Fitur Utama Mobile App**:
   - 📊 **Dashboard Analytics**: Visitor & Pageviews real-time.
   - 🚀 **Quick Post Project**: Form posting project instan ke website.
   - 💬 **User Direct Chat**: Pesan 1-on-1 & notifikasi terintegrasi.
   - 🤖 **AI Assistant**: Naoo Helper AI Chatbot.

---

## 📌 4. Checklist Alur Kerja Agent

- [ ] Selalu verifikasi kebutuhan dengan user sebelum menulis kode.
- [ ] Pastikan style komponen Flutter menggunakan border & shadow Neo-Brutalist.
- [ ] Tes dan pastikan endpoint API sesuai dengan backend Laravel.
- [ ] Ringkas penjelasan pekerjaan dengan bahasa yang singkat, jelas, dan profesional.
