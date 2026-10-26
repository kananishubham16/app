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

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['_id'] ?? json['studentId'] ?? '').toString();
    final sId = (json['studentId'] ?? json['id'] ?? json['_id'] ?? '').toString();
    final rawClass = (json['class'] ?? json['className'] ?? json['classId'] ?? 'Class 4').toString();

    return StudentModel(
      id: rawId,
      name: (json['name'] ?? '').toString(),
      studentId: sId,
      classId: (json['classId'] ?? rawClass).toString(),
      className: (json['className'] ?? rawClass).toString(),
      section: (json['section'] ?? 'A').toString(),
      schoolId: (json['schoolId'] ?? 'school_1').toString(),
      schoolName: (json['schoolName'] ?? 'GPS Primary School').toString(),
      parentId: json['parentId']?.toString(),
      parentName: (json['parentName'] ?? json['parent_name'])?.toString(),
      parentPhone: (json['parentPhone'] ?? json['parentEmail'] ?? json['parent_phone'])?.toString(),
    );
  }
}
