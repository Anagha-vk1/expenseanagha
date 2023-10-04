

import 'package:hive/hive.dart';

import '../models/expense_item.dart';

class HiveDataBase {
  //reference our box
  final _myBox = Hive.box("expense_database");
  //write data
  void saveData(List<ExpenseItem> allExpense) {
    /*
    Hive can only store string and dateTime and not custom objects like expenseItem.
    so lets convert ExpenseItem objects into types that can be stored in our db.
    allExpense=
    [
      ExpenseItem(name/amount/dateTime)
      ..
    ]
    ->
    [
      [name,amount,dateTime],
      ....
      ]
    */
    List<List<dynamic>> allExpenseFormated = [];
    for (var expense in allExpense) {
      //convert each expenseItem into a list of storable types (strings ,dateTime)
      List<dynamic> expenseFormatted = [
        expense.name,
        expense.amount,
        expense.dateTime,
      ];
      allExpenseFormated.add(expenseFormatted);
    }
    //finally store in our db
    _myBox.put("ALL_EXPENSES", allExpenseFormated);
  }

  //read data

  List<ExpenseItem> readData() {
    /*
    data is stored in hive as a list of strings + dateTime,so lets convert our saved data into ExpenseItem object
    saveData=
    [
      [name,amount,dateTime],
      ...
    ]
    ->
    [
      ExpenseItem(name/amount/dateTime),
      ...
    ]
     */
    List savedExpenses = _myBox.get("ALL_EXPENSES") ?? [];
    List<ExpenseItem> allExpenses = [];
    for (int i = 0; i < savedExpenses.length; i++) {
      //collect individual expense data
      String name = savedExpenses[i][0];
      String amount = savedExpenses[i][1];
      DateTime dateTime = savedExpenses[i][2];
      //create expense item
      ExpenseItem expense =
      ExpenseItem(name: name, amount: amount, dateTime: dateTime);
      //add expense to overall list of expenses
      allExpenses.add(expense);
    }
    return allExpenses; // Return the list of expenses ,for testing
  }
}
