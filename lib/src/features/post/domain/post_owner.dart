class PostOwner {
  PostOwner({required this.id, required this.name});

  final String id;
  final String name;

  factory PostOwner.fromJson(Map<String, dynamic> json) {
    return PostOwner(id: json['id'], name: json['name']);
  }
}
