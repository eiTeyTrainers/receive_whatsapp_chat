import 'dart:math';

import 'package:flutter/material.dart';


class dropDownWidget extends StatefulWidget {
 late VoidCallback onIndexSelected;
 final Function onClicked;
 int listIndex = 0;
 
  var OptionList;
 

   dropDownWidget({super.key, required this.listIndex, required this.onClicked, required this.OptionList});


  @override
  State<dropDownWidget> createState() => _dropDownWidgetState();
}
class _dropDownWidgetState extends State<dropDownWidget> {
  bool isPressed = true;


  @override
  Widget build(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height; 
  double chooseGraphButtonHeight = height/16;
  double max = height/4.83;
  double listVariablesHeight =  height/21 * widget.OptionList.length  ;
  double listViewHeight =  listVariablesHeight > max ? max:listVariablesHeight  ;

  
    return Container(
      width: 300,
      child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: chooseGraphButtonHeight + listViewHeight,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isPressed = !isPressed;
                });
              }, 
              
              child: Container(
                
                width:width,
                height:chooseGraphButtonHeight,
                decoration: BoxDecoration(
                color: Color.fromARGB(255, 61, 118, 49),
                ),
                child: Row(
    
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  isPressed == true? Icon(Icons.arrow_right, color: Colors.white):Icon(Icons.arrow_drop_down, color: Colors.white),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Align(
              alignment: Alignment.centerRight,
              child: Text(
                "בחר גרף",
                style: TextStyle(color: Colors.white, fontSize: 22)),
                  ),
                  Spacer()
              ]
              )
              ),
            ),

             AnimatedContainer(
                       
              height:isPressed == true? 0: listViewHeight,
              curve: isPressed ?  Curves.fastOutSlowIn:Curves.bounceOut,
               
              duration: Duration(milliseconds: 1000),
              child: ListView.builder(
              shrinkWrap: true,
              itemExtent: height/21,
              itemCount: widget.OptionList.length,
             
               
              itemBuilder: (context, index) {
                
               return  Center(child:Container(
                child: SizedBox(
                width:width,
                  child: TextButton(
                    onPressed: () =>setState(() {
                      widget.onClicked(index);
                    }),
                    
                    style: TextButton.styleFrom(
                      primary: widget.listIndex == index ? Color.fromARGB(255, 211, 210, 210):Colors.black,
                      backgroundColor: widget.listIndex == index
                              ? Color.fromARGB(255, 31, 90, 33)
                              : Color.fromARGB(255, 217, 216, 214),
                      shape: const RoundedRectangleBorder(
                      ),
                    ),
                    child: Text(
                      widget.OptionList[index]["name"].toString(),
                    ),
                    ),
                  ),
                  )
                );
              },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
  

}