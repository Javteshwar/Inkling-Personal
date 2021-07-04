class FileItem {
  String name;
  double price;
  bool isBought;
  FileItem({
    this.name,
    dynamic price,
    this.isBought,
  }) {
    this.name = name;
    this.isBought = isBought ?? true;
    this.price = price == null ? 0.0 : price.toDouble();
  }

  factory FileItem.fromJson(Map<dynamic, dynamic> mp) {
    return FileItem(
      name: mp['name'],
      price: mp['price'],
      isBought: mp['isBought'],
    );
  }
}
