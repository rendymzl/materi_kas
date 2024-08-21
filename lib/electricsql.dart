// import 'package:electricsql/electricsql.dart';
// import 'package:electricsql_flutter/drivers/drift.dart';

// import 'database.dart';

// // Inisialisasi basis data Drift
// AppDatabase db = AppDatabase();

// // Inisialisasi Electric dengan basis data Drift
// Future<void> main() async {
//   final electric = await electrify<AppDatabase>(
//     dbName: '<db_name>',
//     db: db,
//     migrations: kElectricMigrations,
//     config: ElectricConfig(
//       url: 'http://<ip>:5133',
//     ),
//   );

//   // https://electric-sql.com/docs/usage/auth
//   // Anda dapat menggunakan fungsi `insecureAuthToken` atau `secureAuthToken` untuk menghasilkan token ini
//   final String jwtAuthToken = '<your JWT>';

//   // Connect to the Electric service
//   await electric.connect(jwtAuthToken);
// }
