import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mr_budget/db/dao.dart';
import 'package:flutter_mr_budget/db/database.dart';
import 'package:flutter_mr_budget/ui/add_transaction_screen.dart';
import 'package:flutter_mr_budget/ui/expense_list_screen.dart';
import 'package:flutter_mr_budget/ui/history_screen.dart';
import 'package:flutter_mr_budget/ui/home_screen.dart';

import 'package:flutter_mr_budget/db/models.dart';
import 'package:flutter_mr_budget/ui/settings_screen.dart';

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
  Home _summaryCard;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _summaryCard = Home(dao: widget.dao);
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
    final result = await Navigator.of(context).push(_createRoute());

    print('Navigation result = $result');
    if(result != null && result == true) {
      needRefresh.call(result);
    }
  }

  Route<bool> _createRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TransactionView(dao: dao),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.decelerate;
          var curveTween = CurveTween(curve: curve);

          var tween = Tween(begin: begin, end: end).chain(curveTween);

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
              position: offsetAnimation,
              child: child
          );
        }
    );
  }
}

