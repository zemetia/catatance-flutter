import 'package:flutter/material.dart';

import 'widgets/legal_text_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalTextScreen(
      title: 'Kebijakan Privasi',
      updatedAt: '22 September 2026',
      sections: [
        LegalSection(
          heading: 'Data yang Kami Simpan',
          body:
              'Semua data transaksi, dompet, dan kategori yang kamu catat disimpan '
              'secara lokal di perangkatmu menggunakan database SQLite. Kami tidak '
              'mengunggah, menyalin, atau menyinkronkan data keuanganmu ke server mana pun.',
        ),
        LegalSection(
          heading: 'Akses Perangkat',
          body:
              'Aplikasi ini dapat meminta izin biometrik (sidik jari/Face ID) hanya untuk '
              'fitur kunci aplikasi, dan izin notifikasi hanya untuk pengingat anggaran '
              'dan tagihan. Izin ini tidak digunakan untuk mengambil data pribadi lain.',
        ),
        LegalSection(
          heading: 'Berbagi Data',
          body:
              'Karena data disimpan secara lokal, kami tidak membagikan data keuanganmu '
              'kepada pihak ketiga mana pun. Kamu bertanggung jawab penuh atas cadangan '
              'dan keamanan data di perangkatmu sendiri.',
        ),
        LegalSection(
          heading: 'Perubahan Kebijakan',
          body:
              'Kebijakan ini dapat diperbarui seiring bertambahnya fitur aplikasi. '
              'Perubahan penting akan diinformasikan melalui pembaruan aplikasi.',
        ),
      ],
    );
  }
}
