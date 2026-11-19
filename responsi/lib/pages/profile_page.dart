import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

// ==================== CADANGAN RESPONSI: PROFILE PAGE LENGKAP ====================
// Halaman ini mencakup:
// 1. Username otomatis (read-only dari registrasi / SharedPreferences)
// 2. Foto profil avatar yang bisa diedit / diganti pilihan
// 3. Kesan dan Pesan selama praktikum
// 4. Tombol Logout yang fungsional
// =================================================================================

class ProfilePage extends StatefulWidget {
  final String? initialUsername;

  const ProfilePage({super.key, this.initialUsername});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  int _selectedAvatarIndex = 0;

  // Daftar pilihan avatar profil yang bisa dipilih user
  final List<IconData> _avatarOptions = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.sentiment_very_satisfied_rounded,
    Icons.smart_toy_rounded,
    Icons.pets_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Mengambil username dari session SharedPreferences
  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String currentUsername = await AuthService.getLoggedUsername();
    final int savedAvatar = prefs.getInt('saved_avatar_index') ?? 0;

    setState(() {
      _username = currentUsername.isNotEmpty
          ? currentUsername
          : (widget.initialUsername ?? 'Pengguna');
      _selectedAvatarIndex = savedAvatar;
    });
  }

  // Dialog memilih foto profil / avatar baru
  void _showChangeAvatarDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pilih Avatar Profil'),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_avatarOptions.length, (index) {
              final isSelected = _selectedAvatarIndex == index;
              return InkWell(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('saved_avatar_index', index);

                  setState(() {
                    _selectedAvatarIndex = index;
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Avatar profil berhasil diubah!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: isSelected
                      ? const Color(0xFF5C5CFF)
                      : Colors.grey.shade200,
                  child: Icon(
                    _avatarOptions[index],
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Fungsionalitas Logout
  void _handleLogout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 1. FOTO PROFIL / AVATAR DENGAN TOMBOL EDIT
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFF5C5CFF).withOpacity(0.15),
                    child: Icon(
                      _avatarOptions[_selectedAvatarIndex],
                      size: 64,
                      color: const Color(0xFF5C5CFF),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showChangeAvatarDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5C5CFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. INFORMASI USERNAME (READ ONLY - OTOMATIS SAAT REGISTRASI)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: Color(0xFF5C5CFF), size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Username (Akun Terdaftar)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _username.isNotEmpty ? _username : 'Memuat...',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Chip(
                      label: Text('Aktif', style: TextStyle(color: Colors.green, fontSize: 11)),
                      backgroundColor: Color(0xFFE8F5E9),
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. KARTU KESAN & PESAN PRAKTIKUM
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rate_review_outlined, color: Color(0xFF5C5CFF)),
                        SizedBox(width: 8),
                        Text(
                          'Kesan & Pesan Praktikum',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Text(
                      'Kesan:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Praktikum Pemrograman Aplikasi Mobile sangat menantang dan menambah wawasan mendalam mengenai struktur aplikasi modern Flutter serta integrasi API publik.',
                      style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Pesan:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Terima kasih kepada para asisten praktikum atas bimbingan dan kesabarannya selama satu semester ini. Semoga praktikum ini terus berkembang semakin baik!',
                      style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. TOMBOL LOGOUT FUNCTIONAL
            ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

