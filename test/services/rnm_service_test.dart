import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:rick_and_morty_api/services/rnm_service.dart';
import 'package:rick_and_morty_api/models/character.dart';

void main() {
  group('RnmService', () {
    test('parseia resposta de sucesso', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'info': {'count': 1, 'pages': 1, 'next': null, 'prev': null},
            'results': [
              {
                'id': 1,
                'name': 'Rick',
                'status': 'Alive',
                'species': 'Human',
                'image': 'img',
                'origin': {'name': 'Earth'},
              },
            ],
          }),
          200,
        );
      });
      final service = RnmService(client: mockClient);
      final page = await service.fetchCharacters();
      expect(page.results, isNotEmpty);
      expect(page.results.first.name, 'Rick');
    });

    test('retorna vazio para 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not found', 404);
      });
      final service = RnmService(client: mockClient);
      final page = await service.fetchCharacters(name: 'nada');
      expect(page.results, isEmpty);
    });
  });
}
