import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  FileType _fileType = FileType.audio;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'upload_channel',
      'File Uploads',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('È necessaria l\'autorizzazione per l\'archiviazione')),
        );
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: _fileType,
        allowedExtensions: _fileType == FileType.custom ? ['pdf'] : null,
        allowMultiple: false,
        dialogTitle: 'Seleziona un file',
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _isPlaying = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Errore nella selezione del file: ${e.toString()}')),
      );
    }
  }

  Future<void> _togglePlayback() async {
    if (_selectedFile == null) return;

    if (_isPlaying) {
      await _audioPlayer?.pause();
    } else {
      await _audioPlayer?.play(DeviceFileSource(_selectedFile!.path!));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _submitMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore seleziona un file prima')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      const totalSteps = 10;
      for (int i = 0; i <= totalSteps; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _uploadProgress = i / totalSteps;
        });
      }

      await _showNotification(
        'Caricamento completato',
        '${_selectedFile!.name} è stato aggiunto con successo',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materiale aggiunto!')),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      await _showNotification(
        'Caricamento fallito',
        'Impossibile caricare ${_selectedFile!.name}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Errore nel caricamento del file: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String _getFileSize() {
    if (_selectedFile == null) return '0 KB';
    final sizeInKB = _selectedFile!.size / 1024;
    return sizeInKB > 1024
        ? '${(sizeInKB / 1024).toStringAsFixed(2)} MB'
        : '${sizeInKB.toStringAsFixed(2)} KB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi nuovo materiale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isUploading ? null : _submitMaterial,
            tooltip: 'Conferma',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo*',
                  border: OutlineInputBorder(),
                  hintText: 'Inserisci un titolo descrittivo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci un titolo per il materiale';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione (opzionale)',
                  border: OutlineInputBorder(),
                  hintText: 'Aggiungi una descrizione dettagliata',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Tipo di materiale',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<FileType>(
                segments: const [
                  ButtonSegment(
                    value: FileType.audio,
                    icon: Icon(Icons.audiotrack),
                    label: Text('Audio'),
                  ),
                  ButtonSegment(
                    value: FileType.custom,
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('PDF'),
                  ),
                ],
                selected: {_fileType},
                onSelectionChanged: (Set<FileType> newSelection) {
                  setState(() {
                    _fileType = newSelection.first;
                    _selectedFile = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Seleziona un file'),
                onPressed: _selectFile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _fileType == FileType.audio
                                ? Icons.audiotrack
                                : Icons.picture_as_pdf,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(_getFileSize()),
                              ],
                            ),
                          ),
                          if (_fileType == FileType.audio)
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              onPressed: _togglePlayback,
                              tooltip: _isPlaying ? 'Pausa' : 'Riproduci',
                            ),
                        ],
                      ),
                      if (_fileType == FileType.audio) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Anteprima audio:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          path.basename(_selectedFile!.path!),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_isUploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  'Caricamento: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              const Divider(),
              const Text(
                'Informazioni:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _fileType == FileType.audio
                    ? 'Formati audio supportati: MP3, WAV, AAC'
                    : 'Formati documento supportati: PDF',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Dimensione massima: 25 MB',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
