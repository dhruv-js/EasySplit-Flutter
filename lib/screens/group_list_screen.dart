// import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_my_bill/providers/google_sign_in_provider.dart';
import 'package:split_my_bill/providers/groups.dart';
import 'package:split_my_bill/widgets/create_group_sheet.dart';
import 'package:split_my_bill/widgets/group_tile.dart';
import 'package:split_my_bill/widgets/transaction_tile.dart';

class GroupListScreen extends StatelessWidget {
  static const routeName = '/group-list';

  void addGroup(BuildContext context, bool create) async {
    final result = await showModalBottomSheet(
      context: context,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(35.0),
        ),
      ),
      builder: (context) {
        return CreateGroupSheet(create);
      },
    );
    if (result != null && create) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Pin'),
                content: Text('Pin for the created group is $result'),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Okay'))
                ],
              ));
    }else if(result != null){
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('$result'),
          duration: Duration(seconds: 2),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // final groupsData = Provider.of<Groups>(context);
    // final groups = groupsData.items;
    final google = Provider.of<GoogleSignInProvider>(context);
    final uid = google.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groups'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Create Group'),
                  value: 'create',
                ),
                PopupMenuItem(
                  child: Text('Join Group'),
                  value: 'join',
                ),
                PopupMenuItem(
                  child: Text('Logout'),
                  value: 'logout',
                ),
              ];
            },
            onSelected: (choice) {
              if (choice == 'logout') {
                google.logout();
              } else if (choice == 'create') {
                addGroup(context, true);
              } else if (choice == 'join') {
                addGroup(context, false);
              }
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .where("users", arrayContains: uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            if (snapshot.data == null)
              return Center(
                child: Text('No groups added'),
              );
            final groups = snapshot.data.docs;
            // return Center(child: Text('jfgjgew'),);
            // log(groups[0].data().toString());
            if (groups.length == 0) {
              return Center(child: Text('No groups added'));
            }
            // log(groups.toString());
            // log(groups.length.toString());
            // log(groups[0].data().toString());
            return ListView.builder(
              itemBuilder: (ctx, i) {
                final data = groups[i].data();
                // return Text('jkgkh');
                return GroupTile(data['id'], data['name'], uid);
              },
              //ChangeNotifierProvider.value(
              //   value: groups[i],
              //   child: Text('group $i'),
              // ),
              itemCount: groups.length,
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          return addGroup(context, true);
          // return PopupMenuButton(
          //   itemBuilder: (context) {
          //     return [
          //       PopupMenuItem(
          //         child: Text('Create Group'),
          //         value: 'create',
          //       ),
          //       PopupMenuItem(
          //         child: Text('Join Group'),
          //         value: 'join',
          //       ),
          //     ];
          //   },
          //   onSelected: (choice) {
          //     if (choice == 'create') {
          //       addGroup(context, true);
          //     } else if (choice == 'join') {
          //       addGroup(context, false);
          //     }
          //   },
          // );
        },
      ),
    );
  }
}
/*
ElevatedButton.styleFrom(
                padding: EdgeInsets.all(8.0),
                shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0))),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
 */
