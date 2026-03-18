import 'package:flutter/material.dart';
import 'package:logdash_frontend_mobile/app/app.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjector();
  await injector.get<AuthRepository>().restoreSession();
  runApp(const App());
}
