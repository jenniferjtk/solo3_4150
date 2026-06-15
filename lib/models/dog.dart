class Dog {
  final int? id;
  final String breed;
  final String imageUrl;
  final String caption;
  final String savedAt;

  Dog({
    this.id,
    required this.breed,
    required this.imageUrl,
    required this.caption,
    required this.savedAt,
  });

  // convert a Dog into a map to insert into sqlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'breed': breed,
      'imageUrl': imageUrl,
      'caption': caption,
      'savedAt': savedAt,
    };
  }

  // create a Dog from a sqlite row map
  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'],
      breed: map['breed'],
      imageUrl: map['imageUrl'],
      caption: map['caption'],
      savedAt: map['savedAt'],
    );
  }
}