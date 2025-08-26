import 'package:flutter/foundation.dart';
import 'dart:async';
import '../core/result.dart';
import '../models/character.dart';
import '../services/rnm_service.dart';

class CharacterListViewModel extends ChangeNotifier {
  final RnmService _service;
  CharacterListViewModel(this._service);

  Result<List<Character>> state = Loading();

  // Pagination & search
  int _currentPage = 1;
  String _query = '';
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<Character> _items = [];

  // Debounce
  Timer? _debounce;

  // Cache simples: query -> lista de personagens
  final Map<String, List<Character>> _cache = {};

  List<Character> get items => List.unmodifiable(_items);
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String get query => _query;

  Future<void> init() async {
    await refresh();
  }

  // Debounced search
  void searchDebounced(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      refresh(query: query);
    });
  }

  Future<void> refresh({String? query}) async {
    _query = query ?? _query;
    _currentPage = 1;
    _hasMore = true;
    state = Loading();
    notifyListeners();

    // Verifica cache
    if (_cache.containsKey(_query) && _query.isNotEmpty) {
      _items
        ..clear()
        ..addAll(_cache[_query]!);
      _hasMore = false;
      state = Success(_items);
      notifyListeners();
      return;
    }

    try {
      final page = await _service.fetchCharacters(
        page: _currentPage,
        name: _query,
      );
      _items
        ..clear()
        ..addAll(page.results);
      _hasMore = (page.next != null);
      // Salva no cache
      if (_query.isNotEmpty) {
        _cache[_query] = List<Character>.from(_items);
      }
      state = Success(_items);
    } catch (e) {
      state = Failure(e);
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage += 1;
      final page = await _service.fetchCharacters(
        page: _currentPage,
        name: _query,
      );
      _items.addAll(page.results);
      _hasMore = (page.next != null);
      // Atualiza cache se for busca
      if (_query.isNotEmpty) {
        _cache[_query] = List<Character>.from(_items);
      }
    } catch (_) {
      // keep items, allow retry by user scrolling again or pull-to-refresh
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
