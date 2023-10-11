import 'package:expenseanagha/components/expense_summary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../components/expense_tile.dart';
import '../data/expense_data.dart';
import '../models/expense_item.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final expenseNameController = TextEditingController();
  final expenserupeeController = TextEditingController();
  final expensepaisaController = TextEditingController();
  TextEditingController limitController=TextEditingController();
  double dailyLimit = 0.0; // Change the data type to double

  @override
  void initState() {
    super.initState();

    fetchDailyLimit();
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  Future<void> fetchDailyLimit() async {
    dailyLimit = await getDailyLimit();
    setState(() {});
  }

  void addNewExpense() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Add New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: expenseNameController,
              decoration: const InputDecoration(
                hintText: "Expense Name",
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: expenserupeeController,
                    decoration: const InputDecoration(
                      hintText: "Rupees",
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: expensepaisaController,
                    decoration: const InputDecoration(
                      hintText: "Paisa",
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              save();
              Navigator.pop(context);
              final totalExpenses = calculateTotalExpenses();
              print(totalExpenses);
              if (totalExpenses > dailyLimit) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Daily Limit Exceeded'),
                    content: Text(
                      'Total expenses ($totalExpenses) exceed the daily limit ($dailyLimit).',
                    ),
                    actions: [
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
          MaterialButton(
            onPressed: cancel,
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  double calculateTotalExpenses() {
    final List<ExpenseItem> allExpenses =
    Provider.of<ExpenseData>(context, listen: false).getAllExpenseList();
    double total = 0.0; // Initialize total as a double
    for (final expense in allExpenses) {
      total += double.parse(expense.amount);
    }
    return total;
  }

  void save() {
    if (expenserupeeController.text.isNotEmpty &&
        expensepaisaController.text.isNotEmpty &&
        expenseNameController.text.isNotEmpty) {
      String amount =
          '${expenserupeeController.text}.${expensepaisaController.text}';
      ExpenseItem newExpense = ExpenseItem(
        name: expenseNameController.text,
        amount: amount,
        dateTime: DateTime.now(),
      );

      Provider.of<ExpenseData>(context, listen: false).addNewExpense(newExpense);

      clear();
    }
  }

  void cancel() {
    Navigator.pop(context);
    clear();
  }

  void clear() {
    expenseNameController.clear();
    expenserupeeController.clear();
    expensepaisaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[300],
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: addNewExpense,
          child: Icon(Icons.add),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Weekly summary
                  ExpenseSummary(
                    startOfWeek: value.startOfWeekDate() ?? DateTime.now(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:25.0,left: 16),
                    child: Text(
                      'Daily Limit: ${dailyLimit.toStringAsFixed(2)}', // Format the double with two decimal places
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Expense list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: value.getAllExpenseList().length,
                    itemBuilder: (context, index) => ExpenseTile(
                      name: value.getAllExpenseList()[index].name,
                      amount: value.getAllExpenseList()[index].amount,
                      dateTime: value.getAllExpenseList()[index].dateTime,
                      deleteTapped: (p0) =>
                          deleteExpense(value.getAllExpenseList()[index]),
                    ),
                  ),

                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showLimitInputDialog(context),
              child: Text('Set Daily Limit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLimitInputDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Daily Limit'),
          content: TextField(
            controller: limitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter the daily limit'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                double newDailyLimit = double.tryParse(limitController.text) ?? 0;
                saveDailyLimit(newDailyLimit);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveDailyLimit(double newDailyLimit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('dailyLimit', newDailyLimit);
    setState(() {
      dailyLimit = newDailyLimit;
    });
  }

  Future<double> getDailyLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('dailyLimit') ?? 0;
  }
}
