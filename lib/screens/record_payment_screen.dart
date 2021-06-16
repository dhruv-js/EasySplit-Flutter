import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecordPaymentScreen extends StatefulWidget {
  static const routeName = '/record-payment';

  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  String _payer;
  String _payee;
  TextEditingController amountController = TextEditingController();
  List<dynamic> nameOfUsers;
  List<dynamic> users;
  String groupId;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List<Object>;
    groupId = args[0];
    users = args[1];
    nameOfUsers = args[2];
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who is paying?',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10),
            Container(
              child: DropdownButton(
                // style: TextStyle(fontSize: 18),
                // isExpanded: true,
                // isDense: true,
                items: (nameOfUsers)
                    .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ))
                    .toList(),
                hint: Text(
                  'Select',
                  style: TextStyle(fontSize: 18),
                ),
                value: _payer,
                onChanged: (String value) {
                  setState(() {
                    _payer = value;
                    log(_payer);
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Who is getting paid?',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Container(
              child: DropdownButton(
                // style: TextStyle(fontSize: 18),
                items: (nameOfUsers)
                    .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ))
                    .toList(),
                hint: Text(
                  'Select',
                  style: TextStyle(fontSize: 18),
                ),
                value: _payee,
                onChanged: (String value) {
                  setState(() {
                    _payee = value;
                    log(_payee);
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'The amount that is being paid:',
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),],
              controller: amountController,
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 18),
                hintText: 'Enter the amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  FontAwesomeIcons.rupeeSign,
                  size: 20,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => _recordPayment(context),
                child: Text('Record'))
          ],
        ),
      ),
    );
  }

  void _recordPayment(BuildContext context) async {
    if (amountController.text != '' && _payee != null && _payer != null) {
      int payerIndex = nameOfUsers.indexOf(_payer);
      int payeeIndex = nameOfUsers.indexOf(_payee);
      if (payeeIndex == payerIndex) {
        return;
      }
      if (double.tryParse(amountController.text) == null) {
        return;
      }
      double amt = double.parse(amountController.text);
      if (amt<=0){
        return;
      }
      setState(() {
        amountController.text = '';
        _payer = null;
        _payee = null;
      });
      var recordRef = FirebaseFirestore.instance.collection('groups').doc(groupId).collection('records').doc();
      await recordRef.set({
        'recordId': recordRef.id,
        'createdAt': Timestamp.now(),
        'payer': users[payerIndex],
        'payee': users[payeeIndex],
        'amount': amt
      });
      var grpRef = FirebaseFirestore.instance.collection('groups').doc(groupId);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(grpRef);
        if (!snapshot.exists) {
          throw Exception("Doc does not exist");
        }

        List<dynamic> amountOwed = snapshot.data()['amountOwed'];
        amountOwed[payerIndex] -= amt;
        amountOwed[payeeIndex] += amt;
        transaction.update(grpRef, {'amountOwed': amountOwed});
        log(amountOwed.toString());
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    }
  }
}
