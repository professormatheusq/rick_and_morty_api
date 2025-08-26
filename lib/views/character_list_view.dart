import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_list_viewmodel.dart';
import '../core/result.dart';
import '../models/character.dart';
import 'character_detail_view.dart';

class CharacterListView extends StatefulWidget {
  const CharacterListView({super.key});

  @override
  State<CharacterListView> createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<CharacterListViewModel>();
    vm.init();

    _searchCtrl.addListener(() {
      vm.searchDebounced(_searchCtrl.text);
    });

    _scroll.addListener(() {
      // Infinite scroll trigger
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        vm.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterListViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Personagens')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    // Busca agora é debounced ao digitar
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => vm.refresh(query: _searchCtrl.text),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                final state = vm.state;
                if (state is Loading<List<Character>>) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is Failure<List<Character>>) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Falha ao carregar.'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => vm.refresh(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final items = vm.items;
                if (items.isEmpty) {
                  return const Center(child: Text('Nenhum resultado.'));
                }

                return RefreshIndicator(
                  onRefresh: () => vm.refresh(),
                  child: ListView.builder(
                    controller: _scroll,
                    itemCount: items.length + (vm.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        // Loading indicator for pagination
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final c = items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(c.image),
                        ),
                        title: Text(c.name),
                        subtitle: Text('${c.species} • ${c.status}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CharacterDetailView(character: c),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
