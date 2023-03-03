// This page work as an DB API between the database service and widget page specific to
// peripheral data table and its relevance with widget page.
// API type: jason

class PeripheralDBmodel {
  PeripheralDBmodel({
    required this.id,
    required this.TIME,
    required this.PV,
    required this.PVP,
    required this.PVD,
  });

  final int id;
  final String PV;
  final String TIME;
  final String PVP;
  final String PVD;

  factory PeripheralDBmodel.fromJson(Map<String, dynamic> json) =>
      PeripheralDBmodel(
        id: json["id"] ?? 0,
        PV: json["PV"] ?? '',
        TIME: json["TIME"] ?? '',
        PVP: json["PVP"] ?? '',
        PVD: json["PVD"] ?? '',
      );
}
