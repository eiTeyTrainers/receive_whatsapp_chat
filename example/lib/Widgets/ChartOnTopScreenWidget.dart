import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:whatsalyzer/Models/graphData.model.dart';

import '../main.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class resultChartScreen extends StatefulWidget {
  var listValues; 
  var OptionList;
  var ListIndex;
   resultChartScreen({super.key, required this.listValues, required  this.OptionList, required this.ListIndex});

  @override
  State<resultChartScreen> createState() => _resultChartScreenState();
}

class _resultChartScreenState extends State<resultChartScreen> {
  @override
  Widget build(BuildContext context) {
  double screenHeight = MediaQuery. of(context). size. height;
  double screenWidth = MediaQuery. of(context). size. width;
  String barLabel = widget.OptionList[widget.ListIndex]["barLabel"];
  String chartName = widget.OptionList[widget.ListIndex]["name"];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
    
          title:  Text("תוצאה",
          style: new TextStyle(fontFamily: 'RPT Bold',
          fontSize: 23.0,
          ),
        ),
        ),
          body: widget.listValues.length > 5 ? SfCartesianChart (
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(),
                              title: ChartTitle(text: chartName),
                              // Enable legend
                              legend: Legend(isVisible: true),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              
                              series: <ChartSeries<GraphData, String>>[
                          
                                BarSeries<GraphData, String>(
                                    dataSource: widget.listValues,
                                    xValueMapper: (GraphData listValues, _) => listValues.contact,
                                    yValueMapper: (GraphData listValues, _) => listValues.value,
                                    dataLabelMapper: (GraphData listValues, _) => "${listValues.labelText } ${listValues.value.toString()}",
                                    color: Color.fromARGB(255, 73, 120, 74),
                                    width: 0.8, 
                                    name: barLabel,
                                    // Enable data label
                                    dataLabelSettings: DataLabelSettings(isVisible: true))
                              ]):SfCartesianChart (
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(),
                             isTransposed: true,

                              title: ChartTitle(text: chartName),
                              // Enable legend
                              legend: Legend(isVisible: true),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              
                              series: <ChartSeries<GraphData, String>>[
                          
                                BarSeries<GraphData, String>(
                                    dataSource: widget.listValues,
                                    xValueMapper: (GraphData listValues, _) => listValues.contact,
                                    yValueMapper: (GraphData listValues, _) => listValues.value,
                                    dataLabelMapper: (GraphData listValues, _) => "${listValues.labelText } ${listValues.value.toString()}",
                                    color: Color.fromARGB(255, 73, 120, 74),
                                    width: 0.8, 
                                    name: barLabel,
                                    // Enable data label
                                    dataLabelSettings: DataLabelSettings(isVisible: true))
                              ]),
      ),
    );
  }
}