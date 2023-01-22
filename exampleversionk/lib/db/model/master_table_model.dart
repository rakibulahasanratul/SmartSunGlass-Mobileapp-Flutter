class MasterDBmodel {
  MasterDBmodel({
    required this.id,
    required this.TIME,
    required this.MV,
    required this.MVP,
    required this.MVD,
  });

  final int id;
  final String TIME;
  final String MV;
  final String MVP;
  final String MVD;

  factory MasterDBmodel.fromJson(Map<String, dynamic> json) => MasterDBmodel(
        id: json["id"] ?? 0,
        TIME: json["TIME"] ?? '',
        MV: json["MV"] ?? '',
        MVP: json["MVP"] ?? '',
        MVD: json["MVD"] ?? '',
      );
}
