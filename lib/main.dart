import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'data/models/company.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CompanyAdapter());

  await Hive.openBox<Company>('companies_my');
  await Hive.openBox<Company>('companies_partner');

  runApp(const MyApp());
}
