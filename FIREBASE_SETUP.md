# Configuração do Firebase no Money

O aplicativo **Money** foi projetado para utilizar o **Firebase** como backend em tempo real para sincronizar os dados financeiros entre as duas pessoas do casal.

---

## 1. Passo a Passo de Inicialização

1. **Instale a CLI do Firebase e FlutterFire (caso ainda não tenha):**
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```

2. **Vincule o projeto Flutter ao seu Firebase:**
   No diretório do projeto (`/home/alef/Documentos/Money`), execute:
   ```bash
   flutterfire configure
   ```
   - Selecione ou crie seu projeto Firebase.
   - Escolha as plataformas desejadas (Android, iOS, Web).
   - O comando irá gerar automaticamente o arquivo `lib/firebase_options.dart` e adicionar o `google-services.json` no Android.

3. **Deploy das Regras de Segurança (Firestore Rules):**
   As regras já estão criadas no arquivo [firestore.rules](file:///home/alef/Documentos/Money/firestore.rules).
   Para publicá-las:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## 2. Estrutura de Coleções no Cloud Firestore

```text
users/
  {userId}/
    name: string
    email: string
    avatarEmoji: string
    familyId: string

families/
  {familyId}/
    name: string
    inviteCode: string
    memberIds: [userId1, userId2]
    createdAt: timestamp

    expenses/
      {expenseId}/
        description: string
        amount: number
        categoryId: string
        userId: string
        userName: string
        date: timestamp
        paymentMethod: string

    incomes/
      {incomeId}/
        title: string
        amount: number
        userId: string
        userName: string
        date: timestamp

    fixed_expenses/
      {fixedExpenseId}/
        name: string
        amount: number
        dueDay: number
        isPaid: boolean

    debts/
      {debtId}/
        title: string
        installmentAmount: number
        totalInstallments: number
        paidInstallments: number
        dueDay: number

    goals/
      main_goal/
        title: string
        monthlyTarget: number
        currentSaved: number
```

---

## 3. Modo Offline / Demonstração
O aplicativo possui o repositório `LocalMoneyRepository`, que vem pré-configurado com os valores da especificação (R$ 6.500 de renda conjunta, R$ 2.800 de contas, R$ 700 de dívidas, R$ 1.000 de meta de reserva e R$ 2.000 livres).

Assim, você pode rodar e testar o app imediatamente sem travar ou depender do Firebase estar previamente cadastrado!
