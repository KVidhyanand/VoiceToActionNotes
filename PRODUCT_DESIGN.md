# Voice Notes Assistant

## Product Vision

A mobile app for iPhone and Android that captures spoken user input, transcribes it to structured text, and converts it into actionable notes. The app will categorize notes as public/work/personal, save them in a private library, and allow users to retrieve and share them via email or WhatsApp.

## Core User Flows

1. Record voice input.
2. Get near real-time speech-to-text transcription.
3. Convert transcript into actionable bullet points.
4. Save the result in the user library.
5. Browse and retrieve saved notes.
6. Share notes using email or WhatsApp.

## Key Features

- Microphone recording and transcription
- Actionable point extraction from transcribed text
- Note categorization (personal, work, public)
- Local note persistence in mobile storage
- Note library with search and detail view
- Share notes by email or WhatsApp
- Clear mobile-first UI for both Android and iOS

## MVP Scope

- Use device speech recognition to capture voice and create a transcript
- Provide a simple “Convert to Action Points” flow
- Save notes locally on the device
- Implement a note library list
- Support email + WhatsApp sharing with deep links

## Architecture

- UI: Flutter Material app with a home dashboard
- Speech: `speech_to_text` for speech recognition
- Persistence: `shared_preferences` for saved notes
- Sharing: `url_launcher` for email and WhatsApp
- Future integration: a service layer for LLM/SLM processing and cloud sync

## Screens

- Home / Record screen
- Transcription preview and action extraction
- Save note form with category selection
- Note library list
- Note detail + share actions

## Future Expansion

- Integrate a real LLM/SLM service for richer action-item generation
- Add note editing, search, and filtering
- Support background recording and multi-language transcription
- Add authentication and cloud sync across devices
- Add audio playback of recordings and transcript version history

## Next Steps

1. Install required dependencies.
2. Build the home UI with recording controls.
3. Connect speech recognition and note persistence.
4. Add note detail view and sharing actions.
5. Replace the placeholder action extraction with an LLM/SLM connector.
