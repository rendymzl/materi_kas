import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('accounts', [
    Column.text('account_id'),
    Column.text('store_id'),
    Column.text('name'),
    Column.text('email'),
    Column.text('role'),
    Column.text('created_at')
  ]),
  Table('stores', [
    Column.text('owner_id'),
    Column.text('name'),
    Column.text('address'),
    Column.text('phone'),
    Column.text('telp'),
    Column.text('promo'),
    Column.text('created_at')
  ])
]);
