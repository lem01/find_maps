import 'package:flutter/material.dart';

class Street extends StatefulWidget {
  const Street({super.key});

  @override
  State<Street> createState() => _StreetState();
}

class _StreetState extends State<Street> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Street'),
      ),
    );
  }
}
