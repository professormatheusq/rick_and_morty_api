import 'package:flutter/material.dart';

import 'views/character_list_view.dart';
import 'views/character_detail_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick and Morty',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (_) => const CharacterListView(),
        '/detail': (context) {
          final int id = ModalRoute.of(context)!.settings.arguments as int;
          return CharacterDetailView(characterId: id);
        },
      },
    );
  }
}
