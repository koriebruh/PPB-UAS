class Cart {
  final int userId;
  final int productId;
  final int jumlah;

  Cart({required this.userId, required this.productId, required this.jumlah});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['user_id'],
      productId: json['product_id'],
      jumlah: json['jumlah'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'jumlah': jumlah,
    };
  }
}
