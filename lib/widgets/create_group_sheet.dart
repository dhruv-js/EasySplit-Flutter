import 'dart:developer' as logger;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_my_bill/providers/google_sign_in_provider.dart';

class CreateGroupSheet extends StatefulWidget {
  final bool create;

  CreateGroupSheet(this.create);

  @override
  _CreateGroupSheetState createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  bool join = false;
  bool successful = true;

  @override
  void dispose() {
    nameController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String str;
    if (widget.create) {
      str = 'Create Group';
    } else {
      str = 'Join Group';
    }
    final googleProvider = Provider.of<GoogleSignInProvider>(context);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Color(0x11FCF2CD),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(35.0),
        ),
      ),
      padding: EdgeInsets.all(8.0),
      // color: Theme.of(context).accentColor,

      child: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            if (widget.create)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    // labelText: 'Name',
                    hintText: 'Enter Group Name',
                  ),
                  controller: nameController,
                ),
              ),
            if (!widget.create)
              TextField(
                decoration:
                    InputDecoration(labelText: 'Pin', hintText: 'Enter Pin'),
                controller: pinController,
                keyboardType: TextInputType.number,
              ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
            ),
            ElevatedButton(
              onPressed: () async {
                if (widget.create) {
                  logger.log('jhjkkjh');
                  createGroup(
                      googleProvider.uid, googleProvider.displayName).then((pin) => Navigator.of(context).pop(pin));
                } else {
                  // bool successful = true;
                  joinGroup(googleProvider.uid, googleProvider.displayName,
                          int.parse(pinController.text))
                      .whenComplete(() {
                    if (successful) {
                      return Navigator.of(context)
                          .pop('Group joined successfully');
                    } else {
                      return Navigator.of(context).pop('An error occurred!!');
                    }
                  });
                  logger.log('successful $successful');
                }
                logger.log('end');
              },
              child: Text(str),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> joinGroup(String uid, String name, int pin) async {
    logger.log('start');
    var checkGroupRef = FirebaseFirestore.instance.collection(
        'groups'); //.where('pin', isEqualTo: pin).limit(1).snapshots();
    await checkGroupRef
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get()
        .then((value) {
      if (value.size == 1) {
        logger.log(value.docs[0].data().toString());
        List<dynamic> users = value.docs[0].data()['users'];
        if (users.contains(uid)) {
          return null;
        }
        List<dynamic> nameOfUsers = value.docs[0].data()['nameOfUsers'];
        List<dynamic> amountOwed = value.docs[0].data()['amountOwed'];
        int i = 2;
        String tempName = name;
        while (nameOfUsers.contains(tempName)) {
          tempName = tempName + ' $i';
          i++;
        }
        nameOfUsers.add(tempName);
        amountOwed.add(0.0);
        logger.log('fin');
        return FirebaseFirestore.instance
            .collection('groups')
            .doc(value.docs[0].id)
            .update({
              'nameOfUsers': FieldValue.arrayUnion([tempName]),
              'users': FieldValue.arrayUnion([uid]),
              'amountOwed': amountOwed,
            });
      } else {
        successful = false;
      }
    });
  }

  Future<String> createGroup(String uid, String name) async{
    logger.log(nameController.text);
    if (nameController.text != '') {
      logger.log('hghjghjg');
      var newGroupRef = FirebaseFirestore.instance.collection('groups').doc();
      Random random = new Random();
      int pin = random.nextInt(900000) + 100000;
      logger.log(newGroupRef.id.toString());
      logger.log('id above');

      await newGroupRef.set({
        'name': nameController.text,
        'createdAt': Timestamp.now(),
        'users': [uid],
        'amountOwed': [0.0],
        'nameOfUsers': [name],
        'id': newGroupRef.id,
        'pin': pin,
      });
      return pin.toString();
    }
    return null;
  }
}
