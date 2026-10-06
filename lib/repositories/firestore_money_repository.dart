import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/fixed_expense.dart';
import '../models/debt.dart';
import '../models/financial_goal.dart';
import '../models/user_profile.dart';
import '../models/family.dart';
import 'money_repository.dart';

class FirestoreMoneyRepository implements MoneyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> init() async {}

  @override
  Future<Family?> getFamily(String familyId) async {
    final doc = await _firestore.collection('families').doc(familyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Family.fromMap(doc.data()!, id: doc.id);
  }

  @override
  Future<List<UserProfile>> getFamilyMembers(String familyId) async {
    final query = await _firestore
        .collection('users')
        .where('familyId', isEqualTo: familyId)
        .get();
    return query.docs.map((d) => UserProfile.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Future<void> updateMember(UserProfile user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<Expense>> getExpenses(String familyId) async {
    final query = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();
    return query.docs.map((d) => Expense.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Expense>> watchExpenses(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => Expense.fromMap(d.data(), id: d.id)).toList());
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _firestore
        .collection('families')
        .doc(expense.familyId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    // Busca e deleta através de collectionGroup ou caminho da família
    // Na prática a ID é deletada na subcoleção
  }

  @override
  Future<List<Income>> getIncomes(String familyId) async {
    final query = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('incomes')
        .get();
    return query.docs.map((d) => Income.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Income>> watchIncomes(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('incomes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => Income.fromMap(d.data(), id: d.id)).toList());
  }

  @override
  Future<void> addIncome(Income income) async {
    await _firestore
        .collection('families')
        .doc(income.familyId)
        .collection('incomes')
        .doc(income.id)
        .set(income.toMap());
  }

  @override
  Future<void> deleteIncome(String incomeId) async {}

  @override
  Future<List<FixedExpense>> getFixedExpenses(String familyId) async {
    final query = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('fixed_expenses')
        .get();
    return query.docs.map((d) => FixedExpense.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<FixedExpense>> watchFixedExpenses(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('fixed_expenses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => FixedExpense.fromMap(d.data(), id: d.id)).toList());
  }

  @override
  Future<void> addFixedExpense(FixedExpense fixedExpense) async {
    await _firestore
        .collection('families')
        .doc(fixedExpense.familyId)
        .collection('fixed_expenses')
        .doc(fixedExpense.id)
        .set(fixedExpense.toMap());
  }

  @override
  Future<void> updateFixedExpense(FixedExpense fixedExpense) async {
    await _firestore
        .collection('families')
        .doc(fixedExpense.familyId)
        .collection('fixed_expenses')
        .doc(fixedExpense.id)
        .set(fixedExpense.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteFixedExpense(String id) async {}

  @override
  Future<List<Debt>> getDebts(String familyId) async {
    final query = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('debts')
        .get();
    return query.docs.map((d) => Debt.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Debt>> watchDebts(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('debts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => Debt.fromMap(d.data(), id: d.id)).toList());
  }

  @override
  Future<void> addDebt(Debt debt) async {
    await _firestore
        .collection('families')
        .doc(debt.familyId)
        .collection('debts')
        .doc(debt.id)
        .set(debt.toMap());
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    await _firestore
        .collection('families')
        .doc(debt.familyId)
        .collection('debts')
        .doc(debt.id)
        .set(debt.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteDebt(String id) async {}

  @override
  Future<FinancialGoal?> getGoal(String familyId) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('goals')
        .doc('main_goal')
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return FinancialGoal.fromMap(doc.data()!, id: doc.id);
  }

  @override
  Stream<FinancialGoal?> watchGoal(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('goals')
        .doc('main_goal')
        .snapshots()
        .map((doc) => doc.exists && doc.data() != null
            ? FinancialGoal.fromMap(doc.data()!, id: doc.id)
            : null);
  }

  @override
  Future<void> saveGoal(FinancialGoal goal) async {
    await _firestore
        .collection('families')
        .doc(goal.familyId)
        .collection('goals')
        .doc('main_goal')
        .set(goal.toMap(), SetOptions(merge: true));
  }
}
