import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:whatsalyzer/Models/graphData.model.dart';

import '../main.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GeneralScreen extends StatefulWidget {
  Widget body;
  AppBar appBar;
  GeneralScreen({super.key,required this.body,required this.appBar});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  @override
   Widget build(BuildContext context){
    return Scaffold(
      appBar: widget.appBar,
      resizeToAvoidBottomInset: false,

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Images/whatsalyzerBackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: widget.body /* add child content here */,
      ),
    );
  }
}