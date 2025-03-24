
import 'dart:convert';

class Defects {
  int defectId = 0;
  String defectName = "";
  String defectLocation = "";
  String defectSubLocation = "";
  String defectPriority = "";


  Defects();
  Defects.fromMap(Map<String, dynamic> map) {
    if (map['defectId'] != null) {defectId = map['defectId'];}

    if (map['defectName'] != null) {defectName = map['defectName'];}

    if (map['defectLocation'] != null) {defectLocation = map['defectLocation'];}

    if (map['defectSubLocation'] != null) {defectSubLocation = map['defectSubLocation'];}

    if (map['defectPriority'] != null) {defectPriority = map['defectPriority'];}
  }

  Map<String, dynamic> toMap() {
    return {
      'defectId': defectId,
      'defectName': defectName,
      'defectLocation': defectLocation,
      'defectSubLocation': defectSubLocation,
      'defectPriority': defectPriority,
    };
  }
}
