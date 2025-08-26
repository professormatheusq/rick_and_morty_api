import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/rnm_service.dart';
import 'viewmodels/character_list_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => RnmService()),
        ChangeNotifierProvider(
          create: (ctx) => CharacterListViewModel(ctx.read<RnmService>()),
        ),
      ],
      child: const App(),
    ),
  );
}
