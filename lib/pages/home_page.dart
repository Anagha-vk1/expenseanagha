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
  final expenseNameController=TextEditingController();
  final expenserupeeController=TextEditingController();
  final expensepaisaController=TextEditingController();
  TextEditingController limitController=TextEditingController();
  int? dailyLimit;

  @override
  void initState(){
    super.initState();

    fetchDailyLimit();
    Provider.of<ExpenseData>(context,listen: false).prepareData();
  }
  Future<void> fetchDailyLimit() async {
    dailyLimit = await getDailyLimit();
    setState(() {}); // This triggers a rebuild of the widget.
  }

  void addNewExpense(){
    showDialog(context: context,barrierDismissible: false, builder: (context)=>AlertDialog(title: Text('add new expense'),
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
      MaterialButton(onPressed:() {
        save();
        Navigator.pop(context);
        final totalExpenses = calculateTotalExpenses();
        print(dailyLimit!);
        print(totalExpenses);// Convert the daily limit input to an integer.
        if (totalExpenses > dailyLimit!) {
          // Total expenses exceed the daily limit, show a dialog.
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
                    Navigator.pop(context); // Close the exceeded limit dialog.
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },child:const Text('save')),
      MaterialButton(onPressed: cancel,child:Text('cancel'))
    ],)
    );
  }
void deleteExpsense(ExpenseItem expense){
  Provider.of<ExpenseData>(context,listen: false).deleteExpense(expense);
}
  int calculateTotalExpenses() {
    final List<ExpenseItem> allExpenses = Provider.of<ExpenseData>(context, listen: false).getAllExpenseList();
    int total = 0;
    for (final expense in allExpenses) {
      total += int.parse(expense.amount);
    }
    return total;
  }
  void save(){
    print("hiiiiiiii");
    if(expenserupeeController.text.isNotEmpty && expensepaisaController.text.isNotEmpty && expenseNameController.text.isNotEmpty) {
      String amount =
          '${expenserupeeController.text}.${expensepaisaController.text}';
      ExpenseItem newExpense = ExpenseItem(
        name: expenseNameController.text,
        amount: amount,
        dateTime: DateTime.now(),
      );
      print("success");

      Provider.of<ExpenseData>(context, listen: false)
          .addNewExpense(newExpense);

      clear();
    }
  }
  void cancel(){
    Navigator.pop(context);
    clear();
  }
  void clear(){
    expenseNameController.clear();
    expenserupeeController.clear();
    expensepaisaController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>( builder: (context, value, child) => Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: addNewExpense,
        child: Icon(Icons.add),
      ),
    body:ListView(children: [
      //weeklr summary
      ExpenseSummary(
        startOfWeek: value.startOfWeekDate() ?? DateTime.now(),
      ),
      Text(
        'Daily Limit: ${dailyLimit.toString()}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      //expense list
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: value.getAllExpenseList().length,
        itemBuilder: (context, index) => ExpenseTile(
          name: value.getAllExpenseList()[index].name,
          amount: value.getAllExpenseList()[index].amount,
          dateTime: value.getAllExpenseList()[index].dateTime,
deleteTapped:(p0)=>deleteExpsense(value.getAllExpenseList()[index]) ,
        ), //ExpenseTile
      ),
      ElevatedButton(
        onPressed: () => _showLimitInputDialog(context),
        child: Text('Set Daily Limit'),
      ),
    ]))
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
                int dailyLimit = int.tryParse(limitController.text) ?? 0;
                print(dailyLimit);
                saveDailyLimit(dailyLimit);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveDailyLimit(int dailyLimit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('dailyLimit', dailyLimit);
    setState(() {
      this.dailyLimit = int.tryParse(dailyLimit as String) ?? 0;
    });
    print(prefs);
  }

  Future<int> getDailyLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getInt('dailyLimit'));
    return prefs.getInt('dailyLimit') ?? 0;

  }

}

