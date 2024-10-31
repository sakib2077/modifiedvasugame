import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
// import 'dart:convert'; // for JSON decoding and encoding

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late WebViewControllerPlus _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _loadGameData(); // Load game data when the page finishes loading
          },
        ),
      )
      ..addJavaScriptChannel(
        'ScoreChannel', // JavaScriptChannel for receiving game data updates
        onMessageReceived: (message) async {
          await saveGameData(message.message); // Save game data from JavaScript
        },
      )
      ..loadFlutterAssetServer('lib/Game/index.html');
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  Future<void> saveGameData(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gameData', jsonData);
  }

  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('gameData');
    if (jsonData != null) {
      _controller.runJavaScript('loadSavedData($jsonData);'); // Inject JavaScript to load saved data
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    return Scaffold(
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  @override
  void dispose() {
    _controller.server.close();
    super.dispose();
  }
}
