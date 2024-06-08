import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../config/app_config.dart';
import '../models/schema.dart';

final List<RegExp> fatalResponseCodes = [
  RegExp(r'^22...$'),
  RegExp(r'^23...$'),
  RegExp(r'^42501$'),
];

// late final PowerSyncDatabase db;

bool isLoggedIn() {
  return Supabase.instance.client.auth.currentSession?.accessToken != null;
}

Future<void> openDatabase() async {
  // final dir = await getApplicationSupportDirectory();
  // final path = join(dir.path, 'postgres.db');

  // db = PowerSyncDatabase(schema: schema, path: path);
  // await db.initialize();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // SupabaseConnector? currentConnector;

  // if (isLoggedIn()) {
  //   currentConnector = SupabaseConnector(db);
  //   db.connect(connector: currentConnector);
  // }

  // Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
  //   final AuthChangeEvent event = data.event;
  //   if (event == AuthChangeEvent.signedIn) {
  //     currentConnector = SupabaseConnector(db);
  //     db.connect(connector: currentConnector!);
  //   } else if (event == AuthChangeEvent.signedOut) {
  //     currentConnector = null;
  //     await db.disconnect();
  //   } else if (event == AuthChangeEvent.tokenRefreshed) {
  //     // currentConnector?.prefetchCredentials();
  //   }
  // });
}

// class SupabaseConnector extends PowerSyncBackendConnector {
//   PowerSyncDatabase db;
//   SupabaseConnector(this.db);

//   @override
//   Future<void> uploadData(PowerSyncDatabase database) async {
//     final transaction = await database.getNextCrudTransaction();
//     if (transaction == null) {
//       return;
//     }

//     final rest = Supabase.instance.client.rest;

//     try {
//       for (var op in transaction.crud) {
//         final table = rest.from(op.table);
//         if (op.op == UpdateType.put) {
//           var data = Map<String, dynamic>.of(op.opData!);
//           if (op.table == 'mytable' && data['myfield'] != null) {
//             data['myfield'] = jsonDecode(data['myfield']);
//           }
//           data['id'] = op.id;
//           await table.upsert(data);
//         } else if (op.op == UpdateType.patch) {
//           await table.update(op.opData!).eq('id', op.id);
//         } else if (op.op == UpdateType.delete) {
//           await table.delete().eq('id', op.id);
//         }
//       }
//       await transaction.complete();
//     } on PostgrestException catch (e) {
//       if (e.code != null &&
//           fatalResponseCodes.any((re) => re.hasMatch(e.code!))) {
//         await transaction.complete();
//       } else {
//         rethrow;
//       }
//     }
//   }

//   @override
//   Future<PowerSyncCredentials?> fetchCredentials() async {
//     final session = Supabase.instance.client.auth.currentSession;
//     if (session == null) {
//       return null;
//     }

//     final token = session.accessToken;
//     debugPrint('fetchCredentials $token');
//     return PowerSyncCredentials(endpoint: AppConfig.powersyncUrl, token: token);
//   }
// }
