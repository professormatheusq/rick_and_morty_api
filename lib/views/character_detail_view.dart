import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/rnm_service.dart';

// Widget auxiliar para exibir informações
class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const InfoTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class CharacterDetailView extends StatefulWidget {
  final int characterId;
  const CharacterDetailView({super.key, required this.characterId});

  @override
  State<CharacterDetailView> createState() => _CharacterDetailViewState();
}

class _CharacterDetailViewState extends State<CharacterDetailView> {
  late Future<Character> _futureCharacter;

  @override
  void initState() {
    super.initState();
    final service = context.read<RnmService>();
    _futureCharacter = service.fetchCharacterById(widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Character>(
        future: _futureCharacter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar personagem'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Personagem não encontrado'));
          }
          final character = snapshot.data!;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
              children: [
                Center(
                  child: Hero(
                    tag: 'character_${character.id}',
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          character.image,
                          height: 220,
                          width: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    character.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.white.withOpacity(0.92),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                character.status,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: character.status == 'Alive'
                                  ? Colors.green
                                  : character.status == 'Dead'
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              character.species,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              character.gender == 'Male'
                                  ? Icons.male
                                  : character.gender == 'Female'
                                  ? Icons.female
                                  : Icons.transgender,
                              color: Colors.blueGrey,
                              size: 22,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        InfoTile(label: 'Gênero', value: character.gender),
                        if (character.type.isNotEmpty)
                          InfoTile(label: 'Tipo', value: character.type),
                        InfoTile(label: 'Origem', value: character.originName),
                        InfoTile(
                          label: 'Localização',
                          value: character.locationName,
                        ),
                        InfoTile(
                          label: 'Criado em',
                          value: character.created.split('T').first,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Aparece em ${character.episodes.length} episódio(s):',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (character.episodes.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: character.episodes.map((e) {
                      final epNum = e.split('/').last;
                      return Chip(
                        label: Text('Ep. $epNum'),
                        backgroundColor: Colors.white.withOpacity(0.85),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
