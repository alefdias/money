import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/money_controller.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _hasBiometrics = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _familyCodeController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final hasPrev = await _authService.hasPreviousLogin();
    if (!hasPrev) return;

    final canBio = await _authService.canCheckBiometrics();
    if (mounted) {
      setState(() {
        _hasBiometrics = canBio;
      });
      // Se já logou antes e tem biometria, tenta autenticar
      if (_hasBiometrics) {
        _loginWithBiometrics();
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    final authenticated = await _authService.authenticateWithBiometrics();
    if (authenticated && mounted) {
      final user = _authService.currentUser;
      if (user != null) {
        await context.read<MoneyController>().initWithFirebaseUser(user);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _familyCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        final cred = await _authService.registerWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );
        if (cred.user != null && mounted) {
          await cred.user!.updateDisplayName(_nameController.text.trim());
          if (!mounted) return;
          await context.read<MoneyController>().initWithFirebaseUser(
                cred.user!,
                inviteCode: _familyCodeController.text.trim(),
              );
        }
      } else {
        final cred = await _authService.signInWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );
        if (cred.user != null && mounted) {
          await context.read<MoneyController>().initWithFirebaseUser(cred.user!);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha na autenticação: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}'),
          backgroundColor: AppColors.overLimit,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isLoading = true);

    try {
      final cred = await _authService.signInWithGoogle();
      if (cred != null && cred.user != null && mounted) {
        await context.read<MoneyController>().initWithFirebaseUser(
              cred.user!,
              inviteCode: _familyCodeController.text.trim().isNotEmpty
                  ? _familyCodeController.text.trim()
                  : null,
            );

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no login com Google: $e'),
          backgroundColor: AppColors.overLimit,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo 3D Oficial do Money
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('💵', style: TextStyle(fontSize: 48)),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Título & Subtítulo
                  const Text(
                    'Money',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Controle financeiro familiar e compartilhado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Alternador Entrar / Criar Conta
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSignUp = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isSignUp ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Entrar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: !_isSignUp ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSignUp = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isSignUp ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isSignUp
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Criar Conta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _isSignUp ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botão "Continuar com o Google"
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleAuth,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4285F4),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continuar com o Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Divisor
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ou use seu e-mail',
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Campo Nome (Apenas no Cadastro)
                  if (_isSignUp) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Seu Nome',
                        hintText: 'Ex: Alef',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (val) {
                        if (_isSignUp && (val == null || val.trim().isEmpty)) {
                          return 'Informe seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo Email (Placeholder gmail)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'seuemail@gmail.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Informe seu e-mail';
                      }
                      if (!val.contains('@')) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: 'Sua senha segura',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  // Campo Código do Parceiro (Opcional no Cadastro)
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _familyCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código do Parceiro (Opcional)',
                        hintText: 'Ex: MONEY-7890',
                        prefixIcon: Icon(Icons.group_add_outlined),
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Botão Principal
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailAuth,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Cadastrar Conta' : 'Entrar com E-mail'),
                  ),

                  // Botão Biometria / Impressão Digital (se já logou antes)
                  if (_hasBiometrics && !_isSignUp) ...[
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: _loginWithBiometrics,
                      icon: const Icon(Icons.fingerprint_rounded, size: 24, color: AppColors.primary),
                      label: const Text(
                        'Entrar com Impressão Digital',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
