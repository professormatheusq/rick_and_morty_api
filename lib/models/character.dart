// Domain model for a Character
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String image;
  final String originName;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.originName,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? 'unknown',
      image: json['image'] as String? ?? '',
      originName: (json['origin']?['name'] as String?) ?? 'unknown',
    );
  }
}
