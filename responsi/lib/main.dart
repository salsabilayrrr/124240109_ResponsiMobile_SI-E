import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/favorite_service.dart';

void main() async {
  // 1. Memastikan seluruh mesin internal Flutter siap sebelum membaca memori HP
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Membuka penyimpanan lokal (SharedPreferences) untuk mengecek sesi login
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final String savedUsername = prefs.getString('logged_username') ?? '';

  // 3. Memuat data favorit tersimpan jika user sudah login
  if (isLoggedIn) {
    await FavoriteService().loadFavorites();
  }

  // 4. Menjalankan aplikasi dengan membawa status login awal
  runApp(MainApp(
    isLoggedIn: isLoggedIn,
    username: savedUsername,
  ));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  final String username;

  const MainApp({
    super.key,
    required this.isLoggedIn,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spaceflight News',
      // Pengaturan tema global aplikasi (Biru-Ungu Material 3)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C5CFF),
          primary: const Color(0xFF5C5CFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5C5CFF),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      // Penentuan halaman awal: jika sudah login ke HomePage, jika belum ke LoginPage
      home: isLoggedIn
          ? HomePage(username: username)
          : const LoginPage(),
    );
  }
}
