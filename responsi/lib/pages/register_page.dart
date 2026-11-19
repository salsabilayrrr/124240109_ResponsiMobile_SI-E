import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Pengendali teks untuk menangkap inputan dari kotak form
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ==================== CADANGAN RESPONSI: CONTROLLER KONFIRMASI PASSWORD ====================
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  // ============================================================================================

  // Bersihkan controller dari memori HP saat halaman ditutup
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    // ==================== CADANGAN RESPONSI: DISPOSE CONTROLLER ====================
    _confirmPasswordController.dispose();
    // ===============================================================================
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol Daftar ditekan
  void _handleRegister() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // ==================== CADANGAN RESPONSI: AMBIL KONFIRMASI PASSWORD ====================
    final String confirmPassword = _confirmPasswordController.text.trim();
    // ========================================================================================

    // Validasi: field tidak boleh kosong
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ==================== CADANGAN RESPONSI: VALIDASI KECOCOKAN PASSWORD ====================
    // Jika soal meminta validasi konfirmasi password:
    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // =========================================================================================

    // Simpan akun ke SharedPreferences lewat AuthService
    await AuthService.register(username, password);

    if (!mounted) return;

    // Tampilkan notifikasi hijau sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran Berhasil! Silakan Login.'),
        backgroundColor: Colors.green,
      ),
    );

    // Kembali ke halaman Login
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ==================== CADANGAN RESPONSI: ICON/GAMBAR TEMA DI ATAS ====================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C5CFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.app_registration_rounded, // Ganti Icon sesuai tema
                  size: 64,
                  color: Color(0xFF5C5CFF),
                ),
              ),
              const SizedBox(height: 16),
              // =====================================================================================

              // Judul Halaman
              const Text(
                'Daftar Akun Baru',
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
                  prefixIcon: const Icon(Icons.person_outline),
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
                  prefixIcon: const Icon(Icons.lock_outline),
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
              const SizedBox(height: 16),

              // ==================== CADANGAN RESPONSI: FIELD KONFIRMASI PASSWORD ====================
              // [CARA NONAKTIFKAN]:
              // Jika soal TIDAK meminta konfirmasi password:
              // Hapus atau beri komentar // pada seluruh blok TextField konfirmasi password di bawah ini.
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isConfirmPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // ======================================================================================
              const SizedBox(height: 24),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Daftar'),
              ),
              const SizedBox(height: 16),

              // ==================== CADANGAN RESPONSI: TOMBOL SUDAH PUNYA AKUN? MASUK ====================
              // Memudahkan user kembali ke halaman Login tanpa harus memencet tombol panah back di AppBar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah memiliki akun? ',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context); // Kembali ke LoginPage
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C5CFF),
                      ),
                    ),
                  ),
                ],
              ),
              // ============================================================================================
            ],
          ),
        ),
      ),
    );
  }
}

