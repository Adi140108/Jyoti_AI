# Jyoti AI - Astrology API Integration

This document outlines the architecture and implementation details for the Free Astrology API integration into Jyoti AI.

## Overview

Jyoti AI uses Gemini 2.5 Flash as its core intelligence. Instead of relying purely on the AI's general knowledge (which can hallucinate or provide generic astrological data), we have integrated the **Free Astrology API** (https://freeastrologyapi.com) directly into Gemini using **Function Calling** (Tools).

When a user asks a question, Gemini determines if it needs real astrological data to answer. If it does, it autonomously calls the relevant Free Astrology API endpoint, receives the real data, and uses that data to formulate a personalized, accurate response.

## Architecture: Gemini Function Calling

1. **User asks:** "What dasha am I running right now?"
2. **Gemini analyzes:** Realizes it needs current dasha data for the user's specific birth details.
3. **Gemini executes Tool:** Calls the `get_dasha` function (defined in `jyoti_service.dart`).
4. **App executes API:** The Flutter app intercepts this function call and makes an HTTP request to `https://json.freeastrologyapi.com/vimsottari/maha-dasas-and-antar-dasas` using `astrology_api_service.dart`.
5. **Data returned:** The API returns the real dasha periods.
6. **Gemini processes:** The app feeds the JSON response back to Gemini.
7. **Gemini answers:** Gemini interprets the raw data and responds in natural language: "Aap abhi Rahu ki Mahadasha mein hain..."

## Available Tools (Function Declarations)

The following groups of endpoints have been exposed to Gemini as tools:

| Tool Name | Capability | Underlying Endpoints Used |
| :--- | :--- | :--- |
| `get_birth_chart` | Gets exact planetary degrees and signs | `/planets` |
| `get_divisional_chart` | Gets positions in D2-D60 charts | `/navamsa-chart-info`, `/d10-chart-info`, etc. |
| `get_panchang` | Gets daily Hindu almanac data | `/getsunriseandset`, `/tithi-durations`, `/nakshatra-durations`, etc. |
| `get_muhurat_times` | Gets good/bad timings (Rahu Kaal, etc.) | `/rahu-kalam`, `/abhijit-muhurat`, `/good-bad-times`, etc. |
| `get_dasha` | Gets Vimsottari Dasha periods | `/vimsottari/maha-dasas-and-antar-dasas` |
| `get_match_making` | Gets Ashtakoot compatibility score (36 points) | `/ashtakoot-score` |
| `get_planetary_strength`| Gets Shad Bala (six-fold strength) summary | `/shadbala/shadbala-summary` |
| `get_geo_location` | Resolves a city name to Lat/Long coordinates | `/geo-location/geo-details` |

## Code Structure

### 1. `AstrologyApiService` (`lib/services/astrology_api_service.dart`)
A pure HTTP wrapper class responsible for communicating with the Free Astrology API. It reads the `ASTROLOGY_API_KEY` from the `.env` file and formats the POST requests with the correct `BirthData` payload.

### 2. `JyotiService` (`lib/services/jyoti_service.dart`)
The core AI engine. 
- Defines the `FunctionDeclaration` schema for all the tools.
- Handles the chat loop: parsing user input, sending it to Gemini, intercepting `FunctionCall` requests, delegating to `AstrologyApiService`, and returning `FunctionResponse` to Gemini until a final text answer is generated.
- Generates the daily horoscope (`getDailyReading`) by fetching real planetary positions and asking Gemini to interpret them into a daily reading format.

### 3. `JyotiProvider` (`lib/providers/jyoti_provider.dart`)
State management.
- When the user completes onboarding, it automatically calls `JyotiService.resolveGeoLocation(placeOfBirth)` to convert "Delhi" into `lat: 28.61, lng: 77.20`.
- This geo-data is saved in the `UserProfile` so that every subsequent API call has accurate coordinates without needing to look them up again.
- Fetches real Panchang data for the Dashboard.

### 4. `UserProfile` (`lib/models/models.dart`)
Updated to store `latitude`, `longitude`, and `timezoneOffset` natively. Added helper getters (`birthHour`, `birthMinute`) to parse the string `timeOfBirth` into integers required by the API.

## Requirements

To run this integration, the `.env` file MUST contain:
```env
GEMINI_API_KEY=your_gemini_key
ASTROLOGY_API_KEY=your_free_astrology_api_key
```

You can get an Astrology API key for free at [freeastrologyapi.com/signup](https://freeastrologyapi.com/signup).