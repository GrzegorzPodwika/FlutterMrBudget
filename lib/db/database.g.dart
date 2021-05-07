// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  BudgetDao? _budgetDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Budget` (`budgetId` INTEGER PRIMARY KEY AUTOINCREMENT, `date` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Expense` (`expenseId` INTEGER PRIMARY KEY AUTOINCREMENT, `budgetOwnerId` INTEGER, `name` TEXT, `type` TEXT, `value` REAL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Income` (`incomeId` INTEGER PRIMARY KEY AUTOINCREMENT, `budgetOwnerId` INTEGER, `name` TEXT, `value` REAL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  BudgetDao get budgetDao {
    return _budgetDaoInstance ??= _$BudgetDao(database, changeListener);
  }
}

class _$BudgetDao extends BudgetDao {
  _$BudgetDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _budgetInsertionAdapter = InsertionAdapter(
            database,
            'Budget',
            (Budget item) => <String, Object?>{
                  'budgetId': item.budgetId,
                  'date': _dateTimeConverter.encode(item.date)
                }),
        _expenseInsertionAdapter = InsertionAdapter(
            database,
            'Expense',
            (Expense item) => <String, Object?>{
                  'expenseId': item.expenseId,
                  'budgetOwnerId': item.budgetOwnerId,
                  'name': item.name,
                  'type': item.type,
                  'value': item.value
                }),
        _incomeInsertionAdapter = InsertionAdapter(
            database,
            'Income',
            (Income item) => <String, Object?>{
                  'incomeId': item.incomeId,
                  'budgetOwnerId': item.budgetOwnerId,
                  'name': item.name,
                  'value': item.value
                }),
        _expenseUpdateAdapter = UpdateAdapter(
            database,
            'Expense',
            ['expenseId'],
            (Expense item) => <String, Object?>{
                  'expenseId': item.expenseId,
                  'budgetOwnerId': item.budgetOwnerId,
                  'name': item.name,
                  'type': item.type,
                  'value': item.value
                }),
        _expenseDeletionAdapter = DeletionAdapter(
            database,
            'Expense',
            ['expenseId'],
            (Expense item) => <String, Object?>{
                  'expenseId': item.expenseId,
                  'budgetOwnerId': item.budgetOwnerId,
                  'name': item.name,
                  'type': item.type,
                  'value': item.value
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Budget> _budgetInsertionAdapter;

  final InsertionAdapter<Expense> _expenseInsertionAdapter;

  final InsertionAdapter<Income> _incomeInsertionAdapter;

  final UpdateAdapter<Expense> _expenseUpdateAdapter;

  final DeletionAdapter<Expense> _expenseDeletionAdapter;

  @override
  Future<int?> budgetsCount() async {
    await _queryAdapter.queryNoReturn('SELECT COUNT(*) FROM Budget');
  }

  @override
  Future<Budget?> findBudgetById(int id) async {
    return _queryAdapter.query('SELECT * FROM Budget WHERE budgetId = ?1',
        mapper: (Map<String, Object?> row) => Budget(
            budgetId: row['budgetId'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int?)),
        arguments: [id]);
  }

  @override
  Future<Budget?> getLatestBudget() async {
    return _queryAdapter.query(
        'SELECT * FROM Budget ORDER BY date DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => Budget(
            budgetId: row['budgetId'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int?)));
  }

  @override
  Future<List<Budget>> getAllBudgets() async {
    return _queryAdapter.queryList('SELECT * FROM Budget',
        mapper: (Map<String, Object?> row) => Budget(
            budgetId: row['budgetId'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int?)));
  }

  @override
  Future<List<Expense>> findExpensesByBudgetId(int budgetId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Expense WHERE budgetOwnerId = ?1',
        mapper: (Map<String, Object?> row) => Expense(
            expenseId: row['expenseId'] as int?,
            budgetOwnerId: row['budgetOwnerId'] as int?,
            name: row['name'] as String?,
            type: row['type'] as String?,
            value: row['value'] as double?),
        arguments: [budgetId]);
  }

  @override
  Future<List<Income>> findIncomesByBudgetId(int budgetId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Income WHERE budgetOwnerId = ?1',
        mapper: (Map<String, Object?> row) => Income(
            incomeId: row['incomeId'] as int?,
            budgetOwnerId: row['budgetOwnerId'] as int?,
            name: row['name'] as String?,
            value: row['value'] as double?),
        arguments: [budgetId]);
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    await _budgetInsertionAdapter.insert(budget, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertExpense(Expense expense) async {
    await _expenseInsertionAdapter.insert(expense, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertIncome(Income income) async {
    await _incomeInsertionAdapter.insert(income, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await _expenseUpdateAdapter.update(expense, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    await _expenseDeletionAdapter.delete(expense);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
