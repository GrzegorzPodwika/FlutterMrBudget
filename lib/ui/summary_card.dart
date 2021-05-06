import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mr_budget/backend/db/dao.dart';
import 'package:flutter_mr_budget/backend/db/expense_type.dart';
import 'package:flutter_mr_budget/backend/db/models.dart';
import 'package:flutter_mr_budget/other/utils.dart';
import 'indicator.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatefulWidget {
  final BudgetDao dao;
  _SummaryCardState state;

  SummaryCard({Key key, this.dao}) : super(key: key);

  @override
  _SummaryCardState createState() {
    state = _SummaryCardState();
    return state;
  }

  getState() => state;
}

class _SummaryCardState extends State<SummaryCard> {
  final _fontSize = 22.0;
  final _radius = 180.0;
  final Map<String, Color> _colors = {
    EXPENSE_TYPES[0] : Colors.blue,
    EXPENSE_TYPES[1] : Colors.amber,
    EXPENSE_TYPES[2] : Colors.deepPurple,
    EXPENSE_TYPES[3] : Colors.green,
    EXPENSE_TYPES[4] : Colors.red,
    EXPENSE_TYPES[5] : Colors.black,
    EXPENSE_TYPES[6] : Colors.brown,
    EXPENSE_TYPES[7] : Colors.teal
  };
  List<double> expensesByCategory = [
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0
  ];
  Budget _latestBudget;
  BudgetWithExpensesAndIncomes _wholeBudget;
  int touchedIndex;
  String _formattedDate = '';
  double _totalExpenses = 0.0;
  double _totalIncomes = 0.0;
  List<PieChartSectionData> _pieChartData;


  @override
  void initState() {
    super.initState();
    print('initState SummaryCard (FirstPage)');
    _fetchWholeBudget();
  }

  refresh() {
    _totalExpenses = 0.0;
    _totalIncomes = 0.0;
    expensesByCategory = [
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    ];
    _fetchWholeBudget();
  }

  void _fetchWholeBudget() async {
    _latestBudget = await widget.dao.getLatestBudget();

    setState(() {
      _formattedDate = DateFormat('MMM y').format(_latestBudget.date);
    });

    _wholeBudget = await widget.dao.getBudgetWithExpensesAndIncomesById(_latestBudget.budgetId);

    _wholeBudget.expenses.forEach((expense) {
      _totalExpenses += expense.value;
    });

    _wholeBudget.incomes.forEach((income) {
      _totalIncomes += income.value;
    });

    setState(() {
      _setPieChartData();
    });
  }

  void _setPieChartData() async {
    final expenses = _wholeBudget.expenses;

    for(var i = 0; i < expenses.length; i++) {
      if(expenses[i].type == EXPENSE_TYPES[0])
        expensesByCategory[0] += expenses[i].value;
      else if(expenses[i].type == EXPENSE_TYPES[1])
        expensesByCategory[1] += expenses[i].value;
      else if(expenses[i].type == EXPENSE_TYPES[2])
        expensesByCategory[2] += expenses[i].value;
      else if(expenses[i].type == EXPENSE_TYPES[3])
        expensesByCategory[3] += expenses[i].value;
      else if(expenses[i].type == EXPENSE_TYPES[4])
        expensesByCategory[4] += expenses[i].value;
      else if(expenses[i].type == EXPENSE_TYPES[5])
        expensesByCategory[5] += expenses[i].value;
      else if(expenses[i].type == EXPENSE_TYPES[6])
        expensesByCategory[6] += expenses[i].value;
      else if(expenses[i].type == EXPENSE_TYPES[7])
        expensesByCategory[7] += expenses[i].value;
    }
    
    Map<String, double> mapOfExpenses = new Map();
    for(var i = 0; i < expensesByCategory.length; i++) {
      if(expensesByCategory[i] != 0.0) {
        mapOfExpenses[EXPENSE_TYPES[i]] = expensesByCategory[i];
      }
    }

    _pieChartData = [];

    mapOfExpenses.forEach((key, value) {
      _pieChartData.add(
          PieChartSectionData(
            color: _colors[key],
            value: value,
            title: convertToPercentValue(value, _totalExpenses),
            radius: _radius,
            titleStyle: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)
            ),
          )
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 8.0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  _formattedDate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
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
                          letterSpacing: 1.5,

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
                      '- ${_totalExpenses.toString()} PLN',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '+ ${_totalIncomes.toString()} PLN',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Indicator(
                    color: _colors[EXPENSE_TYPES[0]],
                    text: EXPENSE_TYPES[0],
                    isSquare: false,
                    size: (touchedIndex == 0 && expensesByCategory[0] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 0 && expensesByCategory[0] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                  Indicator(
                    color: _colors[EXPENSE_TYPES[1]],
                    text: EXPENSE_TYPES[1],
                    isSquare: false,
                    size: (touchedIndex == 1 && expensesByCategory[1] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 1 && expensesByCategory[1] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                  Indicator(
                    color: _colors[EXPENSE_TYPES[2]],
                    text: EXPENSE_TYPES[2],
                    isSquare: false,
                    size: (touchedIndex == 2 && expensesByCategory[2] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 2 && expensesByCategory[2] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                  Indicator(
                    color: _colors[EXPENSE_TYPES[3]],
                    text: EXPENSE_TYPES[3],
                    isSquare: false,
                    size: (touchedIndex == 3 && expensesByCategory[3] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 3 && expensesByCategory[3] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: 12.0,),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Indicator(
                    color: _colors[EXPENSE_TYPES[4]],
                    text: EXPENSE_TYPES[4],
                    isSquare: false,
                    size: (touchedIndex == 4 && expensesByCategory[4] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 4 && expensesByCategory[4] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                  Indicator(
                    color: _colors[EXPENSE_TYPES[5]],
                    text: EXPENSE_TYPES[5],
                    isSquare: false,
                    size: (touchedIndex == 5 && expensesByCategory[5] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 5 && expensesByCategory[5] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                  Indicator(
                    color: _colors[EXPENSE_TYPES[6]],
                    text: EXPENSE_TYPES[6],
                    isSquare: false,
                    size: (touchedIndex == 6 && expensesByCategory[6] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 6 && expensesByCategory[6] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                  Indicator(
                    color: _colors[EXPENSE_TYPES[7]],
                    text: EXPENSE_TYPES[7],
                    isSquare: false,
                    size: (touchedIndex == 7 && expensesByCategory[7] != 0.0) ? 18 : 16,
                    textColor: (touchedIndex == 7 && expensesByCategory[7] != 0.0) ? Theme.of(context).textTheme.subtitle2.color : Colors.grey,
                  ),
                ],
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                   PieChartData(
                     pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                       setState(() {
                         final desiredTouch = pieTouchResponse.touchInput is! PointerExitEvent &&
                             pieTouchResponse.touchInput is! PointerUpEvent;
                         if (desiredTouch && pieTouchResponse.touchedSection != null) {
                           touchedIndex = pieTouchResponse.touchedSection.touchedSectionIndex;
                         } else {
                           touchedIndex = -1;
                         }
                       });
                     }),
                     sections: _pieChartData,
                     startDegreeOffset: 180,
                     sectionsSpace: 0,
                     borderData: FlBorderData(
                       show: false,
                     ),
                     centerSpaceRadius: 0,
                   ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



