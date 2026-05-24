/// DTO for login requests.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json['email'] as String,
        password: json['password'] as String,
      );
}

/// DTO for register requests.
class RegisterRequest {
  final String name;
  final String email;
  final String password;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
      );
}

/// DTO for creating a new order.
class CreateOrderRequest {
  final List<CreateOrderItem> items;

  const CreateOrderRequest({required this.items});

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      CreateOrderRequest(
        items: (json['items'] as List)
            .map((e) => CreateOrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A single pizza item in a create order request.
class CreateOrderItem {
  final String leftHalfType;
  final String rightHalfType;

  const CreateOrderItem({
    required this.leftHalfType,
    required this.rightHalfType,
  });

  Map<String, dynamic> toJson() => {
        'leftHalfType': leftHalfType,
        'rightHalfType': rightHalfType,
      };

  factory CreateOrderItem.fromJson(Map<String, dynamic> json) =>
      CreateOrderItem(
        leftHalfType: json['leftHalfType'] as String,
        rightHalfType: json['rightHalfType'] as String,
      );
}
