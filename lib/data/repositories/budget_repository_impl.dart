import '../../core/services/connectivity_service.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../datasources/local_database.dart';
import '../models/budget_model.dart';
import '../models/category_budget_model.dart';
import '../models/sync_queue_model.dart';

extension BudgetModelX on BudgetModel {
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      userId: userId,
      month: month,
      totalBudget: totalBudget,
      remainingBudget: remainingBudget,
      usedBudget: usedBudget,
      createdAt: createdAt,
    );
  }
}

extension BudgetEntityX on BudgetEntity {
  BudgetModel toModel() {
    return BudgetModel(
      id: id,
      userId: userId,
      month: month,
      totalBudget: totalBudget,
      remainingBudget: remainingBudget,
      usedBudget: usedBudget,
      createdAt: createdAt,
    );
  }
}

extension CategoryBudgetModelX on CategoryBudgetModel {
  CategoryBudgetEntity toEntity() {
    return CategoryBudgetEntity(
      id: id,
      userId: userId,
      month: month,
      category: category,
      allocatedAmount: allocatedAmount,
      spentAmount: spentAmount,
    );
  }
}

extension CategoryBudgetEntityX on CategoryBudgetEntity {
  CategoryBudgetModel toModel() {
    return CategoryBudgetModel(
      id: id,
      userId: userId,
      month: month,
      category: category,
      allocatedAmount: allocatedAmount,
      spentAmount: spentAmount,
    );
  }
}

class BudgetRepositoryImpl implements BudgetRepository {
  final LocalDatabase _localDatabase;
  final FirestoreDataSource _firestoreDataSource;
  final ConnectivityService _connectivityService;

  BudgetRepositoryImpl({
    required LocalDatabase localDatabase,
    required FirestoreDataSource firestoreDataSource,
    required ConnectivityService connectivityService,
  })  : _localDatabase = localDatabase,
        _firestoreDataSource = firestoreDataSource,
        _connectivityService = connectivityService;

  @override
  Future<BudgetEntity?> getBudget(String userId, String month) async {
    final model = await _localDatabase.getBudget(userId, month);
    return model?.toEntity();
  }

  @override
  Future<void> setBudget(BudgetEntity budget) async {
    final model = budget.toModel();
    await _localDatabase.upsertBudget(model);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.saveBudget(model);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.create,
          entityType: EntityType.budget,
          payload: model.toMap(),
          entityId: model.id,
        ),
      );
    }
  }

  @override
  Future<void> updateBudgetUsage(
      String userId, String month, double usedAmount) async {
    await _localDatabase.updateBudgetUsage(userId, month, usedAmount);
    if (_connectivityService.isConnected.value) {
      final updated = await _localDatabase.getBudget(userId, month);
      if (updated != null) {
        await _firestoreDataSource.updateBudget(updated);
      }
    } else {
      final existing = await _localDatabase.getBudget(userId, month);
      if (existing != null) {
        await _localDatabase.insertSyncItem(
          SyncQueueModel.create(
            action: SyncAction.update,
            entityType: EntityType.budget,
            payload: existing.toMap(),
            entityId: existing.id,
          ),
        );
      }
    }
  }

  @override
  Future<List<CategoryBudgetEntity>> getCategoryBudgets(
      String userId, String month) async {
    final models = await _localDatabase.getCategoryBudgets(userId, month);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> setCategoryBudget(CategoryBudgetEntity cb) async {
    final model = cb.toModel();
    await _localDatabase.upsertCategoryBudget(model);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.saveCategoryBudget(model);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.create,
          entityType: EntityType.categoryBudget,
          payload: model.toMap(),
          entityId: model.id,
        ),
      );
    }
  }

  @override
  Future<void> updateCategorySpent(
      String userId, String month, String category, double spentAmount) async {
    await _localDatabase.updateCategorySpent(
        userId, month, category, spentAmount);
    if (_connectivityService.isConnected.value) {
      final budgets = await _localDatabase.getCategoryBudgets(userId, month);
      final updated = budgets.where((b) => b.category == category).firstOrNull;
      if (updated != null) {
        await _firestoreDataSource.saveCategoryBudget(updated);
      }
    } else {
      final budgets = await _localDatabase.getCategoryBudgets(userId, month);
      final existing =
          budgets.where((b) => b.category == category).firstOrNull;
      if (existing != null) {
        await _localDatabase.insertSyncItem(
          SyncQueueModel.create(
            action: SyncAction.update,
            entityType: EntityType.categoryBudget,
            payload: existing.toMap(),
            entityId: existing.id,
          ),
        );
      }
    }
  }
}
