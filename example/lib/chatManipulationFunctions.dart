  import 'dart:convert';

import 'package:intl/intl.dart';
  import 'dart:async';
  import 'dart:math';
import 'koala.dart';

Future <List<DataFrame>> wordCheck  (String values) async {
  
String pattern_time_24hr = (",? (0?[0-9]|1[0-9]|2[0-3]):([0-5][0-9])(:[0-5][0-9])?");
String pattern_time_12hr = (
    ",? (0?[0-9]|1[0-2]):([0-9]|[0-5][0-9])(:[0-5][0-9])? [APap][Mm]"
);

String pattern_date_US = (
    "(0?[1-9]|1[0-2])[/.-](0?[1-9]|[12][0-9]|3[01])[/.-](\\d{2}|\\d{4}), ? "
);
String pattern_date_UK = (
  "([12][0-9]|3[01]|0?[1-9])[/.-](0?[1-9]|1[0-2])[/.-](\\d{2}|\\d{4}),? "
);      
List<String> day_of_week_labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];


    List<Map<String, dynamic>> data = [];
    List<Map<String, dynamic>> data_extended = [];
    int last_message_end = 0;
    bool is_UK = false;
    String pattern_date= '';
    String pattern_time = '';
    // dp = re.compile(pattern_date_UK)
    RegExp dp = new RegExp(pattern_date_UK);
    var matches =dp.allMatches(values); 
    for (var  d in matches){
      var date = d.group(0);
      date = date!.replaceAll("-", "/");
      date = date.replaceAll(".", "/");
      if(int.parse(date.split("/")[0]) > 3){
          pattern_date = pattern_date_UK;
          is_UK = true;
      }
    }

    if(!is_UK){
          pattern_date = pattern_date_UK;
    }
    bool is_12hr = false;
    RegExp Reg_12hr = new RegExp(pattern_time_12hr);
    var TwelveHourmatches = Reg_12hr.allMatches(values);
    if(TwelveHourmatches.length > 50){
      pattern_time = pattern_time_12hr;
    }else{
       pattern_time = pattern_time_24hr;
    }
    pattern_time = pattern_time.substring(3);
    RegExp reg_pattern_date = RegExp(pattern_date);
    RegExp reg_pattern_time = RegExp(pattern_time);
    String pattern = pattern_date + pattern_time;

    RegExp p = new RegExp(pattern);
    var cc =p.allMatches(values);
    String last_date = '';
    String last_time = '';
    try{
    for (var  m in cc){

     
      if(data.length == 1969){
        print('fuck');
      }
      var DateTimeV = m.group(0);
      String time = reg_pattern_time.firstMatch(DateTimeV!)!.group(0).toString();
      var date = reg_pattern_date.firstMatch(DateTimeV)!.group(0);
      if (date!.contains(',')){
         date = date.substring(0,date.length-2);
      }
      date = date.replaceAll(".", "/");
      if (is_UK){
        List<String> spp = date.split('/');
        date = spp[1] + '/' + spp[0]+ '/' + spp[2];

      }
      date = date.replaceAll(" ", "");
      List<String> splitedDate = date.split("/");
      int last = splitedDate.length-1;
      if(splitedDate[last].length == 4){
        List<String> date_split = date.split('/');
        if (date_split.length < 3){
          date_split = date.split(".");
        }
        DateTime dateFormated = DateTime.parse(date_split[2] + "-" + date_split[1] + "-" + date_split[0]);
        String  day_of_week = DateFormat('EEEE').format(dateFormated).substring(0,3);
          if (last_message_end > 0){
            var contact_and_msg = values.substring(last_message_end + 3, m.start);
            List<String> split_ = contact_and_msg.split(':');
            String contact = '';
            String message = '';
            if(split_.length > 1 ){
              contact = split_[0];
             
              List<String> msg = split_[1].split("\n");
              message = "";

            List onlyMassageList = split_.sublist(1);
              for(var msg_row in onlyMassageList){
                message += " " + msg_row;
              }
              message = message.substring(2,message.length-1);
            }
            else if(split_.length == 1){
               contact = "System Generated";
              message = split_[0].split("\n")[0];
            }
            if(message != "<Media omitted>"){
              data.add({"Date":last_date,"Time":last_time,"Day_of_week":day_of_week,"Contact":contact,"Message":message});
            }
            List<String> data_split = last_date.split('/');
            int month = int.parse(data_split[0]).round(); 
            int day = int.parse(data_split[1]).round(); 
            int year = int.parse(data_split[2]).round(); 
            List<String> time_split = last_time.split(":");
            int hour = int.parse(time_split[0]).round(); 
            int min = int.parse(time_split[1].split(" ")[0]).round(); 

            if (last_time.contains("M") || last_time.contains("m")){
              String AM_PM = time_split[time_split.length-1].split(" ")[1];
              if (AM_PM == "PM" || AM_PM == "pm"){
                hour += 12;
                if (hour == 24){
                  hour = 12;
                }
              }
              else{
                if(hour == 12){
                  hour = 0;
                }
                

              }
            }
            if(message != "<Media omitted>"){
              data_extended.add({"Month":month,"Day":day,"Year":year,"Hour":hour,"Min":min,"Contact":contact,"Message":message});
            }
          }
          last_date = date;
          last_time = time;
        last_message_end = m.end;
      } 
      
    }
    }catch(e){
      print(e);
      }
    
    DataFrame df_simple = DataFrame.fromRowMaps(data);
    DataFrame df_extended = DataFrame.fromRowMaps(data_extended);
    print(data);
    return [df_simple,df_extended];

}

