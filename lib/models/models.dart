// All data models for Jyoti AI

// ── Rashi (Zodiac Sign) ──
enum Rashi {
  mesha(
    label: 'Mesha',
    english: 'Aries',
    symbol: '♈',
    emoji: '🐏',
    color: 0xFFEF4444,
  ),
  vrishabha(
    label: 'Vrishabha',
    english: 'Taurus',
    symbol: '♉',
    emoji: '🐂',
    color: 0xFF22C55E,
  ),
  mithuna(
    label: 'Mithuna',
    english: 'Gemini',
    symbol: '♊',
    emoji: '👯',
    color: 0xFFFBBF24,
  ),
  karka(
    label: 'Karka',
    english: 'Cancer',
    symbol: '♋',
    emoji: '🦀',
    color: 0xFFC0C0C0,
  ),
  simha(
    label: 'Simha',
    english: 'Leo',
    symbol: '♌',
    emoji: '🦁',
    color: 0xFFFF8C00,
  ),
  kanya(
    label: 'Kanya',
    english: 'Virgo',
    symbol: '♍',
    emoji: '👧',
    color: 0xFF10B981,
  ),
  tula(
    label: 'Tula',
    english: 'Libra',
    symbol: '♎',
    emoji: '⚖️',
    color: 0xFF60A5FA,
  ),
  vrishchika(
    label: 'Vrishchika',
    english: 'Scorpio',
    symbol: '♏',
    emoji: '🦂',
    color: 0xFFDC2626,
  ),
  dhanu(
    label: 'Dhanu',
    english: 'Sagittarius',
    symbol: '♐',
    emoji: '🏹',
    color: 0xFF8B5CF6,
  ),
  makara(
    label: 'Makara',
    english: 'Capricorn',
    symbol: '♑',
    emoji: '🐐',
    color: 0xFF6B7280,
  ),
  kumbha(
    label: 'Kumbha',
    english: 'Aquarius',
    symbol: '♒',
    emoji: '🫗',
    color: 0xFF06B6D4,
  ),
  meena(
    label: 'Meena',
    english: 'Pisces',
    symbol: '♓',
    emoji: '🐟',
    color: 0xFF818CF8,
  );

  final String label;
  final String english;
  final String symbol;
  final String emoji;
  final int color;

  const Rashi({
    required this.label,
    required this.english,
    required this.symbol,
    required this.emoji,
    required this.color,
  });
}

// ── User Tier ──
enum UserTier {
  moon(label: 'Moon', emoji: '🌙', minPoints: 0, color: 0xFFC0C0C0),
  star(label: 'Star', emoji: '⭐', minPoints: 1000, color: 0xFFFBBF24),
  sun(label: 'Sun', emoji: '☀️', minPoints: 5000, color: 0xFFFF8C00),
  nakshatra(
    label: 'Nakshatra',
    emoji: '✨',
    minPoints: 15000,
    color: 0xFFA78BFA,
  );

  final String label;
  final String emoji;
  final int minPoints;
  final int color;

  const UserTier({
    required this.label,
    required this.emoji,
    required this.minPoints,
    required this.color,
  });

  static UserTier fromPoints(int lifetimePoints) {
    if (lifetimePoints >= 15000) return UserTier.nakshatra;
    if (lifetimePoints >= 5000) return UserTier.sun;
    if (lifetimePoints >= 1000) return UserTier.star;
    return UserTier.moon;
  }
}

// ── AI Persona ──
enum Persona {
  vedicSage(
    id: 'vedic_sage',
    name: 'Vedic Sage',
    description: 'Traditional, deep spiritual wisdom, master of Sanskrit literature (Sahitya), and Vedic scriptures.',
    emoji: '🧔‍♂️',
  ),
  modernAstrologer(
    id: 'modern_astrologer',
    name: 'Modern Astrologer',
    description: 'Practical, logic-based advice for the modern world, occasionally citing timeless literary wisdom.',
    emoji: '👔',
  ),
  remedySpecialist(
    id: 'remedy_specialist',
    name: 'Remedy Specialist',
    description: 'Focused on specific Mantras, Gemstones, and fix-it solutions, drawing from the aesthetic emotional power of Rasas.',
    emoji: '📿',
  );

  final String id;
  final String name;
  final String description;
  final String emoji;

  const Persona({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

// ── Points Pack ──
class PointsPack {
  final String id;
  final String name;
  final int priceRs;
  final int points;
  final String talkTime;
  final bool isBestValue;

  const PointsPack({
    required this.id,
    required this.name,
    required this.priceRs,
    required this.points,
    required this.talkTime,
    this.isBestValue = false,
  });

  static const List<PointsPack> packs = [
    PointsPack(
      id: 'starter',
      name: 'Starter',
      priceRs: 19,
      points: 500,
      talkTime: '~25 min',
    ),
    PointsPack(
      id: 'value',
      name: 'Value',
      priceRs: 49,
      points: 1500,
      talkTime: '~75 min',
    ),
    PointsPack(
      id: 'popular',
      name: 'Popular',
      priceRs: 99,
      points: 3500,
      talkTime: '~175 min',
      isBestValue: true,
    ),
    PointsPack(
      id: 'super',
      name: 'Super',
      priceRs: 199,
      points: 8000,
      talkTime: '~400 min',
    ),
  ];
}

// ── Chat Message ──
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? remedy;
  final int? totalTokens;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.remedy,
    this.totalTokens,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'remedy': remedy,
        'totalTokens': totalTokens,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      remedy: json['remedy'] as String?,
      totalTokens: json['totalTokens'] as int?,
    );
  }
}

// ── Chat Session ──
class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ── Daily Reading ──
class DailyReading {
  final Rashi rashi;
  final String summary;
  final String luckyColor;
  final int luckyNumber;
  final String remedy;
  final String favorableTime;
  final DateTime date;
  final double overallScore; // 0.0 to 5.0

  const DailyReading({
    required this.rashi,
    required this.summary,
    required this.luckyColor,
    required this.luckyNumber,
    required this.remedy,
    required this.favorableTime,
    required this.date,
    required this.overallScore,
  });
}

// ── Panchang Data ──
class PanchangData {
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String rahuKaal;
  final String gulikaKaal;
  final String sunrise;
  final String sunset;
  final DateTime date;

  const PanchangData({
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.rahuKaal,
    required this.gulikaKaal,
    required this.sunrise,
    required this.sunset,
    required this.date,
  });
}

// ── User Profile ──
class UserProfile {
  final String name;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final Rashi rashi;
  final String nakshatra;
  final int points;
  final int lifetimePoints;
  final int loginStreak;
  final String language;
  final double? latitude;
  final double? longitude;
  final double? timezoneOffset;

  const UserProfile({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.rashi,
    required this.nakshatra,
    required this.points,
    required this.lifetimePoints,
    required this.loginStreak,
    required this.language,
    this.latitude,
    this.longitude,
    this.timezoneOffset,
  });

  UserTier get tier => UserTier.fromPoints(lifetimePoints);

  /// Whether geo coordinates have been successfully resolved by the API
  bool get hasExactGeoData =>
      latitude != null && longitude != null && timezoneOffset != null;

  /// Hardcoded fallbacks for major cities to ensure API never breaks
  static const Map<String, Map<String, double>> _cityFallbacks = {
    'bangalore': {'lat': 12.9716, 'lng': 77.5946, 'tz': 5.5},
    'bengaluru': {'lat': 12.9716, 'lng': 77.5946, 'tz': 5.5},
    'delhi': {'lat': 28.6139, 'lng': 77.2090, 'tz': 5.5},
    'new delhi': {'lat': 28.6139, 'lng': 77.2090, 'tz': 5.5},
    'mumbai': {'lat': 19.0760, 'lng': 72.8777, 'tz': 5.5},
    'chennai': {'lat': 13.0827, 'lng': 80.2707, 'tz': 5.5},
    'kolkata': {'lat': 22.5726, 'lng': 88.3639, 'tz': 5.5},
    'hyderabad': {'lat': 17.3850, 'lng': 78.4867, 'tz': 5.5},
    'pune': {'lat': 18.5204, 'lng': 73.8567, 'tz': 5.5},
    'ahmedabad': {'lat': 23.0225, 'lng': 72.5714, 'tz': 5.5},
    'jaipur': {'lat': 26.9124, 'lng': 75.7873, 'tz': 5.5},
    'surat': {'lat': 21.1702, 'lng': 72.8311, 'tz': 5.5},
    'lucknow': {'lat': 26.8467, 'lng': 80.9462, 'tz': 5.5},
    'kanpur': {'lat': 26.4499, 'lng': 80.3319, 'tz': 5.5},
    'nagpur': {'lat': 21.1458, 'lng': 79.0882, 'tz': 5.5},
    'indore': {'lat': 22.7196, 'lng': 75.8577, 'tz': 5.5},
    'bhopal': {'lat': 23.2599, 'lng': 77.4126, 'tz': 5.5},
  };

  /// Safe getters that fall back to a hardcoded city or default to Delhi
  double get safeLatitude {
    if (latitude != null) return latitude!;
    final city = placeOfBirth.toLowerCase().trim();
    return _cityFallbacks[city]?['lat'] ?? 28.6139; // Default Delhi
  }

  double get safeLongitude {
    if (longitude != null) return longitude!;
    final city = placeOfBirth.toLowerCase().trim();
    return _cityFallbacks[city]?['lng'] ?? 77.2090; // Default Delhi
  }

  double get safeTimezoneOffset {
    if (timezoneOffset != null) return timezoneOffset!;
    final city = placeOfBirth.toLowerCase().trim();
    return _cityFallbacks[city]?['tz'] ?? 5.5; // Default IST
  }

  /// Parse timeOfBirth string (e.g. "06:30 AM") into hour/minute
  int get birthHour {
    try {
      final parts = timeOfBirth.replaceAll(RegExp(r'[APap][Mm]'), '').trim().split(':');
      int h = int.parse(parts[0]);
      if (timeOfBirth.toUpperCase().contains('PM') && h != 12) h += 12;
      if (timeOfBirth.toUpperCase().contains('AM') && h == 12) h = 0;
      return h;
    } catch (_) {
      return 6; // default
    }
  }

  int get birthMinute {
    try {
      final parts = timeOfBirth.replaceAll(RegExp(r'[APap][Mm]'), '').trim().split(':');
      return int.parse(parts[1]);
    } catch (_) {
      return 0;
    }
  }

  UserProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    Rashi? rashi,
    String? nakshatra,
    int? points,
    int? lifetimePoints,
    int? loginStreak,
    String? language,
    double? latitude,
    double? longitude,
    double? timezoneOffset,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      rashi: rashi ?? this.rashi,
      nakshatra: nakshatra ?? this.nakshatra,
      points: points ?? this.points,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      loginStreak: loginStreak ?? this.loginStreak,
      language: language ?? this.language,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
    );
  }
}
