import 'package:flutter/material.dart';

import 'widgets/legal_text_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalTextScreen(
      title: 'Syarat & Ketentuan',
      updatedAt: '22 September 2026',
      sections: [
        LegalSection(
          heading: 'Penggunaan Aplikasi',
          body:
              'Aplikasi ini disediakan untuk membantu pencatatan keuangan pribadi. '
              'Kamu bertanggung jawab atas keakuratan data transaksi, dompet, dan '
              'anggaran yang kamu masukkan.',
        ),
        LegalSection(
          heading: 'Bukan Nasihat Keuangan',
          body:
              'Ringkasan, grafik, dan proyeksi yang ditampilkan bersifat informatif '
              'berdasarkan data yang kamu masukkan sendiri, dan bukan merupakan '
              'nasihat investasi atau keuangan profesional.',
        ),
        LegalSection(
          heading: 'Tanggung Jawab Data',
          body:
              'Karena data disimpan secara lokal di perangkatmu, kehilangan perangkat, '
              'penghapusan aplikasi, atau kerusakan sistem dapat mengakibatkan hilangnya '
              'data yang belum dicadangkan.',
        ),
        LegalSection(
          heading: 'Perubahan Layanan',
          body:
              'Fitur aplikasi dapat berubah, ditambah, atau dihapus dari waktu ke waktu '
              'untuk meningkatkan kualitas layanan.',
        ),
      ],
    );
  }
}
