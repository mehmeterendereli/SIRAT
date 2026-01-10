/// =============================================================================

/// =============================================================================
/// HIJRI CALENDAR - Hicri Takvim Sistemi
/// =============================================================================
/// 
/// Kuwaiti algorithm kullanarak Miladi → Hicri dönüşüm yapar.
/// Özel günleri (Kandil, Bayram, Ramazan) tespit eder.

class HijriDate {
  final int year;
  final int month;  // 1-12
  final int day;    // 1-30
  
  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });
  
  /// Ay isimleri (Türkçe)
  static const List<String> monthNamesTR = [
    'Muharrem',     // 1
    'Safer',        // 2
    'Rebiülevvel',  // 3
    'Rebiülahir',   // 4
    'Cemaziyelevvel', // 5
    'Cemaziyelahir',  // 6
    'Recep',        // 7
    'Şaban',        // 8
    'Ramazan',      // 9
    'Şevval',       // 10
    'Zilkade',      // 11
    'Zilhicce',     // 12
  ];
  
  /// Ay isimleri (Arapça)
  static const List<String> monthNamesAR = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];
  
  /// Ay isimleri (İngilizce)
  static const List<String> monthNamesEN = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Dhul Qadah',
    'Dhul Hijjah',
  ];
  
  String get monthName => monthNamesTR[month - 1];
  String get monthNameAr => monthNamesAR[month - 1];
  String get monthNameEn => monthNamesEN[month - 1];
  
  /// Formatted string: "12 Recep 1447"
  String format({String locale = 'tr'}) {
    final monthStr = locale == 'ar' 
        ? monthNameAr 
        : locale == 'en' 
            ? monthNameEn 
            : monthName;
    return '$day $monthStr $year';
  }
  
  @override
  String toString() => format();
  
  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;
  
  @override
  int get hashCode => Object.hash(year, month, day);
}

/// =============================================================================
/// HIJRI CALENDAR CONVERTER
/// =============================================================================

class HijriCalendar {
  /// Miladi tarihten Hicri tarihe dönüştür (Kuwaiti Algorithm)
  static HijriDate fromGregorian(DateTime date) {
    final jd = _gregorianToJulian(date.year, date.month, date.day);
    return _julianToHijri(jd);
  }
  
  /// Hicri tarihten Miladi tarihe dönüştür
  static DateTime toGregorian(HijriDate hijri) {
    final jd = _hijriToJulian(hijri.year, hijri.month, hijri.day);
    return _julianToGregorian(jd);
  }
  
  /// Bugünün Hicri tarihi
  static HijriDate get today => fromGregorian(DateTime.now());
  
  // --------------------------------------------------------------------------
  // KUWAITI ALGORITHM - Julian Day Number Conversions
  // --------------------------------------------------------------------------
  
  static int _gregorianToJulian(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    
    return (365.25 * (year + 4716)).floor() +
           (30.6001 * (month + 1)).floor() +
           day + b - 1524;
  }
  
  static HijriDate _julianToHijri(int jd) {
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) / 5316).floor() * 
              ((50 * l2) / 17719).floor() +
              (l2 / 5670).floor() * 
              ((43 * l2) / 15238).floor();
    final l3 = l2 - ((30 - j) / 15).floor() * 
               ((17719 * j) / 50).floor() -
               (j / 16).floor() * 
               ((15238 * j) / 43).floor() + 29;
    final month = ((24 * l3) / 709).floor();
    final day = l3 - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;
    
    return HijriDate(
      year: year,
      month: month,
      day: day,
    );
  }
  
  static int _hijriToJulian(int year, int month, int day) {
    return ((11 * year + 3) / 30).floor() +
           354 * year +
           30 * month -
           ((month - 1) / 2).floor() +
           day + 1948440 - 385;
  }
  
  static DateTime _julianToGregorian(int jd) {
    final l = jd + 68569;
    final n = ((4 * l) / 146097).floor();
    final l2 = l - ((146097 * n + 3) / 4).floor();
    final i = ((4000 * (l2 + 1)) / 1461001).floor();
    final l3 = l2 - ((1461 * i) / 4).floor() + 31;
    final j = ((80 * l3) / 2447).floor();
    final day = l3 - ((2447 * j) / 80).floor();
    final l4 = (j / 11).floor();
    final month = j + 2 - 12 * l4;
    final year = 100 * (n - 49) + i + l4;
    
    return DateTime(year, month, day);
  }
}

/// =============================================================================
/// ISLAMIC SPECIAL DAYS - Özel Günler
/// =============================================================================

enum IslamicSpecialDay {
  none,
  mevlidKandili,    // Rebiülevvel 12
  regaipKandili,    // Recep ilk cuma gecesi
  miracKandili,     // Recep 27
  beratKandili,     // Şaban 15
  kadirGecesi,      // Ramazan 27
  ramazanBayrami,   // Şevval 1-3
  kurbanBayrami,    // Zilhicce 10-13
  asure,            // Muharrem 10
  ramazanStart,     // Ramazan 1
  arefe,            // Bayram öncesi
}

class IslamicSpecialDays {
  /// Bugün özel bir gün mü?
  static IslamicSpecialDay checkSpecialDay(HijriDate date) {
    final m = date.month;
    final d = date.day;
    
    // Muharrem
    if (m == 1 && d == 10) return IslamicSpecialDay.asure;
    
    // Rebiülevvel
    if (m == 3 && d == 12) return IslamicSpecialDay.mevlidKandili;
    
    // Recep
    if (m == 7 && d == 27) return IslamicSpecialDay.miracKandili;
    // Regaip kandili - Recep ayının ilk cuma gecesi (yaklaşık 1-7 arası)
    if (m == 7 && d >= 1 && d <= 7) {
      // Cuma gecesi kontrolü için Gregorian'a çevir
      final greg = HijriCalendar.toGregorian(date);
      if (greg.weekday == DateTime.thursday) {
        return IslamicSpecialDay.regaipKandili;
      }
    }
    
    // Şaban
    if (m == 8 && d == 15) return IslamicSpecialDay.beratKandili;
    
    // Ramazan
    if (m == 9 && d == 1) return IslamicSpecialDay.ramazanStart;
    if (m == 9 && d == 27) return IslamicSpecialDay.kadirGecesi;
    
    // Şevval - Ramazan Bayramı
    if (m == 10 && d >= 1 && d <= 3) return IslamicSpecialDay.ramazanBayrami;
    
    // Zilhicce - Kurban Bayramı
    if (m == 12 && d == 9) return IslamicSpecialDay.arefe;
    if (m == 12 && d >= 10 && d <= 13) return IslamicSpecialDay.kurbanBayrami;
    
    return IslamicSpecialDay.none;
  }
  
  /// Özel gün ismi
  static String getSpecialDayName(IslamicSpecialDay day, {String locale = 'tr'}) {
    switch (day) {
      case IslamicSpecialDay.mevlidKandili:
        return locale == 'tr' ? 'Mevlid Kandili' : 'Mawlid an-Nabi';
      case IslamicSpecialDay.regaipKandili:
        return locale == 'tr' ? 'Regaip Kandili' : 'Raghaib Night';
      case IslamicSpecialDay.miracKandili:
        return locale == 'tr' ? 'Miraç Kandili' : 'Isra and Miraj';
      case IslamicSpecialDay.beratKandili:
        return locale == 'tr' ? 'Berat Kandili' : 'Mid-Shaban Night';
      case IslamicSpecialDay.kadirGecesi:
        return locale == 'tr' ? 'Kadir Gecesi' : 'Laylat al-Qadr';
      case IslamicSpecialDay.ramazanBayrami:
        return locale == 'tr' ? 'Ramazan Bayramı' : 'Eid al-Fitr';
      case IslamicSpecialDay.kurbanBayrami:
        return locale == 'tr' ? 'Kurban Bayramı' : 'Eid al-Adha';
      case IslamicSpecialDay.asure:
        return locale == 'tr' ? 'Aşure Günü' : 'Day of Ashura';
      case IslamicSpecialDay.ramazanStart:
        return locale == 'tr' ? 'Ramazan Başlangıcı' : 'Ramadan Begins';
      case IslamicSpecialDay.arefe:
        return locale == 'tr' ? 'Arefe Günü' : 'Day of Arafah';
      case IslamicSpecialDay.none:
        return '';
    }
  }
  
  /// Özel gün için tema rengi
  static SpecialDayTheme getTheme(IslamicSpecialDay day) {
    switch (day) {
      case IslamicSpecialDay.mevlidKandili:
      case IslamicSpecialDay.regaipKandili:
      case IslamicSpecialDay.miracKandili:
      case IslamicSpecialDay.beratKandili:
      case IslamicSpecialDay.kadirGecesi:
        return SpecialDayTheme.kandil;
      case IslamicSpecialDay.ramazanBayrami:
      case IslamicSpecialDay.kurbanBayrami:
        return SpecialDayTheme.bayram;
      case IslamicSpecialDay.ramazanStart:
        return SpecialDayTheme.ramazan;
      case IslamicSpecialDay.asure:
      case IslamicSpecialDay.arefe:
        return SpecialDayTheme.special;
      case IslamicSpecialDay.none:
        return SpecialDayTheme.none;
    }
  }
}

enum SpecialDayTheme {
  none,
  kandil,   // Altın/Gold tema
  bayram,   // Yeşil/Green tema
  ramazan,  // Mor/Purple tema
  special,  // Mavi/Blue tema
}
