import 'package:flutter/material.dart';

void displayMessageToUser(String messge, BuildContext context) {
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(messge),
    ),
    );
}
