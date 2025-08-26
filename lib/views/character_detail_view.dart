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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
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
      appBar: AppBar(),
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(character.image, height: 220),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  character.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                InfoTile(label: 'Espécie', value: character.species),
                InfoTile(label: 'Status', value: character.status),
                InfoTile(label: 'Gênero', value: character.gender),
                if (character.type.isNotEmpty)
                  InfoTile(label: 'Tipo', value: character.type),
                InfoTile(label: 'Origem', value: character.originName),
                InfoTile(label: 'Localização', value: character.locationName),
                InfoTile(
                  label: 'Criado em',
                  value: character.created.split('T').first,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aparece em ${character.episodes.length} episódio(s)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (character.episodes.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: character.episodes.map((e) {
                      final epNum = e.split('/').last;
                      return Chip(label: Text('Ep. $epNum'));
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
