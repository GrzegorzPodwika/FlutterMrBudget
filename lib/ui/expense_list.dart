import 'package:flutter/material.dart';
import 'package:flutter_mr_budget/backend/db/dao.dart';
import 'package:flutter_mr_budget/backend/db/expense_type.dart';
import 'package:flutter_mr_budget/backend/db/models.dart';

class ExpenseList extends StatefulWidget {
  final BudgetDao dao;

  const ExpenseList({Key key, this.dao}) : super(key: key);

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  Budget _latestBudget;
  BudgetWithExpensesAndIncomes _wholeBudget;
  ListView _listView = ListView();
  int _choiceIndex = -1;
  final _ALL = 'All';

  @override
  void initState() {
    super.initState();
    print('initState ExpenseListState (SecondPage)');
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    _latestBudget = await widget.dao.getLatestBudget();
    _wholeBudget = await widget.dao
        .getBudgetWithExpensesAndIncomesById(_latestBudget.budgetId);

    setState(() {
      _buildListView(_ALL);
    });
  }

  void _buildListView(String expenseType) {
    List<Expense> expenses;
    if(expenseType == _ALL) {
      expenses = _wholeBudget.expenses;
    } else {
      expenses = _wholeBudget.expenses.where(
              (expense) => expense.type == expenseType).toList();
    }

    _listView = ListView.separated(
      itemCount: expenses.length,
      itemBuilder: (BuildContext context, int index) {
        return ExpenseItem(
          expenseName: expenses[index].name,
          amount: expenses[index].value,
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
        color: Colors.grey,
      ),
    );
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
    if(index == -1) {
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
  final String expenseName;
  final double amount;

  const ExpenseItem({Key key, this.expenseName, this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            expenseName,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          Text(
            '- $amount PLN',
            style: TextStyle(
                color: Colors.red,
                fontSize: 18.0,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}
