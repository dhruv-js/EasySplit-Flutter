import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:split_my_bill/screens/record_payment_screen.dart';

class SettleScreen extends StatelessWidget {
  static const routeName = '/settle-screen';

  // final String groupId;

  @override
  Widget build(BuildContext context) {
    final String groupId = ModalRoute.of(context).settings.arguments as String;
    // List<dynamic> nameOfUsers = args[0];
    // List<dynamic> users = args[1];
    // List<dynamic> amountOwed = args[2];
    return Scaffold(
      appBar: AppBar(
        title: Text('Settle'),
      ),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('waiting'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error Loading Data!!'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            log(data.toString());
            List<dynamic> nameOfUsers = (data['nameOfUsers']);
            List<dynamic> users = data['users'];
            List<dynamic> amountOwedTemp = data['amountOwed'];
            List<double> amountOwed =
                amountOwedTemp.map((e) => double.parse(e.toString())).toList();
            print(amountOwed);
            List<List<Object>> settleTransactions = minCashFlow(amountOwed);

            // print(amountOwed);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, i) {
                      double amount = settleTransactions[i][2];
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 4.0,
                          right: 4.0,
                          top: 6.0,
                        ),
                        child: Card(
                          child: ListTile(
                            title: Text(
                              '${nameOfUsers[settleTransactions[i][0]]} owes ${nameOfUsers[settleTransactions[i][1]]}',
                            ),
                            trailing: Text(
                              'Rs ${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: settleTransactions.length,
                  ),
                  // child: ListView.builder(
                  //   itemBuilder: (ctx, i) {
                  //     String text;
                  //     String amt;
                  //     Color color;
                  //     if (double.parse(amountOwed[i].abs().toStringAsFixed(2))
                  //             .round() ==
                  //         0) {
                  //       return Padding(
                  //         padding: const EdgeInsets.only(
                  //             left: 4.0, right: 4.0, top: 6.0),
                  //         child: Card(
                  //           child: ListTile(
                  //             title:
                  //                 Text('${nameOfUsers[i]} is all settled up'),
                  //           ),
                  //         ),
                  //       );
                  //     } else if (amountOwed[i].round() > 0) {
                  //       text = 'owes';
                  //       amt = amountOwed[i].abs().toStringAsFixed(2);
                  //       color = Colors.red;
                  //     } else {
                  //       text = 'is owed';
                  //       amt = amountOwed[i].abs().toStringAsFixed(2);
                  //       color = Colors.green;
                  //     }
                  //     return Padding(
                  //       padding: const EdgeInsets.only(
                  //           left: 4.0, right: 4.0, top: 6.0),
                  //       child: Card(
                  //         child: ListTile(
                  //           title: Text('${nameOfUsers[i]} $text'),
                  //           trailing: Text(
                  //             '₹ $amt',
                  //             style: TextStyle(
                  //                 color: color,
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.w600),
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   itemCount: amountOwed.length,
                  // ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    RecordPaymentScreen.routeName,
                    arguments: [groupId, users, nameOfUsers],
                  ),
                  child: Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      padding: EdgeInsets.all(12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ],
            );
          }
          return Center(
            child: Text('An error has occurred. Please try again later.'),
          );
        },
      ),
    );
  }

  List<List<Object>> minCashFlow(List<double> amountOwed) {
    // List<int> amountOwed = [-500, 200, 300];
    List<List<Object>> settleTransactions = [];
    return minCashFlowRec(amountOwed, settleTransactions);
  }

  List<List<Object>> minCashFlowRec(
    List<double> amount,
    List<List<Object>> settleTransactions,
  ) {
    int mxDebit = getMax(amount), mxCredit = getMin(amount);

    // If both amounts are 0, then
    // all amounts are settled
    if (amount[mxCredit] == 0 || amount[mxDebit] == 0) {
      return settleTransactions;
    }

    // Find the minimum of two amounts
    double minn = minOf2(amount[mxDebit], -amount[mxCredit]);
    amount[mxCredit] += minn;
    amount[mxDebit] -= minn;

    // If minimum is the maximum amount to be
    settleTransactions.add([mxDebit, mxCredit, minn]);
    print("Person $mxDebit pays $minn to Person $mxCredit");

    return minCashFlowRec(amount, settleTransactions);
  }

  double minOf2(double x, double y) {
    return (x < y) ? x : y;
  }

  int getMax(List<double> arr) {
    int maxInd = 0;
    for (int i = 1; i < arr.length; i++) {
      if (arr[i] > arr[maxInd]) {
        maxInd = i;
      }
    }
    return maxInd;
  }

  int getMin(List<double> arr) {
    int minInd = 0;
    for (int i = 1; i < arr.length; i++) {
      if (arr[i] < arr[minInd]) {
        minInd = i;
      }
    }
    return minInd;
  }
}
