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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['role'] as String?)?.toLowerCase() ?? 'teacher';
    UserRole parsedRole;
    if (rawRole == 'coordinator' || rawRole == 'brc') {
      parsedRole = UserRole.brc;
    } else if (rawRole == 'principal' || rawRole == 'admin') {
      parsedRole = UserRole.principal;
    } else if (rawRole == 'parent') {
      parsedRole = UserRole.parent;
    } else {
      parsedRole = UserRole.teacher;
    }

    final rawName = (json['name'] ?? '').toString();
    String initials = '';
    if (rawName.isNotEmpty) {
      final parts = rawName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }
    }

    List<String>? parsedClassIds;
    if (json['classIds'] is List) {
      parsedClassIds = (json['classIds'] as List).map((e) => e.toString()).toList();
    } else if (json['assignedClass'] != null) {
      parsedClassIds = json['assignedClass'].toString().split(',').map((c) => c.trim()).toList();
    }

    List<String>? parsedChildrenIds;
    if (json['childrenIds'] is List) {
      parsedChildrenIds = (json['childrenIds'] as List).map((e) => e.toString()).toList();
    } else if (json['linkedStudentIds'] is List) {
      parsedChildrenIds = (json['linkedStudentIds'] as List).map((e) => e.toString()).toList();
    }

    return UserModel(
      id: (json['id'] ?? json['_id'] ?? json['email'] ?? '').toString(),
      name: rawName,
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '+91 98796 67097').toString(),
      role: parsedRole,
      schoolId: json['schoolId']?.toString(),
      blockId: json['blockId']?.toString(),
      classIds: parsedClassIds,
      childrenIds: parsedChildrenIds,
      subjectIds: (json['subjectIds'] as List?)?.map((e) => e.toString()).toList(),
      avatarInitials: json['avatarInitials']?.toString() ?? initials,
    );
  }
}
