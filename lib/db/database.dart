// @dart=2.12

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter_mr_budget/db/converters.dart';
import 'package:flutter_mr_budget/db/dao.dart';
import 'package:flutter_mr_budget/db/models.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Budget, Expense, Income])
abstract class AppDatabase extends FloorDatabase {
  BudgetDao get budgetDao;
}


