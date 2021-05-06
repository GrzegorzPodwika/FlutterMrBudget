import 'package:flutter/material.dart';
import 'package:flutter_mr_budget/backend/db/dao.dart';
import 'package:flutter_mr_budget/backend/db/models.dart';
import 'package:intl/intl.dart';

class HistoryList extends StatefulWidget {
  final BudgetDao dao;

  const HistoryList({Key key, this.dao})
      : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  List<BudgetWithExpensesAndIncomes> _allBudgets;
  List<double> _expensesByBudget;
  List<double> _incomesByBudget;
  ListView _listView;
  List<String> _formattedDates;

  @override
  void initState() {
    super.initState();
    print('initState HistoryList (ThirdPage)');
    _fetchAllBudgets();
  }

  void _fetchAllBudgets() async {
   _allBudgets = await widget.dao.getAllBudgetsWithExpensesAndIncomes();
   _expensesByBudget = List.filled(_allBudgets.length, 0.0);
   _incomesByBudget = List.filled(_allBudgets.length, 0.0);
   _formattedDates = List.filled(_allBudgets.length, '');

   for(int i = 0; i < _allBudgets.length; i++) {
     var expenses = _allBudgets[i].expenses;
     var incomes = _allBudgets[i].incomes;

     for(int j = 0; j < expenses.length; j++) {
      _expensesByBudget[i] += expenses[j].value;
     }

     for(int j = 0; j < incomes.length; j++) {
      _incomesByBudget[i] += incomes[j].value;
     }

     _formattedDates[i] = DateFormat('MMM y').format(_allBudgets[i].budget.date);
   }

   setState(() {
     _setListView();
   });
  }

  void _setListView() {
    _listView = ListView.builder(
      itemCount: _allBudgets.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: _listView
    );
  }

  Widget _buildHistoryCard(int index) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 8.0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                _formattedDates[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Expenses',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle2.color,
                        fontSize: 18.0,
                        letterSpacing: 1.5
                    ),
                  ),
                  Text(
                    'Total Incomes',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle2.color,
                        fontSize: 18.0,
                        letterSpacing: 1.5
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '- ${_expensesByBudget[index].toString()} PLN',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    '+ ${_incomesByBudget[index].toString()} PLN',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
