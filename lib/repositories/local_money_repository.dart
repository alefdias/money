import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/fixed_expense.dart';
import '../models/debt.dart';
import '../models/financial_goal.dart';
import '../models/user_profile.dart';
import '../models/family.dart';
import 'money_repository.dart';

class LocalMoneyRepository implements MoneyRepository {
  static const String defaultFamilyId = 'family_demo_1';
  final _uuid = const Uuid();

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
    final now = DateTime.now();

    // 1. Família inicial
    _family = Family(
      id: defaultFamilyId,
      name: 'Nossa Família',
      inviteCode: 'MONEY-7890',
      memberIds: ['user_1', 'user_2'],
      createdAt: now.subtract(const Duration(days: 60)),
    );

    // 2. Dois usuários iniciais
    _members.clear();
    _members.addAll([
      const UserProfile(
        id: 'user_1',
        name: 'Você',
        email: 'voce@money.app',
        avatarEmoji: '🧑‍💻',
        familyId: defaultFamilyId,
      ),
      const UserProfile(
        id: 'user_2',
        name: 'Amor',
        email: 'amor@money.app',
        avatarEmoji: '👩‍🎨',
        familyId: defaultFamilyId,
      ),
    ]);

    // 3. Rendas iniciais (conforme especificação: R$ 4.000 + R$ 2.500 = R$ 6.500)
    _incomes.clear();
    _incomes.addAll([
      Income(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_1',
        userName: 'Você',
        title: 'Salário Principal',
        amount: 4000.0,
        category: 'Salário',
        date: DateTime(now.year, now.month, 5),
      ),
      Income(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_2',
        userName: 'Amor',
        title: 'Salário Parceiro(a)',
        amount: 2500.0,
        category: 'Salário',
        date: DateTime(now.year, now.month, 5),
      ),
    ]);

    // 4. Contas Fixas (R$ 2.800)
    _fixedExpenses.clear();
    _fixedExpenses.addAll([
      FixedExpense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        name: 'Aluguel do Apartamento',
        amount: 1600.0,
        dueDay: 10,
        isPaid: true,
        responsibleUserId: 'user_1',
        category: 'Moradia',
      ),
      FixedExpense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        name: 'Energia Elétrica',
        amount: 280.0,
        dueDay: 15,
        isPaid: false,
        responsibleUserId: 'user_2',
        category: 'Contas',
      ),
      FixedExpense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        name: 'Internet Fibra',
        amount: 130.0,
        dueDay: 12,
        isPaid: true,
        category: 'Assinaturas',
      ),
      FixedExpense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        name: 'Condomínio',
        amount: 420.0,
        dueDay: 8,
        isPaid: true,
        category: 'Moradia',
      ),
      FixedExpense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        name: 'Streamings (Netflix & Spotify)',
        amount: 90.0,
        dueDay: 20,
        isPaid: false,
        category: 'Assinaturas',
      ),
      FixedExpense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        name: 'Plano de Saúde',
        amount: 280.0,
        dueDay: 25,
        isPaid: false,
        category: 'Saúde',
      ),
    ]);

    // 5. Dívidas / Parcelamentos (R$ 700: Notebook R$ 250 + Reforma R$ 450)
    _debts.clear();
    _debts.addAll([
      Debt(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        title: 'Notebook Trabalho',
        installmentAmount: 250.0,
        totalInstallments: 10,
        paidInstallments: 3,
        dueDay: 10,
      ),
      Debt(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        title: 'Reforma da Sala',
        installmentAmount: 450.0,
        totalInstallments: 6,
        paidInstallments: 4,
        dueDay: 15,
      ),
    ]);

    // 6. Meta de Economia (R$ 1.000 para guardar)
    _goal = const FinancialGoal(
      id: 'goal_1',
      familyId: defaultFamilyId,
      title: 'Reserva de Emergência & Sonhos',
      monthlyTarget: 1000.0,
      currentSaved: 4800.0,
    );

    // 7. Gastos recentes de exemplo (incluindo compras de hoje)
    _expenses.clear();
    _expenses.addAll([
      // Gastos de hoje
      Expense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_1',
        userName: 'Você',
        description: 'Mercado Semanal',
        amount: 87.50,
        categoryId: 'food',
        date: now,
        paymentMethod: 'Pix',
      ),
      Expense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_2',
        userName: 'Amor',
        description: 'Farmácia & Vitaminas',
        amount: 32.00,
        categoryId: 'health',
        date: now,
        paymentMethod: 'Cartão de Débito',
      ),
      // Gastos recentes nos últimos dias
      Expense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_1',
        userName: 'Você',
        description: 'Posto de Combustível',
        amount: 100.00,
        categoryId: 'fuel',
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'Pix',
      ),
      Expense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_2',
        userName: 'Amor',
        description: 'Padaria & Lanche',
        amount: 45.00,
        categoryId: 'food',
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Pix',
      ),
      Expense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_1',
        userName: 'Você',
        description: 'Almoço Restaurante',
        amount: 78.00,
        categoryId: 'food',
        date: now.subtract(const Duration(days: 3)),
        paymentMethod: 'Cartão de Crédito',
      ),
      Expense(
        id: _uuid.v4(),
        familyId: defaultFamilyId,
        userId: 'user_2',
        userName: 'Amor',
        description: 'Ração e Petiscos Pet',
        amount: 95.00,
        categoryId: 'pets',
        date: now.subtract(const Duration(days: 4)),
        paymentMethod: 'Pix',
      ),
    ]);

    _notifyAll();
  }

  void _notifyAll() {
    _expensesStreamController.add(List.unmodifiable(_expenses));
    _incomesStreamController.add(List.unmodifiable(_incomes));
    _fixedExpensesStreamController.add(List.unmodifiable(_fixedExpenses));
    _debtsStreamController.add(List.unmodifiable(_debts));
    _goalStreamController.add(_goal);
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
    }
  }

  @override
  Future<List<Expense>> getExpenses(String familyId) async => List.unmodifiable(_expenses);

  @override
  Stream<List<Expense>> watchExpenses(String familyId) => _expensesStreamController.stream;

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    _expensesStreamController.add(List.unmodifiable(_expenses));
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    _expenses.removeWhere((e) => e.id == expenseId);
    _expensesStreamController.add(List.unmodifiable(_expenses));
  }

  @override
  Future<List<Income>> getIncomes(String familyId) async => List.unmodifiable(_incomes);

  @override
  Stream<List<Income>> watchIncomes(String familyId) => _incomesStreamController.stream;

  @override
  Future<void> addIncome(Income income) async {
    _incomes.add(income);
    _incomesStreamController.add(List.unmodifiable(_incomes));
  }

  @override
  Future<void> deleteIncome(String incomeId) async {
    _incomes.removeWhere((i) => i.id == incomeId);
    _incomesStreamController.add(List.unmodifiable(_incomes));
  }

  @override
  Future<List<FixedExpense>> getFixedExpenses(String familyId) async => List.unmodifiable(_fixedExpenses);

  @override
  Stream<List<FixedExpense>> watchFixedExpenses(String familyId) => _fixedExpensesStreamController.stream;

  @override
  Future<void> addFixedExpense(FixedExpense fixedExpense) async {
    _fixedExpenses.add(fixedExpense);
    _fixedExpensesStreamController.add(List.unmodifiable(_fixedExpenses));
  }

  @override
  Future<void> updateFixedExpense(FixedExpense fixedExpense) async {
    final idx = _fixedExpenses.indexWhere((f) => f.id == fixedExpense.id);
    if (idx != -1) {
      _fixedExpenses[idx] = fixedExpense;
      _fixedExpensesStreamController.add(List.unmodifiable(_fixedExpenses));
    }
  }

  @override
  Future<void> deleteFixedExpense(String id) async {
    _fixedExpenses.removeWhere((f) => f.id == id);
    _fixedExpensesStreamController.add(List.unmodifiable(_fixedExpenses));
  }

  @override
  Future<List<Debt>> getDebts(String familyId) async => List.unmodifiable(_debts);

  @override
  Stream<List<Debt>> watchDebts(String familyId) => _debtsStreamController.stream;

  @override
  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    _debtsStreamController.add(List.unmodifiable(_debts));
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    final idx = _debts.indexWhere((d) => d.id == debt.id);
    if (idx != -1) {
      _debts[idx] = debt;
      _debtsStreamController.add(List.unmodifiable(_debts));
    }
  }

  @override
  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
    _debtsStreamController.add(List.unmodifiable(_debts));
  }

  @override
  Future<FinancialGoal?> getGoal(String familyId) async => _goal;

  @override
  Stream<FinancialGoal?> watchGoal(String familyId) => _goalStreamController.stream;

  @override
  Future<void> saveGoal(FinancialGoal goal) async {
    _goal = goal;
    _goalStreamController.add(_goal);
  }
}
