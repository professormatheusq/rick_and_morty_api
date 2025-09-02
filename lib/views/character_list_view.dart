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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF185A9D),
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Buscar',
        onPressed: () => vm.refresh(query: _searchCtrl.text, status: vm.status),
        child: const Icon(Icons.search, size: 30),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF232526), Color(0xFF185A9D)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
            // Filtros como chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: vm.status == 'Todos',
                    onSelected: (_) => vm.setStatus('Todos'),
                    selectedColor: Color(0xFF185A9D),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: const Color(0xFF232526),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Alive'),
                    selected: vm.status == 'Alive',
                    onSelected: (_) => vm.setStatus('Alive'),
                    selectedColor: Colors.green,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: const Color(0xFF232526),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Dead'),
                    selected: vm.status == 'Dead',
                    onSelected: (_) => vm.setStatus('Dead'),
                    selectedColor: Colors.red,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: const Color(0xFF232526),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Unknown'),
                    selected: vm.status == 'unknown',
                    onSelected: (_) => vm.setStatus('unknown'),
                    selectedColor: Colors.grey,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: const Color(0xFF232526),
                  ),
                  const Spacer(),
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
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          tween: Tween(begin: 0.95, end: 1),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) {
                            return GestureDetector(
                              onTapDown: (_) => setState(() {}),
                              child: Transform.scale(
                                scale: scale,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                  child: Card(
                                    color: const Color(0xFF232526),
                                    elevation: 8,
                                    shadowColor: Colors.black38,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: Hero(
                                        tag: 'character_${c.id}',
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Icon(
                                            c.status == 'Alive'
                                                ? Icons.favorite
                                                : c.status == 'Dead'
                                                ? Icons.close
                                                : Icons.help_outline,
                                            color: c.status == 'Alive'
                                                ? Colors.greenAccent
                                                : c.status == 'Dead'
                                                ? Colors.redAccent
                                                : Colors.grey,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            c.status,
                                            style: TextStyle(
                                              color: c.status == 'Alive'
                                                  ? Colors.greenAccent
                                                  : c.status == 'Dead'
                                                  ? Colors.redAccent
                                                  : Colors.grey[300],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            c.species,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
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
                                ),
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
      ),
    );
  }
}
