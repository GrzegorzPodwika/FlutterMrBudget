// @dart=2.12

import 'package:floor/floor.dart';
import 'package:flutter_mr_budget/backend/db/models.dart';
import 'package:meta/meta.dart';

@dao
abstract class BudgetDao {

  @insert
  Future<void> insertBudget(Budget budget);

  @insert
  Future<void> insertExpense(Expense expense);

  @insert
  Future<void> insertIncome(Income income);

  @delete
  Future<void> deleteExpense(Expense expense);

  @update
  Future<void> updateExpense(Expense expense);

  @Query('SELECT COUNT(*) FROM Budget')
  Future<int?> budgetsCount();

  @Query('SELECT * FROM Budget WHERE budgetId = :id')
  Future<Budget?> findBudgetById(int id);

  @Query('SELECT * FROM Budget ORDER BY date DESC LIMIT 1')
  Future<Budget?> getLatestBudget();

  @Query('SELECT * FROM Budget')
  Future<List<Budget>> getAllBudgets();

  @Query('SELECT * FROM Expense WHERE budgetOwnerId = :budgetId')
  Future<List<Expense>> findExpensesByBudgetId(int budgetId);

  @Query('SELECT * FROM Income WHERE budgetOwnerId = :budgetId')
  Future<List<Income>> findIncomesByBudgetId(int budgetId);

  Future<BudgetWithExpensesAndIncomes> getBudgetWithExpensesAndIncomesById(int id) async{
    final budget = await findBudgetById(id);
    final expenses = await findExpensesByBudgetId(id);
    final incomes = await findIncomesByBudgetId(id);

    return BudgetWithExpensesAndIncomes(
      budget: budget,
      expenses: expenses,
      incomes: incomes
    );
  }

  Future<List<BudgetWithExpensesAndIncomes>> getAllBudgetsWithExpensesAndIncomes() async {
    List<BudgetWithExpensesAndIncomes> allBudgets = [];

    List<Budget> budgets = await getAllBudgets();

    for(var i = 0; i < budgets.length; i++) {
      final budget = await findBudgetById(budgets[i].budgetId);
      final expenses = await findExpensesByBudgetId(budgets[i].budgetId);
      final incomes = await findIncomesByBudgetId(budgets[i].budgetId);

      allBudgets.add(BudgetWithExpensesAndIncomes(
          budget: budget,
          expenses: expenses,
          incomes: incomes
      ));
    }

    return allBudgets;
  }

}