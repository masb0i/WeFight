# WeFight — Log Progres

Log ini **append-only**: tambahkan entri baru di paling bawah, jangan pernah mengedit atau menghapus entri lama.
Rencana dan checklist ada di [`PLAN.md`](./PLAN.md) — log ini mencatat apa yang benar-benar terjadi.

**Format setiap entri** (satu entri = satu tugas):

```markdown
## YYYY-MM-DD HH:mm — [ID tugas] Judul singkat
- **Status:** selesai | sebagian | terblokir
- **Yang dikerjakan:** …
- **File disentuh:** …
- **Keputusan/kompromi:** … (atau "tidak ada")
- **Kendala:** … (atau "tidak ada")
- **Berikutnya:** [ID tugas]
```

---

## 2026-10-29 17:31 — Perencanaan proyek
- **Status:** selesai
- **Yang dikerjakan:** Mempelajari 5 dokumen di `worksheet/`, mengekstrak teksnya, lalu menyusun `docs/PLAN.md` (spesifikasi, aturan bisnis, arsitektur, 12 milestone M5–M16, 60+ tugas ber-ID, DoD, risiko) dan `docs/PROGRESS.md` ini beserta protokol pencatatan progres.
- **File disentuh:** `docs/PLAN.md`, `docs/PROGRESS.md`, `.workbuddy-ai/memory/MEMORY.md`, `.workbuddy-ai/tmp/extract_docx.py`
- **Keputusan/kompromi:** Riverpod + GoRouter + fl_chart (D1–D3, D8). Tanggal disimpan sebagai `String yyyy-MM-dd` agar pengecekan "satu catatan per tanggal" sederhana (D4). Font Inter masih terbuka (D5) — sementara pakai `textTheme` Material 3.
- **Kendala:** Belum ada repository git dan `lib/main.dart` masih counter app bawaan Flutter. Keputusan D5 menunggu pemilik proyek.
- **Berikutnya:** M5-1 `git init` + commit pertama.

## 2026-10-29 17:58 — Menetapkan referensi UI baru
- **Status:** selesai
- **Yang dikerjakan:** Menyimpan 3 gambar referensi UI ke `docs/ui-reference/`, mengambil warna aslinya lewat sampling piksel (bukan menebak), lalu menulis `docs/UI_SPEC.md` — palet 18 token, 6 definisi gradient, skala tipografi, 20 komponen, layout web/mobile, pemetaan 8 layar referensi ke 7 halaman final, dan catatan implementasi Flutter. `PLAN.md` §6 diganti ke palet burgundy→peach, ditambah §13 soal selisih referensi vs worksheet.
- **File disentuh:** `docs/UI_SPEC.md` (baru), `docs/ui-reference/*` (3 gambar), `docs/PLAN.md` (§0, §5, §6, §8 M5–M6, §12, §13), `docs/PROGRESS.md`
- **Keputusan/kompromi:** D5 selesai — font Plus Jakarta Sans dibundel. D9 — gambar referensi menggantikan style guide Figma sebagai acuan visual. D10 — baseline progres ("sudah turun X dari Y") dihitung dari catatan terawal, jadi tidak perlu field baru di `targets`. Palet worksheet (#1F3A5F biru) dibatalkan, diganti burgundy #59171B.
- **Kendala:** Referensi menampilkan fitur **Jadwal Latihan/Timbang/Pertandingan** yang berstatus Won't now di worksheet Minggu 2. Ditahan sebagai keputusan D11 + §13; default sementara = visual saja, kartu jadwal diganti "Riwayat Terbaru".
- **Berikutnya:** konfirmasi pemilik soal D11 (menu 5 slot) & fitur jadwal, lalu M5-1.
