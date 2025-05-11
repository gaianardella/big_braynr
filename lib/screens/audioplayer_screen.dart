import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import '../services/gemini_api_service.dart';

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

  String? _filePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Inizializzare il percorso del file in modo asincrono
    _initAudioFile();

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

  // Metodo aggiornato per inizializzare il percorso del file audio su macOS
  Future<void> _initAudioFile() async {
    try {
      // Ottieni la directory dei documenti dell'applicazione
      final directory = await getApplicationDocumentsDirectory();

      // Crea il percorso completo al file audio
      final audioFilePath = '${directory.path}/raft.mp3';

      // Verifica se il file esiste già
      final file = File(audioFilePath);
      if (!await file.exists()) {
        // Copia il file dalle risorse dell'app
        try {
          // Percorso corretto alle risorse
          final data = await rootBundle.load('assets/audio/raft.mp3');
          await file.writeAsBytes(
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
          debugPrint('File audio copiato nelle risorse locali: $audioFilePath');
        } catch (e) {
          debugPrint('Errore durante la copia del file audio: $e');
          debugPrint('Dettaglio errore: ${e.toString()}');
        }
      } else {
        debugPrint('File audio trovato: $audioFilePath');
      }

      setState(() {
        _filePath = audioFilePath;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Errore durante l\'inizializzazione del file audio: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_filePath == null) {
      debugPrint('Percorso del file audio non inizializzato');
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_filePath!));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _transcribeAudio() async {
    if (_filePath == null) {
      setState(() => _transcription = 'Errore: File audio non inizializzato');
      return;
    }

    setState(() {
      _isTranscribing = true;
      _transcription = null;
    });

    try {
      final transcript = await transcribeAudioWithGemini(_filePath!);
      setState(() => _transcription = transcript);
    } catch (e) {
      setState(() => _transcription = 'Errore: ${e.toString()}');
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.indigo))
              : _filePath == null
                  ? Center(
                      child: Text(
                        'Impossibile caricare il file audio',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.music_note,
                                    color: Colors.indigo.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Now Playing: raft.mp3',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.indigo.shade100,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: IconButton(
                              iconSize: 64,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.indigo.shade800,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    thumbColor: Colors.indigo.shade600,
                                    activeTrackColor: Colors.indigo.shade400,
                                    inactiveTrackColor: Colors.indigo.shade100,
                                    overlayColor:
                                        Colors.indigo.shade200.withOpacity(0.3),
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                  ),
                                  child: Slider(
                                    min: 0,
                                    max: _duration.inSeconds.toDouble(),
                                    value: _position.inSeconds
                                        .clamp(0, _duration.inSeconds)
                                        .toDouble(),
                                    onChanged: _seek,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_position),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.indigo.shade800,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(_duration),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.indigo.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed:
                                _isTranscribing ? null : _transcribeAudio,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo.shade600,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            icon: const Icon(Icons.transcribe),
                            label: Text(
                              'Transcribe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (_isTranscribing)
                            const CircularProgressIndicator(
                                color: Colors.indigo)
                          else if (_transcription != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.indigo.shade50,
                                    Colors.blue.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.indigo.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.text_fields,
                                        color: Colors.indigo.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Trascrizione',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Text(
                                    _transcription!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
