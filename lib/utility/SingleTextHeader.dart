import '/utility/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Colors.dart';
import 'Fonts.dart';

class SingleTextHeader extends StatelessWidget {
  final String headerText;
  final String subHeaderText;
  final BuildContext context;
  final Function onBack;

  SingleTextHeader(
      this.headerText, this.subHeaderText, this.context, this.onBack);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(
          top: getScreenHeight(40),
          bottom: getScreenHeight(30),
          left: getScreenWidth(20),
          right: getScreenWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // InkWell(
          //   onTap: () {
          //     onBack;
          //     // Navigator.pop(context, true);
          //     // onBackPressed()
          //     onBack();
          //   },
          //   child: Container(
          //       padding: EdgeInsets.all(10),
          //       decoration: BoxDecoration(
          //         color: Colors.grey.shade200,
          //         borderRadius: BorderRadius.circular(50.0),
          //       ),
          //       child: Icon(
          //         Icons.arrow_back_ios_new,
          //         size: 22,
          //         color: backButtonCircleIconColor,
          //       )),
          // ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.06),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerText,
                  style: TextStyle(
                    fontSize: getScreenWidth(25),
                    fontFamily: ffGSemiBold,
                    color: buttonBorderColor,
                  ),
                ),
                subHeaderText != ""
                    ? Text(
                        subHeaderText,
                        style: TextStyle(
                          fontSize: getScreenWidth(14),
                          fontFamily: ffGSemiBold,
                          color: buttonBorderColor,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
