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
  String? _activeFamilyId;

  void setActiveFamily(String familyId) {
    _activeFamilyId = familyId;
  }

  @override
  Future<void> init() async {}

  @override
  Future<Family?> getFamily(String familyId) async {
    final doc = await _firestore.collection('families').doc(familyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Family.fromMap(doc.data()!, id: doc.id);
  }

  // Cria ou busca família do usuário no primeiro login
  Future<Family> getOrCreateUserFamily({
    required String userId,
    required String userName,
    required String email,
    String? inviteCodeToJoin,
  }) async {
    // 1. Verifica se usuário já tem familyId vinculado
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      final existingFamilyId = userDoc.data()!['familyId'];
      if (existingFamilyId != null) {
        final fam = await getFamily(existingFamilyId);
        if (fam != null) return fam;
      }
    }

    // 2. Se informou código de convite para entrar na família do parceiro
    if (inviteCodeToJoin != null && inviteCodeToJoin.trim().isNotEmpty) {
      final query = await _firestore
          .collection('families')
          .where('inviteCode', isEqualTo: inviteCodeToJoin.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final famDoc = query.docs.first;
        final family = Family.fromMap(famDoc.data(), id: famDoc.id);
        
        // Adiciona usuário como membro
        if (!family.memberIds.contains(userId)) {
          final updatedMembers = [...family.memberIds, userId];
          await _firestore.collection('families').doc(family.id).update({
            'memberIds': updatedMembers,
          });
        }

        // Salva perfil do usuário
        await _firestore.collection('users').doc(userId).set({
          'id': userId,
          'name': userName,
          'email': email,
          'avatarEmoji': '👤',
          'familyId': family.id,
        }, SetOptions(merge: true));

        _activeFamilyId = family.id;
        return family;
      }
    }

    // 3. Cria uma nova família para o usuário
    final newFamilyRef = _firestore.collection('families').doc();
    final inviteCode = 'MONEY-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    final newFamily = Family(
      id: newFamilyRef.id,
      name: 'Família de $userName',
      inviteCode: inviteCode,
      memberIds: [userId],
      createdAt: DateTime.now(),
    );

    await newFamilyRef.set(newFamily.toMap());

    // Salva perfil do usuário
    await _firestore.collection('users').doc(userId).set({
      'id': userId,
      'name': userName,
      'email': email,
      'avatarEmoji': '👤',
      'familyId': newFamilyRef.id,
    }, SetOptions(merge: true));

    _activeFamilyId = newFamilyRef.id;
    return newFamily;
  }

  @override
  Future<List<UserProfile>> getFamilyMembers(String familyId) async {
    _activeFamilyId = familyId;
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
    if (_activeFamilyId != null) {
      await _firestore
          .collection('families')
          .doc(_activeFamilyId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
      return;
    }
    final query = await _firestore
        .collectionGroup('expenses')
        .where('id', isEqualTo: expenseId)
        .limit(1)
        .get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<Income>> getIncomes(String familyId) async {
    _activeFamilyId = familyId;
    final query = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('incomes')
        .get();
    return query.docs.map((d) => Income.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Income>> watchIncomes(String familyId) {
    _activeFamilyId = familyId;
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
  Future<void> deleteIncome(String incomeId) async {
    if (_activeFamilyId != null) {
      await _firestore
          .collection('families')
          .doc(_activeFamilyId)
          .collection('incomes')
          .doc(incomeId)
          .delete();
      return;
    }
    final query = await _firestore
        .collectionGroup('incomes')
        .where('id', isEqualTo: incomeId)
        .limit(1)
        .get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

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
  Future<void> deleteFixedExpense(String id) async {
    if (_activeFamilyId != null) {
      await _firestore
          .collection('families')
          .doc(_activeFamilyId)
          .collection('fixed_expenses')
          .doc(id)
          .delete();
      return;
    }
    final query = await _firestore
        .collectionGroup('fixed_expenses')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<Debt>> getDebts(String familyId) async {
    _activeFamilyId = familyId;
    final query = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('debts')
        .get();
    return query.docs.map((d) => Debt.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Debt>> watchDebts(String familyId) {
    _activeFamilyId = familyId;
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
  Future<void> deleteDebt(String id) async {
    if (_activeFamilyId != null) {
      await _firestore
          .collection('families')
          .doc(_activeFamilyId)
          .collection('debts')
          .doc(id)
          .delete();
      return;
    }
    final query = await _firestore
        .collectionGroup('debts')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

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
