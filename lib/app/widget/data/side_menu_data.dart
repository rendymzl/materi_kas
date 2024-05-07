import 'package:material_symbols_icons/symbols.dart';

import '../model/side_menu_model.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Symbols.add_notes, label: 'Transaksi'),
    MenuModel(icon: Symbols.clinical_notes, label: 'Invoice'),
    MenuModel(icon: Symbols.groups, label: 'Customer'),
    MenuModel(icon: Symbols.handyman, label: 'Barang'),
    MenuModel(icon: Symbols.account_circle, label: 'Profil'),
  ];
}
