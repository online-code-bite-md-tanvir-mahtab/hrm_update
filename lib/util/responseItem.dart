class ResponseItem {
  final int id;
  final String resonName;

  const ResponseItem({
    required this.id,
    required this.resonName,
  });

  factory ResponseItem.fromJson(Map<String, dynamic> json) {
    return ResponseItem(
      id: json['id'],
      resonName: json['resonName'],
    );
  }
}
