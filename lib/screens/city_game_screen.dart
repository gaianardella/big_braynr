import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;

class CityGameScreen extends StatefulWidget {
  const CityGameScreen({super.key});

  @override
  State<CityGameScreen> createState() => _CityGameScreenState();
}

class _CityGameScreenState extends State<CityGameScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Usiamo localhost direttamente per macOS
    final String gameUrl = 'http://localhost:8000/city_braynr.html';
        
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Errore WebView: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(gameUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Città - Gioco Interattivo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}