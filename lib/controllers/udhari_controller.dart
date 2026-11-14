import 'package:flutter/material.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/pending_model.dart';
import 'package:shop_app/services/pending_service.dart';

class UdhariController extends ChangeNotifier {
  List<PendingModel> entries = [];
  bool isLoading = false;
  String? errorMessage;

  double get totalUdhari {
    return entries.fold(0, (total, entry) => total + entry.amount);
  }

  Future<void> loadMyEntries(AuthSession session) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      entries = await PendingService.getPendingForUser(session);
    } catch (error) {
      entries = [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
