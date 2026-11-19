import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Kunci (Key) unik untuk menyimpan data di SharedPreferences
  static const String _keyRegUser = 'registered_username';
  static const String _keyRegPass = 'registered_password';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLoggedUser = 'logged_username';

  // 1. Fungsi Registrasi: Menyimpan username dan password baru ke memori HP
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegUser, username);
    await prefs.setString(_keyRegPass, password);
    return true;
  }

  // 2. Fungsi Login: Memeriksa apakah username & password cocok dengan data terdaftar
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final String? registeredUser = prefs.getString(_keyRegUser);
    final String? registeredPass = prefs.getString(_keyRegPass);

    // Cek apakah akun sudah pernah didaftarkan dan password cocok
    if (registeredUser != null &&
        registeredPass != null &&
        registeredUser == username &&
        registeredPass == password) {
      // Simpan status bahwa pengguna telah login
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyLoggedUser, username);
      return true; // Login Sukses
    }

    return false; // Login Gagal (akun tidak ditemukan atau password salah)
  }

  // 3. Fungsi Logout: Menghapus status login dari memori HP
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyLoggedUser);
  }

  // 4. Fungsi Cek Sesi: Mengambil nama username yang sedang login saat ini
  static Future<String> getLoggedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedUser) ?? '';
  }

  // 5. Fungsi Cek Sesi: Mengecek apakah statusnya masih login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}

