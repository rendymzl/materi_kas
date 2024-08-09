import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/operating_costs_model.dart';
// import 'auth_services.dart';
import 'stores_services.dart';

class OperatingCostServices extends GetxController {
  final StoreServices storesService = Get.find();
  final CollectionReference _operatingCostsCollection =
      FirebaseFirestore.instance.collection('operating_cost');

  var operatingCosts = <OperatingCost>[].obs;
  var fountOperatingCost = <OperatingCost>[].obs;

  Future<void> fetchOperatingCost() async {
    try {
      DocumentSnapshot docSnapshot = await _operatingCostsCollection
          .doc(storesService.account.value.ownerUid)
          .get();
      if (docSnapshot.exists) {
        var operatingCostData = docSnapshot.data() as Map<String, dynamic>;
        operatingCosts.value = operatingCostData.values
            .map((operatingCostJson) =>
                OperatingCost.fromJson(operatingCostJson))
            .toList();
        searchOperatingCost('');
      } else {
        operatingCosts.value = [];
        fountOperatingCost.value = [];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> getId() async {
    return _operatingCostsCollection.doc().id;
  }

  Future<void> addOperatingCost(
      Map<String, Map<String, dynamic>> operatingCostMap) async {
    try {
      DocumentReference docRef =
          _operatingCostsCollection.doc(storesService.account.value.ownerUid);
      await docRef.set(operatingCostMap, SetOptions(merge: true));
      await fetchOperatingCost();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateOperatingCost(OperatingCost newOperatingCost,
      OperatingCost currentOperatingCost) async {
    if (currentOperatingCost.id == null) {
      debugPrint('Operating cost ID is null');
      return;
    }

    try {
      await _operatingCostsCollection
          .doc(storesService.account.value.ownerUid)
          .update({currentOperatingCost.id!: newOperatingCost.toJson()});
      await fetchOperatingCost();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteOperatingCost(String id) async {
    try {
      await _operatingCostsCollection
          .doc(storesService.account.value.ownerUid)
          .update({id: FieldValue.delete()});
      operatingCosts.removeWhere((operatingCost) => operatingCost.id == id);
      fountOperatingCost.removeWhere((operatingCost) => operatingCost.id == id);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteAllOperatingCost() async {
    try {
      await _operatingCostsCollection
          .doc(storesService.account.value.ownerUid)
          .delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchOperatingCost(String operatingCostName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (operatingCostName.isEmpty) {
        List<OperatingCost> operatingCostList = [];
        operatingCostList.addAll(operatingCosts);
        operatingCostList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        List<OperatingCost> subList = operatingCostList.take(50).toList();
        fountOperatingCost.clear();
        fountOperatingCost.addAll(subList);
      } else {
        fountOperatingCost.value = operatingCosts.where((customer) {
          return customer.name!
              .toLowerCase()
              .contains(operatingCostName.toLowerCase());
        }).toList();
      }
    });
  }
}
