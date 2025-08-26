// Domain model for a Character
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String originName;
  final String locationName;
  final List<String> episodes;
  final String url;
  final String created;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.originName,
    required this.locationName,
    required this.episodes,
    required this.url,
    required this.created,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? 'unknown',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? 'unknown',
      image: json['image'] as String? ?? '',
      originName: (json['origin']?['name'] as String?) ?? 'unknown',
      locationName: (json['location']?['name'] as String?) ?? 'unknown',
      episodes:
          (json['episode'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      url: json['url'] as String? ?? '',
      created: json['created'] as String? ?? '',
    );
  }
}
