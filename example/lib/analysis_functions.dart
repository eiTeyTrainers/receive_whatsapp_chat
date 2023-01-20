import "string_extension.dart";
import "package:collection/collection.dart";
import 'koala.dart';
import 'dart:math';



List this_word_per_contact(DataFrame df,DataFrame df_expanded, String keyWord) {

  
  Map koalaDf = df.groupedBy ('Contact', ascending: true, nullsFirst: false);
  List<Map<String, dynamic>> df_list = [];
  var s =koalaDf.forEach((k, v) {
    int word_count = 0;
    for(var value in v){

      if(value[4].toString().contains(keyWord)){
        word_count ++;
      }
    }
    df_list.add({"Contact":k,"WordCount":word_count});
  });
  DataFrame graph_df =  DataFrame.fromRowMaps(df_list);
  DataFrame sorted_graph_df = graph_df.sortedBy("WordCount");

  return sorted_graph_df.l;
}
List dailyMsgs(DataFrame df,DataFrame df_expanded, String keyWord) {

  
  Map koalaDf = df.groupedBy ('Date', ascending: true, nullsFirst: false);
  List<Map<String, dynamic>> df_list = [];
    var s =koalaDf.forEach((k, v) {
      List DateList = v;

      df_list.add({"Date":k,"WordCount":DateList.length});
    });
    DataFrame graph_df =  DataFrame.fromRowMaps(df_list);
    DataFrame sorted_graph_df = graph_df.sortedBy("WordCount");
  return sorted_graph_df.l;
}
List msgs_per_hour(DataFrame df,DataFrame df_expanded, String keyWord){

  
  Map koalaDf = df_expanded.groupedBy ('Hour', ascending: true, nullsFirst: false);
  List<Map<String, dynamic>> df_list = [];
    var s =koalaDf.forEach((k, v) {
      List DateList = v;

      df_list.add({"Date":k,"WordCount":DateList.length});
    });
    DataFrame graph_df =  DataFrame.fromRowMaps(df_list);
    DataFrame sorted_graph_df = graph_df.sortedBy("WordCount");
  return sorted_graph_df.l;
}
List contactFrequentWord(DataFrame df,DataFrame df_expanded, String keyWord) {

  
  var ColumsNedded = df.withColumns(['Contact','Message']);
  Map koalaDf = ColumsNedded.groupedBy ('Contact', ascending: true, nullsFirst: false);
  List<Map<String, dynamic>> df_list = [];
    koalaDf.forEach((k, v) {
    Map wordsObject = {};
      List DateList = v;
      DateList.forEach((dfSentence) {
        String sentence = dfSentence[1];
        sentence.split(' ').forEach((word) {

          if(wordsObject[word] != null || wordsObject[word] != null){
            wordsObject[word] +=  1;

          }else{
            wordsObject[word] = 1;
          }
          
        });
      });
       int maxValue=0;
        var maxValuedKey;

    wordsObject.forEach((key,v){

      if(v>maxValue && key != "") {
        maxValue = v;
        maxValuedKey = key;
      }
    });
      df_list.add({"Contact":k,"WordCount":maxValue,"Word":maxValuedKey});
    });
    DataFrame graph_df =  DataFrame.fromRowMaps(df_list);
    DataFrame sorted_graph_df = graph_df.sortedBy("WordCount");
  return sorted_graph_df.l;
}

