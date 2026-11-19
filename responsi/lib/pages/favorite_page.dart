import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favService = FavoriteService();

  @override
  void initState() {
    super.initState();
    // Memasang pendengar: setiap kali data favorit berubah, layar ini langsung me-refresh diri
    _favService.addListener(_onFavoriteChanged);
  }

  @override
  void dispose() {
    _favService.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  void _onFavoriteChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ==================== CADANGAN RESPONSI: DUA VERSI NOTIFIKASI SETELAH DIHAPUS ====================
  // CARA NONAKTIFKAN:
  // - Jika TIDAK INGIN notifikasi sistem HP (Push Notif): beri tanda komentar // pada blok VERSI 1
  // - Jika TIDAK INGIN notifikasi SnackBar: beri tanda komentar // pada blok VERSI 2
  Future<void> _executeDeleteAndNotify(BuildContext context, ItemModel item) async {
    // 1. Eksekusi hapus item dari memori / SharedPreferences
    await _favService.removeFavorite(item);
    
    // ------------------------------------------------------------------------------------------------
    // [VERSI 2] NOTIFIKASI SNACKBAR (DI DALAM APLIKASI / MELAYANG DI BAWAH LAYAR)
    // (Beri tanda komentar // pada blok if ini jika ingin MENONAKTIFKANNYA)
    // ------------------------------------------------------------------------------------------------
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notifikasi: "${item.title}" telah berhasil dihapus dari favorit.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
  // =================================================================================================

  // ==================== OPSI 1: DIALOG KONFIRMASI POPUP (PERSIS SESUAI GAMBAR) ====================
  // Tampilan: Kotak popup tengah, ada Judul "Hapus Favorit", tombol outline Batal & tombol lonjong merah Hapus
  void _showConfirmDeleteDialog(BuildContext context, ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(
            child: Text(
              'Hapus Favorit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            'Hapus "${item.title}" dari daftar favorit?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            // Tombol Outline Batal
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(width: 8),

            // Tombol Merah Hapus
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30), // Warna merah menyala persis gambar
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog
                await _executeDeleteAndNotify(context, item); // Eksekusi hapus & kirim notifikasi
              },
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ==================== OPSI 2: SNACKBAR KONFIRMASI (ALTERNATIF JIKA MINTA SNACKBAR) ====================
  // Tampilan: Bar muncul dari bawah layar dengan tombol [HAPUS]
  void _confirmDeleteWithSnackBar(BuildContext context, ItemModel item) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Yakin ingin menghapus "${item.title}"?'),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'HAPUS',
          textColor: Colors.white,
          onPressed: () async {
            await _executeDeleteAndNotify(context, item); // Eksekusi hapus & kirim notifikasi
          },
        ),
      ),
    );
  }
  // =====================================================================================================

  @override
  Widget build(BuildContext context) {
    // Mengambil seluruh daftar favorit (gabungan News, Blog, dan Reports)
    final List<ItemModel> favorites = _favService.favorites;

    return Scaffold(
      appBar: AppBar(
        // ==================== CADANGAN RESPONSI: FAVORITE BISA DIGANTI JADI BOOKMARK ====================
        // Jika soal meminta Bookmark, cukup ganti teks 'Favorite' jadi 'Bookmark' atau 'Library'
        title: const Text('Favorite'),
        // ================================================================================================
      ),
      // Jika keranjang favorit masih kosong
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ==================== CADANGAN RESPONSI: GANTI IKON BOOKMARK JIKA PERLU ====================
                  // Ganti Icons.favorite_border -> Icons.bookmark_border
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                    color: Colors.grey,
                  ),
                  // ===========================================================================================
                  SizedBox(height: 16),
                  Text(
                    'Belum ada artikel favorit / bookmark.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Buka detail artikel lalu tandai untuk menambahkan ke daftar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          // Jika ada data favorit, tampilkan dalam bentuk ListView
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final ItemModel item = favorites[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    // 1. Thumbnail Gambar dengan Error Handling
                    
                    
                    //HAPUS INI KALO TIDAK ADA IMAGE URL
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 2. Judul Berita (Maksimal 2 Baris)
                    title: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    // 3. Nama Author & Tag Kategori di bawah judul
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${item.author} • [${item.category.toUpperCase()}]',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // 4. Ikon Sampah di sebelah kanan (Trailing) untuk menghapus
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      tooltip: 'Hapus dari Favorit',
                      onPressed: () {
                        // ==================== PILIHAN CARA KONFIRMASI HAPUS ====================
                        // [CARA GANTI / NONAKTIFKAN]:
                        // Default saat ini memakai OPSI 1 (Dialog Popup persis screenshot).
                        // - Jika soal minta Dialog Popup: biarkan baris OPSI 1 aktif.
                        // - Jika soal minta SnackBar Konfirmasi: beri // pada OPSI 1, dan hapus // pada OPSI 2.
                        
                        // OPSI 1 (AKTIF): Dialog Popup (Batal / Hapus)
                        _showConfirmDeleteDialog(context, item);

                        // OPSI 2 (CADANGAN): SnackBar Konfirmasi dari bawah
                        // _confirmDeleteWithSnackBar(context, item);
                        // =======================================================================
                      },
                    ),

                    // 5. Klik pada kartu -> Membuka Halaman Detail
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(item: item),
                        ),
                      ).then((_) {
                        // Penjaga Kepulangan: Refresh layar saat pulang dari Detail
                        setState(() {});
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
