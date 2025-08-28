import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trashvisor/pages/loginandregister/register.dart' show RegisterPage;

/// ===================================================================
///  PALET WARNA GLOBAL (ubah di sini jika mau ganti warna)
/// ===================================================================
class AppColors {
  static const Color green     = Color(0xFF528123); // Button Color
  static const Color deepGreen = Color(0xFF244D24);
  static const Color blackText = Colors.black87;   // teks utama
  static const Color textMuted = Colors.black54;   // hint/deskripsi lembut
  static const Color border    = Color(0xFFE0E0E0);
  static const Color fieldBg   = Colors.white;

  // Warna & teks untuk top-banner (notifikasi di atas)
  static const Color errorBg   = Color(0xFFEA4335);
  static const Color errorText = Colors.white;
}

/// ===================================================================
///  DIMENSI / KNOB UBAHAN (semua angka tinggal diatur di sini)
///  --- BAGIAN INI ADALAH "TITIK UBAHAN" UTAMA UNTUK JARAK/UKURAN ---
/// ===================================================================
class LoginDimens {
  // ---------- HERO (ilustrasi atas) — proporsional terhadap tinggi layar ----------
  static const double heroRatioTall  = 0.38;
  static const double heroRatioShort = 0.3;

  // ---------- KONTEN ----------
  static const double contentMaxWidth = 500; // batasi lebar konten agar rapi di tablet
  static const double sidePadding     = 24;  // <<< UBAH padding kiri/kanan konten

  // ---------- JARAK ATAS ----------
  static const double gapAfterHero  = -40; // <<< boleh negatif (narik konten ke atas)
  static const double brandTopGap   = 0;   // padding murni di atas brand (jangan negatif)
  static const double logoTopOffset = -6;  // geser vertikal ikon logo relatif teks

  // ---------- SPACING LAIN ----------
  static const double gapAfterBrand     = 12; // jarak brand → judul
  static const double gapTitleToDesc    = 10; // jarak judul → deskripsi
  static const double gapAfterDesc      = 20; // jarak deskripsi → field pertama
  static const double gapBetweenFields  = 16; // jarak antar field
  static const double gapBeforeButton   = 24;  // jarak field terakhir → tombol
  static const double bottomPadding     = 20; // padding bawah konten

  // ---------- BRAND ----------
  static const double brandIcon = 40;                 // ukuran logo
  static const EdgeInsets brandTextMargin = EdgeInsets.only(left: 15); // jarak teks dari logo

  // ---------- TIPOGRAFI ----------
  static const double title = 22;
  static const double body  = 14;

  // ---------- FIELD & BUTTON ----------
  static const double fieldHeight = 52;   // tinggi TextField
  static const double fieldRadius = 14;   // radius TextField
  static const EdgeInsets fieldContentPadding =
      EdgeInsets.symmetric(horizontal: 14, vertical: 14);
  static const double btnHeight = 54;     // tinggi tombol
  static const double btnRadius = 16;     // radius tombol

  // ---------- TOP-BANNER (animasi & posisi) ----------
  static const Duration bannerInDuration  = Duration(milliseconds: 220);  // durasi masuk
  static const Duration bannerOutDuration = Duration(milliseconds: 180);  // durasi keluar
  static const Duration bannerShowTime    = Duration(milliseconds: 2000); // lama tampil
  static const double  bannerSideMargin   = 12;                           // jarak kiri/kanan
}

/// ===================================================================
///  LOGIN PAGE — Opsi B: SATU AnimationController di-reuse
/// ===================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  // ---------------------- Controller Form ----------------------
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();
  bool _obscure = true;

  // Link "Daftar Sekarang" (gunakan TapGestureRecognizer supaya bisa di-dispose)
  late final TapGestureRecognizer _toRegister;

  // ---------------------- Top Banner (satu controller) ----------------------
  // NOTE (OPS B): Satu controller untuk semua banner. Hindari "multiple tickers" error.
  late final AnimationController _bannerCtl; // controller animasi masuk/keluar
  OverlayEntry? _bannerEntry;                // entry overlay yang ditempel ke Overlay
  Timer? _bannerTimer;                       // auto-dismiss timer
  String _bannerMessage = '';                // pesan aktif yang sedang ditampilkan

  @override
  void initState() {
    super.initState();

    // (1) Buat controller SEKALI dan di-reuse → lebih efisien & aman memory
    _bannerCtl = AnimationController(
      vsync: this,
      duration: LoginDimens.bannerInDuration,
      reverseDuration: LoginDimens.bannerOutDuration,
    )..addStatusListener((status) {
        // Saat animasi reverse selesai (status: dismissed) → lepas overlay agar bersih
        if (status == AnimationStatus.dismissed) {
          _bannerEntry?.remove();
          _bannerEntry = null;
        }
      });

    // (2) Siapkan recognizer untuk link "Daftar Sekarang"
    _toRegister = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegisterPage()),
        );
      };
  }

  @override
  void dispose() {
    // Penting: release semua resource
    _toRegister.dispose();
    _emailC.dispose();
    _passC.dispose();

    _bannerTimer?.cancel(); // hentikan timer jika masih aktif
    _bannerCtl.dispose();   // dispose controller tunggal
    _bannerEntry?.remove(); // copot overlay jika masih ada
    _bannerEntry = null;

    super.dispose();
  }

  // ---------------------- Validasi ringan ----------------------
  bool _isBlank(String s) => s.trim().isEmpty;
  bool _isValidEmail(String s) {
    // regex sederhana untuk email
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(s.trim());
  }

  // ---------------------- Tampilkan top-banner ----------------------
  void _showTopBanner(String message,
      { Color bg = AppColors.errorBg, Color fg = AppColors.errorText }) {
    _bannerTimer?.cancel();   // reset timer (kalau ada banner yang masih jalan)
    _bannerMessage = message; // simpan pesan yang mau ditampilkan

    final media  = MediaQuery.of(context);
    final topPad = media.padding.top; // SafeArea atas (hindari notch)
    final left   = LoginDimens.bannerSideMargin;
    final right  = LoginDimens.bannerSideMargin;

    if (_bannerEntry == null) {
      // Buat OverlayEntry SEKALI → builder akan membaca _bannerMessage saat rebuild
      _bannerEntry = OverlayEntry(
        builder: (_) {
          return Positioned(
            top: topPad + 8,       // posisi dari atas
            left: left,            // jarak kiri (UBAH di Dimens)
            right: right,          // jarak kanan (UBAH di Dimens)
            child: SlideTransition( // ANIMASI GESER VERTIKAL
              position: Tween<Offset>(
                begin: const Offset(0, -0.2), // start sedikit di atas
                end: Offset.zero,             // berakhir tepat di posisinya
              ).animate(CurvedAnimation(
                parent: _bannerCtl,
                curve: Curves.easeOutCubic,     // easing saat masuk
                reverseCurve: Curves.easeInCubic, // easing saat keluar
              )),
              child: FadeTransition(           // ANIMASI FADE
                opacity: _bannerCtl,
                child: Material(
                  color: bg,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        // NOTE: Text membaca _bannerMessage yang bisa berubah
                        Expanded(
                          child: Text(
                            _bannerMessage,
                            style: TextStyle(
                              color: fg,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      // Masukkan overlay ke atas layar
      Overlay.of(context).insert(_bannerEntry!);
    } else {
      // Overlay sudah ada → minta rebuild agar pesan terbarui
      _bannerEntry!.markNeedsBuild();
    }

    // Mainkan animasi masuk dari awal
    _bannerCtl.forward(from: 0);

    // Auto-dismiss setelah durasi yang ditentukan
    _bannerTimer = Timer(LoginDimens.bannerShowTime, () {
      _bannerCtl.reverse();
    });
  }

  // ---------------------- Aksi tombol Masuk ----------------------
  void _onLogin() {
    // Validasi berurutan (meniru "cek dari atas")
    if (_isBlank(_emailC.text)) {
      _showTopBanner('Email anda belum terisi'); return;
    }
    if (!_isValidEmail(_emailC.text)) {
      _showTopBanner('Format email tidak valid'); return;
    }
    if (_isBlank(_passC.text)) {
      _showTopBanner('Password anda belum terisi'); return;
    }

    // TODO: proses login sebenarnya (call API di sini)

    // (NEW) CONTOH: kalau sukses → navigasi ke HomePage (simulasi)
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (_) => const HomePage(), // <- siapkan HomePage sendiri
    //     settings: const RouteSettings(name: 'HomePage'),
    //   ),
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login dikirim!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media   = MediaQuery.of(context);
    final size    = media.size;
    final isShort = size.height < 700;

    // Tinggi hero responsif (UBAH di LoginDimens jika ingin)
    final heroH = size.height *
        (isShort ? LoginDimens.heroRatioShort : LoginDimens.heroRatioTall);

    // gapAfterHero: kalau negatif → dipakai di Transform.translate (pullUpY)
    final double safeTopPad =
        LoginDimens.gapAfterHero > 0 ? LoginDimens.gapAfterHero : 0;
    final double pullUpY =
        LoginDimens.gapAfterHero < 0 ? LoginDimens.gapAfterHero : 0;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.deferToChild, // link RichText tetap menang
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportH = constraints.maxHeight;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewportH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // =========================== HERO ===========================
                      SizedBox(
                        height: heroH,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/illustrations/login_top.png',
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          cacheWidth: size.width.ceil(),
                          filterQuality: FilterQuality.none,
                        ),
                      ),

                      // ========================== KONTEN ==========================
                      Padding(
                        // <<< semua jarak horizontal/vertical diatur dari LoginDimens
                        padding: EdgeInsets.fromLTRB(
                          LoginDimens.sidePadding,
                          safeTopPad + LoginDimens.brandTopGap,
                          LoginDimens.sidePadding,
                          LoginDimens.bottomPadding,
                        ),
                        child: Transform.translate(
                          offset: Offset(0, pullUpY), // narik konten ke atas jika negatif
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: LoginDimens.contentMaxWidth),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ------------------------- BRAND -------------------------
                                  const Center(
                                    child: _BrandHeader(
                                      assetPath: 'assets/images/logo_apk.png',
                                      text: 'Trashvisor',
                                      iconSize: LoginDimens.brandIcon,
                                      textMargin: LoginDimens.brandTextMargin,
                                    ),
                                  ),
                                  const SizedBox(height: LoginDimens.gapAfterBrand),

                                  // ------------------------- TITLE -------------------------
                                  const Center(
                                    child: Text(
                                      'Selamat Datang Kembali',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: LoginDimens.title,
                                        height: 1.25,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.deepGreen,
                                        fontFamily:
                                            'assets/fonts/nunito/nunito-extrabold.ttf',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: LoginDimens.gapTitleToDesc),

                                  // ------------------------ SUBTITLE -----------------------
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25),
                                      child: Text(
                                        'Masuk sekarang untuk melanjutkan aksi '
                                        'cerdas memilah dan mengelola sampah demi '
                                        'bumi yang lebih bersih',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: LoginDimens.body,
                                          height: 1.75,
                                          color: AppColors.blackText,
                                          fontFamily:
                                              'assets/fonts/roboto/roboto-regular.ttf',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: LoginDimens.gapAfterDesc),

                                  // -------------------------- EMAIL -------------------------
                                  const _FieldLabel('Email'),
                                  const SizedBox(height: 8),
                                  _AppTextField(
                                    controller: _emailC,
                                    hint: 'Masukkan email kamu',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    prefix: const Icon(Icons.mail_outline),
                                  ),
                                  const SizedBox(height: LoginDimens.gapBetweenFields),

                                  // ------------------------ PASSWORD -----------------------
                                  const _FieldLabel('Password'),
                                  const SizedBox(height: 8),
                                  _AppTextField(
                                    controller: _passC,
                                    hint: 'Masukkan password kamu',
                                    obscure: _obscure,
                                    textInputAction: TextInputAction.done,
                                    prefix: const Icon(Icons.lock_outline),
                                    suffix: IconButton(
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                    ),
                                  ),

                                  // Align(
                                  //   alignment: Alignment.centerRight,
                                  //   child: TextButton(
                                  //     onPressed: () {/* TODO: Forgot password */},
                                  //     child: const Text(
                                  //       'Lupa Password?',
                                  //       style: TextStyle(color: AppColors.deepGreen),
                                  //     ),
                                  //   ),
                                  // ),
                                  const SizedBox(height: LoginDimens.gapBeforeButton),

                                  // -------------------------- BUTTON -----------------------
                                  SizedBox(
                                    width: double.infinity,
                                    height: LoginDimens.btnHeight,
                                    child: ElevatedButton(
                                      onPressed: _onLogin, // validasi + banner
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              LoginDimens.btnRadius),
                                        ),
                                      ),
                                      child: const Text(
                                        'Masuk',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // --------------------------- CTA -------------------------
                                  Center(
                                    child: Text.rich(
                                      TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black87, fontSize: 13),
                                        children: [
                                          const TextSpan(text: 'Belum punya akun? '),
                                          TextSpan(
                                            text: 'Daftar Sekarang',
                                            style: const TextStyle(
                                              color: AppColors.deepGreen,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            recognizer: _toRegister,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ======================== END KONTEN =========================
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ===================================================================
///  KOMPONEN UI KECIL (label + textfield + brand)
/// ===================================================================
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w700,
        // gunakan Nunito Bold sesuai permintaan
        fontFamily: 'assets/fonts/nunito/nunito-bold.ttf',
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LoginDimens.fieldHeight, // <<< ubah tinggi field dari sini
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.fieldBg,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          contentPadding: LoginDimens.fieldContentPadding, // <<< padding dalam field
          prefixIcon: prefix,
          suffixIcon: suffix,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(LoginDimens.fieldRadius), // <<< radius field
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.deepGreen, width: 1.2),
            borderRadius: BorderRadius.circular(LoginDimens.fieldRadius),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final double iconSize;
  final String assetPath;
  final String text;
  final EdgeInsets textMargin;

  const _BrandHeader({
    super.key,
    this.iconSize = LoginDimens.brandIcon,
    required this.assetPath,
    required this.text,
    this.textMargin = LoginDimens.brandTextMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Geser ikon relatif ke teks (lihat LoginDimens.logoTopOffset)
        Transform.translate(
          offset: const Offset(0, LoginDimens.logoTopOffset),
          child: Image.asset(
            assetPath,
            height: iconSize, // <<< ubah ukuran logo dari LoginDimens.brandIcon
            errorBuilder: (_, __, ___) => Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.eco, size: iconSize * 0.7, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: textMargin, // <<< atur jarak teks dari logo
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.deepGreen,
            ),
          ),
        ),
      ],
    );
  }
}
