class StudentModel {
  final String id;
  final String name;
  final String studentId; // enrollment number
  final String classId;
  final String className;
  final String section;
  final String schoolId;
  final String schoolName;
  final String? parentId;
  final String? parentName;
  final String? parentPhone;

  const StudentModel({
    required this.id,
    required this.name,
    required this.studentId,
    required this.classId,
    required this.className,
    required this.section,
    required this.schoolId,
    required this.schoolName,
    this.parentId,
    this.parentName,
    this.parentPhone,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'studentId': studentId,
    'classId': classId,
    'className': className,
    'section': section,
    'schoolId': schoolId,
    'schoolName': schoolName,
    'parentId': parentId,
    'parentName': parentName,
    'parentPhone': parentPhone,
  };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'] as String,
    name: json['name'] as String,
    studentId: json['studentId'] as String,
    classId: json['classId'] as String,
    className: json['className'] as String,
    section: json['section'] as String,
    schoolId: json['schoolId'] as String,
    schoolName: json['schoolName'] as String,
    parentId: json['parentId'] as String?,
    parentName: json['parentName'] as String?,
    parentPhone: json['parentPhone'] as String?,
  );
}
