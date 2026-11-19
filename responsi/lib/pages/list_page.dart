import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class ListPage extends StatefulWidget {
  final String title; // 'News', 'Blog', atau 'Reports'
  final String endpoint; // 'articles', 'blogs', atau 'reports'

  const ListPage({super.key, required this.title, required this.endpoint});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Future<List<ItemModel>> _futureItems;

  // Variabel penyimpan author yang sedang dipilih untuk filter (null = tampilkan semua)
  String? _selectedAuthor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _selectedAuthor = null; // Reset filter saat data dimuat ulang
      _futureItems = ApiService.getItems(widget.endpoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritePage()),
              ).then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ItemModel>>(
        future: _futureItems,
        builder: (context, snapshot) {
          // KONDISI 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // KONDISI 2: Error Jaringan
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // KONDISI 3: Data Kosong
          final List<ItemModel> allItems = snapshot.data ?? [];
          if (allItems.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada data yang tersedia.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ================= LOGIKA FITUR FILTER (20 Poin) =================
          // 1. Ekstrak seluruh author unik (tidak ada duplikat) menggunakan .toSet()
          final List<String> uniqueAuthors = allItems
              .map((item) => item.author)
              .where((author) => author.trim().isNotEmpty)
              .toSet()
              .toList();

          // 2. Saring data yang akan ditampilkan sesuai chip yang aktif
          final List<ItemModel> displayedItems = _selectedAuthor == null
              ? allItems
              : allItems
                    .where((item) => item.author == _selectedAuthor)
                    .toList();
          // =================================================================

          return Column(
            children: [
              // Deretan Chip Filter Horizontal yang bisa di-scroll ke samping
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: uniqueAuthors.map((author) {
                    final bool isSelected = _selectedAuthor == author;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(author),
                        selected: isSelected,
                        showCheckmark: true,
                        checkmarkColor: Colors.white,
                        selectedColor: const Color(0xFF5C5CFF),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // Logika Toggle: klik untuk memilih, klik lagi untuk batal (tampilkan semua)
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedAuthor = selected ? author : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Daftar Berita yang sudah disaring (dibungkus Expanded agar mengisi sisa layar)
              Expanded(
                child: displayedItems.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada artikel dari $_selectedAuthor',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadData();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: displayedItems.length,
                          itemBuilder: (context, index) {
                            final ItemModel item = displayedItems[index];

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),








//KALO GA PAKE IMAGE.URL HAPUS INI 

                                //Thumbnail Gambar + Error Handling
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
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

                                // Judul Berita (Maksimal 2 Baris)
                                title: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),



                              


                                // ==================== CADANGAN RESPONSI: PILIHAN POSISI RATING ====================
                                // [OPSI 1] SUBTITLE: RATING DI BAWAH NAMA RESTORAN (AKTIF)
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [



                                      // DI SEBELAH KIRI BAWAH JUDULLL  
                                      // ⭐️ Baris Rating
                                      // Row(
                                      //   children: [
                                      //     const Icon(
                                      //       Icons.star,
                                      //       color: Colors.amber,
                                      //       size: 16,
                                      //     ),
                                      //     const SizedBox(width: 4),
                                      //     Text(
                                      //       item.rating.toString(),
                                      //       style: const TextStyle(
                                      //         fontWeight: FontWeight.bold,
                                      //         fontSize: 12,
                                      //         color: Colors.black87,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),







                                  //MENAMBAHKAN PLATFORM KALO ADA 
                                    // Row(
                                    //     children: [
                                    //       Icon(
                                    //         item.platform.toLowerCase().contains('windows') 
                                    //             ? Icons.computer 
                                    //             : Icons.web,
                                    //         size: 14,
                                    //         color: Colors.grey.shade700,
                                    //       ),
                                    //       const SizedBox(width: 4),
                                    //       Text(
                                    //         item.platform,
                                    //         style: TextStyle(
                                    //           fontSize: 11,
                                    //           color: Colors.grey.shade700,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),









                                      const SizedBox(height: 4),
                                      // Info Kota / Author
                                      Text(
                                        item.author,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // [OPSI 2] TRAILING: RATING DI POJOK KANAN KARTU (CADANGAN)
                                
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.rating.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                
                        // =================================================================================










                                // Navigasi ke Detail
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPage(item: item),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
