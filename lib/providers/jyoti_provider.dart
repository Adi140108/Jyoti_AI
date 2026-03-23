import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jyoti_ai/models/models.dart';
import 'package:jyoti_ai/services/jyoti_service.dart';

class JyotiProvider extends ChangeNotifier {
  JyotiProvider() {
    _initPrefs();
  }

  SharedPreferences? _prefs;
  static const String _chatHistoryKey = 'chat_history';
  static const String _loginStreakKey = 'login_streak';
  static const String _lastLoginDateKey = 'last_login_date';
  static const String _pointsKey = 'user_points';
  static const String _lifetimePointsKey = 'user_lifetime_points';
  static const String _dailyClaimedKey = 'daily_claimed';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _languageKey = 'user_language';
  static const String _personaKey = 'user_persona';

  // ── Theme ──
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs?.setBool(_isDarkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs!.getBool(_isDarkModeKey) ?? true;
    _loadChatHistory();
    _loadUserData();
    _checkStreakOnStartup();
  }

  /// Load persisted user data (streak, points) from SharedPreferences
  void _loadUserData() {
    if (_prefs == null) return;
    final savedStreak = _prefs!.getInt(_loginStreakKey) ?? 0;
    final savedPoints = _prefs!.getInt(_pointsKey) ?? 250;
    final savedLifetime = _prefs!.getInt(_lifetimePointsKey) ?? 0;
    final savedLanguage = _prefs!.getString(_languageKey) ?? 'Hindi';
    final savedPersonaId = _prefs!.getString(_personaKey) ?? Persona.modernAstrologer.id;
    
    _user = _user.copyWith(
      loginStreak: savedStreak,
      points: savedPoints,
      lifetimePoints: savedLifetime,
      language: savedLanguage,
    );
    
    _persona = Persona.values.firstWhere((p) => p.id == savedPersonaId, 
      orElse: () => Persona.modernAstrologer);
      
    notifyListeners();
  }

  /// On app startup, check if the streak is still valid.
  /// If the user missed a day (last login was more than 1 day ago), reset streak to 0.
  void _checkStreakOnStartup() {
    if (_prefs == null) return;
    final lastLoginStr = _prefs!.getString(_lastLoginDateKey);
    if (lastLoginStr != null) {
      final lastLogin = DateTime.tryParse(lastLoginStr);
      if (lastLogin != null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final lastDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
        final diff = todayDate.difference(lastDate).inDays;
        if (diff > 1) {
          // Missed a day — reset streak
          _user = _user.copyWith(loginStreak: 0);
          _prefs!.setInt(_loginStreakKey, 0);
          _prefs!.setBool(_dailyClaimedKey, false);
          notifyListeners();
        } else if (diff == 1) {
          // New day — allow claiming
          _prefs!.setBool(_dailyClaimedKey, false);
        }
        // diff == 0 means same day — keep dailyClaimed as is
      }
    }
  }

  /// Whether the daily login bonus has already been claimed today
  bool get hasDailyBeenClaimed => _prefs?.getBool(_dailyClaimedKey) ?? false;

  /// Persist points to SharedPreferences
  Future<void> _savePoints() async {
    if (_prefs == null) return;
    await _prefs!.setInt(_pointsKey, _user.points);
    await _prefs!.setInt(_lifetimePointsKey, _user.lifetimePoints);
  }

  Future<void> _loadChatHistory() async {
    final historyStr = _prefs?.getString(_chatHistoryKey);
    if (historyStr != null) {
      try {
        // Offload heavy JSON decoding and model mapping to a background isolate
        final List<ChatSession> loadedSessions = await Isolate.run(() {
          final List<dynamic> decoded = jsonDecode(historyStr);
          return decoded.map((e) => ChatSession.fromJson(e)).toList();
        });

        _sessions.clear();
        _sessions.addAll(loadedSessions);
        
        if (_sessions.isNotEmpty) {
          _currentSessionId = _sessions.first.id;
        } else {
          _createNewSession();
        }
        notifyListeners();
      } catch (e) {
        _createNewSession();
      }
    } else {
      _createNewSession();
    }
  }

  Future<void> _saveChatHistory() async {
    if (_prefs == null) return;
    final encoded = jsonEncode(_sessions.map((e) => e.toJson()).toList());
    await _prefs!.setString(_chatHistoryKey, encoded);
  }

  void _createNewSession() {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      messages: [],
      createdAt: DateTime.now(),
    );
    _sessions.insert(0, newSession);
    _currentSessionId = newSession.id;
    notifyListeners();
  }

  // ── User ──
  UserProfile _user = UserProfile(
    name: 'User',
    dateOfBirth: DateTime(1998, 5, 15),
    timeOfBirth: '06:30 AM',
    placeOfBirth: 'Delhi',
    rashi: Rashi.mesha,
    nakshatra: 'Ashwini',
    points: 250,
    lifetimePoints: 0,
    loginStreak: 0,
    language: 'Hindi',
  );

  // ── Chat ──
  final List<ChatSession> _sessions = [];
  String? _currentSessionId;
  bool _isChatLoading = false;

  // ── Daily Reading ──
  DailyReading? _dailyReading;
  PanchangData? _panchang;
  bool _isReadingLoading = false;

  // ── AI Persona ──
  Persona _persona = Persona.modernAstrologer;
  Persona get persona => _persona;
  
  void setPersona(Persona p) {
    _persona = p;
    _prefs?.setString(_personaKey, p.id);
    notifyListeners();
  }

  // ── Onboarding ──
  bool _hasCompletedOnboarding = false;

  // ── Getters ──
  UserProfile get user => _user;
  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  String? get currentSessionId => _currentSessionId;
  
  List<ChatMessage> get messages {
    if (_currentSessionId == null) return [];
    final session = _sessions.firstWhere((s) => s.id == _currentSessionId, 
      orElse: () => _sessions.first);
    return session.messages;
  }
  
  ChatSession? get currentSession {
    if (_currentSessionId == null) return null;
    return _sessions.firstWhere((s) => s.id == _currentSessionId, 
      orElse: () => _sessions.first);
  }
  bool get isChatLoading => _isChatLoading;
  DailyReading? get dailyReading => _dailyReading;
  PanchangData? get panchang => _panchang;
  bool get isReadingLoading => _isReadingLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // ── Onboarding ──
  void completeOnboarding({
    required String name,
    required DateTime dob,
    required String timeOfBirth,
    required String placeOfBirth,
    required Rashi rashi,
    required String language,
  }) {
    _user = _user.copyWith(
      name: name,
      dateOfBirth: dob,
      timeOfBirth: timeOfBirth,
      placeOfBirth: placeOfBirth,
      rashi: rashi,
      language: language,
    );
    _prefs?.setString(_languageKey, language);
    _hasCompletedOnboarding = true;
    notifyListeners();
    // Resolve geo location in background, then load data
    _resolveGeoAndLoadData();
  }

  void skipOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
    loadDailyData();
  }

  /// Resolve geo coordinates for user's place of birth, then load daily data
  Future<void> _resolveGeoAndLoadData() async {
    try {
      final geo = await JyotiService.resolveGeoLocation(_user.placeOfBirth);
      if (geo != null) {
        _user = _user.copyWith(
          latitude: geo['latitude'],
          longitude: geo['longitude'],
          timezoneOffset: geo['timezone'],
        );
        notifyListeners();
      }
    } catch (_) {
      // Silently handle — continue without geo data
    }
    loadDailyData();
  }

  // ── Daily Data ──
  Future<void> loadDailyData() async {
    _isReadingLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        JyotiService.getDailyReading(_user.rashi, _user),
        JyotiService.getPanchang(_user),
      ]);
      _dailyReading = results[0] as DailyReading;
      _panchang = results[1] as PanchangData;
    } catch (e) {
      // Silently handle — UI shows fallback
    } finally {
      _isReadingLoading = false;
      notifyListeners();
    }
  }

  // ── Chat ──
  void startNewChat() {
    _createNewSession();
    _saveChatHistory();
  }

  void switchSession(String id) {
    _currentSessionId = id;
    notifyListeners();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_currentSessionId == id) {
      if (_sessions.isNotEmpty) {
        _currentSessionId = _sessions.first.id;
      } else {
        _createNewSession();
      }
    }
    _saveChatHistory();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_currentSessionId == null) _createNewSession();

    final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSessionId);
    if (sessionIndex == -1) return;

    if (_user.points <= 0) {
      _sessions[sessionIndex].messages.add(
        ChatMessage(
          text: 'Aapke paas paryapt points nahi hain. Kripya aur prashn poochne ke liye points recharge karein. 💎',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
      return;
    }

    // Add user message
    final userMsg = ChatMessage(text: text.trim(), isUser: true, timestamp: DateTime.now());
    _sessions[sessionIndex].messages.add(userMsg);
    
    _isChatLoading = true;
    notifyListeners();

    try {
      // Pass the chat history and persona to give the AI memory
      final response = await JyotiService.getAIResponse(text, _user, _sessions[sessionIndex].messages, _persona);
      _sessions[sessionIndex].messages.add(response);

      // Auto-titling: if it's the first user message, generate a title
      if (_sessions[sessionIndex].messages.where((m) => m.isUser).length == 1) {
        _generateTitleForSession(_sessions[sessionIndex]);
      }

      // Deduct points dynamically based on AI context usage (tokens)
      int pointsToDeduct = 15; // Default fallback
      if (response.totalTokens != null && response.totalTokens! > 0) {
        pointsToDeduct = (response.totalTokens! / 15).ceil().clamp(10, 100);
      }

      if (_user.points >= pointsToDeduct) {
        _user = _user.copyWith(points: _user.points - pointsToDeduct);
      } else {
        _user = _user.copyWith(points: 0);
      }

    } catch (e) {
      _sessions[sessionIndex].messages.add(
        ChatMessage(
          text:
              'Maaf kijiye, abhi thoda issue aa raha hai. Kripya thodi der baad try karein. 🙏',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isChatLoading = false;
      _saveChatHistory(); // Save locally
      notifyListeners();
    }
  }

  Future<void> _generateTitleForSession(ChatSession session) async {
    try {
      final title = await JyotiService.generateChatTitle(session.messages);
      final index = _sessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        _sessions[index] = _sessions[index].copyWith(title: title);
        _saveChatHistory();
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── Points ──
  void addPoints(int amount) {
    _user = _user.copyWith(
      points: _user.points + amount,
      lifetimePoints: _user.lifetimePoints + amount,
    );
    _savePoints();
    notifyListeners();
  }

  /// Claim daily login bonus. Can only be claimed once per day.
  /// Streak increments if called on a consecutive day, resets if a day was missed.
  void claimDailyLogin() {
    if (_prefs == null) return;

    // Don't allow double-claiming
    if (hasDailyBeenClaimed) return;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastLoginStr = _prefs!.getString(_lastLoginDateKey);

    int newStreak = 1; // Default for first-time or after reset
    if (lastLoginStr != null) {
      final lastLogin = DateTime.tryParse(lastLoginStr);
      if (lastLogin != null) {
        final lastDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
        final diff = todayDate.difference(lastDate).inDays;
        if (diff == 1) {
          // Consecutive day → increment streak
          newStreak = _user.loginStreak + 1;
        } else if (diff == 0) {
          // Same day (should be caught by hasDailyBeenClaimed, but just in case)
          return;
        }
        // diff > 1 → streak was already reset in _checkStreakOnStartup, newStreak = 1
      }
    }

    _user = _user.copyWith(loginStreak: newStreak);
    addPoints(10);

    // Persist
    _prefs!.setInt(_loginStreakKey, newStreak);
    _prefs!.setString(_lastLoginDateKey, todayDate.toIso8601String());
    _prefs!.setBool(_dailyClaimedKey, true);

    notifyListeners();
  }

  // ── Language ──
  void setLanguage(String lang) {
    _user = _user.copyWith(language: lang);
    _prefs?.setString(_languageKey, lang);
    notifyListeners();
  }

  // ── Rashi ──
  void setRashi(Rashi rashi) {
    _user = _user.copyWith(rashi: rashi);
    notifyListeners();
    loadDailyData();
  }

  // ── Sign Out ──
  Future<void> signOut() async {
    // Clear all persisted data (includes daily claimed flag)
    if (_prefs != null) {
      await _prefs!.clear();
    }

    // Reset user to defaults
    _user = UserProfile(
      name: 'Cosmic Soul',
      dateOfBirth: DateTime(2000, 1, 1),
      timeOfBirth: 'Unknown',
      placeOfBirth: 'India',
      rashi: Rashi.mesha,
      nakshatra: 'Ashwini',
      points: 0,
      lifetimePoints: 0,
      loginStreak: 0,
      language: 'English',
    );

    // Clear sessions
    _sessions.clear();
    _currentSessionId = null;
    _createNewSession();

    // Reset onboarding flag
    _hasCompletedOnboarding = false;

    notifyListeners();
  }
}
