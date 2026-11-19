import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'list_page.dart';
import 'login_page.dart';
// ==================== CADANGAN RESPONSI: IMPORT HALAMAN FAVORIT & PROFIL UNTUK NAVBAR ====================
import 'favorite_page.dart';
import 'profile_page.dart';
// =========================================================================================================

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ==================== CADANGAN RESPONSI: INDEX AKTIF BOTTOM NAVIGATION BAR ====================
  int _currentTabIndex = 0;
  // ==============================================================================================

  // Fungsi untuk menangani proses Logout
  void _handleLogout(BuildContext context) async {
    // 1. Hapus status login dari SharedPreferences
    await AuthService.logout();

    if (!context.mounted) return;

    // 2. Tendang keluar ke LoginPage dan hapus seluruh tumpukan halaman sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // Widget pembantu (helper) untuk membuat kartu menu agar kode tidak berulang
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String endpoint,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Berpindah ke Halaman List sesuai kategori menu yang dipilih
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListPage(
                title: title,
                endpoint: endpoint,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wadah Ikon Berwarna
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C5CFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF5C5CFF),
                ),
              ),
              const SizedBox(width: 16),
              // Bagian Teks Judul dan Deskripsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget konten halaman beranda asli (3 Menu News, Blog, Reports + Tombol Logout)
  //YANG INI KALO MISALLLLLL ADA CARD NYAAA KAYA LATIHAN RESPONSI
  Widget _buildHomeMenuContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // 1. Menu News (Endpoint: articles / shows)
          _buildMenuCard(
            context: context,
            icon: Icons.newspaper,
            title: 'News / Shows',
            description:
                'Get an overview of the latest news or shows! Easily link your users to the right content.',
            endpoint: 'shows',
          ),

          // 2. Menu Blog (Endpoint: blogs)
          _buildMenuCard(
            context: context,
            icon: Icons.menu_book,
            title: 'Blog / Schedule',
            description:
                'Explore detailed information, schedules, and blogs for deeper insights.',
            endpoint: 'blogs',
          ),

          // 3. Menu Reports (Endpoint: reports)
          _buildMenuCard(
            context: context,
            icon: Icons.analytics_outlined,
            title: 'Reports / More',
            description:
                'Discover extra reports and official published data directly from the API.',
            endpoint: 'reports',
          ),

          const SizedBox(height: 24),

          // Tombol Log Out Berwarna Merah (Ketentuan Soal Asli)
          ElevatedButton(
            onPressed: () => _handleLogout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ==================== CADANGAN RESPONSI: 2 PILIHAN STRATEGI BERANDA ====================
    // CARA MEMILIH BESOK DI RESPONSI:
    //
    // [STRATEGI A] Jika soal meminta 3 KARTU MENU (seperti Spaceflight News):
    //   Gunakan: _buildHomeMenuContent(context)
    //
    // [STRATEGI B] Jika soal LANGSUNG KE ENDPOINT (seperti TVMaze / shows tanpa kartu menu):
    //   Gunakan: const ListPage(title: 'Daftar Shows', endpoint: 'shows')
    //
    final List<Widget> pages = [
      // --- PILIH SALAH SATU DI BAWAH INI (CUKUP PINDAHKAN TANDA KOMENTAR //): ---
      
      // _buildHomeMenuContent(context),                                 // <- STRATEGI A: 3 Kartu Menu
      // const ListPage(title: 'Daftar Shows', endpoint: 'list'),      // <- STRATEGI B: Langsung List Data



     const ListPage(title: 'Resep Masakan', endpoint: 'recipes'), 


      // Tab 1: Favorit / Bookmark
      const FavoritePage(),

      // Tab 2: Profil Pengguna
      ProfilePage(initialUsername: widget.username),
    ];
    // =====================================================================================

    return Scaffold(
      // AppBar hanya aktif jika tab yang dibuka adalah menu beranda ber-kartu (Strategi A)
      // Jika pakai Strategi B (ListPage), ListPage sudah punya AppBar sendiri
      appBar: _currentTabIndex == 0
          ? AppBar(
              // title: Text('Hai, ${widget.username}!'),
              automaticallyImplyLeading: false,
            )
          : null,

      // Menampilkan halaman sesuai tab yang dipilih
      body: pages[_currentTabIndex],

      // ==================== CADANGAN RESPONSI: BOTTOM NAVIGATION BAR 3 MENU ====================
      // [CARA NONAKTIFKAN]:
      // Jika soal responsi TIDAK meminta BottomNavigationBar (ingin menu beranda normal saja):
      // 1. Ubah body di atas menjadi: body: _buildHomeMenuContent(context),
      // 2. Beri tanda komentar // pada seluruh blok bottomNavigationBar di bawah ini.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        selectedItemColor: const Color(0xFF5C5CFF),
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      // ========================================================================================
    );
  }
}