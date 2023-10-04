
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../bargraph/bar_graph.dart';
import '../data/expense_data.dart';
import '../datetime/date_time_helper.dart';

class ExpenseSummary extends StatelessWidget {
  final DateTime startOfWeek;
  const ExpenseSummary({
    Key? key,
    required this.startOfWeek,
  }) : super(key: key);
//calculate max amount in bar graph
  double calculateMax(
      ExpenseData value,
      String sunday,
      String monday,
      String tuesday,
      String wedsday,
      String thursday,
      String friday,
      String saturday,
      ) {
    double? max = 100;
    List<double> values = [
      value.calculateDailyExpenseSummary()[sunday] ?? 0,
      value.calculateDailyExpenseSummary()[monday] ?? 0,
      value.calculateDailyExpenseSummary()[tuesday] ?? 0,
      value.calculateDailyExpenseSummary()[wedsday] ?? 0,
      value.calculateDailyExpenseSummary()[thursday] ?? 0,
      value.calculateDailyExpenseSummary()[friday] ?? 0,
      value.calculateDailyExpenseSummary()[saturday] ?? 0,
    ];
    //sort from smallest to largest
    values.sort();
    //get largest amount(which is at the end of the sorted list)
    //and increase the cap slightly so the graph looks almost full
    max = values.last * 1.1;
    return max == 0 ? 100 : max;
  }

  //calculate  the week total
  String calculateWeekTotal(
      ExpenseData value,
      String sunday,
      String monday,
      String tuesday,
      String wedsday,
      String thursday,
      String friday,
      String saturday,
      ) {
    List<double> values = [
      value.calculateDailyExpenseSummary()[sunday] ?? 0,
      value.calculateDailyExpenseSummary()[monday] ?? 0,
      value.calculateDailyExpenseSummary()[tuesday] ?? 0,
      value.calculateDailyExpenseSummary()[wedsday] ?? 0,
      value.calculateDailyExpenseSummary()[thursday] ?? 0,
      value.calculateDailyExpenseSummary()[friday] ?? 0,
      value.calculateDailyExpenseSummary()[saturday] ?? 0,
    ];
    double total = 0;
    for (int i = 0; i < values.length; i++) {
      total += values[i];
    }
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    //get yymmdd for each day of this week
    String sunday =
    convertDateTimeToString(startOfWeek.add(const Duration(days: 0)));
    String monday =
    convertDateTimeToString(startOfWeek.add(const Duration(days: 1)));
    String tuesday =
    convertDateTimeToString(startOfWeek.add(const Duration(days: 2)));
    String wedsday =
    convertDateTimeToString(startOfWeek.add(const Duration(days: 3)));
    String thursday =
    convertDateTimeToString(startOfWeek.add(const Duration(days: 4)));
    String friday =
    convertDateTimeToString(startOfWeek.add(const Duration(days: 5)));
    String saturday =
    convertDateTimeToString(startOfWeek.add(const Duration(days: 6)));

    return Consumer<ExpenseData>(
        builder: (context, value, child) => Column(
          children: [
            //week total
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  const Text(
                    'Week Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                      '\₹${calculateWeekTotal(value, sunday, monday, tuesday, wedsday, thursday, friday, saturday)}'),
                ],
              ),
            ),
            //bar graph
            SizedBox(
              height: 200,
              child: MyBarGraph(
                maxY: calculateMax(value, sunday, monday, tuesday, wedsday,
                    thursday, friday, saturday),
                sunAmount:
                value.calculateDailyExpenseSummary()[sunday] ?? 0,
                monAmount:
                value.calculateDailyExpenseSummary()[monday] ?? 0,
                tueAmount:
                value.calculateDailyExpenseSummary()[tuesday] ?? 0,
                wedAmount:
                value.calculateDailyExpenseSummary()[wedsday] ?? 0,
                thurAmount:
                value.calculateDailyExpenseSummary()[thursday] ?? 0,
                friAmount:
                value.calculateDailyExpenseSummary()[friday] ?? 0,
                satAmount:
                value.calculateDailyExpenseSummary()[saturday] ?? 0,
              ),
            ),
          ],
        ));
  }
}
