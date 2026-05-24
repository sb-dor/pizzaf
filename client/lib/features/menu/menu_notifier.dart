import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

import '../../core/api/api_client.dart';

class MenuNotifier extends ChangeNotifier {
  MenuNotifier(this._apiClient);

  final ApiClient _apiClient;

  List<PizzaInfo> _pizzas = const [];
  bool _loading = false;
  String? _error;

  List<PizzaInfo> get pizzas => _pizzas;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pizzas = await _apiClient.getPizzas();
    } on Object catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
