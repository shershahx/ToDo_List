import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_list/utils/session_manager.dart';

class CounterProvider extends ChangeNotifier {
  int _counter = 0;
  bool _isInitialized = false;

  final _storage = const FlutterSecureStorage();
  
  String get _key => 'counter_value_${SessionManager().currentEmail ?? 'default'}';

  int get counter => _counter;
  bool get isInitialized => _isInitialized;

  CounterProvider() {
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final valStr = await _storage.read(key: _key);
    if (valStr != null) {
      _counter = int.tryParse(valStr) ?? 0;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveCounter() async {
    await _storage.write(key: _key, value: _counter.toString());
  }

  void increment() {
    _counter++;
    notifyListeners();
    _saveCounter();
  }

  void decrement() {
    _counter--;
    notifyListeners();
    _saveCounter();
  }

  void reset() {
    _counter = 0;
    notifyListeners();
    _saveCounter();
  }
}
