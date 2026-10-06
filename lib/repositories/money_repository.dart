import '../models/expense.dart';
import '../models/income.dart';
import '../models/fixed_expense.dart';
import '../models/debt.dart';
import '../models/financial_goal.dart';
import '../models/user_profile.dart';
import '../models/family.dart';

abstract class MoneyRepository {
  Future<void> init();

  // Membros e Família
  Future<Family?> getFamily(String familyId);
  Future<List<UserProfile>> getFamilyMembers(String familyId);
  Future<void> updateMember(UserProfile user);

  // Gastos
  Future<List<Expense>> getExpenses(String familyId);
  Stream<List<Expense>> watchExpenses(String familyId);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);

  // Rendas
  Future<List<Income>> getIncomes(String familyId);
  Stream<List<Income>> watchIncomes(String familyId);
  Future<void> addIncome(Income income);
  Future<void> deleteIncome(String incomeId);

  // Contas Fixas
  Future<List<FixedExpense>> getFixedExpenses(String familyId);
  Stream<List<FixedExpense>> watchFixedExpenses(String familyId);
  Future<void> addFixedExpense(FixedExpense fixedExpense);
  Future<void> updateFixedExpense(FixedExpense fixedExpense);
  Future<void> deleteFixedExpense(String id);

  // Dívidas
  Future<List<Debt>> getDebts(String familyId);
  Stream<List<Debt>> watchDebts(String familyId);
  Future<void> addDebt(Debt debt);
  Future<void> updateDebt(Debt debt);
  Future<void> deleteDebt(String id);

  // Meta de Economia
  Future<FinancialGoal?> getGoal(String familyId);
  Stream<FinancialGoal?> watchGoal(String familyId);
  Future<void> saveGoal(FinancialGoal goal);
}
