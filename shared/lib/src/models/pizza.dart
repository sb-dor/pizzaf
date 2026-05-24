/// Represents the type of pizza available.
enum PizzaType {
  pepperoni('Pepperoni', 'Classic pepperoni with mozzarella and tomato sauce', 5.99),
  margherita('Margherita', 'Fresh mozzarella, tomatoes, and basil', 4.99),
  bbqChicken('BBQ Chicken', 'Grilled chicken, BBQ sauce, red onions, cilantro', 6.49),
  hawaiian('Hawaiian', 'Ham, pineapple, and mozzarella cheese', 5.49),
  fourCheese('Four Cheese', 'Mozzarella, gorgonzola, parmesan, and fontina', 6.99),
  veggie('Veggie', 'Bell peppers, mushrooms, olives, onions, tomatoes', 5.49),
  meatLovers('Meat Lovers', 'Pepperoni, sausage, bacon, and ham', 7.49),
  buffalo('Buffalo', 'Spicy buffalo chicken, blue cheese, celery', 6.49);

  const PizzaType(this.displayName, this.description, this.halfPrice);

  final String displayName;
  final String description;

  /// Price for one half of the pizza.
  final double halfPrice;
}

/// Represents which side of a half-and-half pizza.
enum HalfSide { left, right }

/// One half of a pizza.
class PizzaHalf {
  final PizzaType type;
  final HalfSide side;

  const PizzaHalf({required this.type, required this.side});

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'side': side.name,
      };

  factory PizzaHalf.fromJson(Map<String, dynamic> json) => PizzaHalf(
        type: PizzaType.values.byName(json['type'] as String),
        side: HalfSide.values.byName(json['side'] as String),
      );
}

/// A configured pizza with two halves, ready for ordering.
class CartPizza {
  final PizzaHalf leftHalf;
  final PizzaHalf rightHalf;

  const CartPizza({required this.leftHalf, required this.rightHalf});

  /// Total price is the sum of both halves.
  double get price => leftHalf.type.halfPrice + rightHalf.type.halfPrice;

  /// Display-friendly name.
  String get displayName {
    if (leftHalf.type == rightHalf.type) {
      return leftHalf.type.displayName;
    }
    return '${leftHalf.type.displayName} / ${rightHalf.type.displayName}';
  }

  Map<String, dynamic> toJson() => {
        'leftHalf': leftHalf.toJson(),
        'rightHalf': rightHalf.toJson(),
        'price': price,
      };

  factory CartPizza.fromJson(Map<String, dynamic> json) => CartPizza(
        leftHalf: PizzaHalf.fromJson(json['leftHalf'] as Map<String, dynamic>),
        rightHalf:
            PizzaHalf.fromJson(json['rightHalf'] as Map<String, dynamic>),
      );
}

/// Pizza type info returned from the server API.
class PizzaInfo {
  final String id;
  final String name;
  final String description;
  final double halfPrice;
  final String imageUrl;

  const PizzaInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.halfPrice,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'halfPrice': halfPrice,
        'imageUrl': imageUrl,
      };

  factory PizzaInfo.fromJson(Map<String, dynamic> json) => PizzaInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        halfPrice: (json['halfPrice'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
      );
}
