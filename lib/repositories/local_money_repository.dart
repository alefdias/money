import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/fixed_expense.dart';
import '../models/debt.dart';
import '../models/financial_goal.dart';
import '../models/user_profile.dart';
import '../models/family.dart';
import 'money_repository.dart';

class LocalMoneyRepository implements MoneyRepository {
  static const String defaultFamilyId = 'family_real_1';

  late Family _family;
  final List<UserProfile> _members = [];
  final List<Expense> _expenses = [];
  final List<Income> _incomes = [];
  final List<FixedExpense> _fixedExpenses = [];
  final List<Debt> _debts = [];
  FinancialGoal? _goal;

  final _expensesStreamController = StreamController<List<Expense>>.broadcast();
  final _incomesStreamController = StreamController<List<Income>>.broadcast();
  final _fixedExpensesStreamController = StreamController<List<FixedExpense>>.broadcast();
  final _debtsStreamController = StreamController<List<Debt>>.broadcast();
  final _goalStreamController = StreamController<FinancialGoal?>.broadcast();

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Família real
    final familyJson = prefs.getString('money_family');
    if (familyJson != null) {
      _family = Family.fromMap(jsonDecode(familyJson));
    } else {
      _family = Family(
        id: defaultFamilyId,
        name: 'Nossa Família',
        inviteCode: 'MONEY-${DateTime.now().millisecond + 1000}',
        memberIds: ['user_1'],
        createdAt: DateTime.now(),
      );
      await prefs.setString('money_family', jsonEncode(_family.toMap()));
    }

    // 2. Membros reais
    final membersJson = prefs.getStringList('money_members');
    _members.clear();
    if (membersJson != null && membersJson.isNotEmpty) {
      for (final m in membersJson) {
        _members.add(UserProfile.fromMap(jsonDecode(m)));
      }
    } else {
      _members.add(
        const UserProfile(
          id: 'user_1',
          name: 'Você',
          email: '',
          avatarEmoji: '👤',
          familyId: defaultFamilyId,
        ),
      );
    }

    // 3. Rendas reais (inicia vazio, sem dados falsos)
    final incomesJson = prefs.getStringList('money_incomes');
    _incomes.clear();
    if (incomesJson != null) {
      for (final i in incomesJson) {
        _incomes.add(Income.fromMap(jsonDecode(i)));
      }
    }

    // 4. Contas Fixas reais (inicia vazio, sem dados falsos)
    final fixedJson = prefs.getStringList('money_fixed_expenses');
    _fixedExpenses.clear();
    if (fixedJson != null) {
      for (final f in fixedJson) {
        _fixedExpenses.add(FixedExpense.fromMap(jsonDecode(f)));
      }
    }

    // 5. Dívidas reais (inicia vazio, sem dados falsos)
    final debtsJson = prefs.getStringList('money_debts');
    _debts.clear();
    if (debtsJson != null) {
      for (final d in debtsJson) {
        _debts.add(Debt.fromMap(jsonDecode(d)));
      }
    }

    // 6. Meta real
    final goalJson = prefs.getString('money_goal');
    if (goalJson != null) {
      _goal = FinancialGoal.fromMap(jsonDecode(goalJson));
    } else {
      _goal = null; // Zero fake data
    }

    // 7. Gastos reais (inicia vazio, sem dados falsos)
    final expensesJson = prefs.getStringList('money_expenses');
    _expenses.clear();
    if (expensesJson != null) {
      for (final e in expensesJson) {
        _expenses.add(Expense.fromMap(jsonDecode(e)));
      }
    }

    _notifyAll();
  }

  void _notifyAll() {
    _expensesStreamController.add(List.unmodifiable(_expenses));
    _incomesStreamController.add(List.unmodifiable(_incomes));
    _fixedExpensesStreamController.add(List.unmodifiable(_fixedExpenses));
    _debtsStreamController.add(List.unmodifiable(_debts));
    _goalStreamController.add(_goal);
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _expenses.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('money_expenses', list);
    _expensesStreamController.add(List.unmodifiable(_expenses));
  }

  Future<void> _saveIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _incomes.map((i) => jsonEncode(i.toMap())).toList();
    await prefs.setStringList('money_incomes', list);
    _incomesStreamController.add(List.unmodifiable(_incomes));
  }

  Future<void> _saveFixedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _fixedExpenses.map((f) => jsonEncode(f.toMap())).toList();
    await prefs.setStringList('money_fixed_expenses', list);
    _fixedExpensesStreamController.add(List.unmodifiable(_fixedExpenses));
  }

  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _debts.map((d) => jsonEncode(d.toMap())).toList();
    await prefs.setStringList('money_debts', list);
    _debtsStreamController.add(List.unmodifiable(_debts));
  }

  @override
  Future<Family?> getFamily(String familyId) async => _family;

  @override
  Future<List<UserProfile>> getFamilyMembers(String familyId) async => List.unmodifiable(_members);

  @override
  Future<void> updateMember(UserProfile user) async {
    final idx = _members.indexWhere((m) => m.id == user.id);
    if (idx != -1) {
      _members[idx] = user;
    } else {
      _members.add(user);
    }
    final prefs = await SharedPreferences.getInstance();
    final list = _members.map((m) => jsonEncode(m.toMap())).toList();
    await prefs.setStringList('money_members', list);
  }

  @override
  Future<List<Expense>> getExpenses(String familyId) async => List.unmodifiable(_expenses);

  @override
  Stream<List<Expense>> watchExpenses(String familyId) => _expensesStreamController.stream;

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    await _saveExpenses();
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    _expenses.removeWhere((e) => e.id == expenseId);
    await _saveExpenses();
  }

  @override
  Future<List<Income>> getIncomes(String familyId) async => List.unmodifiable(_incomes);

  @override
  Stream<List<Income>> watchIncomes(String familyId) => _incomesStreamController.stream;

  @override
  Future<void> addIncome(Income income) async {
    _incomes.add(income);
    await _saveIncomes();
  }

  @override
  Future<void> deleteIncome(String incomeId) async {
    _incomes.removeWhere((i) => i.id == incomeId);
    await _saveIncomes();
  }

  @override
  Future<List<FixedExpense>> getFixedExpenses(String familyId) async => List.unmodifiable(_fixedExpenses);

  @override
  Stream<List<FixedExpense>> watchFixedExpenses(String familyId) => _fixedExpensesStreamController.stream;

  @override
  Future<void> addFixedExpense(FixedExpense fixedExpense) async {
    _fixedExpenses.add(fixedExpense);
    await _saveFixedExpenses();
  }

  @override
  Future<void> updateFixedExpense(FixedExpense fixedExpense) async {
    final idx = _fixedExpenses.indexWhere((f) => f.id == fixedExpense.id);
    if (idx != -1) {
      _fixedExpenses[idx] = fixedExpense;
      await _saveFixedExpenses();
    }
  }

  @override
  Future<void> deleteFixedExpense(String id) async {
    _fixedExpenses.removeWhere((f) => f.id == id);
    await _saveFixedExpenses();
  }

  @override
  Future<List<Debt>> getDebts(String familyId) async => List.unmodifiable(_debts);

  @override
  Stream<List<Debt>> watchDebts(String familyId) => _debtsStreamController.stream;

  @override
  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    await _saveDebts();
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    final idx = _debts.indexWhere((d) => d.id == debt.id);
    if (idx != -1) {
      _debts[idx] = debt;
      await _saveDebts();
    }
  }

  @override
  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
    await _saveDebts();
  }

  @override
  Future<FinancialGoal?> getGoal(String familyId) async => _goal;

  @override
  Stream<FinancialGoal?> watchGoal(String familyId) => _goalStreamController.stream;

  @override
  Future<void> saveGoal(FinancialGoal goal) async {
    _goal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('money_goal', jsonEncode(goal.toMap()));
    _goalStreamController.add(_goal);
  }
}
