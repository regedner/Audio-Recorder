import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'recording.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(RecordingAdapter());
  await Hive.openBox<Recording>('recordings');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AudioRecorderPage(),
    );
  }
}

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  static const platform = MethodChannel('com.example.audio/recorder');
  String _recordingPath = "";
  bool _isRecording = false;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _duration = 0.0;
  String _selectedFormat = "3gp"; // Default format
  List<String> _formats = ["3gp", "wav", "aac", "mp3"];
  List<String> _recordings = [];

  // Hive box
  late Box<Recording> _recordingBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _recordingBox = await Hive.openBox<Recording>('recordings');
    setState(() {
      _recordings = _recordingBox.values.map((e) => e.filePath).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Recorder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format selection button
            Row(
              children: [
                Text("Select Format: "),
                DropdownButton<String>(
                  value: _selectedFormat,
                  items: _formats.map((String format) {
                    return DropdownMenuItem<String>(
                      value: format,
                      child: Text(format.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (String? newFormat) {
                    setState(() {
                      _selectedFormat = newFormat!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Start / Stop recording button
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? "Stop Recording" : "Start Recording"),
            ),
            SizedBox(height: 20),
            // Playback and delete button
            if (_recordingPath.isNotEmpty)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _isPlaying ? _stopPlaying : _playRecording,
                    child: Text(_isPlaying ? "Stop Playing" : "Play Recording"),
                  ),
                  ElevatedButton(
                    onPressed: _deleteRecording,
                    child: Text("Delete Recording"),
                  ),
                ],
              ),
            SizedBox(height: 20),
            // List of saved recordings
            Expanded(
              child: ListView.builder(
                itemCount: _recordings.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_recordings[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () => _playRecordingAt(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteRecordingAt(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      final format = _selectedFormat;
      final fileName = "recording_${DateTime.now().millisecondsSinceEpoch}.$format";
      final result = await platform.invokeMethod('startRecording', {"format": format});
      setState(() {
        _recordingPath = result;
        _isRecording = true;
      });
    } on PlatformException catch (e) {
      print("Failed to start recording: ${e.message}");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final result = await platform.invokeMethod('stopRecording');
      setState(() {
        _isRecording = false;
        _recordings.add(_recordingPath);
        final recording = Recording(
          filePath: _recordingPath,
          format: _selectedFormat,
          duration: _duration.toInt(),
          createdAt: DateTime.now(),
        );
        _recordingBox.add(recording);  // Save to Hive
        _recordingPath = "";
      });
    } on PlatformException catch (e) {
      print("Failed to stop recording: ${e.message}");
    }
  }

  Future<void> _playRecording() async {
    try {
      await platform.invokeMethod('playRecording', {"path": _recordingPath});
      setState(() {
        _isPlaying = true;
      });
    } on PlatformException catch (e) {
      print("Failed to play recording: ${e.message}");
    }
  }

  Future<void> _stopPlaying() async {
    try {
      await platform.invokeMethod('stopPlaying');
      setState(() {
        _isPlaying = false;
      });
    } on PlatformException catch (e) {
      print("Failed to stop playing: ${e.message}");
    }
  }

  Future<void> _deleteRecording() async {
    try {
      await platform.invokeMethod('deleteRecording', {"path": _recordingPath});
      setState(() {
        _recordingPath = "";
      });
    } on PlatformException catch (e) {
      print("Failed to delete recording: ${e.message}");
    }
  }

  Future<void> _deleteRecordingAt(int index) async {
    try {
      await platform.invokeMethod('deleteRecording', {"path": _recordings[index]});
      setState(() {
        _recordings.removeAt(index);
      });
    } on PlatformException catch (e) {
      print("Failed to delete recording: ${e.message}");
    }
  }

  Future<void> _playRecordingAt(int index) async {
    try {
      await platform.invokeMethod('playRecording', {"path": _recordings[index]});
      setState(() {
        _isPlaying = true;
      });
    } on PlatformException catch (e) {
      print("Failed to play recording: ${e.message}");
    }
  }
}
