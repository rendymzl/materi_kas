import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widget/customer_input_field_widget.dart';
import '../../../widget/model/payment_card.dart';
import '../controllers/home_controller.dart';

void paymentDialog(BuildContext context, HomeController controller) {
  Get.defaultDialog(
    title: 'Pembayaran',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (3 / 4),
      width: MediaQuery.of(context).size.width * (1 / 3),
      child: ListView(
        children: const [
          CustomerInputFieldCard(),
          PaymentCard(),
        ],
      ),
    ),
  );
}
