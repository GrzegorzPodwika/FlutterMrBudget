import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mr_budget/db/dao.dart';
import 'package:flutter_mr_budget/db/expense_type.dart';
import 'package:flutter_mr_budget/db/models.dart';
import 'package:flutter_mr_budget/other/utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseList extends StatefulWidget {
  final BudgetDao dao;

  const ExpenseList({Key key, this.dao}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  Budget _latestBudget;
  BudgetWithExpensesAndIncomes _wholeBudget;
  int _choiceIndex = -1;
  final _ALL = 'All';
  ListView _listView = ListView();

  @override
  void initState() {
    super.initState();
    _fetchLatestBudget();
  }

  void _fetchLatestBudget() async {
    _latestBudget = await widget.dao.getLatestBudget();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    _wholeBudget = await widget.dao
        .getBudgetWithExpensesAndIncomesById(_latestBudget.budgetId);

    setState(() {
      _buildListView(_ALL);
    });
  }

  void _buildListView(String expenseType) async {
    List<Expense> expenses;
     if (expenseType == _ALL) {
        expenses = _wholeBudget.expenses;
    } else {
        expenses = _wholeBudget.expenses
          .where((expense) => expense.type == expenseType)
          .toList();
    }

    _listView = ListView.separated(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return ExpenseItem(
          expense: expenses[index],
          onUpdated: (updatedExpense) {
            if (updatedExpense != null) {
              _updateExpenseInListAndDb(updatedExpense, expenseType);
            }
          },
          onDelete: (expenseToDelete) {
            if (expenseToDelete != null) {
              _deleteExpenseInListAndDb(expenseToDelete, expenseType);
            }
          },
        );
      },
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 1,
          color: Colors.grey,
        )
    );
  }

  void _updateExpenseInListAndDb(
      Expense updatedExpense, String expenseType) async {
    await widget.dao.updateExpense(updatedExpense);
    _wholeBudget.expenses[_wholeBudget.expenses
            .indexWhere((exp) => exp.expenseId == updatedExpense.expenseId)] =
        updatedExpense;

    setState(() {
      _buildListView(expenseType);
    });
  }

  void _deleteExpenseInListAndDb(
      Expense expenseToDelete, String expenseType
      ) async {
    await widget.dao.deleteExpense(expenseToDelete);
    _wholeBudget.expenses.remove(expenseToDelete);

    setState(() {
      _buildListView(expenseType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChoiceChips(),
            Expanded(child: _listView),
          ],
    ));
  }

  _buildChoiceChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildChoiceChip(-1),
              _buildChoiceChip(0),
              _buildChoiceChip(1),
              _buildChoiceChip(2),
              _buildChoiceChip(3),
            ],
          ),
          Row(
            children: [
              _buildChoiceChip(4),
              _buildChoiceChip(5),
              _buildChoiceChip(6),
              _buildChoiceChip(7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(int index) {
    if (index == -1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ChoiceChip(
          label: Text('All'),
          selected: _choiceIndex == index,
          selectedColor: Theme.of(context).accentColor,
          onSelected: (bool selected) {
            setState(() {
              _choiceIndex = selected ? index : -1;
              _buildListView(_ALL);
            });
          },
          backgroundColor: Colors.grey[800],
          labelStyle: TextStyle(color: Colors.white),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(EXPENSE_TYPES[index]),
        selected: _choiceIndex == index,
        selectedColor: Theme.of(context).accentColor,
        onSelected: (bool selected) {
          setState(() {
            _choiceIndex = selected ? index : -1;
            _buildListView(EXPENSE_TYPES[index]);
          });
        },
        backgroundColor: Colors.grey[800],
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final Function(Expense) onUpdated;
  final Function(Expense) onDelete;
  final _controllerExpenseAmount = TextEditingController();
  final _controllerExpenseName = TextEditingController();

  ExpenseItem({Key key, this.expense, this.onUpdated, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              expense.name,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Text(
              '- ${expense.value} PLN',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      secondaryActions: [
        IconSlideAction(
            caption: 'Edit',
            color: Colors.blue[700],
            icon: Icons.edit,
            onTap: () {
              _showEditDialog(context);
            }),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            onDelete(expense);
          },
        )
      ],
    );
  }

  _showEditDialog(context) {
    print("expense = $expense");
    print("controller = $_controllerExpenseName");
    _controllerExpenseName.text = expense.name;
    _controllerExpenseAmount.text = '${expense.value}';

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Modify expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controllerExpenseName,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        controller: _controllerExpenseAmount,
                        style: TextStyle(color: Colors.red),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          DecimalTextInputFormatter(decimalRange: 2)
                        ],
                        decoration: InputDecoration(
                            suffixText: 'PLN',
                            suffixStyle: TextStyle(color: Colors.red)),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          onUpdated(_getExpense());
                          Navigator.of(context).pop();
                        },
                        child: Text('Confirm'))
                  ],
                )
              ],
            ),
          );
        });
  }

  Expense _getExpense() {
    var newExpenseName = _controllerExpenseName.text;
    var newExpenseAmount = _controllerExpenseAmount.text;

    if (newExpenseName == null ||
        newExpenseName.isEmpty ||
        newExpenseAmount == null ||
        newExpenseAmount.isEmpty) {
      return null;
    }

    final updatedExpense = Expense(
        expenseId: expense.expenseId,
        budgetOwnerId: expense.budgetOwnerId,
        name: newExpenseName,
        type: expense.type,
        value: double.parse(newExpenseAmount));

    return updatedExpense;
  }
}
