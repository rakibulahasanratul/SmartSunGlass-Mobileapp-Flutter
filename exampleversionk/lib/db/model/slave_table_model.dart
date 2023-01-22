class SlaveDBmodel {
  SlaveDBmodel({
    required this.id,
    required this.TIME,
    required this.SV,
    required this.SVP,
    required this.SVD,
  });

  final int id;
  final String SV;
  final String TIME;
  final String SVP;
  final String SVD;

  factory SlaveDBmodel.fromJson(Map<String, dynamic> json) => SlaveDBmodel(
        id: json["id"] ?? 0,
        SV: json["SV"] ?? '',
        TIME: json["TIME"] ?? '',
        SVP: json["SVP"] ?? '',
        SVD: json["SVD"] ?? '',
      );
}
