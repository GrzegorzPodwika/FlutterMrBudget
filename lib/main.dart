import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mr_budget/backend/db/dao.dart';
import 'package:flutter_mr_budget/backend/db/database.dart';
import 'package:flutter_mr_budget/ui/add_transaction_view.dart';
import 'package:flutter_mr_budget/ui/expense_list.dart';
import 'package:flutter_mr_budget/ui/history.dart';
import 'package:flutter_mr_budget/ui/summary_card.dart';

import 'package:flutter_mr_budget/backend/db/models.dart';
import 'package:flutter_mr_budget/ui/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase.databaseBuilder('budget.db').build();
  final dao = database.budgetDao;
  final latestBudget = await dao.getLatestBudget();

  if(latestBudget == null) {
    await dao.insertBudget(Budget(budgetId: 0, date: DateTime.now()));
  } else if(latestBudget.date.month != DateTime.now().month) {
    await dao.insertBudget(Budget(budgetId: 0, date: DateTime.now()));
  }

  runApp(MyApp(dao: dao));
}

class MyApp extends StatelessWidget {
  final BudgetDao dao;

  const MyApp({Key key, this.dao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkLightTheme(dao: dao);
  }
}

class DarkLightTheme extends StatefulWidget {
  final BudgetDao dao;

  const DarkLightTheme({Key key, this.dao}) : super(key: key);

  @override
  _DarkLightThemeState createState() => _DarkLightThemeState();
}

class _DarkLightThemeState extends State<DarkLightTheme> {
  int _currentIndex = 0;
  PageController _pageController;
  bool _light = true;
  SummaryCard _summaryCard;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _summaryCard = SummaryCard(dao: widget.dao);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _light ? _lightTheme : _darkTheme,
      home: Scaffold(
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              _summaryCard,
              ExpenseList(dao: widget.dao),
              HistoryList(dao: widget.dao),
              SettingsView(onChanged: (bool state) {
                setState(() {
                  _light = state;
                });
              },),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          items: [
            BottomNavyBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
            ),
            BottomNavyBarItem(
                icon: Icon(Icons.list),
                title: Text('Expenses'),

            ),
            BottomNavyBarItem(
                icon: Icon(Icons.history),
                title: Text('History'),
            ),
            BottomNavyBarItem(
                icon: Icon(Icons.settings),
                title: Text('Settings'),
            )
          ],
        ),
        floatingActionButton: (_currentIndex == 0) ?
            CustomFAB(
                dao: widget.dao,
                needRefresh: (state) {
                  if(state) {
                    _summaryCard.getState().refresh();
                  }
                },
            ) : null,
      ),
      debugShowCheckedModeBanner: false,
    );
  }

}

class CustomFAB extends StatelessWidget {
  final BudgetDao dao;
  final Function(bool) needRefresh;

  const CustomFAB({Key key, this.dao, this.needRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton(
        onPressed: () {
          _navigateToAddTransactionView(context);
        },
        child: Icon(
          Icons.add,
          size: 35.0,
        ),
      ),
    );
  }


  void _navigateToAddTransactionView(context) async {
    final result = await Navigator.push(context, MaterialPageRoute<bool>(builder: (BuildContext context){
      return TransactionView(dao: dao);
      })
    );

    print('Navigation result = $result');
    if(result != null && result == true) {
      needRefresh.call(result);
    }
  }
}


ThemeData _lightTheme = ThemeData(
  accentColor: Colors.teal,
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  textTheme: TextTheme(
    headline6: TextStyle(
        color: Colors.black,
        fontSize: 20.0
    ),
    subtitle2: TextStyle(
      color: Colors.black,
      fontSize: 18.0
    )
  )
);

ThemeData _darkTheme = ThemeData(
    accentColor: Colors.amber,
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.white,
            fontSize: 20.0
      ),
      subtitle2: TextStyle(
        color: Colors.white,
        fontSize: 18.0
      )
  )
);
