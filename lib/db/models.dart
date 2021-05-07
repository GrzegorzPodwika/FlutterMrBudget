import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:meta/meta.dart';

@entity
class Budget extends Equatable {
  @PrimaryKey(autoGenerate: true)
  final int budgetId;
  final DateTime date;

  Budget({
    this.budgetId,
    @required this.date}
    );

  @override
  List<Object> get props => [budgetId, date];
}

@entity
class Expense extends Equatable {
  @PrimaryKey(autoGenerate: true)
  final int expenseId;
  final int budgetOwnerId;
  final String name;
  final String type;
  final double value;

  Expense(
      {this.expenseId,
      @required this.budgetOwnerId,
      @required this.name,
      @required this.type,
      @required this.value});

  @override
  List<Object> get props => [expenseId, budgetOwnerId, name, type, value];
}

@entity
class Income extends Equatable {
  @PrimaryKey(autoGenerate: true)
  final int incomeId;
  final int budgetOwnerId;
  final String name;
  final double value;

  Income(
      {this.incomeId,
        @required this.budgetOwnerId,
        @required this.name,
        @required this.value});

  @override
  List<Object> get props => [incomeId, budgetOwnerId, name, value];
}

class BudgetWithExpensesAndIncomes {
  final Budget budget;
  final List<Expense> expenses;
  final List<Income> incomes;

  BudgetWithExpensesAndIncomes({this.budget, this.expenses, this.incomes});
}