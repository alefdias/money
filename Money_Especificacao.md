# Money

## 1. Visão Geral

**Money** é um aplicativo de controle financeiro familiar desenvolvido em **Flutter + Dart**, inicialmente para uso de duas pessoas.

O objetivo principal não é apenas registrar gastos, mas responder de maneira simples:

> **Quanto ainda podemos gastar sem comprometer nossas contas e metas?**

O aplicativo registra receitas, despesas, contas fixas, dívidas e metas financeiras. Com essas informações, calcula automaticamente quanto dinheiro está disponível para gastar durante o mês e cria limites diários.

O **Gemini** será utilizado como assistente financeiro para transformar os dados calculados pelo sistema em análises e mensagens fáceis de entender.

---

## 2. Tecnologias

### Aplicativo
- Flutter
- Dart
- Android inicialmente
- Visual limpo, simples e moderno (Light Mode)

### Backend
**Firebase**, responsável por:
- Firebase Authentication (login e cadastro dos usuários);
- Cloud Firestore (banco de dados NoSQL em tempo real);
- Sincronização automática entre os dois celulares;
- Atualização em tempo real dos gastos e limites;
- Armazenamento das configurações e dados familiares.

### Banco de dados
Cloud Firestore (NoSQL, realtime).

### Inteligência Artificial
**Google Gemini API**

O Gemini será utilizado para:
- analisar os gastos;
- explicar a situação financeira;
- identificar padrões;
- gerar alertas inteligentes;
- responder perguntas sobre as finanças;
- gerar resumos financeiros.

> **Importante:** o Gemini não será responsável pelos cálculos financeiros principais. Saldo, limite diário, parcelas, orçamento disponível, porcentagens e projeções matemáticas serão calculados pelo próprio sistema.

---

## 3. Conceito de Família

O Money terá um **Grupo Familiar**, inicialmente composto por duas contas:

```text
Família
├── Usuário 1
└── Usuário 2
```

Cada pessoa terá seu próprio login, mas ambas participarão do mesmo orçamento familiar.

Cada gasto registrará quem realizou a compra.

Exemplo:

```text
Mercado
R$ 147,80

Categoria: Alimentação
Pago por: Usuário 1
Data: 05/10/2026
```

Os dados serão sincronizados entre os dois celulares.

---

## 4. Cadastro Inicial

Na primeira utilização, o aplicativo realizará uma configuração financeira.

### Rendas

Exemplo:

```text
Seu salário:       R$ 4.000
Salário parceiro:  R$ 2.500
Renda familiar:    R$ 6.500
```

Também será possível cadastrar:
- salário;
- renda extra;
- vendas;
- freelance;
- outras receitas.

---

## 5. Contas Fixas

O usuário poderá cadastrar despesas recorrentes, como:
- aluguel;
- energia;
- internet;
- telefone;
- streaming;
- financiamento.

Cada conta poderá possuir:
- nome;
- valor;
- categoria;
- vencimento;
- recorrência;
- responsável;
- status de pagamento.

Status:
- A vencer
- Pago
- Atrasado

---

## 6. Dívidas e Parcelamentos

O usuário poderá cadastrar dívidas e compras parceladas.

Exemplo:

```text
Notebook

Valor da parcela: R$ 250
Parcelas: 10
Pagas: 3
Restantes: 7
Vencimento: dia 10
```

O Money deverá considerar automaticamente as parcelas futuras no planejamento financeiro.

---

## 7. Meta de Economia

O casal poderá definir quanto deseja guardar por mês.

Exemplo:

```text
Renda:                R$ 6.500
Contas:              -R$ 2.800
Dívidas:             -R$   700
Meta para guardar:   -R$ 1.000
--------------------------------
Disponível:           R$ 2.000
```

A meta de economia será tratada como dinheiro reservado.

---

## 8. Limite de Gastos

O aplicativo calculará quanto o casal ainda pode gastar no mês e uma referência diária.

O cálculo considerará:
- dinheiro restante;
- dias restantes;
- contas ainda não pagas;
- dívidas;
- parcelas;
- meta de economia;
- gastos já realizados.

---

## 9. Limite Dinâmico

O orçamento deverá se adaptar ao comportamento do casal.

Se o limite recomendado for R$ 100 e o casal gastar R$ 60, os R$ 40 restantes continuarão disponíveis.

Se gastar R$ 150, o sistema identificará que foram gastos R$ 50 acima do planejado e recalculará os próximos limites.

---

## 10. Cadastro de Gastos

Botão principal:

**+ Adicionar gasto**

Campos:
- valor;
- descrição;
- categoria;
- quem gastou;
- forma de pagamento;
- data;
- observação.

---

## 11. Categorias

Categorias iniciais:
- 🛒 Alimentação
- 🏠 Casa
- 🚗 Transporte
- ⛽ Combustível
- 💊 Saúde
- 🎮 Lazer
- 👕 Roupas
- 📱 Assinaturas
- 💳 Dívidas
- 🎓 Educação
- 🐶 Animais
- 🎁 Presentes
- 📦 Compras
- 📌 Outros

O usuário poderá criar categorias personalizadas.

---

## 12. Tela Inicial

A Home deverá mostrar rapidamente:

```text
Money

Disponível este mês
R$ 1.284,70

HOJE
R$ 100,00 gastos

Limite recomendado
R$ 137,00

✓ Dentro da meta
R$ 37 disponíveis
```

---

## 13. Gastos do Casal

O aplicativo mostrará quanto cada pessoa registrou no período, sem transformar isso em competição.

```text
Gastos este mês

Você       R$ 840
Parceiro   R$ 620

Total      R$ 1.460
```

---

## 14. Últimos Gastos

```text
🛒 Mercado
R$ 87,50
Você

💊 Farmácia
R$ 32,00
Parceiro

⛽ Posto
R$ 100,00
Você
```

---

## 15. Resumo Diário

Exemplo:

```text
Resumo de hoje

Gastos:       R$ 100
Limite:       R$ 137
Economizado:  R$ 37
```

Mensagem:

> 🎉 Parabéns! Vocês gastaram apenas R$100 hoje e ficaram R$37 abaixo do limite planejado.

---

## 16. Gemini — Money Inteligente

O aplicativo terá uma área de assistente financeiro usando Gemini.

Perguntas possíveis:
- Como estamos financeiramente este mês?
- Onde gastamos mais?
- Podemos gastar R$500 este final de semana?
- Quanto precisamos economizar por dia?
- Estamos gastando mais com mercado?
- Quanto gastamos com lazer?
- Se continuarmos assim, quanto vai sobrar?

---

## 17. Funcionamento do Gemini

O aplicativo consulta os dados e realiza os cálculos primeiro.

Exemplo de dados resumidos:

```json
{
  "renda": 6500,
  "contas": 2800,
  "dividas": 700,
  "meta_economia": 1000,
  "gastos_mes": 1460,
  "dias_restantes": 18
}
```

O Gemini recebe apenas os dados necessários e transforma os resultados em uma explicação simples.

---

## 18. Segurança da API Gemini

A chave da API Gemini **não deverá ficar diretamente no aplicativo Flutter**.

Arquitetura:

```text
Flutter
   ↓
Firebase Cloud Function (ou backend seguro)
   ↓
Gemini API
   ↓
Firebase Cloud Function
   ↓
Flutter
```

Isso reduz o risco de exposição da chave no APK.

---

## 19. Insights Automáticos

Exemplos:

> ✨ Vocês estão R$182 abaixo do orçamento esperado para este momento do mês.

> ⚠️ Os gastos com alimentação estão 23% maiores que no mês passado.

> 🔥 Se continuarem nesse ritmo, poderão terminar o mês com aproximadamente R$420 além da meta.

---

## 20. Projeção do Mês

```text
PROJEÇÃO

Saldo atual:       R$ 2.480
Gastos previstos:  R$ 1.320
Meta reservada:    R$   800
Sobra estimada:    R$   360
```

---

## 21. Histórico

Filtros:
- Hoje
- 7 dias
- 30 dias
- Este mês
- Mês passado
- Período personalizado

---

## 22. Gráficos

O Money poderá apresentar:
- gastos por categoria;
- evolução dos gastos por dia;
- comparação mensal;
- orçamento utilizado;
- evolução da economia.

---

## 23. Cartões de Crédito

Em uma evolução do sistema, será possível cadastrar cartões com:
- nome;
- bandeira;
- limite;
- fechamento;
- vencimento;
- valor utilizado;
- limite disponível.

Compras parceladas deverão ser distribuídas pelos respectivos meses.

---

## 24. Notificações

Exemplos:

> Vocês ainda podem gastar R$87 hoje mantendo a meta.

> ⚠️ Vocês chegaram a 90% do orçamento de lazer.

> 🎉 Hoje vocês ficaram R$42 abaixo da meta.

---

## 25. Design Simples & Clean (Light Mode)

Interface clara, intuitiva e sem distrações visuais:

Sugestão de paleta:

```text
Fundo principal:   #F8F9FA (ou Branco puro #FFFFFF)
Superfícies/Cards: #FFFFFF
Bordas/Divisores:  #E9ECEF
Texto principal:   #1A1D20 (escuro, alta legibilidade)
Texto secundário:  #6C757D (cinza suave)
```

Indicadores de status:
- Verde (#2ECC71 / #10B981): dentro da meta / saldo positivo
- Laranja/Amarelo (#F39C12 / #F59E0B): atenção / próximo do limite
- Vermelho (#E74C3C / #EF4444): acima do orçamento / conta atrasada

---

## 26. Navegação

Menu inferior:

```text
🏠 Início
📊 Gastos
＋ Adicionar
🎯 Metas
👤 Perfil
```

O botão central de adicionar gasto deverá possuir maior destaque.

---

## 27. Estrutura Principal

```text
Money
├── Autenticação
├── Família
│   ├── Usuário 1
│   └── Usuário 2
├── Dashboard
├── Receitas
├── Gastos
│   ├── Diário
│   ├── Semanal
│   └── Mensal
├── Contas
├── Dívidas
├── Metas
├── Categorias
├── Relatórios
├── Projeções
├── Gemini
│   ├── Insights
│   ├── Chat
│   └── Resumos
└── Configurações
```

---

## 28. Banco de Dados — Estrutura Inicial (Firestore)

Coleções sugeridas:

```text
users (id, name, email, family_id, created_at)
families (id, name, code, members, created_at)
incomes (id, family_id, user_id, title, amount, category, date)
expenses (id, family_id, user_id, description, amount, category_id, date, payment_method)
categories (id, family_id, name, icon, color, is_default)
fixed_expenses (id, family_id, name, amount, due_day, status, responsible_user_id)
debts (id, family_id, title, total_amount, installment_amount, total_installments, paid_installments, due_day)
financial_goals (id, family_id, monthly_target, current_saved, title)
monthly_budgets (id, family_id, month, year, available_limit, daily_limit)
ai_insights (id, family_id, summary, created_at)
```

Cada documento financeiro terá referência a `family_id` e `user_id`.

---

## 29. Privacidade e Segurança

O aplicativo deverá:
- utilizar autenticação (Firebase Auth);
- proteger coleções com Firestore Security Rules;
- separar dados por `family_id`;
- impedir acesso de usuários externos;
- nunca armazenar senhas manualmente;
- não expor a chave do Gemini;
- enviar ao Gemini somente as informações necessárias.

---

## 30. MVP — Primeira Versão

Implementar inicialmente:

1. Login
2. Criar família
3. Convidar segundo usuário
4. Cadastrar renda
5. Cadastrar contas fixas
6. Cadastrar dívidas
7. Definir meta de economia
8. Registrar gastos
9. Categorizar gastos
10. Identificar quem gastou
11. Dashboard diário
12. Dashboard mensal
13. Limite diário dinâmico
14. Sincronização entre os usuários
15. Histórico
16. Integração Gemini
17. Insights
18. Visual Clean & Simples (Light Mode)

Recursos posteriores:
- cartões;
- parcelamentos avançados;
- exportação;
- relatórios;
- anexos e comprovantes;
- novas metas;
- planejamento anual.

---

## 31. Princípio do Money

O Money não deverá apenas dizer:

> Você gastou R$2.000.

Ele deverá responder:

> Você gastou R$2.000, ainda possui R$1.240 disponíveis e pode gastar aproximadamente R$68 por dia até o final do mês sem comprometer sua meta.

A principal pergunta respondida pelo aplicativo será:

# Quanto podemos gastar?

E não apenas:

# Quanto já gastamos?

---

## 32. Experiência Desejada

Ao abrir o aplicativo, o usuário deverá entender sua situação financeira em poucos segundos:

```text
R$ 1.284
disponíveis

R$ 87
podem ser gastos hoje

✓ Dentro da meta

✨ Mantendo esse ritmo,
vocês devem atingir a meta
do mês.
```

Essa simplicidade deverá ser o principal diferencial do **Money**.
