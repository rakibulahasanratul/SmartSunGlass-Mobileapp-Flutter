// This page work as an DB API between the database service and widget page specific to
// central data table and its relevance with widget page.
// API type: jason

class CentralDBmodel {
  CentralDBmodel({
    required this.id,
    required this.TIME,
    required this.CV,
    required this.CVP,
    required this.CVD,
  });

  final int id;
  final String TIME;
  final String CV;
  final String CVP;
  final String CVD;

  factory CentralDBmodel.fromJson(Map<String, dynamic> json) => CentralDBmodel(
        id: json["id"] ?? 0,
        TIME: json["TIME"] ?? '',
        CV: json["CV"] ?? '',
        CVP: json["CVP"] ?? '',
        CVD: json["CVD"] ?? '',
      );
}
