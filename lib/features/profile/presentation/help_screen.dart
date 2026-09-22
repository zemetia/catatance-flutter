import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';

class _Faq {
  const _Faq(this.question, this.answer);

  final String question;
  final String answer;
}

const _faqs = [
  _Faq(
    'Bagaimana cara menambah transaksi baru?',
    'Ketuk tombol "+" di tengah navigasi bawah, lalu isi nominal, kategori, '
        'dan dompet yang digunakan.',
  ),
  _Faq(
    'Apakah data saya tersimpan di server?',
    'Tidak. Semua data transaksi, dompet, dan anggaran tersimpan secara lokal '
        'di perangkatmu — lihat Kebijakan Privasi untuk detailnya.',
  ),
  _Faq(
    'Bagaimana cara pindah saldo antar dompet?',
    'Buka Profil > Semua Dompet, lalu ketuk ikon transfer untuk memindahkan '
        'saldo dari satu dompet ke dompet lain.',
  ),
  _Faq(
    'Kenapa saldo dompet saya tidak berubah otomatis?',
    'Saldo dompet mengikuti nominal awal dan transfer yang kamu catat sendiri. '
        'Pastikan setiap transaksi dicatat di dompet yang benar.',
  ),
  _Faq(
    'Bagaimana cara mengganti tema aplikasi?',
    'Buka Profil > Tampilan & Bahasa > Tema untuk memilih palet warna dan '
        'mode gelap/terang/sistem.',
  ),
];

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Pertanyaan Umum',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: Container(
              color: scheme.surfaceContainerHigh,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Column(
                  children: [
                    for (var i = 0; i < _faqs.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: AppSpacing.md,
                          endIndent: AppSpacing.md,
                          color: scheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ExpansionTile(
                        title: Text(
                          _faqs[i].question,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        expandedAlignment: Alignment.topLeft,
                        children: [
                          Text(
                            _faqs[i].answer,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Masih butuh bantuan?',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.push('/profile/feedback'),
              icon: const Icon(LucideIcons.message_square, size: 18),
              label: const Text('Kirim Masukan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
