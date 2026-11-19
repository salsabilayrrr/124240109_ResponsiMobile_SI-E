import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Pengendali input teks
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ==================== CADANGAN RESPONSI: LIHAT/SEMBUNYIKAN PASSWORD ====================
  bool _isPasswordObscured = true;
  // =======================================================================================

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi proses Login saat tombol ditekan
  void _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // 1. Validasi: jika kosong, munculkan SnackBar merah
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Gagal! Username dan Password tidak boleh kosong.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Cek kebenaran akun ke AuthService (SharedPreferences)
    final bool isSuccess = await AuthService.login(username, password);

    if (!mounted) return;

    if (isSuccess) {
      // Muat data favorit milik akun ini
      await FavoriteService().loadFavorites();

      if (!mounted) return;

      // 3. Jika berhasil, ganti halaman ke HomePage (pushReplacement agar tidak bisa di-back ke login)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(username: username),
        ),
      );
    } else {
      // 4. Jika gagal / belum register / salah password: WAJIB SnackBar MERAH (Ketentuan Soal)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Gagal! Pastikan sudah Register atau cek password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ==================== CADANGAN RESPONSI: ICON/GAMBAR TEMA DI ATAS ====================
              // [CARA NONAKTIFKAN]:
              // Jika soal TIDAK meminta icon/gambar di atas form, hapus atau beri // pada Container ini.
              // Ganti Icon(Icons.xxx) sesuai tema soal (misal Icons.movie, Icons.tv, Icons.fastfood).
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C5CFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded, // Ganti Icon sesuai tema, misal Icons.movie, Icons.tv, dll
                  size: 64,
                  color: Color(0xFF5C5CFF),
                ),
              ),
              const SizedBox(height: 16),
              // =====================================================================================

              // Judul Halaman
              const Text(
                'Silakan Login',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Kotak Input Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kotak Input Password
              TextField(
                controller: _passwordController,
                // ==================== CADANGAN RESPONSI: TOGGLE LIHAT PASSWORD ====================
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // ==================================================================================
              ),
              const SizedBox(height: 24),

              // Tombol Login
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),

              // Tombol Teks Pindah ke Halaman Register
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  'Belum punya akun? Daftar di sini',
                  style: TextStyle(color: Color(0xFF5C5CFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
