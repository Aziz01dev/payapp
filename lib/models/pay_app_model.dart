class PayAppModel {
  final int id;
  final String title;
  final int price;
  final String day;
  final String cardprice;

  PayAppModel({
    required this.id,
    required this.title,
    required this.price,
    required this.day,
    required this.cardprice
  });

  PayAppModel copyWith({int? id, String? title, int? price, String? day, String?cardpice}) {
    return PayAppModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      day: day ?? this.day,
      cardprice: cardprice??this.cardprice,
    );
  }

  factory PayAppModel.fromMap(Map<String, dynamic> map) {
    return PayAppModel(
      id: map['id'],
      title: map['title'],
      price: map['price'],
      day: map['day'],
      cardprice: map["cardprice"]
    );
  }

  Map<String, dynamic> toMap() {
    return {"title": title, "price": price, "day": day, "cardprice":cardprice};
  }
}
