import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_list_viewmodel.dart';
import '../core/result.dart';
import '../models/character.dart';

class CharacterListView extends StatefulWidget {
  const CharacterListView({super.key});

  @override
  State<CharacterListView> createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loadMoreError = false;
  @override
  void initState() {
    super.initState();
    final vm = context.read<CharacterListViewModel>();
    vm.init();

    _searchCtrl.addListener(() {
      vm.searchDebounced(_searchCtrl.text);
    });

    _scroll.addListener(() async {
      // Infinite scroll trigger
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        final result = await vm.loadMoreWithResult();
        if (result == false && !_loadMoreError) {
          _loadMoreError = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao carregar mais personagens.'),
              ),
            );
          }
        } else if (result == true) {
          _loadMoreError = false;
        }
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Personagens',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nome...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: vm.status,
                        style: const TextStyle(color: Colors.black),
                        items: const [
                          DropdownMenuItem(
                            value: 'Todos',
                            child: Text('Todos'),
                          ),
                          DropdownMenuItem(
                            value: 'Alive',
                            child: Text('Alive'),
                          ),
                          DropdownMenuItem(value: 'Dead', child: Text('Dead')),
                          DropdownMenuItem(
                            value: 'unknown',
                            child: Text('Unknown'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) vm.setStatus(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: vm.sortOrder == SortOrder.asc
                        ? 'Ordem A-Z'
                        : 'Ordem Z-A',
                    icon: Icon(
                      vm.sortOrder == SortOrder.asc
                          ? Icons.sort_by_alpha
                          : Icons.sort_by_alpha_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      vm.setSortOrder(
                        vm.sortOrder == SortOrder.asc
                            ? SortOrder.desc
                            : SortOrder.asc,
                      );
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        vm.refresh(query: _searchCtrl.text, status: vm.status),
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
                    onRefresh: () async {
                      await vm.refresh();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lista atualizada!')),
                        );
                      }
                    },
                    child: ListView.builder(
                      controller: _scroll,
                      itemCount: items.length + (vm.hasMore ? 1 : 0),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final c = items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: Card(
                            color: Colors.white.withOpacity(0.93),
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Hero(
                                tag: 'character_${c.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    c.image,
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      c.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: c.status == 'Alive'
                                        ? Colors.green
                                        : c.status == 'Dead'
                                        ? Colors.red
                                        : Colors.grey,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${c.species}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/detail',
                                  arguments: c.id,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
