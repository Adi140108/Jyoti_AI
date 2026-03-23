import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jyoti_ai/models/models.dart';
import 'package:jyoti_ai/services/astrology_api_service.dart';

/// Jyoti AI service using Gemini 2.5 Flash with Function Calling.
///
/// When the user asks an astrology question, Gemini can autonomously
/// invoke the Free Astrology API tools to fetch real planetary data,
/// panchang, dashas, compatibility scores, etc. — then interpret the
/// results in natural language.
class JyotiService {
  // ════════════════════════════════════════════════
  //  FUNCTION DECLARATIONS (Tools for Gemini)
  // ════════════════════════════════════════════════

  static final _birthParamsSchema = {
    'year': Schema(SchemaType.integer, description: 'Birth year, e.g. 1998'),
    'month': Schema(SchemaType.integer, description: 'Birth month 1-12'),
    'date': Schema(SchemaType.integer, description: 'Birth date 1-31'),
    'hours':
        Schema(SchemaType.integer, description: 'Birth hour in 24h format 0-23'),
    'minutes': Schema(SchemaType.integer, description: 'Birth minutes 0-59'),
    'seconds': Schema(SchemaType.integer, description: 'Birth seconds 0-59'),
    'latitude': Schema(SchemaType.number,
        description: 'Latitude of birth place, e.g. 28.6139 for Delhi'),
    'longitude': Schema(SchemaType.number,
        description: 'Longitude of birth place, e.g. 77.209 for Delhi'),
    'timezone': Schema(SchemaType.number,
        description: 'Timezone offset in hours, e.g. 5.5 for IST'),
  };

  static List<Tool> get _astrologyTools => [
        Tool(functionDeclarations: [
          // 1. Birth Chart (Planets in Rasi)
          FunctionDeclaration(
            'get_birth_chart',
            'Get the Vedic birth chart showing all planet positions in the Rasi chart (signs). '
                'Returns positions of Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu, '
                'and the Ascendant with their degrees and signs. '
                'Use this when the user asks about their birth chart, kundli, horoscope, '
                'planet positions, which sign a planet is in, or general natal chart analysis.',
            Schema(SchemaType.object,
                properties: _birthParamsSchema,
                requiredProperties: [
                  'year',
                  'month',
                  'date',
                  'hours',
                  'minutes',
                  'seconds',
                  'latitude',
                  'longitude',
                  'timezone'
                ]),
          ),

          // 2. Divisional Chart
          FunctionDeclaration(
            'get_divisional_chart',
            'Get planet positions in a specific Vedic divisional chart. '
                'Supported chart types: navamsa-chart-info (D9 for marriage/dharma), '
                'd2-chart-info (Hora for wealth), d3-chart-info (Drekkana for siblings), '
                'd4-chart-info (Chaturthamsa for property), d7-chart-info (Saptamsa for children), '
                'd10-chart-info (Dasamsa for career/profession), d12-chart-info (Dwadasamsa for parents), '
                'd24-chart-info (Siddhamsa for education). '
                'Use this when the user asks about Navamsa, career chart (D10), marriage analysis, etc.',
            Schema(SchemaType.object, properties: {
              ..._birthParamsSchema,
              'chart_type': Schema(SchemaType.string,
                  description:
                      'The divisional chart type endpoint, e.g. "navamsa-chart-info", "d10-chart-info"'),
            }, requiredProperties: [
              'year',
              'month',
              'date',
              'hours',
              'minutes',
              'seconds',
              'latitude',
              'longitude',
              'timezone',
              'chart_type'
            ]),
          ),

          // 3. Panchang
          FunctionDeclaration(
            'get_panchang',
            'Get the daily Panchang (Hindu almanac) data for a date and location. '
                'Returns: Tithi (lunar day), Nakshatra (birth star), Yoga, Karana, '
                'Vedic weekday, sunrise, and sunset times. '
                'Use this when the user asks about today\'s panchang, tithi, nakshatra, '
                'auspicious timings, or daily Vedic calendar data.',
            Schema(SchemaType.object,
                properties: _birthParamsSchema,
                requiredProperties: [
                  'year',
                  'month',
                  'date',
                  'hours',
                  'minutes',
                  'seconds',
                  'latitude',
                  'longitude',
                  'timezone'
                ]),
          ),

          // 4. Muhurat / Good-Bad Times
          FunctionDeclaration(
            'get_muhurat_times',
            'Get auspicious and inauspicious timings for a date: Rahu Kalam, '
                'Yama Gandam, Gulika Kalam, Abhijit Muhurat, Hora timings, '
                'and general good/bad time periods throughout the day. '
                'Use this when the user asks about rahu kaal, shubh muhurat, '
                'good times to start work, inauspicious periods, or timing advice.',
            Schema(SchemaType.object,
                properties: _birthParamsSchema,
                requiredProperties: [
                  'year',
                  'month',
                  'date',
                  'hours',
                  'minutes',
                  'seconds',
                  'latitude',
                  'longitude',
                  'timezone'
                ]),
          ),

          // 5. Vimsottari Dasa
          FunctionDeclaration(
            'get_dasha',
            'Get the Vimsottari Maha Dasa periods for a birth chart. '
                'Returns all dasa periods with their start and end dates. '
                'Also returns the current running Maha Dasa, Antar Dasa, and Pratyantar Dasa. '
                'Use this when the user asks about their current dasha, '
                'planetary period, mahadasha, antardasha, or time-based predictions.',
            Schema(SchemaType.object,
                properties: _birthParamsSchema,
                requiredProperties: [
                  'year',
                  'month',
                  'date',
                  'hours',
                  'minutes',
                  'seconds',
                  'latitude',
                  'longitude',
                  'timezone'
                ]),
          ),

          // 6. Match Making
          FunctionDeclaration(
            'get_match_making',
            'Get Ashtakoot Kundli matching score between two people. '
                'Requires birth details of both male and female. Returns compatibility scores '
                'across 8 koots (Varna, Vashya, Tara, Yoni, Graha Maitri, Gana, Bhakoota, Nadi). '
                'Max score is 36. Above 18 is generally considered compatible. '
                'Use this when the user asks about marriage compatibility, kundli matching, or partner matching.',
            Schema(SchemaType.object, properties: {
              'male_year': Schema(SchemaType.integer),
              'male_month': Schema(SchemaType.integer),
              'male_date': Schema(SchemaType.integer),
              'male_hours': Schema(SchemaType.integer),
              'male_minutes': Schema(SchemaType.integer),
              'male_seconds': Schema(SchemaType.integer),
              'male_latitude': Schema(SchemaType.number),
              'male_longitude': Schema(SchemaType.number),
              'male_timezone': Schema(SchemaType.number),
              'female_year': Schema(SchemaType.integer),
              'female_month': Schema(SchemaType.integer),
              'female_date': Schema(SchemaType.integer),
              'female_hours': Schema(SchemaType.integer),
              'female_minutes': Schema(SchemaType.integer),
              'female_seconds': Schema(SchemaType.integer),
              'female_latitude': Schema(SchemaType.number),
              'female_longitude': Schema(SchemaType.number),
              'female_timezone': Schema(SchemaType.number),
            }, requiredProperties: [
              'male_year',
              'male_month',
              'male_date',
              'male_hours',
              'male_minutes',
              'male_seconds',
              'male_latitude',
              'male_longitude',
              'male_timezone',
              'female_year',
              'female_month',
              'female_date',
              'female_hours',
              'female_minutes',
              'female_seconds',
              'female_latitude',
              'female_longitude',
              'female_timezone',
            ]),
          ),

          // 7. Shad Bala (Planetary Strength)
          FunctionDeclaration(
            'get_planetary_strength',
            'Get Shad Bala (six-fold planetary strength) summary. '
                'Shows how strong or weak each planet is in the birth chart. '
                'A strong planet gives better results in its dasa and areas. '
                'Use this when the user asks about planetary strength, which planet is strong/weak, '
                'or Shad Bala analysis.',
            Schema(SchemaType.object,
                properties: _birthParamsSchema,
                requiredProperties: [
                  'year',
                  'month',
                  'date',
                  'hours',
                  'minutes',
                  'seconds',
                  'latitude',
                  'longitude',
                  'timezone'
                ]),
          ),

          // 8. Geo Location lookup
          FunctionDeclaration(
            'get_geo_location',
            'Look up the geographic coordinates (latitude, longitude) and timezone '
                'for a place name. Use this when you need to convert a city/place name '
                'into coordinates required by other astrology functions.',
            Schema(SchemaType.object, properties: {
              'place_name': Schema(SchemaType.string,
                  description: 'City or place name, e.g. "Delhi", "Mumbai", "New York"'),
            }, requiredProperties: [
              'place_name'
            ]),
          ),
        ]),
      ];

  // ════════════════════════════════════════════════
  //  FUNCTION CALL HANDLER
  // ════════════════════════════════════════════════

  /// Execute a function call from Gemini and return the result
  static Future<Map<String, dynamic>> _executeFunctionCall(
    FunctionCall call,
  ) async {
    final args = call.args;

    switch (call.name) {
      case 'get_birth_chart':
        return AstrologyApiService.getPlanets(
          year: args['year'] as int,
          month: args['month'] as int,
          date: args['date'] as int,
          hours: args['hours'] as int,
          minutes: args['minutes'] as int,
          seconds: args['seconds'] as int,
          latitude: (args['latitude'] as num? ?? 28.6139).toDouble(),
          longitude: (args['longitude'] as num? ?? 77.2090).toDouble(),
          timezone: (args['timezone'] as num? ?? 5.5).toDouble(),
        );

      case 'get_divisional_chart':
        return AstrologyApiService.getDivisionalChart(
          chartType: args['chart_type'] as String,
          year: args['year'] as int,
          month: args['month'] as int,
          date: args['date'] as int,
          hours: args['hours'] as int,
          minutes: args['minutes'] as int,
          seconds: args['seconds'] as int,
          latitude: (args['latitude'] as num? ?? 28.6139).toDouble(),
          longitude: (args['longitude'] as num? ?? 77.2090).toDouble(),
          timezone: (args['timezone'] as num? ?? 5.5).toDouble(),
        );

      case 'get_panchang':
        return AstrologyApiService.getFullPanchang(
          year: args['year'] as int,
          month: args['month'] as int,
          date: args['date'] as int,
          hours: args['hours'] as int,
          minutes: args['minutes'] as int,
          seconds: args['seconds'] as int,
          latitude: (args['latitude'] as num? ?? 28.6139).toDouble(),
          longitude: (args['longitude'] as num? ?? 77.2090).toDouble(),
          timezone: (args['timezone'] as num? ?? 5.5).toDouble(),
        );

      case 'get_muhurat_times':
        return AstrologyApiService.getMuhuratTimes(
          year: args['year'] as int,
          month: args['month'] as int,
          date: args['date'] as int,
          hours: args['hours'] as int,
          minutes: args['minutes'] as int,
          seconds: args['seconds'] as int,
          latitude: (args['latitude'] as num? ?? 28.6139).toDouble(),
          longitude: (args['longitude'] as num? ?? 77.2090).toDouble(),
          timezone: (args['timezone'] as num? ?? 5.5).toDouble(),
        );

      case 'get_dasha':
        return AstrologyApiService.getMahaDasasAndAntarDasas(
          year: args['year'] as int,
          month: args['month'] as int,
          date: args['date'] as int,
          hours: args['hours'] as int,
          minutes: args['minutes'] as int,
          seconds: args['seconds'] as int,
          latitude: (args['latitude'] as num? ?? 28.6139).toDouble(),
          longitude: (args['longitude'] as num? ?? 77.2090).toDouble(),
          timezone: (args['timezone'] as num? ?? 5.5).toDouble(),
        );

      case 'get_match_making':
        return AstrologyApiService.getAshtakootScore(
          maleYear: args['male_year'] as int,
          maleMonth: args['male_month'] as int,
          maleDate: args['male_date'] as int,
          maleHours: args['male_hours'] as int,
          maleMinutes: args['male_minutes'] as int,
          maleSeconds: args['male_seconds'] as int,
          maleLatitude: (args['male_latitude'] as num? ?? 28.6139).toDouble(),
          maleLongitude: (args['male_longitude'] as num? ?? 77.2090).toDouble(),
          maleTimezone: (args['male_timezone'] as num? ?? 5.5).toDouble(),
          femaleYear: args['female_year'] as int,
          femaleMonth: args['female_month'] as int,
          femaleDate: args['female_date'] as int,
          femaleHours: args['female_hours'] as int,
          femaleMinutes: args['female_minutes'] as int,
          femaleSeconds: args['female_seconds'] as int,
          femaleLatitude: (args['female_latitude'] as num? ?? 28.6139).toDouble(),
          femaleLongitude: (args['female_longitude'] as num? ?? 77.2090).toDouble(),
          femaleTimezone: (args['female_timezone'] as num? ?? 5.5).toDouble(),
        );

      case 'get_planetary_strength':
        return AstrologyApiService.getShadBalaSummary(
          year: args['year'] as int,
          month: args['month'] as int,
          date: args['date'] as int,
          hours: args['hours'] as int,
          minutes: args['minutes'] as int,
          seconds: args['seconds'] as int,
          latitude: (args['latitude'] as num? ?? 28.6139).toDouble(),
          longitude: (args['longitude'] as num? ?? 77.2090).toDouble(),
          timezone: (args['timezone'] as num? ?? 5.5).toDouble(),
        );

      case 'get_geo_location':
        return AstrologyApiService.getGeoLocation(args['place_name'] as String);

      default:
        return {'error': true, 'message': 'Unknown function: ${call.name}'};
    }
  }

  static const String _sahityaKnowledge = '''
SAHITYA (Sanskrit Literature) CONTEXT:
- Genres: Mahakavya (Epic - e.g., Raghuvamsham), Khandakavya (Minor - e.g., Meghadutam), Nataka (Drama - e.g., Shakuntalam), Gadya (Prose).
- Key Authors: Kalidasa (Nature imagery, Upama mastery), Bhasa, Magha, Bharavi.
- Rasa Theory (9 Aesthetics): 
  - Shringar (Love/Erotic), Hasya (Comic), Karuna (Sorrow/Compassion), 
  - Raudra (Anger), Veera (Heroic/Energy), Bhayanaka (Fear), 
  - Bibhatsa (Disgust), Adbhuta (Wonder), Shanta (Peace/Tranquility).
- Philosophy: "Word and meaning united is poetry" (Bhamaha), "Poetry is language ensouled with rasa" (Vishvanatha).
''';

  /// Call Gemini 2.5 Flash with astrology function calling tools.
  /// When Gemini requests a function call, we execute it and loop
  /// until Gemini returns a final text response.
  static Future<ChatMessage> getAIResponse(
    String userMessage,
    UserProfile user,
    List<ChatMessage> history,
    Persona persona,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return ChatMessage(
        text:
            'System: API key not found in .env file. Please ask the developer to configure the GEMINI_API_KEY.',
        isUser: false,
        timestamp: DateTime.now(),
        totalTokens: 0,
      );
    }

    final hasAstrologyApi = AstrologyApiService.isConfigured;

    // Build location context string
    final locationInfo = 'Lat=${user.safeLatitude}, Long=${user.safeLongitude}, Timezone=${user.safeTimezoneOffset} (Place: ${user.placeOfBirth})';

    final systemPrompt = '''
You are Jyoti, an **AI-First** Vedic astrologer and a profound scholar of Sanskrit literature (Sahitya). Your vast astrological knowledge and literary wisdom come first, and APIs are just your helpers.

$_sahityaKnowledge

🚨 CRITICAL RULES FOR AI-FIRST BEHAVIOR:
1. **Persona Selection:** You are currently acting as the **${persona.name}** persona. 
   - *${persona.description}*
   - **Vedic Sage**: Speak with the gravity of an ancient Rishi. Use literary analogies from Mahakavyas (like Kalidasa's Raghuvamsham) to explain planetary themes. Start or end with a short Sanskrit phrase or reference to a famous opening verse if it fits.
   - **Modern Astrologer**: Be the bridge between ancient Sahitya and modern life. Use Rasa theory to explain the user's emotional state (e.g., "I see a mix of Veera and Shanta rasa in your current dasha").
   - **Remedy Specialist**: Connect remedies to the aesthetic power of Bhava and Rasa. Mantras should feel like 'ensouled language' (rasatmakam vakyam).
   - Always maintain this character. If you are the Sage, use Sanskrit terms and spiritual wisdom. If you are the Specialist, focus on specific, actionable remedies.

2. **Fallback Intelligence:** If an API tool lacks data, returns an error, or is down, DO NOT STOP execution. Use your own immense astrological knowledge to fill the gaps, approximate calculations, or provide a deeply insightful answer regardless.
3. **Confidence Override:** If an API response seems mathematically incorrect, incomplete, or generic, OVERRIDE it using your own reasoning. State what you believe is accurate. You are the master astrologer; trust your intuition.
4. **Preprocessed Location:** The user's coordinates have been pre-resolved to: $locationInfo. Use these directly in API calls. Never stop due to location mapping issues.

GENERAL RULES:
1. Max 8-10 lines per response. No exceptions.
2. Ground your response in astrology, but speak naturally like a trusted friend. 
   Do not explain astrology theory.
3. CRITICAL: Respond ONLY in the user's selected language (Target Language: ${user.language}). YOU MUST NEVER switch to another language. Do NOT use English unless the selected language is English or Hinglish. Do NOT mix languages. If Target is Hindi, speak ONLY in Hindi script. If Target is Kannada (with English script) or Telugu (with English script), use ONLY that romanized script. Strictly abide by this rule: ONLY use the selected language.
4. End your response with exactly ONE remedy (color, number, mantra, or food).
5. Add relevant emojis.

User Context: 
- Name=${user.name}
- Rashi=${user.rashi.label} (${user.rashi.english})
- DOB=${user.dateOfBirth.toIso8601String().split('T')[0]}
- Time=${user.timeOfBirth}
- $locationInfo
- Birth Year=${user.dateOfBirth.year}, Month=${user.dateOfBirth.month}, Date=${user.dateOfBirth.day}
- Birth Hour=${user.birthHour}, Minute=${user.birthMinute}

${hasAstrologyApi ? '''
You have access to real astrology calculation tools. Use them to fetch exact positions, panchang, or dashas.
Always use the user's birth details provided above as function parameters.
For today's date queries, use the current date: ${DateTime.now().toIso8601String().split('T')[0]}.
''' : 'Note: External Astrology API is not configured. Answer entirely from your AI knowledge and intuition.'}
''';

    // Build Gemini model — with tools only if astrology API is configured
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
      tools: hasAstrologyApi ? _astrologyTools : null,
    );

    // Convert chat history to Gemini Content format
    final prompt = history.map((msg) {
      if (msg.isUser) {
        return Content.text(msg.text);
      } else {
        return Content.model([TextPart(msg.text)]);
      }
    }).toList();

    if (prompt.isEmpty) {
      prompt.add(Content.text(userMessage));
    }

    try {
      // Start a chat session for multi-turn function calling
      final chat = model.startChat(history: prompt.length > 1 ? prompt.sublist(0, prompt.length - 1) : []);
      
      var response = await chat.sendMessage(prompt.last);

      // Function calling loop — execute until we get a text response
      int maxIterations = 5; // Safety limit
      while (maxIterations > 0) {
        final functionCalls = response.functionCalls.toList();
        if (functionCalls.isEmpty) break; // Got final text response

        // Execute all function calls
        final functionResponses = <Content>[];
        for (final call in functionCalls) {
          final result = await _executeFunctionCall(call);
          functionResponses.add(
            Content.functionResponse(call.name, result),
          );
        }

        // Send function results back to Gemini
        // Send each function response individually via the chat
        for (final fr in functionResponses) {
          response = await chat.sendMessage(fr);
        }

        maxIterations--;
      }

      final text = response.text ?? 'I sense some cosmic interference... ✨';
      final usage = response.usageMetadata;
      final totalTokens = usage?.totalTokenCount ?? 50;

      return ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        totalTokens: totalTokens,
      );
    } catch (e) {
      return ChatMessage(
        text: 'Maaf kijiye, abhi thoda issue aa raha hai: $e',
        isUser: false,
        timestamp: DateTime.now(),
        totalTokens: 0,
      );
    }
  }

  // ── AUTO TITLING ──

  /// Generate a short 3-4 word title for a chat session based on messages
  static Future<String> generateChatTitle(List<ChatMessage> messages) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return 'New Chat';

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final historyText = messages
          .take(4)
          .map((m) => '${m.isUser ? "User" : "AI"}: ${m.text}')
          .join('\n');

      final prompt = '''
Based on this astrology chat snippet, generate a VERY SHORT (max 3 words) title.
Examples: "Career Growth", "Marriage Matching", "Rahu Dasha Advice".
Return ONLY the title text, no quotes or punctuation.

Chat:
$historyText
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final title = response.text?.trim() ?? 'Astrology Chat';
      return title.replaceAll('"', '').split('\n').first;
    } catch (_) {
      return 'New Chat';
    }
  }

  // ════════════════════════════════════════════════
  //  DAILY READING (AI-generated with real data)
  // ════════════════════════════════════════════════

  /// Get today's daily reading — uses real API data if available
  static Future<DailyReading> getDailyReading(
    Rashi rashi,
    UserProfile user,
  ) async {
    // If astrology API is configured and user has geo data, get real panchang
    if (AstrologyApiService.isConfigured && user.hasExactGeoData) {
      try {
        final now = DateTime.now();
        final planets = await AstrologyApiService.getPlanets(
          year: user.dateOfBirth.year,
          month: user.dateOfBirth.month,
          date: user.dateOfBirth.day,
          hours: user.birthHour,
          minutes: user.birthMinute,
          seconds: 0,
          latitude: user.safeLatitude,
          longitude: user.safeLongitude,
          timezone: user.safeTimezoneOffset,
        );

        // Use Gemini to generate a personalized reading from real data
        final apiKey = dotenv.env['GEMINI_API_KEY'];
        if (apiKey != null && apiKey.isNotEmpty) {
          final model = GenerativeModel(
            model: 'gemini-2.5-flash',
            apiKey: apiKey,
          );
          final prompt = '''
Generate a daily horoscope reading for ${rashi.label} (${rashi.english}) for ${now.toIso8601String().split('T')[0]}.
The person's birth chart data: ${jsonEncode(planets['output'])}

CRITICAL: The entire response MUST be generated ONLY in the following language: ${user.language}. Do NOT use any other language!

Return ONLY a valid JSON object (no markdown, no code blocks) with these exact keys:
{
  "summary": "4-5 lines daily prediction in ${user.language}",
  "luckyColor": "one color name in ${user.language}",
  "luckyNumber": a single digit number,
  "remedy": "one short remedy with emoji in ${user.language}",
  "favorableTime": "time range like 10:00 AM – 1:00 PM",
  "overallScore": a number from 1.0 to 5.0
}
''';

          final response = await model.generateContent([Content.text(prompt)]);
          final text = response.text ?? '';
          
          // Parse JSON from response
          try {
            // Clean up response - remove code blocks if present
            var cleanText = text.trim();
            if (cleanText.startsWith('```')) {
              cleanText = cleanText
                  .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
                  .replaceFirst(RegExp(r'\n?```$'), '');
            }
            final data = jsonDecode(cleanText) as Map<String, dynamic>;
            return DailyReading(
              rashi: rashi,
              summary: data['summary'] as String? ?? 'Aaj ka din aapke liye balanced hai.',
              luckyColor: data['luckyColor'] as String? ?? 'Blue',
              luckyNumber: (data['luckyNumber'] as num?)?.toInt() ?? 7,
              remedy: data['remedy'] as String? ?? '🕉️ Meditation karo.',
              favorableTime: data['favorableTime'] as String? ?? '9:00 AM – 12:00 PM',
              date: now,
              overallScore: (data['overallScore'] as num?)?.toDouble() ?? 3.5,
            );
          } catch (_) {
            // Fall through to default
          }
        }
      } catch (_) {
        // Fall through to default
      }
    }

    // Fallback: return a sensible default
    return _generateDefaultReading(rashi);
  }

  /// Get today's panchang — real API data if available
  static Future<PanchangData> getPanchang(UserProfile user) async {
    if (AstrologyApiService.isConfigured) {
      try {
        final now = DateTime.now();
        final panchang = await AstrologyApiService.getFullPanchang(
          year: now.year,
          month: now.month,
          date: now.day,
          hours: now.hour,
          minutes: now.minute,
          seconds: 0,
          latitude: user.safeLatitude,
          longitude: user.safeLongitude,
          timezone: user.safeTimezoneOffset,
        );

        final output = panchang['output'] as Map<String, dynamic>? ?? {};
        final sunrise = output['sunrise_sunset'] as Map<String, dynamic>? ?? {};
        final tithi = output['tithi'];
        final nakshatra = output['nakshatra'];
        final yoga = output['yoga'];
        final karana = output['karana'];

        // Get Rahu Kalam and Gulika separately
        final muhurat = await AstrologyApiService.getMuhuratTimes(
          year: now.year,
          month: now.month,
          date: now.day,
          hours: now.hour,
          minutes: now.minute,
          seconds: 0,
          latitude: user.safeLatitude,
          longitude: user.safeLongitude,
          timezone: user.safeTimezoneOffset,
        );

        final muhuratOutput = muhurat['output'] as Map<String, dynamic>? ?? {};

        return PanchangData(
          tithi: _extractName(tithi, 'Tithi'),
          nakshatra: _extractName(nakshatra, 'Nakshatra'),
          yoga: _extractName(yoga, 'Yoga'),
          karana: _extractName(karana, 'Karana'),
          rahuKaal: _extractTimeRange(muhuratOutput['rahu_kalam']),
          gulikaKaal: _extractTimeRange(muhuratOutput['gulika_kalam']),
          sunrise: sunrise['sun_rise_time']?.toString() ?? '06:00 AM',
          sunset: sunrise['sun_set_time']?.toString() ?? '06:00 PM',
          date: now,
        );
      } catch (_) {
        // Fall through to default
      }
    }

    // Fallback: return default data
    return PanchangData(
      tithi: 'Loading...',
      nakshatra: 'Loading...',
      yoga: 'Loading...',
      karana: 'Loading...',
      rahuKaal: 'Loading...',
      gulikaKaal: 'Loading...',
      sunrise: '06:00 AM',
      sunset: '06:00 PM',
      date: DateTime.now(),
    );
  }

  // ════════════════════════════════════════════════
  //  GEO RESOLUTION
  // ════════════════════════════════════════════════

  /// Resolve a place name to lat/long/timezone using the API
  static Future<Map<String, double>?> resolveGeoLocation(
      String placeName) async {
    if (!AstrologyApiService.isConfigured) return null;
    try {
      final result = await AstrologyApiService.getGeoLocation(placeName);
      final output = result['output'];
      if (output != null && output is Map<String, dynamic>) {
        final lat = (output['latitude'] as num?)?.toDouble();
        final lng = (output['longitude'] as num?)?.toDouble();
        final tz = (output['timezone'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          return {
            'latitude': lat,
            'longitude': lng,
            'timezone': tz ?? 5.5,
          };
        }
      }
    } catch (_) {}
    return null;
  }

  // ════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════

  static String _extractName(dynamic data, String fallback) {
    if (data == null) return fallback;
    if (data is Map) {
      return data['name']?.toString() ??
          data['tithi_name']?.toString() ??
          data['nakshatra_name']?.toString() ??
          data.values.first?.toString() ??
          fallback;
    }
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        return first['name']?.toString() ??
            first['tithi_name']?.toString() ??
            first['nakshatra_name']?.toString() ??
            fallback;
      }
      return first.toString();
    }
    return data.toString();
  }

  static String _extractTimeRange(dynamic data) {
    if (data == null) return 'N/A';
    if (data is Map) {
      final start = data['start']?.toString() ?? data['begin']?.toString();
      final end = data['end']?.toString();
      if (start != null && end != null) return '$start – $end';
      return data.values.join(' – ');
    }
    return data.toString();
  }

  static DailyReading _generateDefaultReading(Rashi rashi) {
    return DailyReading(
      rashi: rashi,
      summary:
          'Aaj ka din aapke liye balanced hai. Professional life mein steady progress hoga. '
          'Apne health pe focus karo — subah ki walk energy boost degi. '
          'Kisi close friend se achi khabar mil sakti hai dopahar ke baad. '
          'Financial planning ke liye accha waqt hai.',
      luckyColor: 'Blue',
      luckyNumber: 7,
      remedy: '🕉️ Aaj shaam ko 5 minute meditation karo — clarity milegi.',
      favorableTime: '9:00 AM – 12:00 PM',
      date: DateTime.now(),
      overallScore: 3.5,
    );
  }
}
