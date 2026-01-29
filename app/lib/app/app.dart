import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infrastructure/database/sqlite_clipboard_repository.dart';
import '../infrastructure/ai/ai_service.dart';
import '../infrastructure/native_bridge/native_bridge_service.dart';
import '../ui/main_window/main_window_view_model.dart';
import '../ui/main_window/main_window_page.dart';

/// Root application widget with dependency injection.
class ClipboardBrainApp extends StatefulWidget {
  const ClipboardBrainApp({super.key});

  @override
  State<ClipboardBrainApp> createState() => _ClipboardBrainAppState();
}

class _ClipboardBrainAppState extends State<ClipboardBrainApp> {
  late final SqliteClipboardRepository _repository;
  late final NativeBridgeService _nativeBridge;
  late final AIService _aiService;
  late final ClipboardViewModel _viewModel;
  bool _initialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    try {
      _repository = SqliteClipboardRepository();
      await _repository.initialize();

      _nativeBridge = NativeBridgeService();
      _aiService = StubAIService();

      _viewModel = ClipboardViewModel(
        repository: _repository,
        nativeBridge: _nativeBridge,
        aiService: _aiService,
      );
      await _viewModel.initialize();

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _initError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard Brain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_initError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Initialization Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_initError!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing Clipboard Brain...'),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider<ClipboardViewModel>.value(
      value: _viewModel,
      child: const MainWindowPage(),
    );
  }
}
