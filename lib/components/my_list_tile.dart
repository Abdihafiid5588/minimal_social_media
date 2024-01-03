import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget? trailing;

  const MyListTile({
    Key? key,
    required this.title,
    required this.subTitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          title: Text(title),
          subtitle: Text(
            subTitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}
