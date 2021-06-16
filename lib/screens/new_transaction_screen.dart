import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewTransactionScreen extends StatefulWidget {
  // static const routeName = '/new-transaction';
  final bool isEditing;
  final List<dynamic> users;
  final List<dynamic> nameOfUsers;
  final String groupId;
  final String transactionId;
  final String label;
  final String paidByName;
  final double amount;

  NewTransactionScreen({
    @required this.isEditing,
    this.users,
    @required this.nameOfUsers,
    @required this.groupId,
    this.transactionId,
    this.paidByName,
    this.label,
    this.amount,
  });

  // String chosenValue() {
  //   int index = users.indexOf(paidBy);
  //   return nameOfUsers[index];
  // }

  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController labelController = TextEditingController();
  String _chosenValue;
  bool firstBuild = true;

  @override
  void dispose() {
    amountController.dispose();
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && firstBuild) {
      amountController.text = widget.amount.toString();
      labelController.text = widget.label;
      _chosenValue = widget.paidByName;
      firstBuild = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Label'),
              controller: labelController,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Amount Paid'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),],
              controller: amountController,
            ),
            Container(
              child: DropdownButton(
                items: (widget.nameOfUsers)
                    .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ))
                    .toList(),
                hint: Text('Select a name'),
                value: _chosenValue,
                onChanged: (String value) {
                  setState(() {
                    _chosenValue = value;
                    log(_chosenValue);
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.isEditing ? _editTransaction() : _addTransaction();
                return Navigator.of(context).pop();
              },
              child: Text(
                  widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
            )
          ],
        ),
      ),
    );
  }

  void _editTransaction() async {
    if (amountController.text != '' && _chosenValue != null) {
      if (double.tryParse(amountController.text) == null) {
        return;
      }
      double amt = double.parse(amountController.text);

      String label = labelController.text;

      var grpRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      var editTransactionRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('transactions')
          .doc(widget.transactionId);
      String paidById = widget.users[widget.nameOfUsers.indexOf(_chosenValue)];
      DocumentSnapshot transactionSnapshot = await editTransactionRef.get();
      var transactionSnapshotData = transactionSnapshot.data();
      var timeStamp = transactionSnapshotData['createdAt'];
      int dividedAmong = transactionSnapshotData['dividedAmong'];
      String wasPaidById = transactionSnapshotData['paidBy'];
      double wasAmount = transactionSnapshotData['amount'];
      if (amt != wasAmount ||
          label != transactionSnapshotData['label'] ||
          paidById != wasPaidById) {
        var newTransactionRef = FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('transactions')
            .doc();
        await newTransactionRef.set({
          'id': newTransactionRef.id,
          'amount': amt,
          'createdAt': timeStamp,
          'paidBy': paidById,
          'label': label,
          'dividedAmong': dividedAmong,
        }).then((value) => editTransactionRef.delete());
        // editTransactionRef.update({
        //   'amount': amt,
        //   'paidBy': paidBy,
        //   'label': label,
        // });
      }
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(grpRef);
        // DocumentSnapshot snapshot2 = await transaction.get(editTransactionRef);
        if (!snapshot.exists) {
          throw Exception("Doc does not exist");
        }
        var snapshotData = snapshot.data();
        // var snapshotData2 = snapshot2.data();
        int index = snapshotData['nameOfUsers'].indexOf(_chosenValue);
        log(snapshotData.toString());
        // log(snapshotData['users']);
        // log(snapshotData['paidBy']);
        int wasIndex = snapshotData['users'].indexOf(wasPaidById);
        // String paidBy = snapshotData['users'][index];

        // if (amt != transactionSnapshot['amount'] ||
        //     label != transactionSnapshot['label'] ||
        //     paidBy != transactionSnapshot['paidBy']) {
        //   var newTransactionRef = FirebaseFirestore.instance
        //       .collection('groups')
        //       .doc(widget.groupId)
        //       .collection('transactions')
        //       .doc();
        //   await newTransactionRef.set({
        //     'id': newTransactionRef.id,
        //     'amount': amt,
        //     'createdAt': Timestamp.now(),
        //     'paidBy': paidById,
        //     'label': label,
        //     'dividedAmong': dividedAmong,
        //   }).then((value) => editTransactionRef.delete());
          // editTransactionRef.update({
          //   'amount': amt,
          //   'paidBy': paidBy,
          //   'label': label,
          // });
        // }
        log('above');
        // log(paidBy);
        // log(paidById);
        if (amt != widget.amount || wasPaidById != paidById) {
          log('below');
          List<dynamic> amountOwed = snapshot.data()['amountOwed'];
          log(amountOwed.toString());
          int wasTotalPeople = dividedAmong;
          log(wasTotalPeople.toString());
          // double wasAmount = snapshotData2['amount'];
          log(wasAmount.toString());
          double wasPerPerson = double.parse((wasAmount / wasTotalPeople).toStringAsFixed(2));
          log(wasPerPerson.toString());
          double perPerson = double.parse((amt / wasTotalPeople).toStringAsFixed(2));
          log(perPerson.toString());
          // log('here');
          for (int i = 0; i < wasTotalPeople; i++) {
            if (i == index){
              continue;
            }
            amountOwed[i] += perPerson - wasPerPerson;
            log('loop');
          }
          amountOwed[index] += (amt-wasAmount) - (wasTotalPeople-1) * (perPerson-wasPerPerson);
          log('was Index $wasIndex');
          log('index $index');
          amountOwed[wasIndex] += wasAmount;
          amountOwed[index] -= amt;
          transaction.update(grpRef, {'amountOwed': amountOwed});
          log(amountOwed.toString());
        }
      });
      // var newTransactionRef = FirebaseFirestore.instance
      //     .collection('groups')
      //     .doc(widget.groupId)
      //     .collection('transactions')
      //     .doc();
      // await newTransactionRef.set({
      //   'id': newTransactionRef.id,
      //   'amount': amt,
      //   'createdAt': Timestamp.now(),
      //   'paidBy': paidById,
      //   'label': label,
      //   'dividedAmong': dividedAmong,
      // });
    }
  }

  void _addTransaction() async {
    if (amountController.text != '' && _chosenValue != null) {

      if (double.tryParse(amountController.text) == null) {
        return;
      }
      double amt = double.parse(amountController.text);
      String label = labelController.text;

      var grpRef =
          FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(grpRef);
        if (!snapshot.exists) {
          throw Exception("Doc does not exist");
        }
        var snapshotData = snapshot.data();
        int index = snapshotData['nameOfUsers'].indexOf(_chosenValue);
        String paidBy = snapshotData['users'][index];
        List<dynamic> amountOwed = snapshotData['amountOwed'];
        int dividedAmong = amountOwed.length;
        double perPerson = double.parse((amt / dividedAmong).toStringAsFixed(2));
        for (int i = 0; i < amountOwed.length; i++) {
          if (i==index){
            continue;
          }
          amountOwed[i] += perPerson;
        }
        amountOwed[index] += amt - (amountOwed.length-1) * perPerson;
        amountOwed[index] -= amt;
        transaction.update(grpRef, {'amountOwed': amountOwed});
        log(amountOwed.toString());


        var newTransactionRef = FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('transactions')
            .doc();
        await newTransactionRef.set({
          'id': newTransactionRef.id,
          'amount': amt,
          'createdAt': Timestamp.now(),
          'paidBy': paidBy,
          'label': label,
          'dividedAmong': dividedAmong,
        });
      });



      // widget.amountOwed[index] -= amt;
      // for (int i=0; i<totalPeople; i++){
      //   widget.amountOwed[i] += perPerson;
      // }
      // await grpRef.update({
      //   'amountOwed': widget.amountOwed,
      // });
    }
  }
}
