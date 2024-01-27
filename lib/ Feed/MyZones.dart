import 'package:flutter/material.dart';
import 'package:teen/%20Feed/MyZoneCell.dart';

class MyZones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: MyZoneCell(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
