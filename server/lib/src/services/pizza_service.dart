import 'package:shared/shared.dart';
import '../db/database.dart';

/// Service for pizza menu operations.
class PizzaService {
  final Database _db;

  PizzaService(this._db);

  /// Get all available pizza types.
  List<PizzaInfo> getAllPizzas() => _db.getAllPizzaTypes();

  /// Get a specific pizza type by ID.
  PizzaInfo? getPizza(String id) => _db.getPizzaType(id);
}
