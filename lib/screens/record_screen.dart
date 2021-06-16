import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecordScreen extends StatelessWidget {
  static const routeName = '/record';

  @override
  Widget build(BuildContext context) {
    final groupDetails =
        ModalRoute.of(context).settings.arguments as List<dynamic>;
    List<dynamic> users = groupDetails[0];
    List<dynamic> nameOfUsers = groupDetails[1];
    final groupId = groupDetails[2];

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('records')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data == null)
            return Center(
              child: Text('No transactions added'),
            );
          final records = snapshot.data.docs;
          if (records.length > 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemBuilder: (ctx, i) {
                  final tData = records[i].data();
                  int paidByIndex = users.indexOf(tData['payer']);
                  int payeeIndex = users.indexOf(tData['payee']);
                  String payerName = nameOfUsers[paidByIndex];
                  String payeeName = nameOfUsers[payeeIndex];
                  String amount = tData['amount'].toString();
                  return Card(
                    child: ListTile(
                      leading: FaIcon(FontAwesomeIcons.moneyBill),
                      title: Text('$payerName paid $payeeName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                      trailing: Text(
                        '₹ $amount',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
                itemCount: records.length,
              ),
            );
          }
          return Center(
            child: Text('No payments recorded'),
          );
        },
      ),
    );
  }
}
