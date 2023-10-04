import 'package:expenseanagha/components/expense_summary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState(){
    super.initState();

    Provider.of<ExpenseData>(context,listen: false).prepareData();
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
      MaterialButton(onPressed: save,child:Text('save')),
      MaterialButton(onPressed: cancel,child:Text('cancel'))
    ],)
    );
  }
void deleteExpsense(ExpenseItem expense){
  Provider.of<ExpenseData>(context,listen: false).deleteExpense(expense);
}

  void save(){
    if(expenserupeeController.text.isNotEmpty && expensepaisaController.text.isNotEmpty && expenseNameController.text.isNotEmpty) {
      String amount =
          '${expenserupeeController.text}.${expensepaisaController.text}';
      ExpenseItem newExpense = ExpenseItem(
        name: expenseNameController.text,
        amount: amount,
        dateTime: DateTime.now(),
      );
      Navigator.pop(context);
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
    ]))
    );
  }
}

