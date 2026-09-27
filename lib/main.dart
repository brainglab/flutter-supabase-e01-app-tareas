import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'diseno/tema.dart';
import 'ui/pantalla_tareas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
    ),
  );

  // Sin pantalla de login: un usuario anónimo real.
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession == null) {
    await auth.signInAnonymously();
  }

  runApp(
    MaterialApp(
      title: 'Mis tareas',
      theme: temaBrainglab(), // Brainglab UI (lib/diseno)
      debugShowCheckedModeBanner: false,
      home: const PantallaTareas(),
    ),
  );
}
