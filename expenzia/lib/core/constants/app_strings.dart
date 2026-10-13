class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Expenzia';
  static const String tagline = 'Spend Smarter Save More';
  static const String getStarted = 'Get Started';

  // Navigation
  static const String home = 'Home';
  static const String history = 'History';
  static const String add = 'Add';
  static const String credit = 'Credit';
  static const String profile = 'Profile';

  // Dashboard
  static const String totalBalance = 'Total Balance';
  static const String totalIncome = 'Income';
  static const String totalExpenses = 'Expenses';
  static const String dailyAverage = 'Daily Average';
  static const String weekly = 'Weekly';
  static const String transactionsHistory = 'Transactions History';
  static const String seeAll = 'See all';
  static const String noTransactions = 'No transactions yet';
  static const String noTransactionsSubtitle =
      'Add your first expense to get started';
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String userName = 'User';

  // Forms
  static const String transaction = 'Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String transactionHistory = 'Transaction History';
  static const String transactionType = 'TRANSACTION TYPE';
  static const String name = 'NAME';
  static const String amount = 'AMOUNT';
  static const String date = 'DATE';
  static const String save = 'Save';
  static const String clear = 'Clear';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';

  // Transaction types
  static const String expense = 'Expense';
  static const String income = 'Income';

  // Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Shopping',
    'Transport',
    'Entertainment',
    'Health',
    'Education',
    'Bills & Utilities',
    'Transfer',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Transfer',
    'Other',
  ];

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidAmount = 'Please enter a valid positive amount';
  static const String amountTooLarge = 'Amount is too large';
  static const String selectCategory = 'Please select a transaction type';
  static const String invalidDate = 'Please select a valid date';

  // Messages
  static const String expenseSaved = 'Transaction saved successfully';
  static const String expenseUpdated = 'Transaction updated successfully';
  static const String expenseDeleted = 'Transaction deleted successfully';
  static const String saveFailed = 'Failed to save. Please try again.';
  static const String updateFailed = 'Failed to update. Please try again.';
  static const String deleteFailed = 'Failed to delete. Please try again.';
  static const String loadFailed = 'Failed to load transactions.';

  // Delete dialog
  static const String deleteConfirm = 'Delete Transaction';
  static const String deleteMessage =
      'Are you sure you want to delete this transaction? This action cannot be undone.';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Profile
  static const String clearStorage = 'Clear Storage';
  static const String clearStorageConfirm = 'Clear All Data';
  static const String clearStorageMessage =
      'This will delete all your transactions. This action cannot be undone.';
  static const String clearStorageSuccess = 'All data cleared successfully';

  // Database
  static const String dbName = 'expenzia.db';
  static const String tableExpenses = 'expenses';
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colAmount = 'amount';
  static const String colCategory = 'category';
  static const String colDate = 'date';
  static const String colDescription = 'description';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
}
