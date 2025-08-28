import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trashvisor/pages/onboarding/onboarding_page.dart';

// ========================================
// KONSTANTA DESAIN DAN UKURAN
// ========================================
// Konstanta ini memudahkan perubahan ukuran di masa depan
// dan membuat kode lebih mudah dibaca dan dipelihara

const double kLogoHeight = 160;              // Tinggi logo utama Trashvisor
const double kIconSize = 120;                // Ukuran icon fallback jika logo gagal dimuat
const double kSponsorLogoHeight = 50;        // Tinggi logo sponsor (diperbesar dari 36 ke 50)
const double kBottomPadding = 20;            // Padding bawah untuk section sponsor
const double kSponsorLogoSpacing = 35;       // Jarak antar logo sponsor (diperbesar dari 25 ke 35)
const double kTitleFontSize = 28;            // Ukuran font judul "Trashvisor"
const double kDidukungFontSize = 12;         // Ukuran font teks "Didukung oleh"
const double kSpacerAfterDidukung = 25;      // Jarak setelah teks "Didukung oleh" (diperbesar dari 20 ke 25)
const Color kTrashvisorTitleColor = Color(0xFF2C5E2B); // Warna hijau untuk judul

// ========================================
// FUNGSI UTAMA APLIKASI
// ========================================
void main() {
  // Memastikan Flutter framework sudah siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ========================================
// WIDGET UTAMA APLIKASI
// ========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trashvisor App',
      
      debugShowCheckedModeBanner: false, // MENGHILANGKAN BANNER DEBUG
      
      // Konfigurasi tema aplikasi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        
        // Definisi style teks yang dapat digunakan di seluruh aplikasi
        textTheme: TextTheme(
          // Style untuk judul besar (digunakan untuk "Trashvisor")
          headlineLarge: TextStyle(
            fontSize: kTitleFontSize,
            fontWeight: FontWeight.w600,
            color: kTrashvisorTitleColor,
            letterSpacing: 0.2,
          ),
          // Style untuk teks kecil (digunakan untuk "Didukung oleh")
          bodySmall: const TextStyle(
            fontSize: kDidukungFontSize,
          ),
        ),
      ),
      
      // Halaman pertama yang ditampilkan adalah splash screen
      home: const _SplashScreen(),
    );
  }
}

// ========================================
// SPLASH SCREEN - HALAMAN PEMBUKA
// ========================================
class _SplashScreen extends StatefulWidget {
  const _SplashScreen({super.key});

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  
  // ========================================
  // DAFTAR GAMBAR ONBOARDING
  // ========================================
  // Gambar-gambar ini akan di-preload untuk memastikan
  // tampilan yang mulus saat halaman onboarding dibuka
  static const _onboardingAssets = <String>[
    'assets/images/onboarding/onboarding1.png',
    'assets/images/onboarding/onboarding2.png',
    'assets/images/onboarding/onboarding3.png',
    'assets/images/onboarding/onboarding4.png',
  ];

  @override
  void initState() {
    super.initState();
    // Memulai proses persiapan dan navigasi ke halaman berikutnya
    _prepareAndGo();
  }

  // ========================================
  // FUNGSI PERSIAPAN DAN NAVIGASI
  // ========================================
  Future<void> _prepareAndGo() async {
    // Pre-cache (muat sebelumnya) gambar-gambar onboarding
    // agar saat halaman onboarding dibuka, gambar sudah siap
    await Future.wait(_onboardingAssets.map((path) async {
      try {
        // Mencoba memuat gambar ke dalam cache
        await precacheImage(AssetImage(path), context);
      } catch (_) {
        // Jika ada gambar yang gagal dimuat, aplikasi tetap berjalan
        // Error diabaikan agar tidak mengganggu user experience
      }
    }));

    // Memastikan splash screen tampil minimal 3 detik
    // untuk memberikan waktu user melihat logo dan sponsor
    await Future.delayed(const Duration(seconds: 3));

    // Cek apakah widget masih aktif sebelum navigasi
    // (mencegah error jika user keluar dari aplikasi)
    if (!mounted) return;
    
    // Navigasi ke halaman onboarding dengan mengganti halaman saat ini
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnBoardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ========================================
            // BAGIAN TENGAH - LOGO DAN JUDUL
            // ========================================
            Center(
              child: _buildLogoSection(),
            ),

            // ========================================
            // BAGIAN BAWAH - SPONSOR
            // ========================================
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: kBottomPadding),
                child: _buildSponsorSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // BUILDER UNTUK SECTION LOGO DAN JUDUL
  // ========================================
  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Hanya menggunakan ruang yang diperlukan
      children: [
        // Logo utama aplikasi
        Image.asset(
          'assets/images/logo_apk.png',
          height: kLogoHeight,
          fit: BoxFit.contain, // Menjaga proporsi gambar
          // Fallback jika logo gagal dimuat - menampilkan icon delete
          errorBuilder: (_, __, ___) => const Icon(
            Icons.delete, 
            size: kIconSize,
          ),
        ),
        
        // Jarak antara logo dan judul
        const SizedBox(height: 16),
        
        // Judul aplikasi menggunakan style yang sudah didefinisikan di theme
        Text(
          'Trashvisor',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
  }

  // ========================================
  // BUILDER UNTUK SECTION SPONSOR
  // ========================================
  Widget _buildSponsorSection() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Hanya menggunakan ruang yang diperlukan
      children: [
        // Teks "Didukung oleh"
        Text(
          'Didukung oleh',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        
        // Jarak antara teks dan logo sponsor (diperbesar untuk tampilan yang lebih baik)
        const SizedBox(height: kSpacerAfterDidukung),
        
        // Baris logo sponsor dengan jarak yang lebih besar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Logo sponsor pertama
            _SponsorLogo('assets/images/sponsors/skilvuv_logo.png'),
            
            // Jarak antar logo (diperbesar dari 25 ke 35)
            SizedBox(width: kSponsorLogoSpacing),
            
            // Logo sponsor kedua
            _SponsorLogo('assets/images/sponsors/polman_logo.png'),
            
            // Jarak antar logo
            SizedBox(width: kSponsorLogoSpacing),
            
            // Logo sponsor ketiga
            _SponsorLogo('assets/images/sponsors/team_logo.png'),
          ],
        ),
      ],
    );
  }
}

// ========================================
// WIDGET LOGO SPONSOR
// ========================================
// Widget terpisah untuk logo sponsor agar mudah digunakan kembali
// dan memudahkan maintenance
class _SponsorLogo extends StatelessWidget {
  final String path; // Path ke file gambar logo sponsor
  
  const _SponsorLogo(this.path, {super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      height: kSponsorLogoHeight, // Tinggi logo sponsor (diperbesar ke 50)
      fit: BoxFit.contain, // Menjaga proporsi gambar
      
      // Fallback jika logo sponsor gagal dimuat
      // Menampilkan kotak kosong dengan ukuran yang sama
      errorBuilder: (_, __, ___) => SizedBox(
        width: kSponsorLogoHeight, 
        height: kSponsorLogoHeight,
      ),
    );
  }
}