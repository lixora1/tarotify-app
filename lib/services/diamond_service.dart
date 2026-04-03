import 'package:shared_preferences/shared_preferences.dart';

/// Elmas sistemi — yerel depolama
class DiamondService {
  DiamondService._();
  static final DiamondService instance = DiamondService._();

  static const String _key = 'diamonds';
  static const int fortuneCost = 50;
  static const int adReward = 25;

  int _diamonds = 0;
  int get diamonds => _diamonds;

  final List<void Function(int)> _listeners = [];
  void addListener(void Function(int) cb) => _listeners.add(cb);
  void removeListener(void Function(int) cb) => _listeners.remove(cb);
  void _notify() { for (final cb in _listeners) cb(_diamonds); }

  Future<void> initDiamonds(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    _diamonds = amount;
    await prefs.setInt(_key, amount);
    _notify();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _diamonds = prefs.getInt(_key) ?? 0;
    _notify();
  }

  Future<bool> spend(int amount) async {
    if (_diamonds < amount) return false;
    _diamonds -= amount;
    await _save();
    return true;
  }

  Future<void> earn(int amount) async {
    _diamonds += amount;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _diamonds);
    _notify();
  }
}
