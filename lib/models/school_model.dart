class SchoolModel {
  final String id;
  final String name;
  final String blockId;
  final String blockName;
  final String address;
  final String principalId;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.blockId,
    required this.blockName,
    required this.address,
    required this.principalId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'blockId': blockId,
    'blockName': blockName,
    'address': address,
    'principalId': principalId,
  };

  factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
    id: json['id'] as String,
    name: json['name'] as String,
    blockId: json['blockId'] as String,
    blockName: json['blockName'] as String,
    address: json['address'] as String,
    principalId: json['principalId'] as String,
  );
}

class BlockModel {
  final String id;
  final String name;
  final String district;
  final List<String> schoolIds;

  const BlockModel({
    required this.id,
    required this.name,
    required this.district,
    required this.schoolIds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'district': district,
    'schoolIds': schoolIds,
  };

  factory BlockModel.fromJson(Map<String, dynamic> json) => BlockModel(
    id: json['id'] as String,
    name: json['name'] as String,
    district: json['district'] as String,
    schoolIds: (json['schoolIds'] as List).cast<String>(),
  );
}

class ClassModel {
  final String id;
  final String name; // e.g., 'Class 3'
  final String section;
  final String schoolId;
  final String? teacherId;
  final List<String> studentIds;

  const ClassModel({
    required this.id,
    required this.name,
    required this.section,
    required this.schoolId,
    this.teacherId,
    required this.studentIds,
  });

  String get displayName => '$name - $section';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'section': section,
    'schoolId': schoolId,
    'teacherId': teacherId,
    'studentIds': studentIds,
  };

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    id: json['id'] as String,
    name: json['name'] as String,
    section: json['section'] as String,
    schoolId: json['schoolId'] as String,
    teacherId: json['teacherId'] as String?,
    studentIds: (json['studentIds'] as List).cast<String>(),
  );
}
