import 'package:shared/shared.dart';

/// In-memory database for the pizza server.
///
/// Stores all data in HashMaps. Simple, fast, no external dependencies.
/// Data is lost on server restart — perfect for development.
class Database {
  // Users: email -> UserRecord
  final Map<String, UserRecord> _usersByEmail = {};
  // Users: id -> UserRecord
  final Map<String, UserRecord> _usersById = {};
  // Refresh tokens: token -> RefreshTokenRecord
  final Map<String, RefreshTokenRecord> _refreshTokens = {};
  // Pizza types: id -> PizzaInfo
  final Map<String, PizzaInfo> _pizzaTypes = {};
  // Orders: id -> Order
  final Map<String, Order> _orders = {};
  // Orders by user: userId -> [orderId]
  final Map<String, List<String>> _ordersByUser = {};

  Database() {
    _seedPizzaTypes();
  }

  // ── Users ──────────────────────────────────────────────────────

  UserRecord? getUserByEmail(String email) => _usersByEmail[email];

  UserRecord? getUserById(String id) => _usersById[id];

  void addUser(UserRecord user) {
    _usersByEmail[user.email] = user;
    _usersById[user.id] = user;
  }

  // ── Refresh Tokens ─────────────────────────────────────────────

  RefreshTokenRecord? getRefreshToken(String token) => _refreshTokens[token];

  void addRefreshToken(RefreshTokenRecord record) {
    _refreshTokens[record.token] = record;
  }

  void deleteRefreshToken(String token) {
    _refreshTokens.remove(token);
  }

  void deleteAllRefreshTokensForUser(String userId) {
    _refreshTokens.removeWhere((_, v) => v.userId == userId);
  }

  // ── Pizza Types ────────────────────────────────────────────────

  List<PizzaInfo> getAllPizzaTypes() => _pizzaTypes.values.toList();

  PizzaInfo? getPizzaType(String id) => _pizzaTypes[id];

  // ── Orders ─────────────────────────────────────────────────────

  void addOrder(Order order) {
    _orders[order.id] = order;
    _ordersByUser.putIfAbsent(order.userId, () => []).add(order.id);
  }

  Order? getOrder(String id) => _orders[id];

  List<Order> getOrdersForUser(String userId) {
    final ids = _ordersByUser[userId] ?? [];
    return ids.map((id) => _orders[id]).whereType<Order>().toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final order = _orders[orderId];
    if (order == null) return;
    _orders[orderId] = Order(
      id: order.id,
      userId: order.userId,
      items: order.items,
      status: status,
      createdAt: order.createdAt,
      totalPrice: order.totalPrice,
    );
  }

  // ── Seed Data ──────────────────────────────────────────────────

  void _seedPizzaTypes() {
    for (final type in PizzaType.values) {
      final info = PizzaInfo(
        id: type.name,
        name: type.displayName,
        description: type.description,
        halfPrice: type.halfPrice,
        imageUrl: _pizzaImageUrls[type]!,
      );
      _pizzaTypes[info.id] = info;
    }
  }

  static const _pizzaImageUrls = {
    PizzaType.pepperoni:
        'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?auto=format&fit=crop&w=900&q=80',
    PizzaType.margherita:
        'https://images.unsplash.com/photo-1764705309243-c47cbc9792e4?auto=format&fit=crop&w=900&q=80',
    PizzaType.bbqChicken:
        'https://images.unsplash.com/photo-1767065603868-3ab099506cea?auto=format&fit=crop&w=900&q=80',
    PizzaType.hawaiian:
        'https://images.unsplash.com/photo-1745031601360-b189f522ea90?auto=format&fit=crop&w=900&q=80',
    PizzaType.fourCheese:
        'https://images.unsplash.com/photo-1571407843718-a5878b564b22?auto=format&fit=crop&w=900&q=80',
    PizzaType.veggie:
        'https://images.unsplash.com/photo-1651307441149-2e2c0e1978b1?auto=format&fit=crop&w=900&q=80',
    PizzaType.meatLovers:
        'https://images.unsplash.com/photo-1767065603893-51ab14faefaa?auto=format&fit=crop&w=900&q=80',
    PizzaType.buffalo:
        'https://images.unsplash.com/photo-1593504049359-74330189a345?auto=format&fit=crop&w=900&q=80',
  };
}

/// Internal user record with password hash.
class UserRecord {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;

  const UserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  User toUser() => User(id: id, name: name, email: email);
}

/// Internal refresh token record.
class RefreshTokenRecord {
  final String token;
  final String userId;
  final DateTime expiresAt;

  const RefreshTokenRecord({
    required this.token,
    required this.userId,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
