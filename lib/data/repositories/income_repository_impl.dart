import '../../core/services/connectivity_service.dart';
import '../../domain/entities/income_entity.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../datasources/local_database.dart';
import '../models/income_model.dart';
import '../models/sync_queue_model.dart';

extension IncomeModelX on IncomeModel {
  IncomeEntity toEntity() {
    return IncomeEntity(
      id: id,
      userId: userId,
      amount: amount,
      source: source,
      notes: notes,
      transactionDate: transactionDate,
      createdAt: createdAt,
    );
  }
}

extension IncomeEntityX on IncomeEntity {
  IncomeModel toModel() {
    return IncomeModel(
      id: id,
      userId: userId,
      amount: amount,
      source: source,
      notes: notes,
      transactionDate: transactionDate,
      createdAt: createdAt,
    );
  }
}

class IncomeRepositoryImpl implements IncomeRepository {
  final LocalDatabase _localDatabase;
  final FirestoreDataSource _firestoreDataSource;
  final ConnectivityService _connectivityService;

  IncomeRepositoryImpl({
    required LocalDatabase localDatabase,
    required FirestoreDataSource firestoreDataSource,
    required ConnectivityService connectivityService,
  })  : _localDatabase = localDatabase,
        _firestoreDataSource = firestoreDataSource,
        _connectivityService = connectivityService;

  @override
  Future<void> addIncome(IncomeEntity income) async {
    final model = income.toModel();
    await _localDatabase.insertIncome(model);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.saveIncome(model);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.create,
          entityType: EntityType.income,
          payload: model.toMap(),
          entityId: model.id,
        ),
      );
    }
  }

  @override
  Future<void> updateIncome(IncomeEntity income) async {
    final model = income.toModel();
    await _localDatabase.updateIncome(model);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.updateIncome(model);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.update,
          entityType: EntityType.income,
          payload: model.toMap(),
          entityId: model.id,
        ),
      );
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    await _localDatabase.deleteIncome(id);
    if (_connectivityService.isConnected.value) {
      await _firestoreDataSource.deleteIncome(id);
    } else {
      await _localDatabase.insertSyncItem(
        SyncQueueModel.create(
          action: SyncAction.delete,
          entityType: EntityType.income,
          payload: {'id': id},
          entityId: id,
        ),
      );
    }
  }

  @override
  Future<List<IncomeEntity>> getIncome(String userId) async {
    final models = await _localDatabase.getIncomeByUser(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<IncomeEntity>> getIncomeByMonth(
      String userId, String month) async {
    final models = await _localDatabase.getIncomeByMonth(userId, month);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<double> getTotalIncomeForMonth(
    String userId,
    String month,
  ) async {
    final incomes = await getIncomeByMonth(userId, month);

    return incomes.fold<double>(
      0.0,
      (sum, income) => sum + income.amount,
    );
  }
}
