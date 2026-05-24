/// Represents the status of an order through its lifecycle.
enum OrderStatus {
  placed('Placed', 'Your order has been received'),
  preparing('Preparing', 'Our chefs are preparing your pizza'),
  baking('Baking', 'Your pizza is in the oven'),
  ready('Ready', 'Your pizza is ready for pickup'),
  delivered('Delivered', 'Your pizza has been delivered');

  const OrderStatus(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Represents an order containing one or more configured pizzas.
class Order {
  final String id;
  final String userId;
  final List<OrderPizzaItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final double totalPrice;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'totalPrice': totalPrice,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['userId'] as String,
        items: (json['items'] as List)
            .map((e) => OrderPizzaItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        status: OrderStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        totalPrice: (json['totalPrice'] as num).toDouble(),
      );
}

/// A single pizza item within an order.
class OrderPizzaItem {
  final int? id;
  final String leftHalfType;
  final String rightHalfType;
  final double price;

  const OrderPizzaItem({
    this.id,
    required this.leftHalfType,
    required this.rightHalfType,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'leftHalfType': leftHalfType,
        'rightHalfType': rightHalfType,
        'price': price,
      };

  factory OrderPizzaItem.fromJson(Map<String, dynamic> json) =>
      OrderPizzaItem(
        id: json['id'] as int?,
        leftHalfType: json['leftHalfType'] as String,
        rightHalfType: json['rightHalfType'] as String,
        price: (json['price'] as num).toDouble(),
      );
}
