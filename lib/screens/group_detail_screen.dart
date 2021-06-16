// import 'dart:math';

// import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:split_my_bill/providers/group.dart';
import 'package:split_my_bill/providers/groups.dart';
import 'package:split_my_bill/screens/new_transaction_screen.dart';
import 'package:split_my_bill/screens/record_screen.dart';
import 'package:split_my_bill/screens/settle_screen.dart';
import 'package:split_my_bill/widgets/transaction_tile.dart';

class GroupDetailScreen extends StatelessWidget {
  static const routeName = '/group-detail';

  @override
  Widget build(BuildContext context) {
    final groupDetails =
        ModalRoute.of(context).settings.arguments as List<dynamic>;
    // Group _group = Provider.of<Groups>(context).findById(groupId);

    List<dynamic> users = groupDetails[0];
    List<dynamic> nameOfUsers = groupDetails[1];
    List<dynamic> amountOwed = groupDetails[2];
    final groupId = groupDetails[3];
    final groupName = groupDetails[4];

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('transactions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          if (snapshot.data == null)
            return Center(
              child: Text('No transactions added'),
            );
          final transactions = snapshot.data.docs;

          // print('jvk');
          // print(transactions[0].data().toString());
          // print('kvj');
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                actions: [
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text('Add transaction'),
                          value: 'add',
                        ),
                        PopupMenuItem(
                          child: Text('Payment Record'),
                          value: 'record',
                        ),
                        PopupMenuItem(
                          child: Text('Pin'),
                          value: 'pin',
                        ),
                      ];
                    },
                    onSelected: (choice) {
                      if (choice == 'add') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => NewTransactionScreen(
                              isEditing: false,
                              // users: users,
                              groupId: groupId,
                              nameOfUsers: nameOfUsers,
                            ),
                          ),
                        );
                      } else if (choice == 'record') {
                        Navigator.of(context).pushNamed(RecordScreen.routeName,
                            arguments: [users, nameOfUsers, groupId]);
                      } else if (choice == 'pin') {
                        showPin(context, groupId);
                      }
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.add),
                  //   onPressed: () => Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //         builder: (ctx) => NewTransactionScreen(
                  //               isEditing: false,
                  //               // users: users,
                  //               groupId: groupId,
                  //               nameOfUsers: nameOfUsers,
                  //             )),
                  //   ),
                  // ),
                ],
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(groupName),
                  background: Hero(
                    tag: groupId,
                    // child: Image.asset(
                    //   'assets/images/snap-easy.jpeg',
                    //   fit: BoxFit.fill,
                    // ),
                    child: Container(
                      child: Center(child: Text('EASY\n   SPLIT', style: TextStyle(color: Theme.of(context).accentColor, fontSize: 28),)),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              if (transactions.length > 0)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final tData = transactions[i].data();
                      // log(users.toString());
                      // log(nameOfUsers.toString());
                      // log(tData['paidBy']);
                      final index = users.indexOf(tData['paidBy']);
                      // log(index.toString());
                      return TransactionTile(
                        groupId,
                        tData['id'],
                        tData['label'],
                        tData['amount'].toDouble(),
                        nameOfUsers[index],
                        tData['paidBy'],
                        nameOfUsers,
                        users,
                      );
                    },
                    childCount: transactions.length,
                  ),
                ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: transactions.length == 0
                    ? Center(child: Text('No Transactions'))
                    : SizedBox(
                        height: 600,
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          'Settle',
          style: TextStyle(fontSize: 18),
        ),
        onPressed: () => Navigator.of(context).pushNamed(
          SettleScreen.routeName,
          arguments: groupId,
        ),
        icon: FaIcon(FontAwesomeIcons.handshake),
      ),
    );
  }

  Future<void> showPin(BuildContext context, String groupId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();
    int pin = snapshot.data()['pin'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pin'),
        content: Text('Pin for the created group is $pin'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }
}
