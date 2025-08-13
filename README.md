# Flutter Audio Recorder App

This is a Flutter-based audio recording application with native Android integration for recording and playback in multiple audio formats. The app uses a Flutter UI with a platform channel to invoke native Android code for recording, playing, stopping, and deleting audio files. Recorded files are saved locally and managed with Hive for persistence.

---

## Features

- Record audio in multiple formats: **3gp**, **wav**, **aac**, **mp3**  
- Play and stop recorded audio  
- Delete individual recordings  
- List and manage saved recordings  
- Persistent storage of recordings metadata using [Hive](https://pub.dev/packages/hive)  
- Native Android audio recording and playback implemented with `MediaRecorder` and `MediaPlayer`  
- Flutter UI with format selection dropdown and playback controls  

---

## Project Structure

- **Flutter frontend**  
  - UI for recording controls, format selection, playback, and recordings list  
  - Uses `MethodChannel` to communicate with native Android code  
  - Uses Hive for local storage of recording metadata  

- **Android native code** (Kotlin)  
  - Handles audio recording and playback via `MediaRecorder` and `MediaPlayer`  
  - Supports different audio formats with format-specific encoding  
  - Manages file deletion  

---

## Usage

1. Clone this repository  
2. Run `flutter pub get` to install dependencies  
3. Build and run on an Android device or emulator (requires microphone and storage permissions)  
4. Select the desired recording format  
5. Tap **Start Recording** to begin, **Stop Recording** to finish  
6. Play, stop, or delete recordings from the UI  

---

## Dependencies

- [Flutter](https://flutter.dev) SDK  
- [Hive](https://pub.dev/packages/hive) for lightweight NoSQL storage  
- [path_provider](https://pub.dev/packages/path_provider) for file system paths  

---

## Screenshot

![audiorecord](https://github.com/user-attachments/assets/4d53d4c0-a6ef-4854-9933-9fc79e065b14)


---

## Notes

- WAV format is not natively supported on Android’s `MediaRecorder`, so a 3GP workaround is used internally for WAV selection.  
- MP3 recording is simulated by using MPEG_4 output format with AAC encoder (Android does not provide native MP3 encoding).  
- Audio files are stored in the app-specific external files directory.  

---
