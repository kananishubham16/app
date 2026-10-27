class CharacterBadge {
  final String id;
  final String badgeKey;
  final String title;
  final String titleGu;
  final String iconName;
  final String awardedBy;
  final DateTime awardedAt;

  const CharacterBadge({
    required this.id,
    required this.badgeKey,
    required this.title,
    required this.titleGu,
    required this.iconName,
    required this.awardedBy,
    required this.awardedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'badgeKey': badgeKey,
    'title': title,
    'titleGu': titleGu,
    'iconName': iconName,
    'awardedBy': awardedBy,
    'awardedAt': awardedAt.toIso8601String(),
  };

  factory CharacterBadge.fromJson(Map<String, dynamic> json) {
    return CharacterBadge(
      id: json['id'] as String? ?? 'badge_${DateTime.now().millisecondsSinceEpoch}',
      badgeKey: json['badgeKey'] as String? ?? 'high_effort',
      title: json['title'] as String? ?? 'High Effort',
      titleGu: json['titleGu'] as String? ?? 'પરિશ્રમી પ્રયાસ',
      iconName: json['iconName'] as String? ?? 'star',
      awardedBy: json['awardedBy'] as String? ?? 'Teacher',
      awardedAt: json['awardedAt'] != null
          ? DateTime.tryParse(json['awardedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static const List<Map<String, String>> availableTemplates = [
    {
      'key': 'curious_mind',
      'title': 'Curious Questioner',
      'titleGu': 'જિજ્ઞાસુ વિદ્યાર્થી',
      'icon': 'lightbulb_outline',
      'desc': 'Asks thoughtful questions and shows high classroom curiosity.',
      'descGu': 'વર્ગખંડમાં પ્રશ્નો પૂછીને શીખવાની અદભુત ઉત્સુકતા દર્શાવે છે.',
    },
    {
      'key': 'team_player',
      'title': 'Team Player & Empathy',
      'titleGu': 'સહકાર અને ટીમવર્ક',
      'icon': 'handshake_outlined',
      'desc': 'Helps peers learn and collaborates generously in group activities.',
      'descGu': 'સહપાઠીઓને શીખવામાં મદદ કરે છે અને જૂથ પ્રવૃત્તિઓમાં સહયોગ આપે છે.',
    },
    {
      'key': 'high_effort',
      'title': 'High Effort & Grit',
      'titleGu': 'ખંત અને સાતત્યપૂર્ણ પ્રયાસ',
      'icon': 'track_changes_outlined',
      'desc': 'Perseveres through challenging tasks and completes practice diligently.',
      'descGu': 'અઘરા વિષયોમાં પણ હિંમત હાર્યા વિના નિયમિત મહાવરો પૂર્ણ કરે છે.',
    },
    {
      'key': 'creative_thinker',
      'title': 'Creative Thinker',
      'titleGu': 'સર્જનાત્મક વિચારસરણી',
      'icon': 'palette_outlined',
      'desc': 'Brings original ideas, expressive storytelling, and imaginative solutions.',
      'descGu': 'નવા વિચારો, સર્જનાત્મક અભિવ્યક્તિ અને અનન્ય ઉકેલો રજૂ કરે છે.',
    },
    {
      'key': 'active_sport',
      'title': 'Energetic & Well-being',
      'titleGu': 'ઉત્સાહી અને શારીરિક સુદ્રઢતા',
      'icon': 'sports_volleyball_outlined',
      'desc': 'Exemplary participation in physical activities, sports, and hygiene.',
      'descGu': 'રમતગમત, શારીરિક પ્રવૃત્તિઓ અને સ્વચ્છતામાં અગ્રેસર રહે છે.',
    },
  ];
}

class HolisticEvaluationModel {
  final String studentId;
  final double practiceGrit;        // 0 to 100 based on remedial practice completion
  final double learningConsistency;  // 0 to 100 based on attendance & evaluation regularity
  final double engagementCuriosity;  // 0 to 100 based on questions & classroom participation
  final double teamworkEmpathy;      // 0 to 100 based on peer learning & social skills
  final double coCurricular;         // 0 to 100 based on sports, arts & hygiene
  final List<CharacterBadge> badges;
  final String? teacherNotes;
  final DateTime updatedAt;

  const HolisticEvaluationModel({
    required this.studentId,
    required this.practiceGrit,
    required this.learningConsistency,
    required this.engagementCuriosity,
    required this.teamworkEmpathy,
    required this.coCurricular,
    this.badges = const [],
    this.teacherNotes,
    required this.updatedAt,
  });

  /// 360-degree Composite Holistic Progress Score (0-100)
  double get compositeScore {
    final raw = (practiceGrit * 0.25) +
        (learningConsistency * 0.25) +
        (engagementCuriosity * 0.20) +
        (teamworkEmpathy * 0.15) +
        (coCurricular * 0.15);
    return raw.clamp(0.0, 100.0);
  }

  String getLocalizedStatus(bool isGu) {
    final score = compositeScore;
    if (score >= 85) {
      return isGu ? 'સર્વાંગી ઉત્કૃષ્ટ વિકાસ' : 'Exemplary Holistic Growth';
    } else if (score >= 65) {
      return isGu ? 'પ્રશંસનીય પ્રગતિ અને સારો પ્રયાસ' : 'Steady Holistic Progress';
    } else {
      return isGu ? 'પ્રોત્સાહનની જરૂરિયાત' : 'Emerging & Needs Encouragement';
    }
  }

  HolisticEvaluationModel copyWith({
    String? studentId,
    double? practiceGrit,
    double? learningConsistency,
    double? engagementCuriosity,
    double? teamworkEmpathy,
    double? coCurricular,
    List<CharacterBadge>? badges,
    String? teacherNotes,
    DateTime? updatedAt,
  }) {
    return HolisticEvaluationModel(
      studentId: studentId ?? this.studentId,
      practiceGrit: practiceGrit ?? this.practiceGrit,
      learningConsistency: learningConsistency ?? this.learningConsistency,
      engagementCuriosity: engagementCuriosity ?? this.engagementCuriosity,
      teamworkEmpathy: teamworkEmpathy ?? this.teamworkEmpathy,
      coCurricular: coCurricular ?? this.coCurricular,
      badges: badges ?? this.badges,
      teacherNotes: teacherNotes ?? this.teacherNotes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'practiceGrit': practiceGrit,
    'learningConsistency': learningConsistency,
    'engagementCuriosity': engagementCuriosity,
    'teamworkEmpathy': teamworkEmpathy,
    'coCurricular': coCurricular,
    'badges': badges.map((b) => b.toJson()).toList(),
    'teacherNotes': teacherNotes,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory HolisticEvaluationModel.fromJson(Map<String, dynamic> json) {
    return HolisticEvaluationModel(
      studentId: json['studentId'] as String? ?? '',
      practiceGrit: (json['practiceGrit'] as num?)?.toDouble() ?? 75.0,
      learningConsistency: (json['learningConsistency'] as num?)?.toDouble() ?? 80.0,
      engagementCuriosity: (json['engagementCuriosity'] as num?)?.toDouble() ?? 80.0,
      teamworkEmpathy: (json['teamworkEmpathy'] as num?)?.toDouble() ?? 85.0,
      coCurricular: (json['coCurricular'] as num?)?.toDouble() ?? 78.0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((item) => CharacterBadge.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      teacherNotes: json['teacherNotes'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
