import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  void Function(BuildContext)? deleteTapped;

 ExpenseTile({
    Key? key,
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.deleteTapped,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          //delete btn

          SlidableAction(
            onPressed: deleteTapped,
            icon: Icons.delete,
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          //edit btn
          // SlidableAction(
          //   onPressed: deleteTapped,
          //   icon: Icons.settings,
          //   backgroundColor: Colors.green,
          //   borderRadius: BorderRadius.circular(4),
          // )
        ],
      ),
      child: ListTile(
        title: Text(name),
        subtitle: Text('${dateTime.day}/${dateTime.month}/${dateTime.year}'),
        trailing: Text('Rs:' + amount),
      ),
    );
  }
}
