import 'package:cloud_firestore/cloud_firestore.dart';

class TopupTranHistoryModel {
  String user_id;

  String payment_method;

  final amount;

  bool isTopup;

  String order_id;

  String payment_status;

  Timestamp date;

  String id;
  String? serviceType;
  String? transactionUser;
  String? note;


  TopupTranHistoryModel({
    required this.amount,
    required this.user_id,
    required this.order_id,
    required this.payment_method,
    required this.payment_status,
    required this.date,
    required this.id,
    required this.isTopup,
    required this.serviceType,
    required this.transactionUser,
    required this.note,
  });

  factory TopupTranHistoryModel.fromJson(Map<String, dynamic> parsedJson) {
    return TopupTranHistoryModel(
      amount: parsedJson['amount'] ?? 0.0,
      id: parsedJson['id'],
      isTopup: parsedJson['isTopUp'] ?? false,
      date: parsedJson['date'] ?? '',
      order_id: parsedJson['order_id'] ?? '',
      payment_method: parsedJson['payment_method'] ?? '',
      payment_status: parsedJson['payment_status'] ?? false,
      user_id: parsedJson['user_id'],
      serviceType: parsedJson['serviceType'] ?? '',
      transactionUser: parsedJson['transactionUser'],
      note: parsedJson['note'] ?? "Wallet Transaction",
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'amount': amount,
      'id': id,
      'date': date,
      'isTopUp': isTopup,
      'payment_status': payment_status,
      'order_id': order_id,
      'payment_method': payment_method,
      'user_id': user_id,
      'serviceType': serviceType,
      'transactionUser': this.transactionUser,
      'note': this.note,
    };
    return json;
  }
}
