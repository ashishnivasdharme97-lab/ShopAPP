import 'package:flutter/material.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/udhari_bill_model.dart';
import 'package:shop_app/services/udhar_service.dart';

class UdhariController extends ChangeNotifier {
  UdhariController({UdharService? service})
      : _service = service ?? UdharService();

  final UdharService _service;
  List<UdhariBillModel> entries = [];
  bool isLoading = false;
  String? errorMessage;

  double get totalUdhari {
    return entries.fold(
      0,
      (total, entry) => total + entry.remainingAmount,
    );
  }

  Future<void> loadMyEntries(AuthSession session) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      entries = await _service.getMyEntries(session);
    } catch (error) {
      entries = [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }
}
