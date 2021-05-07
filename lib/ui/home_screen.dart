import 'package:flutter/material.dart';
import 'package:flutter_mr_budget/db/dao.dart';
import 'package:flutter_mr_budget/db/models.dart';
import 'package:flutter_mr_budget/other/summary_card.dart';

class Home extends StatefulWidget {
  final BudgetDao dao;
  _HomeState state;

  Home({Key key, this.dao}) : super(key: key);

  @override
  _HomeState createState() {
    state = _HomeState();
    return state;
  }

  getState() => state;
}

class _HomeState extends State<Home> {

  Budget _latestBudget;
  BudgetWithExpensesAndIncomes _wholeBudget;
  Widget _summaryCard = Container();

  refresh() {
    _fetchWholeBudget();
  }


  @override
  void initState() {
    super.initState();
    _fetchWholeBudget();
  }

  void _fetchWholeBudget() async {
    _latestBudget = await widget.dao.getLatestBudget();
    _wholeBudget = await widget.dao.getBudgetWithExpensesAndIncomesById(
        _latestBudget.budgetId);

    setState(() {
      _summaryCard = SummaryCard(wholeBudget: _wholeBudget);
    });

  }


  @override
  Widget build(BuildContext context) {
    return _summaryCard;
  }

}


