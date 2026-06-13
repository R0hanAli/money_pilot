import '../entities/income_entity.dart';

abstract class IncomeRepository {
  Future<List<IncomeEntity>> getIncome(String userId);
  Future<List<IncomeEntity>> getIncomeByMonth(String userId, String month);
  Future<void> addIncome(IncomeEntity income);
  Future<void> updateIncome(IncomeEntity income);
  Future<void> deleteIncome(String id);
  Future<double> getTotalIncomeForMonth(String userId, String month);
}
