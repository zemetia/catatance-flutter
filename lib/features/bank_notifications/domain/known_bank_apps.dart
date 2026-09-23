/// A preset bank/e-wallet app offered in the bank-app picker, so the user
/// doesn't have to know their Android package name by heart.
class KnownBankApp {
  const KnownBankApp({
    required this.packageName,
    required this.label,
    required this.section,
  });

  final String packageName;
  final String label;

  /// Grouping shown as a section header in the picker (e.g. "Bank Besar").
  final String section;
}

/// Common Indonesian bank & e-wallet apps that post transaction
/// notifications, grouped into sections for the picker. Not exhaustive —
/// the picker also offers a custom entry for anything not listed here.
///
/// Package names are verified against each app's live Google Play Store
/// listing, not guessed by naming convention — several entries here (BCA
/// mobile, BNI Mobile Banking, Livin' by Mandiri, Jenius, digibank by DBS,
/// OCTO by CIMB Niaga, DANA, ShopeePay, LinkAja) previously shipped with a
/// wrong, guessed package name that would never have matched a real
/// notification's source app.
const knownBankApps = [
  // Bank besar
  KnownBankApp(packageName: 'com.bca', label: 'BCA mobile', section: 'Bank Besar'),
  KnownBankApp(
    packageName: 'com.bca.mybca.omni.android',
    label: 'myBCA',
    section: 'Bank Besar',
  ),
  KnownBankApp(
    packageName: 'com.bcadigital.blu',
    label: 'blu by BCA Digital',
    section: 'Bank Besar',
  ),
  KnownBankApp(packageName: 'id.co.bri.brimo', label: 'BRImo BRI', section: 'Bank Besar'),
  KnownBankApp(packageName: 'src.com.bni', label: 'BNI Mobile Banking', section: 'Bank Besar'),
  KnownBankApp(packageName: 'id.bni.wondr', label: 'wondr by BNI', section: 'Bank Besar'),
  KnownBankApp(
    packageName: 'id.bmri.livin',
    label: 'Livin\' by Mandiri',
    section: 'Bank Besar',
  ),
  KnownBankApp(packageName: 'com.bsm.activity2', label: 'BSI Mobile', section: 'Bank Besar'),
  KnownBankApp(
    packageName: 'id.co.btn.mobilebanking.android',
    label: 'balé by BTN',
    section: 'Bank Besar',
  ),

  // Bank digital
  KnownBankApp(packageName: 'com.btpn.dc', label: 'Jenius', section: 'Bank Digital'),
  KnownBankApp(
    packageName: 'id.co.bankbkemobile.digitalbank',
    label: 'SeaBank',
    section: 'Bank Digital',
  ),
  KnownBankApp(
    packageName: 'com.jago.digitalBanking',
    label: 'Bank Jago/Jago Syariah',
    section: 'Bank Digital',
  ),
  KnownBankApp(packageName: 'com.alloapp.yump', label: 'Allo Bank', section: 'Bank Digital'),
  KnownBankApp(
    packageName: 'com.bnc.finance',
    label: 'neobank (BNC Digital)',
    section: 'Bank Digital',
  ),
  KnownBankApp(
    packageName: 'com.dbs.id.pt.digitalbank',
    label: 'digibank by DBS Indonesia',
    section: 'Bank Digital',
  ),
  KnownBankApp(
    packageName: 'id.co.bankfama.android',
    label: 'Superbank',
    section: 'Bank Digital',
  ),
  KnownBankApp(
    packageName: 'id.co.bankraya.apps',
    label: 'Bank Raya',
    section: 'Bank Digital',
  ),
  KnownBankApp(
    packageName: 'com.senyumkubank.rekeningonline',
    label: 'Amar Bank (Senyumku)',
    section: 'Bank Digital',
  ),
  KnownBankApp(
    packageName: 'bjj.bank.digital.indo.prod',
    label: 'Bank Saqu',
    section: 'Bank Digital',
  ),

  // Bank lainnya
  KnownBankApp(
    packageName: 'id.co.cimbniaga.mobile.android',
    label: 'OCTO by CIMB Niaga',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'com.dbank.mobile',
    label: 'D-Bank PRO (Danamon)',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'net.myinfosys.PermataMobileX',
    label: 'PermataMobile X',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'com.ocbcnisp.onemobileapp',
    label: 'OCBC mobile Indonesia',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'id.com.uiux.mobile',
    label: 'Maybank2u ID (M2U)',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'com.bankmega.megamobile',
    label: 'Bank Mega Mobile',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'gurilap.bjbmobile',
    label: 'DIGI by bank bjb',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'com.panin.mobilepanin',
    label: 'MobilePanin',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'com.uob.id.digitalbank',
    label: 'UOB TMRW Indonesia',
    section: 'Bank Lainnya',
  ),
  KnownBankApp(
    packageName: 'id.co.commbank.commaccess.mobile.launchers',
    label: 'CommBank ID (Commonwealth)',
    section: 'Bank Lainnya',
  ),

  // E-wallet
  KnownBankApp(packageName: 'com.gojek.gopay', label: 'GoPay', section: 'E-Wallet'),
  KnownBankApp(
    packageName: 'com.gojek.app',
    label: 'Gojek (GoPay & layanan lain)',
    section: 'E-Wallet',
  ),
  KnownBankApp(packageName: 'ovo.id', label: 'OVO', section: 'E-Wallet'),
  KnownBankApp(packageName: 'id.dana', label: 'DANA', section: 'E-Wallet'),
  KnownBankApp(packageName: 'com.shopeepay.id', label: 'ShopeePay', section: 'E-Wallet'),
  KnownBankApp(packageName: 'com.telkom.mwallet', label: 'LinkAja', section: 'E-Wallet'),
  KnownBankApp(packageName: 'com.bca.sakuku', label: 'Sakuku (BCA)', section: 'E-Wallet'),
  KnownBankApp(packageName: 'id.flip', label: 'Flip', section: 'E-Wallet'),
  KnownBankApp(packageName: 'com.isaku.app', label: 'i.saku (Indomaret)', section: 'E-Wallet'),
  KnownBankApp(packageName: 'com.ada.astrapay', label: 'AstraPay', section: 'E-Wallet'),
];
