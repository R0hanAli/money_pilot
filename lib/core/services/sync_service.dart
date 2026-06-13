import 'package:get/get.dart';
import '../../data/datasources/local_database.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/models/sync_queue_model.dart';
import 'connectivity_service.dart';

class SyncService extends GetxService {
  final _db = LocalDatabase.instance;
  final _firestore = FirestoreDataSource();
  ConnectivityService get _connectivity => Get.find<ConnectivityService>();

  @override
  void onInit() {
    super.onInit();
    _connectivity.isConnected.listen((online) {
      if (online) _processSyncQueue();
    });
  }

  Future<void> _processSyncQueue() async {
    try {
      final items = await _db.getPendingSyncItems();
      for (final item in items) {
        await _db.updateSyncStatus(item.id, SyncStatus.syncing);
        try {
          await _syncItem(item);
          await _db.deleteSyncItem(item.id);
        } catch (_) {
          await _db.updateSyncStatus(item.id, SyncStatus.failed);
        }
      }
    } catch (_) {}
  }

  Future<void> _syncItem(SyncQueueModel item) async {
    switch (item.entityType) {
      case EntityType.expense:
        await _syncExpense(item);
        break;
      case EntityType.income:
        await _syncIncome(item);
        break;
      case EntityType.budget:
        await _syncBudget(item);
        break;
      case EntityType.categoryBudget:
        await _syncCategoryBudget(item);
        break;
    }
  }

  Future<void> _syncExpense(SyncQueueModel item) async {
    switch (item.action) {
      case SyncAction.create:
      case SyncAction.update:
        final model = await _db.getExpenseById(item.entityId);
        if (model != null) {
          if (item.action == SyncAction.create) {
            await _firestore.saveExpense(model);
          } else {
            await _firestore.updateExpense(model);
          }
        }
        break;
      case SyncAction.delete:
        await _firestore.deleteExpense(item.entityId);
        break;
    }
  }

  Future<void> _syncIncome(SyncQueueModel item) async {
    switch (item.action) {
      case SyncAction.create:
      case SyncAction.update:
        final items = await _db.getIncomeByUser(item.payload['userId'] ?? '');
        final match = items.where((e) => e.id == item.entityId).firstOrNull;
        if (match != null) {
          if (item.action == SyncAction.create) {
            await _firestore.saveIncome(match);
          } else {
            await _firestore.updateIncome(match);
          }
        }
        break;
      case SyncAction.delete:
        await _firestore.deleteIncome(item.entityId);
        break;
    }
  }

  Future<void> _syncBudget(SyncQueueModel item) async {
    final month = item.payload['month'] as String? ?? '';
    final userId = item.payload['userId'] as String? ?? '';
    final budget = await _db.getBudget(userId, month);
    if (budget != null) {
      if (item.action == SyncAction.create) {
        await _firestore.saveBudget(budget);
      } else {
        await _firestore.updateBudget(budget);
      }
    }
  }

  Future<void> _syncCategoryBudget(SyncQueueModel item) async {
    final userId = item.payload['userId'] as String? ?? '';
    final month = item.payload['month'] as String? ?? '';
    final budgets = await _db.getCategoryBudgets(userId, month);
    for (final cb in budgets) {
      await _firestore.saveCategoryBudget(cb);
    }
  }

  Future<void> triggerSync() async {
    if (_connectivity.isConnected.value) {
      await _processSyncQueue();
    }
  }
}
