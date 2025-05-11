import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/gemini_map_service.dart';

class ConceptualMapScreen extends StatefulWidget {
  const ConceptualMapScreen({super.key});

  @override
  State<ConceptualMapScreen> createState() => _ConceptualMapScreenState();
}

class _ConceptualMapScreenState extends State<ConceptualMapScreen> {
  late final ConceptualMapService _mapService;
  Future<String>? _conceptualMapFuture;
  bool _isLoading = false;
  String? _errorMessage;
  String? _mapData;

  @override
  void initState() {
    super.initState();
    _mapService = ConceptualMapService();
    _loadConceptualMap();
  }

  Future<void> _loadConceptualMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mapData = null;
    });

    try {
      _conceptualMapFuture = _mapService.generateConceptualMap();
      final result = await _conceptualMapFuture;

      if (mounted) {
        setState(() {
          _mapData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conceptual Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadConceptualMap,
            tooltip: 'Regenerate Map',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating conceptual map...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _ErrorWidget(
        error: _errorMessage!,
        onRetry: _loadConceptualMap,
      );
    }

    if (_mapData != null && _mapData!.isNotEmpty) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MarkdownBody(
            data: _mapData!,
            selectable: true,
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: Theme.of(context).textTheme.bodyMedium,
              h1: Theme.of(context).textTheme.headlineMedium,
              h2: Theme.of(context).textTheme.titleLarge,
              h3: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    return _ErrorWidget(
      error: 'No data available',
      onRetry: _loadConceptualMap,
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error Generating Conceptual Map',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
