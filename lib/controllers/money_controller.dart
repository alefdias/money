import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/fixed_expense.dart';
import '../models/debt.dart';
import '../models/financial_goal.dart';
import '../models/user_profile.dart';
import '../models/family.dart';
import '../models/budget_summary.dart';
import '../core/engine/money_calculator.dart';
import '../repositories/money_repository.dart';
import '../repositories/local_money_repository.dart';
import '../repositories/firestore_money_repository.dart';
import '../services/gemini_service.dart';

class MoneyController extends ChangeNotifier {
  MoneyRepository _repository;
  final GeminiService _geminiService = GeminiService();
  final _uuid = const Uuid();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Family? _family;
  Family? get family => _family;

  List<UserProfile> _members = [];
  List<UserProfile> get members => _members;

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  List<Income> _incomes = [];
  List<Income> get incomes => _incomes;

  List<FixedExpense> _fixedExpenses = [];
  List<FixedExpense> get fixedExpenses => _fixedExpenses;

  List<Debt> _debts = [];
  List<Debt> get debts => _debts;

  FinancialGoal? _goal;
  FinancialGoal? get goal => _goal;

  final List<GeminiMessage> _chatMessages = [];
  List<GeminiMessage> get chatMessages => List.unmodifiable(_chatMessages);
  bool _isGeminiThinking = false;
  bool get isGeminiThinking => _isGeminiThinking;

  MoneyController({MoneyRepository? repository})
      : _repository = repository ?? LocalMoneyRepository();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _repository.init();

    final familyId = LocalMoneyRepository.defaultFamilyId;
    _family = await _repository.getFamily(familyId);
    _members = await _repository.getFamilyMembers(familyId);
    if (_members.isNotEmpty) {
      _currentUser = _members.first;
    }

    _expenses = await _repository.getExpenses(familyId);
    _incomes = await _repository.getIncomes(familyId);
    _fixedExpenses = await _repository.getFixedExpenses(familyId);
    _debts = await _repository.getDebts(familyId);
    _goal = await _repository.getGoal(familyId);

    _chatMessages.clear();
    _chatMessages.add(
      GeminiMessage(
        text: 'Olá! Sou seu assistente financeiro do Money. Como posso ajudar com suas contas hoje?',
        isUser: false,
      ),
    );

    _subscribeToStreams(familyId);

    _isLoading = false;
    notifyListeners();
  }

  // Inicialização 100% real conectada à conta Firebase do usuário
  Future<void> initWithFirebaseUser(User user, {String? inviteCode}) async {
    _isLoading = true;
    notifyListeners();

    final firestoreRepo = FirestoreMoneyRepository();
    _repository = firestoreRepo;

    final realFamily = await firestoreRepo.getOrCreateUserFamily(
      userId: user.uid,
      userName: user.displayName ?? (user.email?.split('@').first ?? 'Usuário'),
      email: user.email ?? '',
      inviteCodeToJoin: inviteCode,
    );

    _family = realFamily;
    _currentUser = UserProfile(
      id: user.uid,
      name: user.displayName ?? (user.email?.split('@').first ?? 'Usuário'),
      email: user.email ?? '',
      avatarEmoji: '👤',
      familyId: realFamily.id,
    );

    _members = await _repository.getFamilyMembers(realFamily.id);
    if (_members.isEmpty) {
      _members = [_currentUser!];
    }

    _expenses = await _repository.getExpenses(realFamily.id);
    _incomes = await _repository.getIncomes(realFamily.id);
    _fixedExpenses = await _repository.getFixedExpenses(realFamily.id);
    _debts = await _repository.getDebts(realFamily.id);
    _goal = await _repository.getGoal(realFamily.id);

    _subscribeToStreams(realFamily.id);

    _isLoading = false;
    notifyListeners();
  }

  void _subscribeToStreams(String familyId) {
    _repository.watchExpenses(familyId).listen((data) {
      _expenses = data;
      notifyListeners();
    });

    _repository.watchIncomes(familyId).listen((data) {
      _incomes = data;
      notifyListeners();
    });

    _repository.watchFixedExpenses(familyId).listen((data) {
      _fixedExpenses = data;
      notifyListeners();
    });

    _repository.watchDebts(familyId).listen((data) {
      _debts = data;
      notifyListeners();
    });

    _repository.watchGoal(familyId).listen((data) {
      _goal = data;
      notifyListeners();
    });
  }

  UserProfile get user1 => _members.isNotEmpty
      ? _members[0]
      : (_currentUser ?? const UserProfile(id: 'user_1', name: 'Você', email: '', avatarEmoji: '👤'));

  UserProfile get user2 => _members.length > 1
      ? _members[1]
      : const UserProfile(id: 'user_2', name: 'Parceiro(a)', email: '', avatarEmoji: '👥');

  BudgetSummary get summary {
    return MoneyCalculator.calculate(
      incomes: _incomes,
      fixedExpenses: _fixedExpenses,
      debts: _debts,
      goal: _goal,
      expenses: _expenses,
      user1: user1,
      user2: user2,
    );
  }

  String get quickInsight => _geminiService.generateQuickInsight(summary, _expenses);

  void switchActiveUser(String userId) {
    final found = _members.firstWhere((m) => m.id == userId, orElse: () => _currentUser!);
    _currentUser = found;
    notifyListeners();
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    required String categoryId,
    required String userId,
    required String paymentMethod,
    DateTime? date,
    String? notes,
    bool isInstallment = false,
    int installmentsCount = 1,
    int installmentNumber = 1,
    String? installmentGroupId,
    bool createAllInstallments = false,
  }) async {
    final member = _members.firstWhere((m) => m.id == userId, orElse: () => _currentUser!);
    final baseDate = date ?? DateTime.now();

    if (isInstallment && createAllInstallments && installmentsCount > 1) {
      final groupId = installmentGroupId ?? _uuid.v4();
      final installmentValue = amount / installmentsCount;

      for (int i = 1; i <= installmentsCount; i++) {
        final installmentDate = DateTime(baseDate.year, baseDate.month + (i - 1), baseDate.day);
        final expense = Expense(
          id: _uuid.v4(),
          familyId: _family?.id ?? 'family_real_1',
          userId: userId,
          userName: member.name,
          description: '$description ($i/${installmentsCount}x)',
          amount: double.parse(installmentValue.toStringAsFixed(2)),
          categoryId: categoryId,
          date: installmentDate,
          paymentMethod: paymentMethod,
          notes: notes,
          isInstallment: true,
          installmentsCount: installmentsCount,
          installmentNumber: i,
          installmentGroupId: groupId,
        );
        await _repository.addExpense(expense);
      }
    } else {
      final newExpense = Expense(
        id: _uuid.v4(),
        familyId: _family?.id ?? 'family_real_1',
        userId: userId,
        userName: member.name,
        description: isInstallment && installmentsCount > 1 && !description.contains('(')
            ? '$description ($installmentNumber/${installmentsCount}x)'
            : description,
        amount: amount,
        categoryId: categoryId,
        date: baseDate,
        paymentMethod: paymentMethod,
        notes: notes,
        isInstallment: isInstallment,
        installmentsCount: installmentsCount,
        installmentNumber: installmentNumber,
        installmentGroupId: installmentGroupId,
      );
      await _repository.addExpense(newExpense);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    await _repository.deleteExpense(expenseId);
  }

  Future<void> toggleFixedExpensePaid(String id) async {
    final item = _fixedExpenses.firstWhere((f) => f.id == id);
    final updated = item.copyWith(isPaid: !item.isPaid);
    await _repository.updateFixedExpense(updated);
  }

  Future<void> addFixedExpense({
    required String name,
    required double amount,
    required int dueDay,
    String? category,
    String? responsibleUserId,
  }) async {
    final item = FixedExpense(
      id: _uuid.v4(),
      familyId: _family?.id ?? 'family_real_1',
      name: name,
      amount: amount,
      dueDay: dueDay,
      category: category ?? 'Contas Fixas',
      responsibleUserId: responsibleUserId,
    );
    await _repository.addFixedExpense(item);
  }

  Future<void> addIncome({
    required String title,
    required double amount,
    required String userId,
    String? category,
  }) async {
    final member = _members.firstWhere((m) => m.id == userId, orElse: () => _currentUser!);
    final income = Income(
      id: _uuid.v4(),
      familyId: _family?.id ?? 'family_real_1',
      userId: userId,
      userName: member.name,
      title: title,
      amount: amount,
      category: category ?? 'Salário',
      date: DateTime.now(),
    );
    await _repository.addIncome(income);
  }

  Future<void> addDebt({
    required String title,
    required double installmentAmount,
    required int totalInstallments,
    required int paidInstallments,
    required int dueDay,
  }) async {
    final debt = Debt(
      id: _uuid.v4(),
      familyId: _family?.id ?? 'family_real_1',
      title: title,
      installmentAmount: installmentAmount,
      totalInstallments: totalInstallments,
      paidInstallments: paidInstallments,
      dueDay: dueDay,
    );
    await _repository.addDebt(debt);
  }

  Future<void> updateSavingsGoal(double newMonthlyTarget) async {
    final currentGoal = _goal ??
        FinancialGoal(
          id: 'goal_1',
          familyId: _family?.id ?? 'family_real_1',
          title: 'Reserva Familiar',
          monthlyTarget: newMonthlyTarget,
        );
    final updated = currentGoal.copyWith(monthlyTarget: newMonthlyTarget);
    await _repository.saveGoal(updated);
  }

  Future<void> askGemini(String question) async {
    if (question.trim().isEmpty) return;

    _chatMessages.add(GeminiMessage(text: question, isUser: true));
    _isGeminiThinking = true;
    notifyListeners();

    final answer = await _geminiService.askAssistant(
      question: question,
      summary: summary,
      expenses: _expenses,
    );

    _chatMessages.add(GeminiMessage(text: answer, isUser: false));
    _isGeminiThinking = false;
    notifyListeners();
  }
}
