import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import '../services/gemini_api_service.dart'; // ✅ Import your service

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({Key? key}) : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isTranscribing = false;
  String? _transcription;

  final String _filePath =
      'C:\\Users\\Rick\\Desktop\\big_braynr\\assets\\audio\\Raft.mp3';

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_filePath));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _transcribeAudio() async {
    setState(() {
      _isTranscribing = true;
      _transcription = null;
    });

    try {
      final transcript = await transcribeAudioWithGemini(_filePath);
      setState(() => _transcription = transcript);
    } catch (e) {
      setState(() => _transcription = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isTranscribing = false);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _seek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Reproducer')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Now Playing: Raft.mp3'),
              const SizedBox(height: 20),
              IconButton(
                iconSize: 64,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(height: 20),
              Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds
                    .clamp(0, _duration.inSeconds)
                    .toDouble(),
                onChanged: _seek,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position)),
                  Text(_formatDuration(_duration)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isTranscribing ? null : _transcribeAudio,
                icon: const Icon(Icons.transcribe),
                label: const Text('Transcribe'),
              ),
              const SizedBox(height: 20),
              if (_isTranscribing)
                const CircularProgressIndicator()
              else if (_transcription != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _transcription!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
