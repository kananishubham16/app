import 'package:flutter/widgets.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

enum UserRole { teacher, principal, brc, parent }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? schoolId;
  final String? blockId;
  final List<String>? classIds; // for teachers
  final List<String>? childrenIds; // for parents
  final List<String>? subjectIds; // assigned subjects for teachers
  final String? avatarInitials;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.schoolId,
    this.blockId,
    this.classIds,
    this.childrenIds,
    this.subjectIds,
    this.avatarInitials,
  });

  String get roleDisplayName {
    switch (role) {
      case UserRole.teacher:
        return 'Primary School Teacher';
      case UserRole.principal:
        return 'School Principal';
      case UserRole.brc:
        return 'Block Resource Coordinator';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String getLocalizedRoleName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return roleDisplayName;
    switch (role) {
      case UserRole.teacher:
        return l10n.teacher;
      case UserRole.principal:
        return l10n.principal;
      case UserRole.brc:
        return l10n.brc;
      case UserRole.parent:
        return l10n.parent;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role.name,
    'schoolId': schoolId,
    'blockId': blockId,
    'classIds': classIds,
    'childrenIds': childrenIds,
    'subjectIds': subjectIds,
    'avatarInitials': avatarInitials,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    role: UserRole.values.byName(json['role'] as String),
    schoolId: json['schoolId'] as String?,
    blockId: json['blockId'] as String?,
    classIds: (json['classIds'] as List?)?.cast<String>(),
    childrenIds: (json['childrenIds'] as List?)?.cast<String>(),
    subjectIds: (json['subjectIds'] as List?)?.cast<String>(),
    avatarInitials: json['avatarInitials'] as String?,
  );
}
