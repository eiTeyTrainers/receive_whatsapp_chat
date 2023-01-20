
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:receive_whatsapp_chat/models/chat_content.dart';
import 'package:receive_whatsapp_chat/receive_whatsapp_chat.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:whatsalyzer/Models/graphData.model.dart';
import 'package:whatsalyzer/Widgets/ChartOnTopScreenWidget.dart';
import 'package:whatsalyzer/Widgets/GeneralScreen.dart';

import 'Widgets/dropDownCheck.dart';
import 'analysis_functions.dart';
import 'chatManipulationFunctions.dart';
import 'koala.dart' as koala;
void main() {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  var s = false;
   ThemeData lightThemeData = new ThemeData(
      appBarTheme:
      AppBarTheme(
        backgroundColor: Color.fromARGB(255, 61, 118, 49)
      ),
      primaryColor: Color.fromARGB(255, 61, 118, 49),
      textTheme: new TextTheme(
        button: TextStyle(color: Colors.white70)
      ),
      brightness: Brightness.light,
      accentColor: Color.fromARGB(255, 61, 118, 49),
      colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Color.fromARGB(255, 61, 118, 49),
    ),);
  
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightThemeData,
      home: GeneralScreen(
        
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Whatsalyzer')
        ),
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState<HomePage> extends ReceiveWhatsappChat<StatefulWidget> with SingleTickerProviderStateMixin  {
 String chat = '';
 String chatName = '';

    
  var _intentDataStreamSubscription;
  var _sharedFiles;
  String? _sharedText;
  
   
     void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
  StreamSubscription  _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        print("Shared:" + (_sharedFiles.map((f)=> f.path)?.join(",") ?? ""));
        _sharedFiles = value;

      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((value) => 
          setState(() {
        _sharedText = value;
      })
      
      );
  }

  @override
  void dispose() {
    super.dispose();
  }
  int listIndex = 0;

    void selectIndex(int index) {
    setState(() {
      listIndex = index;
    });

  }


  TextEditingController keyWordController = TextEditingController();
  String data = "";
  List<GraphData> listValues = [];
  bool chatPicked = false;
  bool isDone = false;
  bool isLoading = false;
  
  List<Map<String, Object>>  OptionList = [
      {"name":'לפי מילה',"funcNum": 0,"funcArgumentsWidget":"Keyboard","keyboardLabel":'לפי מילה',"barLabel":"כמות מילים"},
      {"name":'תאריך',"funcNum": 1,"funcArgumentsWidget":"Dates","barLabel":"כמות מסרונים בתאריך"},
      {"name":'מילה לכל משתמש',"funcNum": 2,"funcArgumentsWidget":"","barLabel":"כמות מילה נפוצה של משתמש"}
    ];

  DateTime selectSecondDate = DateTime.now();
  
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery. of(context). size. height;
    double screenWidth = MediaQuery. of(context). size. width;
    if(isDone == true){
 SchedulerBinding.instance.addPostFrameCallback((_) {

  // add your code here.

  Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => resultChartScreen(listValues: listValues,OptionList:OptionList,ListIndex:listIndex)));
});
        isDone = false;
      }
    return SafeArea(
      top: true,
      minimum: EdgeInsets.only(top: 4),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: screenHeight,
          child: Column(
            children: [ 
                  SizedBox(
                    width: MediaQuery. of(context).size.width/2,
                    height: MediaQuery. of(context).size.height/18
,
                    child: ElevatedButton(
              style:ElevatedButton.styleFrom(
                backgroundColor:  Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                await LaunchApp.openApp(
                    androidPackageName: 'com.whatsapp',
                    iosUrlScheme: 'whatsapp://app',
                    appStoreLink:
                        'https://apps.apple.com/us/app/whatsapp-messenger/id310633997',
                );
              },
              child: const Text("בחר צ'אט"),
              ),
                  ),
         
              Text(chatPicked ? "$chatName בחרת את  " : "לא בחרת צאט"),
              Spacer(),
            dropDownWidget(
             OptionList:OptionList,
             listIndex:listIndex,
             onClicked: selectIndex,
              
            ),
            Spacer(),
           SizedBox( 
              height:60,
              width:screenWidth/1.3,
              child: ListView.builder(             
             itemCount: OptionList.length,
             itemBuilder:  (context, fieldIndex) {
              return listIndex == fieldIndex ?
              
            OptionList[fieldIndex]["funcArgumentsWidget"] == "Keyboard"? 
             Directionality(
              textDirection: TextDirection.rtl,
               child: TextField(
                controller: keyWordController, 
                
                textAlign: TextAlign.right,
              decoration: InputDecoration(
                filled:true,
                labelStyle: TextStyle(color: Colors.black),
                fillColor: ui.Color.fromARGB(255, 222, 221, 189),
                enabledBorder: OutlineInputBorder(            
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(width:1 ,color: ui.Color.fromARGB(0, 0, 0, 0))),
            focusedBorder:OutlineInputBorder(
            
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: ui.Color.fromARGB(0, 0, 0, 0), width: 1.5),
          ),
                labelText: OptionList[fieldIndex]["keyboardLabel"].toString(),
                           )
                      ,),
             ): Container(): Container();
                    }
                   )
                  ),
                  Spacer(),
                  Spacer(),
        
              isLoading == false?
              Container(): 
                Container(
                  height:MediaQuery.of(context).size.height/2,
                   child: Align(
                    alignment: Alignment.center,
                     child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Color.fromARGB(255, 53, 123, 45),
                      size: 89,
                      ),
                   ),
                 ),
                 Expanded(
                   child: Align(
                    alignment: Alignment.bottomLeft,
                     child: SizedBox(
                      height: 45,
                      width: double.infinity,
                       child: TextButton(onPressed: () async {
                              if(chatPicked != false){
                              setState(() {
                                isLoading = true;
                              });

                              List<koala.DataFrame> result = await compute( wordCheck,chat);
                              koala.DataFrame df = result[0];
                              koala.DataFrame df_extended = result[1];
                              String keyWord = keyWordController.text;
                              List funcList = [this_word_per_contact,dailyMsgs,contactFrequentWord,msgs_per_hour];
                              var analyzingFunction = funcList[listIndex](df,df_extended,keyWord);
                              List<GraphData> listGraphResults = [];
                              
                            for(List row in analyzingFunction){
                              listGraphResults.add(GraphData(contact: row[0], value: row[1],labelText:row.length >= 3?"${row[2]} -":""));
                            }
                                    isDone = true;
                              setState(() {
                                  listValues = listGraphResults;
                                  isLoading = false;
                              });
                              }
                            }, child:  Text(
                              'התחל',
                            ),style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    
                                    backgroundColor: ui.Color.fromARGB(255, 38, 139, 222))
                                    ,),
                     ),
                   ),
                 )
            ]
            ),
              
            ),
          ),
      
    );
  }
  
  List<String> nameListManipulation(String names) {
  String replacedOneNames = names.replaceAll('[', ''); 
  String replacedNames = replacedOneNames.replaceAll(']', ''); 
  replacedNames = replacedOneNames.replaceAll("'", ''); 
  String trimedNames = replacedNames.trim();
  List<String> listNames = trimedNames.split(',');
  return listNames;
  }
  
  List<String> valueListManipulation(String values) {
      String replacedOneValues = values.replaceAll('[', ''); 
      String replacedValues = replacedOneValues.replaceAll(']', ''); 
      String trimedValues = replacedValues.trim();
      List<String> listvalues = trimedValues.split(','); 
      return listvalues;
  }

  @override
  void receiveChatContent(String currName,String chatContent) {
    chatName = currName;
    chat = chatContent;
    chatPicked = true;
    setState(() {
      
    });
  }
}




