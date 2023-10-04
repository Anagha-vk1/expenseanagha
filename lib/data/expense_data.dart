

import 'package:flutter/material.dart';

import '../datetime/date_time_helper.dart';
import '../models/expense_item.dart';
import 'hive_database.dart';

class ExpenseData extends ChangeNotifier {
  //list of all expenses
  List<ExpenseItem> OverallExpenseList = [];

  //get expense list
  List<ExpenseItem> getAllExpenseList() {
    return OverallExpenseList;
  }

 // prepare data to display
  final db = HiveDataBase();
  void prepareData() {
    //if there exist data,get it
    if (db.readData().isNotEmpty) {
      OverallExpenseList = db.readData();
    }
  }

  //add new expense
  void addNewExpense(ExpenseItem newExpense) {
    OverallExpenseList.add(newExpense);
    notifyListeners();
    db.saveData(OverallExpenseList);
  }

  //delete expense
  void deleteExpense(ExpenseItem expense) {
    OverallExpenseList.remove(expense);
    notifyListeners();
    db.saveData(OverallExpenseList);
  }

  //get weekday(mon,tues,etc) from a dateTime object
  String getDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thur';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  //get the date for the start of the week(sunday)
  DateTime? startOfWeekDate() {
    DateTime? startOfWeek;
    //get today date
    DateTime today = DateTime.now();
    //go backward from today to find sunday
    for (int i = 0; i < 7; i++) {
      if (getDayName(today.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = today.subtract(Duration(days: i));
        break;
      }
    }
    return startOfWeek;
  }
  //convert

  //daily expense summary
  Map<String, double> calculateDailyExpenseSummary() {
    Map<String, double> dailyExpenseSummary = {
      //date(yymmdd):amountTotalForDay
    };
    for (var expense in OverallExpenseList) {
      String date = convertDateTimeToString(expense.dateTime);
      double amount = double.parse(expense.amount);

      if (dailyExpenseSummary.containsKey(date)) {
        double currentAmount = dailyExpenseSummary[date]!;
        currentAmount += amount;
        dailyExpenseSummary[date] = currentAmount;
      } else {
        dailyExpenseSummary.addAll({date: amount});
      }
    }
    return dailyExpenseSummary;
  }
}
