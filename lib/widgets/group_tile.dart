// import 'dart:developer';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:split_my_bill/providers/group.dart';
import 'package:split_my_bill/screens/group_detail_screen.dart';

class GroupTile extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String uid;

  GroupTile(this.groupId, this.groupName, this.uid);

  @override
  Widget build(BuildContext context) {
    Color _color = Theme.of(context).accentColor;
    return FutureBuilder(
      future:
          FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
      builder: (ctx, snapshot) {
        // log(snapshot.data.toString());
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(title: Text('Loading...'));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error Loading Data!!'));
        } else if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          // print('data');
          // print(data.toString());
          // print('data end');
          List<dynamic> nameOfUsers =
              (data['nameOfUsers']); //.map((e) => e.toString())).toList();
          List<dynamic> users = data['users']; // as List<String>;
          List<dynamic> amountOwed =
              data['amountOwed']; //.cast<int>();// as List<int>;
          int index = users.indexOf(uid);
          // print(index.toString());
          // print(amountOwed.toString());
          String text;
          // log(groupName);
          // log(amountOwed[index].toString());
          // log(amountOwed[index].round().toString());
          if (amountOwed[index].round() == 0) {
            text = 'You are all settled up';
          } else if (amountOwed[index] > 0) {
            text = 'You owe ₹${amountOwed[index].round().toString()}';
          } else {
            text =
                'You are owed ₹${amountOwed[index].abs().round().toString()}';
          }
          return Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 6.0),
            child: Card(
              elevation: 4,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actions: [
                  IconSlideAction(
                    caption: 'Delete',
                    icon: Icons.delete,
                    color: Colors.red,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Delete!!'),
                        content: Text(
                            'Are you sure want to delete this transaction'),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
                              // deleteTransaction();
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                child: ListTile(
                  onTap: () => Navigator.of(context)
                      .pushNamed(GroupDetailScreen.routeName, arguments: [
                    users,
                    nameOfUsers,
                    amountOwed,
                    groupId,
                    groupName,
                  ]),
                  title: Text(
                    groupName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  subtitle: Text(text),
                  //${amountOwed[index]}
                  leading: Hero(
                      tag: groupId,
                      child: CircleAvatar(
                        // foregroundImage:
                        //     AssetImage('assets/images/snap-easy.jpeg'),
                        child: Text(
                          groupName[0],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white,fontSize: 24,),
                        ),
                        backgroundColor: Color(0xff14C0CC),
                      )),
                ),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }


}
