import 'package:flutter/foundation.dart';

class Group with ChangeNotifier{
  final String id;
  final String title;
  List<String> members;

  Group({
    @required this.id,
    @required this.title,
    @required this.members,
  });

}
