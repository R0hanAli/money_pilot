import '../../core/services/connectivity_service.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../datasources/local_database.dart';
import '../models/expense_model.dart';
import '../models/sync_queue_model.dart';

extension ExpenseModelX on ExpenseModel {
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      userId: userId,
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      description: description,
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ExpenseEntityX on ExpenseEntity {
  ExpenseModel toModel() {
    return ExpenseModel(
      id: id,
      userId: userId,
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      description: description,
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final LocalDatabase _localDatabase;
  final FirestoreDataSource _firestoreDataSource;
  final ConnectivityService _connectivityService;

  ExpenseRepositoryImpl({
    required LocalDatabase localDatabase,
    required FirestoreDataSource firestoreDataSource,
    required ConnectivityService connectivityService,
  })  : _localDatabase = localDatabase,
        _firestoreDataSource = firestoreDataSource,
        _connectivityService = connectivityService;

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    final model = expense.toModel();
    await _localDatabase.insertExpense(model);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.saveExpense(model);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.create,
          entityType: EntityType.expense,
          payload: model.toMap(),
          entityId: model.id,
        ),
      );
    }
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final model = expense.toModel();
    await _localDatabase.updateExpense(model);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.updateExpense(model);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.update,
          entityType: EntityType.expense,
          payload: model.toMap(),
          entityId: model.id,
        ),
      );
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _localDatabase.deleteExpense(id);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.deleteExpense(id);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.delete,
          entityType: EntityType.expense,
          payload: {'id': id},
          entityId: id,
        ),
      );
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpenses(String userId) async {
    final models = await _localDatabase.getExpensesByUser(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByMonth(
      String userId, String month) async {
    final models = await _localDatabase.getExpensesByMonth(userId, month);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByCategory(
      String userId, String category) async {
    final models = await _localDatabase.getExpensesByCategory(userId, category);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ExpenseEntity?> getExpenseById(String id) async {
    final model = await _localDatabase.getExpenseById(id);
    return model?.toEntity();
  }

  @override
  Future<double> getTotalExpenseForMonth(
    String userId,
    String month,
  ) async {
    final incomes = await getExpensesByMonth(userId, month);

    return incomes.fold<double>(
      0.0,
      (sum, income) => sum + income.amount,
    );
  }
}
