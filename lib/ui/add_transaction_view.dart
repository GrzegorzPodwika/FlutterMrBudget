import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mr_budget/backend/db/dao.dart';
import 'package:flutter_mr_budget/backend/db/expense_type.dart';
import 'package:flutter_mr_budget/backend/db/models.dart';
import 'package:flutter_mr_budget/other/utils.dart';

class TransactionView extends StatefulWidget {
  final BudgetDao dao;

  const TransactionView({Key key, this.dao}) : super(key: key);

  @override
  _TransactionViewState createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView>
    with SingleTickerProviderStateMixin {
  final _iconSize = 60.0;
  var _isCorrect = false;
  var _selectedIcon = -1;
  var _iconColors = <Color>[
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey,
  ];
  final _controllerExpenseAmount = TextEditingController();
  final _controllerExpenseName = TextEditingController();
  final _controllerIncomeAmount = TextEditingController();
  final _controllerIncomeName = TextEditingController();

  TabController _tabController;
  Budget _latestBudget;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if(_tabController.index == 0) {
        setState(() {
          if(_controllerExpenseAmount.text == null || _controllerExpenseAmount.text.isEmpty) {
            _isCorrect = false;
          } else {
            _isCorrect = true;
          }
        });
      } else {
        setState(() {
          if(_controllerIncomeAmount.text == null || _controllerIncomeAmount.text.isEmpty) {
            _isCorrect = false;
          } else
            _isCorrect = true;
        });
      }
    });
    _fetchLatestBudget();
  }

  void _fetchLatestBudget() async {
    _latestBudget = await widget.dao.getLatestBudget();
  }

  @override
  void dispose() {
    _controllerExpenseAmount.dispose();
    _controllerExpenseName.dispose();
    _controllerIncomeAmount.dispose();
    _controllerIncomeName.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TabBar(
          unselectedLabelColor: Theme.of(context).textTheme.subtitle2.color,
          labelColor: Theme.of(context).accentColor,
          tabs: [
            Tab(
              text: 'EXPENSE',
            ),
            Tab(
              text: 'INCOME',
            ),
          ],
          controller: _tabController,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildExpenseView(), _buildIncomeView()],
        ),
        floatingActionButton: _isCorrect
            ? FloatingActionButton(
                child: Icon(
                  Icons.add,
                  size: 35.0,
                ),
                onPressed: () {
                  if (_tabController.index == 0) {
                    _addExpense();
                  } else {
                    _addIncome();
                  }
                })
            : null,
      ),
    );
  }

  Widget _buildExpenseView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
              controller: _controllerExpenseAmount,
              onChanged: (String value) async {
                _onTextChange(value);
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
              decoration: InputDecoration(
                hintText: '100.50',
                labelText: 'Amount',
                suffixText: 'PLN',
                filled: true,
              )),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
              controller: _controllerExpenseName,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Last party',
                filled: true,
                labelText: 'Expense name',
              )),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.local_grocery_store),
                color: _iconColors[0],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 0;
                  _changeColor(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.local_taxi),
                color: _iconColors[1],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 1;
                  _changeColor(1);
                },
              ),
              IconButton(
                icon: Icon(Icons.healing),
                color: _iconColors[2],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 2;
                  _changeColor(2);
                },
              ),
              IconButton(
                icon: Icon(Icons.family_restroom),
                color: _iconColors[3],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 3;
                  _changeColor(3);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.card_giftcard),
                color: _iconColors[4],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 4;
                  _changeColor(4);
                },
              ),
              IconButton(
                icon: Icon(Icons.book),
                color: _iconColors[5],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 5;
                  _changeColor(5);
                },
              ),
              IconButton(
                icon: Icon(Icons.home),
                color: _iconColors[6],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 6;
                  _changeColor(6);
                },
              ),
              IconButton(
                icon: Icon(Icons.games),
                color: _iconColors[7],
                iconSize: _iconSize,
                onPressed: () {
                  _selectedIcon = 7;
                  _changeColor(7);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onTextChange(String value) {
    setState(() {
      if(value != null && value.isNotEmpty)
        _isCorrect = true;
      else
        _isCorrect = false;
    });
  }

  Widget _buildIncomeView() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
              inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
              controller: _controllerIncomeAmount,
              keyboardType: TextInputType.number,
              onChanged: (String value) async {
                _onTextChange(value);
              },
              decoration: InputDecoration(
                hintText: '100.50',
                labelText: 'Amount',
                suffixText: 'PLN',
                filled: true,
              )),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
              controller: _controllerIncomeName,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Salary',
                filled: true,
                labelText: 'Income name',
              )),
        ],
      ),
    );
  }

  void _changeColor(int iconIndex) {
    setState(() {
      for (var i = 0; i < _iconColors.length; i++) {
        if (i == iconIndex) {
          _iconColors[i] = Theme.of(context).accentColor;
        } else {
          _iconColors[i] = Colors.grey;
        }
      }
    });
  }

  void _addExpense() async {
    return;
    if(_controllerExpenseAmount.text == null || _controllerExpenseAmount.text.isEmpty) {

    }
    var amount = double.parse(_controllerExpenseAmount.text);
    var expenseName = _controllerExpenseName.text;
    var expenseType = EXPENSE_TYPES[_selectedIcon];

    final expense = Expense(
        expenseId: null,
        budgetOwnerId: _latestBudget.budgetId,
        name: expenseName,
        type: expenseType,
        value: amount);

    await widget.dao.insertExpense(expense);
    _closeTransactionView();
  }

  void _addIncome() async {

    final double amount = double.parse(_controllerIncomeAmount.text);
    final incomeName = _controllerIncomeName.text;

    final income = Income(
        incomeId: null,
        budgetOwnerId: _latestBudget.budgetId,
        name: incomeName,
        value: amount);

    await widget.dao.insertIncome(income);
    _closeTransactionView();
  }

  void _closeTransactionView() {
    Navigator.pop(context, true);
  }
}
