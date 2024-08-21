// import 'package:powersync/sqlite3_common.dart' as sqlite;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../../powersync.dart';

class Account {
  String? id;
  String accountId;
  DateTime? createdAt;
  String name;
  String email;
  String role;
  String? storeId;

  Account({
    this.id,
    required this.accountId,
    this.createdAt,
    required this.name,
    required this.email,
    required this.role,
    this.storeId,
  });

  Account.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        accountId = json['account_id'],
        createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at']).toLocal()
            : null,
        name = json['name'],
        email = json['email'],
        role = json['role'],
        storeId = json['store_id'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['account_id'] = accountId;
    data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['store_id'] = storeId;
    return data;
  }

//   Account accountFromTable(AccountsData data) {
//   return Account(
//     id: data.id,
//     accountId: data.accountId,
//     createdAt: data.createdAt,
//     name: data.name,
//     email: data.email,
//     role: data.role,
//     storeId: data.storeId,
//   );
// }

  // CRUD operations

  // Insert (Create)
  static Future<void> insert(Account account) async {
    try {
      await Supabase.instance.client.from('accounts').insert(account.toJson());
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Update
  Future<void> update() async {
    try {
      await Supabase.instance.client
          .from('accounts')
          .update(toJson())
          .eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Delete
  Future<void> delete() async {
    try {
      await Supabase.instance.client.from('accounts').delete().eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Fetch all accounts by uid
  static Future<Account?> get(String uid) async {
    try {
      final response = await Supabase.instance.client
          .from('accounts')
          .select()
          .eq('account_id', uid);
      if (response.isNotEmpty) {
        Account account;
        account = Account.fromJson(response.first);
        return account;
      } else {
        return null;
      }
    } on AuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  static Future<List<Account>> getCashier(String storeId) async {
    try {
      final response = await Supabase.instance.client
          .from('accounts')
          .select()
          .eq('store_id', storeId)
          .eq('role', 'worker');
      debugPrint(storeId);
      debugPrint(response.length.toString());
      if (response.isNotEmpty) {
        List<Account> accounts =
            (response as List).map((json) => Account.fromJson(json)).toList();
        return accounts;
      } else {
        return [];
      }
    } on AuthException catch (e) {
      debugPrint(e.message);
      return [];
    }
  }

  // Real-time subscription to changes in the accounts table
  static Stream<List<Account>> subscribeToAccounts(String storeId) {
    return Supabase.instance.client
        .from('accounts')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .map((data) => data.map((json) => Account.fromJson(json)).toList());
  }

  // Account.fromRow(sqlite.Row row)
  //     : id = row['id'] as String?,
  //       accountId = row['account_id'] as String,
  //       createdAt = DateTime.parse(row['created_at'] as String).toLocal(),
  //       name = row['name'] as String,
  //       email = row['email'] as String,
  //       role = row['role'] as String,
  //       storeId = row['store_id'] as String;
  // // Get account by id

  // static Future<Account> getById(String id) async {
  //   final result = await db.get('SELECT * FROM accounts WHERE id = ?', [id]);
  //   if (result.isNotEmpty) {
  //     return Account.fromRow(result);
  //   }
  //   return Account(
  //       accountId: 'accountId',
  //       createdAt: DateTime.now(),
  //       name: 'name',
  //       email: 'email',
  //       role: 'role',
  //       storeId: 'storeId');
  // }
}



  // // Create table
  // static Future<void> createTable() async {
  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS accounts (
  //       id TEXT PRIMARY KEY,
  //       account_id TEXT,
  //       created_at TEXT,
  //       name TEXT,
  //       email TEXT,
  //       role TEXT,
  //       store_id TEXT
  //     )
  //   ''');
  // }

  // // Insert (Create)
  // Future<void> insert() async {
  //   await db.execute('''
  //     INSERT INTO accounts (id, account_id, created_at, name, email, role, store_id)
  //     VALUES (?, ?, ?, ?, ?, ?, ?)
  //   ''', [
  //     id,
  //     accountId,
  //     createdAt.toIso8601String(),
  //     name,
  //     email,
  //     role,
  //     storeId
  //   ]);
  // }

  // // Update
  // Future<void> update() async {
  //   await db.execute('''
  //     UPDATE accounts
  //     SET account_id = ?, created_at = ?, name = ?, email = ?, role = ?, store_id = ?
  //     WHERE id = ?
  //   ''', [
  //     accountId,
  //     createdAt.toIso8601String(),
  //     name,
  //     email,
  //     role,
  //     storeId,
  //     id
  //   ]);
  // }

  // // Delete by id
  // Future<void> delete() async {
  //   await db.execute('DELETE FROM accounts WHERE id = ?', [id]);
  // }

  // // Get all accounts by storeId
  // static Future<List<Account>> getAllByStoreId(String storeId) async {
  //   final List<Account> accounts = [];
  //   final result = await db
  //       .execute('SELECT * FROM accounts WHERE store_id = ?', [storeId]);
  //   for (final row in result) {
  //     accounts.add(Account.fromRow(row));
  //   }
  //   return accounts;
  // }

  // // // Get account by id
  // static Future<Account?> getById(String id) async {
  //   final result =
  //       await db.execute('SELECT * FROM accounts WHERE owner_id = ?', [id]);
  //   if (result.isNotEmpty) {
  //     return Account.fromRow(result.first);
  //   }
  //   return null;
  // }

  // // Get account by id=================
  // static Future<Account?> getById(String id) async {
  //   final result =
  //       await db.execute('SELECT * FROM accounts WHERE id = ?', [id]);
  //   if (result.isNotEmpty) {
  //     return Account.fromRow(result.first);
  //   }
  //   return null;
  // }



// class Account {
//   String? id;
//   String name;
//   String email;
//   String role;
//   Rx<Stores?> stores;
//   String ownerId;

//   Account({
//     this.id,
//     required this.name,
//     required this.email,
//     required this.role,
//     Stores? stores,
//     required this.ownerId,
//   }) : stores = Rx<Stores?>(stores);

//   Account.fromJson(Map<String, dynamic> json)
//       : id = json['id'],
//         name = json['name'],
//         email = json['email'],
//         role = json['role'],
//         stores = Rx<Stores?>(
//             json['stores'] != null ? Stores.fromJson(json['stores']) : null),
//         ownerId = json['owner_id'];

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['email'] = email;
//     data['role'] = role;
//     data['stores'] = stores.value?.toJson();
//     data['owner_id'] = ownerId;
//     return data;
//   }
// }
