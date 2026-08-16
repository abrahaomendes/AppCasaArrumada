import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void setupDatabase() {
  // Na web, usa SQLite na thread principal (sem necessidade de COOP/COEP headers)
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
