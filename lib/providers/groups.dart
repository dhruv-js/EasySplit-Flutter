import 'package:flutter/material.dart';
import 'package:split_my_bill/providers/group.dart';

class Groups with ChangeNotifier{
  List<Group> _items = [
    Group(id: 'GNfyq8ufx5E9Pumjalnt', title: 'Chandru', members: ['Geet', 'Sarthak', 'Devansh',],),
    Group(id: 'ySEk2FWw9hsxkVW6TojD', title: 'C lite', members: ['Kohav', 'Harsal', 'Adit', 'Harsh',],),
  ];

  List<Group> get items{
    return [..._items];
  }
  List<String> myGroups = ['GNfyq8ufx5E9Pumjalnt'];

  Group findById(String id){
    return _items.firstWhere((e) => e.id == id);
  }

  void addGroup(Group group){
    _items.add(group);
    notifyListeners();
  }
}