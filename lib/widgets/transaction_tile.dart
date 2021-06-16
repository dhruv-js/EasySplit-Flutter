import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:split_my_bill/screens/new_transaction_screen.dart';

class TransactionTile extends StatelessWidget {
  final String groupId;
  final String transactionId;
  final String paidByName;
  final String label;
  final double amount;
  final String uid;
  final List<dynamic> nameOfUsers;
  final List<dynamic> users;

  // FirebaseAuth.

  TransactionTile(
    this.groupId,
    this.transactionId,
    this.label,
    this.amount,
    this.paidByName,
    this.uid,
    this.nameOfUsers,
    this.users,
  );

//future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
//   if (snapshot.connectionState == ConnectionState.done) {
//   Map<String, dynamic> data = snapshot.data.data();
//   bool url = true;
//   if (data['imageUrl'] == '' || data['imageUrl'] == null){
//   url = false;
//   }
//   }
  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //
    //   builder: (context, snapshot) {
    //
    //       // log('data');
    //       // log(data.toString());
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 6.0),
      child: Card(
        elevation: 8,
        child: Slidable(
          // actionExtentRatio: 1/2,
          actionPane: SlidableDrawerActionPane(),
          actions: [
            IconSlideAction(
              caption: 'Edit',
              icon: Icons.edit,
              color: Colors.amberAccent,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => NewTransactionScreen(
                    isEditing: true,
                    label: label,
                    groupId: groupId,
                    amount: amount,
                    paidByName: paidByName,
                    nameOfUsers: nameOfUsers,
                    transactionId: transactionId,
                    users: users,
                  ),
                ),
              ),
            ),
            IconSlideAction(
              caption: 'Delete',
              icon: Icons.delete,
              color: Colors.red,
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Delete!!'),
                  content: Text('Are you sure want to delete this transaction'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteTransaction();
                      },
                      child: Text('Yes'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: ListTile(
            key: Key(transactionId),
            leading: FutureBuilder(
              future:
                  FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data = snapshot.data.data();
                  bool url = true;
                  if (data['imageUrl'] == '' || data['imageUrl'] == null) {
                    url = false;
                  }
                  return CircleAvatar(
                    foregroundImage:
                        url ? NetworkImage(data['imageUrl']) : null,
                    backgroundColor: Theme.of(context).primaryColor,
                  );
                }
                return CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                );
              },
            ),
            title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            // subtitle: Text('Paid by ${data['name']}'),
            subtitle: Text('Paid by $paidByName'),
            trailing: Text(
              '₹ ${amount.toStringAsFixed(0).toString()}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void deleteTransaction() async {
    var grpRef = FirebaseFirestore.instance.collection('groups').doc(groupId);
    var deleteTransactionRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('transactions')
        .doc(transactionId);
    DocumentSnapshot transactionSnapshot = await deleteTransactionRef.get();
    var transactionSnapshotData = transactionSnapshot.data();
    double wasAmount = amount; // transactionSnapshotData['amount'];
    String paidById = uid; //transactionSnapshotData['paidBy'];
    int index = users.indexOf(paidById);
    int totalPeople = transactionSnapshotData['dividedAmong'];
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await grpRef.get();
      if (!snapshot.exists) {
        throw Exception("Doc does not exist");
      }
      var snapshotData = snapshot.data();
      List<dynamic> amountOwed = snapshotData['amountOwed'];
      double perPerson = wasAmount / totalPeople;
      for (int i = 0; i < totalPeople; i++) {
        amountOwed[i] -= perPerson;
      }
      amountOwed[index] += wasAmount;
      transaction.update(grpRef, {'amountOwed': amountOwed});
    }).then((value) => deleteTransactionRef.delete());
    // FirebaseFirestore.instance
    //     .collection('groups')
    //     .doc(groupId)
    //     .collection('transactions')
    //     .doc(transactionId)
    //     .delete();
  }
}
