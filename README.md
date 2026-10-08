# ghost-dock

```
 ██████╗ ███████╗██╗  ██╗ ██████╗ ███████╗
 ██╔════╝ ██╔════╝██║  ██║██╔═══██╗██╔════╝
 ██║  ███╗█████╗  ███████║██║   ██║█████╗
 ██║   ██║██╔══╝  ██╔══██║██║   ██║██╔══╝
 ╚██████╔╝███████╗██║  ██║╚██████╔╝███████╗
  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
   dock GNOME tanpa background + genie Mac
```

**Author: LALA**

Dock kiri ala macOS buat GNOME: ikon melayang polos di atas wallpaper. Panel, kotak, bayangan, border — semuanya dibuang total, bukan cuma ditransparanin setengah-setengah. Waktu minimize, jendela nyeret ke dock lewat animasi genie yang rambat pelan kayak macOS, bukan slide kaku.

Gue bikin ini karena bawaan Ubuntu (ubuntu-dock) gambar background-nya sendiri dan set opacity-nya tetep aja keliatan kotaknya. Capek ngoprek, akhirnya jadi satu script.

## Cara pakai

```bash
git clone https://github.com/Coding-No/ghost-dock.git
cd ghost-dock
./install.sh
```

Abis itu biarin script-nya minta restart shell:
- **X11**: tekan `Alt+F2`, ketik `r`, Enter. Selesai, gak perlu logout.
- **Wayland**: logout → login lagi.

Kalau ikon 36 kekecilan di monitor lu:

```bash
ICON_SIZE=48 ./install.sh
```

Jalanin `./install.sh` dua kali juga aman — script deteksi apa yang udah kepasang dan lewati.

## Apa aja yang dipasang

- **Dash to Dock** (micheleg) — si dock-nya. Di-download resmi dari extensions.gnome.org, bukan kode nyempil di repo ini.
- **Compiz alike magic lamp** (hermes83) — animasi genie-nya. Gue set 250ms biar lembut, bawaannya 400ms kayak lelet.
- **Patch CSS kecil** — bagian yang bikin background-nya gak keliatan sama sekali. Backup stylesheet asli disimpan sebelum diutak-atik.

## Yang di-set di dconf

| Key | Nilai | Fungsi |
|---|---|---|
| `transparency-mode` | `FIXED` | mode transparan tetap, gak dinamis |
| `background-opacity` | `0.0` | opacity background nol |
| `apply-custom-theme` | `false` | gak ikut tema gelap — biar CSS patch yang pegang |
| `dash-max-icon-size` | `36` | ukuran ikon |
| `click-action` | `minimize` | klik ikon = minimize (khas Mac) |
| `autohide` | `true` | dock sembunyi sendiri |
| `show-running` | `false` | gak ada titik indikator dobel |
| `dock-position` | `LEFT` | nempel di kiri |

Magic lamp-nya sendiri: `duration=250`, `x-tiles=6`, `y-tiles=35` — tile-nya gue lebarin biar rambatannya halus.

## Syarat

- GNOME Shell 45 ke atas (Ubuntu 24.04 udah oke, Fedora 39+ juga).
- Jalan di X11 sama Wayland.
- Butuh `curl`, `unzip`, `python3` — Ubuntu desktop biasanya udah ada semua.
- `ubuntu-dock` otomatis dimatiin biar gak rebutan renderan.

## Buat balikin

```bash
./uninstall.sh
```

Matiin kedua ekstensi, hapus patch CSS (stylesheet asli dari backup ikut dipulihin), setelan dconf dibiarin — gak ngaruh selama ekstensi mati.

## Credits

- [Dash to Dock](https://github.com/micheleg/dash-to-dock) — Michael Egger, GPL-3.
- [Compiz alike magic lamp effect](https://github.com/hermes83/compiz-alike-magic-lamp-effect) — hermes83, GPL-3.

Dua-duanya di-download pas install lewat extensions.gnome.org. Repo ini isinya script doang.
