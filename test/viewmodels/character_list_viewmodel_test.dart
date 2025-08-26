import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_api/viewmodels/character_list_viewmodel.dart';
import 'package:rick_and_morty_api/models/character.dart';

import 'package:rick_and_morty_api/core/result.dart';
import 'package:rick_and_morty_api/services/rnm_service.dart';
import 'package:rick_and_morty_api/models/paged_response.dart';

class FakeService extends RnmService {
  final List<Character> fakeList;
  FakeService(this.fakeList) : super();
  @override
  Future<PagedResponse<Character>> fetchCharacters({
    int page = 1,
    String? name,
  }) async {
    return Future.value(
      PagedResponse<Character>(
        count: fakeList.length,
        pages: 1,
        next: null,
        prev: null,
        results: fakeList,
      ),
    );
  }
}

void main() {
  test('refresh popula lista e estado', () async {
    final vm = CharacterListViewModel(
      FakeService([
        Character(
          id: 1,
          name: 'Rick',
          status: 'Alive',
          species: 'Human',
          image: 'img',
          originName: 'Earth',
        ),
      ]),
    );
    await vm.refresh(query: 'Rick');
    expect(vm.items.length, 1);
    expect(vm.state, isA<Success<List<Character>>>());
  });
}
