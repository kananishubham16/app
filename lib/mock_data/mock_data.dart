import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/quiz_model.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/models/user_model.dart';

class MockData {
  // ==========================================
  // 1. BLOCK DATA
  // ==========================================
  static const BlockModel block = BlockModel(
    id: 'block_1',
    name: 'Gandhinagar Block',
    district: 'Gandhinagar',
    schoolIds: ['school_1', 'school_2', 'school_3'],
  );

  static final List<BlockModel> blocks = [block];

  // ==========================================
  // 2. SCHOOLS DATA
  // ==========================================
  static final List<SchoolModel> schools = [
    const SchoolModel(
      id: 'school_1',
      name: 'GPS Sector 7 Primary School',
      blockId: 'block_1',
      blockName: 'Gandhinagar Block',
      address: 'Sector 7, Gandhinagar, Gujarat 382007',
      principalId: 'user_principal',
    ),
    const SchoolModel(
      id: 'school_2',
      name: 'GPS Sector 21 Primary School',
      blockId: 'block_1',
      blockName: 'Gandhinagar Block',
      address: 'Sector 21, Gandhinagar, Gujarat 382021',
      principalId: 'user_principal_2',
    ),
    const SchoolModel(
      id: 'school_3',
      name: 'GPS Sector 14 Primary School',
      blockId: 'block_1',
      blockName: 'Gandhinagar Block',
      address: 'Sector 14, Gandhinagar, Gujarat 382014',
      principalId: 'user_principal_3',
    ),
  ];

  // ==========================================
  // 3. CLASSES DATA (2 per school)
  // ==========================================
  static final List<ClassModel> classes = [
    // School 1 (Sector 7)
    const ClassModel(
      id: 'class_3a_s1',
      name: 'Class 3',
      section: 'A',
      schoolId: 'school_1',
      teacherId: 'user_teacher',
      studentIds: [
        'student_1',
        'student_2',
        'student_3',
        'student_4',
        'student_5',
      ],
    ),
    const ClassModel(
      id: 'class_4a_s1',
      name: 'Class 4',
      section: 'A',
      schoolId: 'school_1',
      teacherId: 'user_teacher',
      studentIds: [
        'student_6',
        'student_7',
        'student_8',
        'student_9',
        'student_10',
      ],
    ),
    // School 2 (Sector 21)
    const ClassModel(
      id: 'class_3a_s2',
      name: 'Class 3',
      section: 'A',
      schoolId: 'school_2',
      teacherId: 'user_teacher_s2_3',
      studentIds: [
        'student_11',
        'student_12',
        'student_13',
        'student_14',
        'student_15',
      ],
    ),
    const ClassModel(
      id: 'class_4a_s2',
      name: 'Class 4',
      section: 'A',
      schoolId: 'school_2',
      teacherId: 'user_teacher_s2_4',
      studentIds: [
        'student_16',
        'student_17',
        'student_18',
        'student_19',
        'student_20',
      ],
    ),
    // School 3 (Sector 14)
    const ClassModel(
      id: 'class_3a_s3',
      name: 'Class 3',
      section: 'A',
      schoolId: 'school_3',
      teacherId: 'user_teacher_s3_3',
      studentIds: [
        'student_21',
        'student_22',
        'student_23',
        'student_24',
        'student_25',
      ],
    ),
    const ClassModel(
      id: 'class_4a_s3',
      name: 'Class 4',
      section: 'A',
      schoolId: 'school_3',
      teacherId: 'user_teacher_s3_4',
      studentIds: [
        'student_26',
        'student_27',
        'student_28',
        'student_29',
        'student_30',
      ],
    ),
  ];

  // ==========================================
  // 4. DEMO USERS (One per role + supplementary)
  // ==========================================
  static final List<UserModel> demoUsers = [
    const UserModel(
      id: 'user_teacher',
      name: 'Anita Sharma',
      email: 'teacher@demo.com',
      phone: '+91 98796 67097',
      role: UserRole.teacher,
      schoolId: 'school_1',
      classIds: ['class_3a_s1', 'class_4a_s1'],
      subjectIds: ['subject_math', 'subject_english'],
      avatarInitials: 'AS',
    ),
    const UserModel(
      id: 'user_teacher_guj',
      name: 'Bhavna Joshi',
      email: 'teacher2@demo.com',
      phone: '+91 98796 67097',
      role: UserRole.teacher,
      schoolId: 'school_1',
      classIds: ['class_3a_s1', 'class_4a_s1'],
      subjectIds: ['subject_guj'],
      avatarInitials: 'BJ',
    ),
    const UserModel(
      id: 'user_teacher_evs',
      name: 'Ramesh Solanki',
      email: 'teacher3@demo.com',
      phone: '+91 98796 67097',
      role: UserRole.teacher,
      schoolId: 'school_1',
      classIds: ['class_3a_s1', 'class_4a_s1'],
      subjectIds: ['subject_evs'],
      avatarInitials: 'RS',
    ),
    const UserModel(
      id: 'user_principal',
      name: 'Rajesh Patel',
      email: 'principal@demo.com',
      phone: '+91 98765 43211',
      role: UserRole.principal,
      schoolId: 'school_1',
      avatarInitials: 'RP',
    ),
    const UserModel(
      id: 'user_brc',
      name: 'Meera Desai',
      email: 'brc@demo.com',
      phone: '+91 98765 43212',
      role: UserRole.brc,
      blockId: 'block_1',
      avatarInitials: 'MD',
    ),
    const UserModel(
      id: 'user_parent',
      name: 'Suresh Kumar',
      email: 'parent@demo.com',
      phone: '+91 70169 81997',
      role: UserRole.parent,
      childrenIds: ['student_1', 'student_2'],
      avatarInitials: 'SK',
    ),
  ];

  // ==========================================
  // 5. SUBJECTS & TOPICS (4 Subjects, 5 Topics each)
  // ==========================================
  static final List<SubjectModel> subjects = [
    const SubjectModel(
      id: 'subject_math',
      name: 'Mathematics',
      description:
          'Foundational numeracy, arithmetic operations, and basic geometry.',
      iconName: 'calculate',
      applicableClassIds: ['class_3', 'class_4'],
      topics: [
        TopicModel(
          id: 'topic_math_add',
          name: 'Addition',
          subjectId: 'subject_math',
          learningObjectives: [
            '2 and 3 digit addition without carry',
            '3-digit addition with carry over',
            'Word problems involving addition',
          ],
          orderIndex: 1,
        ),
        TopicModel(
          id: 'topic_math_sub',
          name: 'Subtraction',
          subjectId: 'subject_math',
          learningObjectives: [
            '2-digit subtraction without borrowing',
            '3-digit subtraction with borrowing/regrouping',
            'Word problems involving subtraction',
          ],
          orderIndex: 2,
        ),
        TopicModel(
          id: 'topic_math_mul',
          name: 'Multiplication',
          subjectId: 'subject_math',
          learningObjectives: [
            'Multiplication tables up to 10',
            'Multiplying 2-digit by 1-digit numbers',
            'Repeated addition concept',
          ],
          orderIndex: 3,
        ),
        TopicModel(
          id: 'topic_math_div',
          name: 'Division',
          subjectId: 'subject_math',
          learningObjectives: [
            'Equal sharing and grouping',
            'Single digit division with remainder',
            'Division as inverse of multiplication',
          ],
          orderIndex: 4,
        ),
        TopicModel(
          id: 'topic_math_frac',
          name: 'Fractions',
          subjectId: 'subject_math',
          learningObjectives: [
            'Understanding halves, thirds, and quarters',
            'Numerator and denominator identification',
            'Visual fraction representation',
          ],
          orderIndex: 5,
        ),
      ],
    ),
    const SubjectModel(
      id: 'subject_guj',
      name: 'Gujarati',
      description: 'Gujarati language literacy, grammar, reading comprehension, and creative writing.',
      iconName: 'translate',
      applicableClassIds: ['class_3', 'class_4'],
      topics: [
        TopicModel(
          id: 'topic_guj_letters',
          name: 'Letters (મૂળાક્ષર)',
          subjectId: 'subject_guj',
          learningObjectives: [
            'Vowels and consonants recognition',
            'Barakhadi articulation',
            'Compound consonants (જોડાક્ષર)',
          ],
          orderIndex: 1,
        ),
        TopicModel(
          id: 'topic_guj_words',
          name: 'Words (શબ્દો)',
          subjectId: 'subject_guj',
          learningObjectives: [
            'Spelling accuracy (જોડણી)',
            'Compound words identification',
            'Rhyming words and antonyms',
          ],
          orderIndex: 2,
        ),
        TopicModel(
          id: 'topic_guj_sentences',
          name: 'Sentences (વાક્ય રચના)',
          subjectId: 'subject_guj',
          learningObjectives: [
            'Subject-verb-object sentence structuring',
            'Punctuation marks (પૂર્ણવિરામ, પ્રશ્નાર્થચિહ્ન)',
            'Forming meaningful interrogative sentences',
          ],
          orderIndex: 3,
        ),
        TopicModel(
          id: 'topic_guj_reading',
          name: 'Reading (વાંચન)',
          subjectId: 'subject_guj',
          learningObjectives: [
            'Fluent paragraph reading with proper tone',
            'Story comprehension and question answering',
            'Poem recitation and thematic understanding',
          ],
          orderIndex: 4,
        ),
        TopicModel(
          id: 'topic_guj_writing',
          name: 'Writing (લેખન)',
          subjectId: 'subject_guj',
          learningObjectives: [
            'Neat handwriting and word spacing',
            'Short paragraph on familiar topics',
            'Picture description writing',
          ],
          orderIndex: 5,
        ),
      ],
    ),
    const SubjectModel(
      id: 'subject_eng',
      name: 'English',
      description: 'Foundational English communication, phonics, vocabulary, and sentence construction.',
      iconName: 'language',
      applicableClassIds: ['class_3', 'class_4'],
      topics: [
        TopicModel(
          id: 'topic_eng_alphabet',
          name: 'Alphabet & Capitalization',
          subjectId: 'subject_eng',
          learningObjectives: [
            'Uppercase and lowercase letters matching',
            'Alphabetical order sorting',
            'Capitalization of proper nouns and sentence beginnings',
          ],
          orderIndex: 1,
        ),
        TopicModel(
          id: 'topic_eng_phonics',
          name: 'Phonics & Sounds',
          subjectId: 'subject_eng',
          learningObjectives: [
            'Short and long vowel sounds',
            'Consonant digraphs (sh, ch, th, ph)',
            'Rhyming word patterns (CVC words)',
          ],
          orderIndex: 2,
        ),
        TopicModel(
          id: 'topic_eng_vocab',
          name: 'Vocabulary',
          subjectId: 'subject_eng',
          learningObjectives: [
            'Daily life objects and action words',
            'Opposites and synonyms',
            'Animal names, young ones, and habitats',
          ],
          orderIndex: 3,
        ),
        TopicModel(
          id: 'topic_eng_reading',
          name: 'Reading Comprehension',
          subjectId: 'subject_eng',
          learningObjectives: [
            'Reading 3-4 sentence stories with comprehension',
            'Sight words recognition',
            'Locating facts in short passages',
          ],
          orderIndex: 4,
        ),
        TopicModel(
          id: 'topic_eng_writing',
          name: 'Basic Writing',
          subjectId: 'subject_eng',
          learningObjectives: [
            'Writing simple sentences with correct word order',
            'Using full stops and question marks',
            'Filling in missing words in guided paragraphs',
          ],
          orderIndex: 5,
        ),
      ],
    ),
    const SubjectModel(
      id: 'subject_evs',
      name: 'Environmental Studies',
      description: 'Natural science, environmental awareness, health, and social surroundings.',
      iconName: 'eco',
      applicableClassIds: ['class_3', 'class_4'],
      topics: [
        TopicModel(
          id: 'topic_evs_plants',
          name: 'Plants & Trees',
          subjectId: 'subject_evs',
          learningObjectives: [
            'Parts of a plant and their key functions',
            'Photosynthesis basics (sunlight, air, water)',
            'Types of plants: herbs, shrubs, trees, climbers',
          ],
          orderIndex: 1,
        ),
        TopicModel(
          id: 'topic_evs_animals',
          name: 'Animals & Habitats',
          subjectId: 'subject_evs',
          learningObjectives: [
            'Domestic and wild animal classifications',
            'Herbivores, carnivores, omnivores',
            'Animal shelters and sounds',
          ],
          orderIndex: 2,
        ),
        TopicModel(
          id: 'topic_evs_water',
          name: 'Water & Conservation',
          subjectId: 'subject_evs',
          learningObjectives: [
            'Sources of fresh water and water cycle',
            'Importance of clean drinking water',
            'Rainwater harvesting and water conservation methods',
          ],
          orderIndex: 3,
        ),
        TopicModel(
          id: 'topic_evs_air',
          name: 'Air & Weather',
          subjectId: 'subject_evs',
          learningObjectives: [
            'Properties of air and atmospheric presence',
            'Air pollution causes and remedies',
            'Weather seasons: Summer, Monsoon, Winter',
          ],
          orderIndex: 4,
        ),
        TopicModel(
          id: 'topic_evs_food',
          name: 'Food & Nutrition',
          subjectId: 'subject_evs',
          learningObjectives: [
            'Healthy food habits and balanced diet',
            'Sources of food (plants and animals)',
            'Cleanliness and food preservation',
          ],
          orderIndex: 5,
        ),
      ],
    ),
  ];

  // ==========================================
  // 6. STUDENTS DATA (30 students across 3 schools)
  // ==========================================
  static final List<StudentModel> students = [
    // --- School 1, Class 3-A ---
    const StudentModel(
      id: 'student_1',
      name: 'Aarav Kumar',
      studentId: 'GN-2026-3001',
      classId: 'class_3a_s1',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent',
      parentName: 'Suresh Kumar',
      parentPhone: '+91 70169 81997',
    ),
    const StudentModel(
      id: 'student_2',
      name: 'Diya Kumar',
      studentId: 'GN-2026-3002',
      classId: 'class_3a_s1',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent',
      parentName: 'Suresh Kumar',
      parentPhone: '+91 70169 81997',
    ),
    const StudentModel(
      id: 'student_3',
      name: 'Priya Sharma',
      studentId: 'GN-2026-3003',
      classId: 'class_3a_s1',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p3',
      parentName: 'Manoj Sharma',
      parentPhone: '+91 70169 81997',
    ),
    const StudentModel(
      id: 'student_4',
      name: 'Rahul Varma',
      studentId: 'GN-2026-3004',
      classId: 'class_3a_s1',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p4',
      parentName: 'Girish Varma',
      parentPhone: '+91 70169 81997',
    ),
    const StudentModel(
      id: 'student_5',
      name: 'Ananya Patel',
      studentId: 'GN-2026-3005',
      classId: 'class_3a_s1',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p5',
      parentName: 'Bhavesh Patel',
      parentPhone: '+91 98765 11003',
    ),

    // --- School 1, Class 4-A ---
    const StudentModel(
      id: 'student_6',
      name: 'Bhavik Solanki',
      studentId: 'GN-2026-4001',
      classId: 'class_4a_s1',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p6',
      parentName: 'Hasmukh Solanki',
      parentPhone: '+91 98765 11004',
    ),
    const StudentModel(
      id: 'student_7',
      name: 'Kavyan Shah',
      studentId: 'GN-2026-4002',
      classId: 'class_4a_s1',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p7',
      parentName: 'Amit Shah',
      parentPhone: '+91 98765 11005',
    ),
    const StudentModel(
      id: 'student_8',
      name: 'Nidhi Joshi',
      studentId: 'GN-2026-4003',
      classId: 'class_4a_s1',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p8',
      parentName: 'Chirag Joshi',
      parentPhone: '+91 98765 11006',
    ),
    const StudentModel(
      id: 'student_9',
      name: 'Harshil Dave',
      studentId: 'GN-2026-4004',
      classId: 'class_4a_s1',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p9',
      parentName: 'Kirit Dave',
      parentPhone: '+91 98765 11007',
    ),
    const StudentModel(
      id: 'student_10',
      name: 'Pooja Prajapati',
      studentId: 'GN-2026-4005',
      classId: 'class_4a_s1',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_1',
      schoolName: 'GPS Sector 7 Primary School',
      parentId: 'user_parent_p10',
      parentName: 'Bharat Prajapati',
      parentPhone: '+91 98765 11008',
    ),

    // --- School 2, Class 3-A ---
    const StudentModel(
      id: 'student_11',
      name: 'Meet Vaghela',
      studentId: 'GN-2026-3011',
      classId: 'class_3a_s2',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p11',
      parentName: 'Vikram Vaghela',
      parentPhone: '+91 98765 12001',
    ),
    const StudentModel(
      id: 'student_12',
      name: 'Krishna Parmar',
      studentId: 'GN-2026-3012',
      classId: 'class_3a_s2',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p12',
      parentName: 'Nayan Parmar',
      parentPhone: '+91 98765 12002',
    ),
    const StudentModel(
      id: 'student_13',
      name: 'Riya Chauhan',
      studentId: 'GN-2026-3013',
      classId: 'class_3a_s2',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p13',
      parentName: 'Dipak Chauhan',
      parentPhone: '+91 98765 12003',
    ),
    const StudentModel(
      id: 'student_14',
      name: 'Dhruv Thakor',
      studentId: 'GN-2026-3014',
      classId: 'class_3a_s2',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p14',
      parentName: 'Vinod Thakor',
      parentPhone: '+91 98765 12004',
    ),
    const StudentModel(
      id: 'student_15',
      name: 'Sneha Makwana',
      studentId: 'GN-2026-3015',
      classId: 'class_3a_s2',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p15',
      parentName: 'Pravin Makwana',
      parentPhone: '+91 98765 12005',
    ),

    // --- School 2, Class 4-A ---
    const StudentModel(
      id: 'student_16',
      name: 'Jayesh Rathod',
      studentId: 'GN-2026-4011',
      classId: 'class_4a_s2',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p16',
      parentName: 'Ramesh Rathod',
      parentPhone: '+91 98765 12006',
    ),
    const StudentModel(
      id: 'student_17',
      name: 'Heena Barot',
      studentId: 'GN-2026-4012',
      classId: 'class_4a_s2',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p17',
      parentName: 'Mahesh Barot',
      parentPhone: '+91 98765 12007',
    ),
    const StudentModel(
      id: 'student_18',
      name: 'Dev Patel',
      studentId: 'GN-2026-4013',
      classId: 'class_4a_s2',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p18',
      parentName: 'Jitendra Patel',
      parentPhone: '+91 98765 12008',
    ),
    const StudentModel(
      id: 'student_19',
      name: 'Tanya Desai',
      studentId: 'GN-2026-4014',
      classId: 'class_4a_s2',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p19',
      parentName: 'Samir Desai',
      parentPhone: '+91 98765 12009',
    ),
    const StudentModel(
      id: 'student_20',
      name: 'Parth Chavda',
      studentId: 'GN-2026-4015',
      classId: 'class_4a_s2',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_2',
      schoolName: 'GPS Sector 21 Primary School',
      parentId: 'user_parent_p20',
      parentName: 'Gautam Chavda',
      parentPhone: '+91 98765 12010',
    ),

    // --- School 3, Class 3-A ---
    const StudentModel(
      id: 'student_21',
      name: 'Ishan Pandya',
      studentId: 'GN-2026-3021',
      classId: 'class_3a_s3',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p21',
      parentName: 'Hemant Pandya',
      parentPhone: '+91 98765 13001',
    ),
    const StudentModel(
      id: 'student_22',
      name: 'Mansi Goswami',
      studentId: 'GN-2026-3022',
      classId: 'class_3a_s3',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p22',
      parentName: 'Kailash Goswami',
      parentPhone: '+91 98765 13002',
    ),
    const StudentModel(
      id: 'student_23',
      name: 'Tanvi Raval',
      studentId: 'GN-2026-3023',
      classId: 'class_3a_s3',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p23',
      parentName: 'Ashok Raval',
      parentPhone: '+91 98765 13003',
    ),
    const StudentModel(
      id: 'student_24',
      name: 'Yash Bhatt',
      studentId: 'GN-2026-3024',
      classId: 'class_3a_s3',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p24',
      parentName: 'Paresh Bhatt',
      parentPhone: '+91 98765 13004',
    ),
    const StudentModel(
      id: 'student_25',
      name: 'Kinjal Solanki',
      studentId: 'GN-2026-3025',
      classId: 'class_3a_s3',
      className: 'Class 3',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p25',
      parentName: 'Nilesh Solanki',
      parentPhone: '+91 98765 13005',
    ),

    // --- School 3, Class 4-A ---
    const StudentModel(
      id: 'student_26',
      name: 'Arnav Mehta',
      studentId: 'GN-2026-4021',
      classId: 'class_4a_s3',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p26',
      parentName: 'Chetan Mehta',
      parentPhone: '+91 98765 13006',
    ),
    const StudentModel(
      id: 'student_27',
      name: 'Jhanvi Trivedi',
      studentId: 'GN-2026-4022',
      classId: 'class_4a_s3',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p27',
      parentName: 'Shailesh Trivedi',
      parentPhone: '+91 98765 13007',
    ),
    const StudentModel(
      id: 'student_28',
      name: 'Vivek Nayak',
      studentId: 'GN-2026-4023',
      classId: 'class_4a_s3',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p28',
      parentName: 'Sanjay Nayak',
      parentPhone: '+91 98765 13008',
    ),
    const StudentModel(
      id: 'student_29',
      name: 'Jatin Sen',
      studentId: 'GN-2026-4024',
      classId: 'class_4a_s3',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p29',
      parentName: 'Manish Sen',
      parentPhone: '+91 98765 13009',
    ),
    const StudentModel(
      id: 'student_30',
      name: 'Komal Rawat',
      studentId: 'GN-2026-4025',
      classId: 'class_4a_s3',
      className: 'Class 4',
      section: 'A',
      schoolId: 'school_3',
      schoolName: 'GPS Sector 14 Primary School',
      parentId: 'user_parent_p30',
      parentName: 'Dinesh Rawat',
      parentPhone: '+91 98765 13010',
    ),
  ];

  // ==========================================
  // 7. ASSESSMENTS DATA
  // ==========================================
  static final List<AssessmentModel> assessments = [
    // ----------------------------------------------------
    // STUDENT 1: Aarav Kumar (Weak in Math & English Phonics)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s1_math',
      studentId: 'student_1',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 34,
      notes: 'Struggles with regrouping in subtraction and fraction concepts.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 8,
        ), // WEAK (40%)
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 4,
        ), // WEAK (20%)
      ],
    ),
    AssessmentModel(
      id: 'asmt_s1_eng',
      studentId: 'student_1',
      subjectId: 'subject_eng',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 16),
      totalMarks: 100,
      obtainedMarks: 38,
      notes: 'Needs phonics reinforcement and basic vocabulary building.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_eng_alphabet',
          topicName: 'Alphabet & Capitalization',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_eng_phonics',
          topicName: 'Phonics & Sounds',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
        TopicScore(
          topicId: 'topic_eng_vocab',
          topicName: 'Vocabulary',
          totalMarks: 20,
          obtainedMarks: 8,
        ), // WEAK (40%)
        TopicScore(
          topicId: 'topic_eng_reading',
          topicName: 'Reading Comprehension',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK (30%)
        TopicScore(
          topicId: 'topic_eng_writing',
          topicName: 'Basic Writing',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
      ],
    ),
    AssessmentModel(
      id: 'asmt_s1_guj',
      studentId: 'student_1',
      subjectId: 'subject_guj',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 17),
      totalMarks: 100,
      obtainedMarks: 52,
      notes: 'Average in Gujarati. Needs sentence framing assistance.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_guj_letters',
          topicName: 'Letters (મૂળાક્ષર)',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_guj_words',
          topicName: 'Words (શબ્દો)',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_guj_sentences',
          topicName: 'Sentences (વાક્ય રચના)',
          totalMarks: 20,
          obtainedMarks: 7,
        ), // WEAK (35%)
        TopicScore(
          topicId: 'topic_guj_reading',
          topicName: 'Reading (વાંચન)',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_guj_writing',
          topicName: 'Writing (લેખન)',
          totalMarks: 20,
          obtainedMarks: 8,
        ), // WEAK (40%)
      ],
    ),
    AssessmentModel(
      id: 'asmt_s1_evs',
      studentId: 'student_1',
      subjectId: 'subject_evs',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 18),
      totalMarks: 100,
      obtainedMarks: 58,
      notes:
          'Good curiosity in nature and animals; weak in water conservation.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_evs_plants',
          topicName: 'Plants & Trees',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_evs_animals',
          topicName: 'Animals & Habitats',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_evs_water',
          topicName: 'Water & Conservation',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK (30%)
        TopicScore(
          topicId: 'topic_evs_air',
          topicName: 'Air & Weather',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_evs_food',
          topicName: 'Food & Nutrition',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
      ],
    ),

    // ----------------------------------------------------
    // STUDENT 2: Diya Kumar (Strong / High Average)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s2_math',
      studentId: 'student_2',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 72,
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 13,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s2_eng',
      studentId: 'student_2',
      subjectId: 'subject_eng',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 16),
      totalMarks: 100,
      obtainedMarks: 76,
      topicScores: const [
        TopicScore(
          topicId: 'topic_eng_alphabet',
          topicName: 'Alphabet & Capitalization',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_eng_phonics',
          topicName: 'Phonics & Sounds',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_eng_vocab',
          topicName: 'Vocabulary',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_eng_reading',
          topicName: 'Reading Comprehension',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_eng_writing',
          topicName: 'Basic Writing',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s2_guj',
      studentId: 'student_2',
      subjectId: 'subject_guj',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 17),
      totalMarks: 100,
      obtainedMarks: 78,
      topicScores: const [
        TopicScore(
          topicId: 'topic_guj_letters',
          topicName: 'Letters (મૂળાક્ષર)',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_guj_words',
          topicName: 'Words (શબ્દો)',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_guj_sentences',
          topicName: 'Sentences (વાક્ય રચના)',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_guj_reading',
          topicName: 'Reading (વાંચન)',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_guj_writing',
          topicName: 'Writing (લેખન)',
          totalMarks: 20,
          obtainedMarks: 13,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s2_evs',
      studentId: 'student_2',
      subjectId: 'subject_evs',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 18),
      totalMarks: 100,
      obtainedMarks: 80,
      topicScores: const [
        TopicScore(
          topicId: 'topic_evs_plants',
          topicName: 'Plants & Trees',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_evs_animals',
          topicName: 'Animals & Habitats',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_evs_water',
          topicName: 'Water & Conservation',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_evs_air',
          topicName: 'Air & Weather',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_evs_food',
          topicName: 'Food & Nutrition',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
      ],
    ),

    // ----------------------------------------------------
    // STUDENT 3: Priya Sharma (Strong - >85%)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s3_math',
      studentId: 'student_3',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 89,
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 20,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s3_eng',
      studentId: 'student_3',
      subjectId: 'subject_eng',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 16),
      totalMarks: 100,
      obtainedMarks: 86,
      topicScores: const [
        TopicScore(
          topicId: 'topic_eng_alphabet',
          topicName: 'Alphabet & Capitalization',
          totalMarks: 20,
          obtainedMarks: 20,
        ),
        TopicScore(
          topicId: 'topic_eng_phonics',
          topicName: 'Phonics & Sounds',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_eng_vocab',
          topicName: 'Vocabulary',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_eng_reading',
          topicName: 'Reading Comprehension',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_eng_writing',
          topicName: 'Basic Writing',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s3_guj',
      studentId: 'student_3',
      subjectId: 'subject_guj',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 17),
      totalMarks: 100,
      obtainedMarks: 91,
      topicScores: const [
        TopicScore(
          topicId: 'topic_guj_letters',
          topicName: 'Letters (મૂળાક્ષર)',
          totalMarks: 20,
          obtainedMarks: 20,
        ),
        TopicScore(
          topicId: 'topic_guj_words',
          topicName: 'Words (શબ્દો)',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_guj_sentences',
          topicName: 'Sentences (વાક્ય રચના)',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_guj_reading',
          topicName: 'Reading (વાંચન)',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_guj_writing',
          topicName: 'Writing (લેખન)',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s3_evs',
      studentId: 'student_3',
      subjectId: 'subject_evs',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 18),
      totalMarks: 100,
      obtainedMarks: 92,
      topicScores: const [
        TopicScore(
          topicId: 'topic_evs_plants',
          topicName: 'Plants & Trees',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_evs_animals',
          topicName: 'Animals & Habitats',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_evs_water',
          topicName: 'Water & Conservation',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_evs_air',
          topicName: 'Air & Weather',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_evs_food',
          topicName: 'Food & Nutrition',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
      ],
    ),

    // ----------------------------------------------------
    // STUDENT 4: Rahul Varma (Average - ~55%)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s4_math',
      studentId: 'student_4',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 55,
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 7,
        ), // WEAK (35%)
      ],
    ),
    AssessmentModel(
      id: 'asmt_s4_eng',
      studentId: 'student_4',
      subjectId: 'subject_eng',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 16),
      totalMarks: 100,
      obtainedMarks: 51,
      topicScores: const [
        TopicScore(
          topicId: 'topic_eng_alphabet',
          topicName: 'Alphabet & Capitalization',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_eng_phonics',
          topicName: 'Phonics & Sounds',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_eng_vocab',
          topicName: 'Vocabulary',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_eng_reading',
          topicName: 'Reading Comprehension',
          totalMarks: 20,
          obtainedMarks: 8,
        ),
        TopicScore(
          topicId: 'topic_eng_writing',
          topicName: 'Basic Writing',
          totalMarks: 20,
          obtainedMarks: 7,
        ), // WEAK (35%)
      ],
    ),
    AssessmentModel(
      id: 'asmt_s4_guj',
      studentId: 'student_4',
      subjectId: 'subject_guj',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 17),
      totalMarks: 100,
      obtainedMarks: 58,
      topicScores: const [
        TopicScore(
          topicId: 'topic_guj_letters',
          topicName: 'Letters (મૂળાક્ષર)',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_guj_words',
          topicName: 'Words (શબ્દો)',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_guj_sentences',
          topicName: 'Sentences (વાક્ય રચના)',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_guj_reading',
          topicName: 'Reading (વાંચન)',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_guj_writing',
          topicName: 'Writing (લેખન)',
          totalMarks: 20,
          obtainedMarks: 8,
        ), // WEAK (40%)
      ],
    ),
    AssessmentModel(
      id: 'asmt_s4_evs',
      studentId: 'student_4',
      subjectId: 'subject_evs',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 18),
      totalMarks: 100,
      obtainedMarks: 56,
      topicScores: const [
        TopicScore(
          topicId: 'topic_evs_plants',
          topicName: 'Plants & Trees',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_evs_animals',
          topicName: 'Animals & Habitats',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_evs_water',
          topicName: 'Water & Conservation',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_evs_air',
          topicName: 'Air & Weather',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_evs_food',
          topicName: 'Food & Nutrition',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
      ],
    ),

    // STUDENT 5: Ananya Patel -> NOT ASSESSED (intentionally omitted to model unassessed students)

    // ----------------------------------------------------
    // STUDENT 6: Bhavik Solanki (Weak in Math Division & English)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s6_math',
      studentId: 'student_6',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 32,
      notes: 'Struggles with division, multiplication tables, and fractions.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 7,
        ), // WEAK (35%)
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK (30%)
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 4,
        ), // WEAK (20%)
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
      ],
    ),
    AssessmentModel(
      id: 'asmt_s6_eng',
      studentId: 'student_6',
      subjectId: 'subject_eng',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 16),
      totalMarks: 100,
      obtainedMarks: 36,
      topicScores: const [
        TopicScore(
          topicId: 'topic_eng_alphabet',
          topicName: 'Alphabet & Capitalization',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_eng_phonics',
          topicName: 'Phonics & Sounds',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK (30%)
        TopicScore(
          topicId: 'topic_eng_vocab',
          topicName: 'Vocabulary',
          totalMarks: 20,
          obtainedMarks: 7,
        ), // WEAK (35%)
        TopicScore(
          topicId: 'topic_eng_reading',
          topicName: 'Reading Comprehension',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK (30%)
        TopicScore(
          topicId: 'topic_eng_writing',
          topicName: 'Basic Writing',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
      ],
    ),

    // ----------------------------------------------------
    // STUDENT 7: Kavyan Shah (Average - 63%)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s7_math',
      studentId: 'student_7',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 64,
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 14,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 13,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
      ],
    ),

    // ----------------------------------------------------
    // STUDENT 8: Nidhi Joshi (Strong - 88%)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s8_math',
      studentId: 'student_8',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 88,
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
      ],
    ),

    // ----------------------------------------------------
    // STUDENT 9: Harshil Dave (Average - 53%)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s9_math',
      studentId: 'student_9',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 53,
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 8,
        ), // WEAK (40%)
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 8,
        ), // WEAK (40%)
      ],
    ),

    // ----------------------------------------------------
    // STUDENT 10: Pooja Prajapati (Weak in Gujarati & Math - 38%)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s10_guj',
      studentId: 'student_10',
      subjectId: 'subject_guj',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 17),
      totalMarks: 100,
      obtainedMarks: 34,
      notes: 'Difficulties with sentence formation and handwriting.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_guj_letters',
          topicName: 'Letters (મૂળાક્ષર)',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_guj_words',
          topicName: 'Words (શબ્દો)',
          totalMarks: 20,
          obtainedMarks: 8,
        ), // WEAK (40%)
        TopicScore(
          topicId: 'topic_guj_sentences',
          topicName: 'Sentences (વાક્ય રચના)',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
        TopicScore(
          topicId: 'topic_guj_reading',
          topicName: 'Reading (વાંચન)',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK (25%)
        TopicScore(
          topicId: 'topic_guj_writing',
          topicName: 'Writing (લેખન)',
          totalMarks: 20,
          obtainedMarks: 4,
        ), // WEAK (20%)
      ],
    ),

    // ----------------------------------------------------
    // SCHOOL 2 ASSESSMENTS (Students 11-20)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s11_evs',
      studentId: 'student_11',
      subjectId: 'subject_evs',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 18),
      totalMarks: 100,
      obtainedMarks: 36, // WEAK
      notes: 'Weak in water conservation and environmental cycle.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_evs_plants',
          topicName: 'Plants & Trees',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
        TopicScore(
          topicId: 'topic_evs_animals',
          topicName: 'Animals & Habitats',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_evs_water',
          topicName: 'Water & Conservation',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK
        TopicScore(
          topicId: 'topic_evs_air',
          topicName: 'Air & Weather',
          totalMarks: 20,
          obtainedMarks: 6,
        ),
        TopicScore(
          topicId: 'topic_evs_food',
          topicName: 'Food & Nutrition',
          totalMarks: 20,
          obtainedMarks: 6,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s12_math',
      studentId: 'student_12',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 58, // AVERAGE
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s13_math',
      studentId: 'student_13',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 84, // STRONG
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s14_math',
      studentId: 'student_14',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 62, // AVERAGE
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 13,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
      ],
    ),
    // student_15: Sneha Makwana -> NOT ASSESSED

    AssessmentModel(
      id: 'asmt_s16_evs',
      studentId: 'student_16',
      subjectId: 'subject_evs',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 18),
      totalMarks: 100,
      obtainedMarks: 38, // WEAK
      notes: 'Plant parts and function need physical identification activity.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_evs_plants',
          topicName: 'Plants & Trees',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK
        TopicScore(
          topicId: 'topic_evs_animals',
          topicName: 'Animals & Habitats',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_evs_water',
          topicName: 'Water & Conservation',
          totalMarks: 20,
          obtainedMarks: 8,
        ),
        TopicScore(
          topicId: 'topic_evs_air',
          topicName: 'Air & Weather',
          totalMarks: 20,
          obtainedMarks: 8,
        ),
        TopicScore(
          topicId: 'topic_evs_food',
          topicName: 'Food & Nutrition',
          totalMarks: 20,
          obtainedMarks: 7,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s17_math',
      studentId: 'student_17',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 60, // AVERAGE
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 13,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s18_math',
      studentId: 'student_18',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 86, // STRONG
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s19_math',
      studentId: 'student_19',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 82, // STRONG
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s20_math',
      studentId: 'student_20',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 56, // AVERAGE
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
      ],
    ),

    // ----------------------------------------------------
    // SCHOOL 3 ASSESSMENTS (Students 21-30)
    // ----------------------------------------------------
    AssessmentModel(
      id: 'asmt_s21_eng',
      studentId: 'student_21',
      subjectId: 'subject_eng',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 16),
      totalMarks: 100,
      obtainedMarks: 34, // WEAK
      notes: 'Requires vocabulary flashcard activities.',
      topicScores: const [
        TopicScore(
          topicId: 'topic_eng_alphabet',
          topicName: 'Alphabet & Capitalization',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_eng_phonics',
          topicName: 'Phonics & Sounds',
          totalMarks: 20,
          obtainedMarks: 6,
        ),
        TopicScore(
          topicId: 'topic_eng_vocab',
          topicName: 'Vocabulary',
          totalMarks: 20,
          obtainedMarks: 5,
        ), // WEAK
        TopicScore(
          topicId: 'topic_eng_reading',
          topicName: 'Reading Comprehension',
          totalMarks: 20,
          obtainedMarks: 6,
        ),
        TopicScore(
          topicId: 'topic_eng_writing',
          topicName: 'Basic Writing',
          totalMarks: 20,
          obtainedMarks: 5,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s22_math',
      studentId: 'student_22',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 58, // AVERAGE
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s23_math',
      studentId: 'student_23',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 88, // STRONG
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 20,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s24_math',
      studentId: 'student_24',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 62, // AVERAGE
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 13,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s25_math',
      studentId: 'student_25',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 36, // WEAK
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 7,
        ), // WEAK
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK
      ],
    ),
    AssessmentModel(
      id: 'asmt_s26_math',
      studentId: 'student_26',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 91, // STRONG
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 20,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 17,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s27_math',
      studentId: 'student_27',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 85, // STRONG
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 19,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 18,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 16,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s28_math',
      studentId: 'student_28',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 59, // AVERAGE
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 15,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 13,
        ),
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 12,
        ),
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 10,
        ),
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 9,
        ),
      ],
    ),
    AssessmentModel(
      id: 'asmt_s29_math',
      studentId: 'student_29',
      subjectId: 'subject_math',
      type: AssessmentType.regular,
      date: DateTime(2026, 9, 15),
      totalMarks: 100,
      obtainedMarks: 35, // WEAK
      topicScores: const [
        TopicScore(
          topicId: 'topic_math_add',
          topicName: 'Addition',
          totalMarks: 20,
          obtainedMarks: 11,
        ),
        TopicScore(
          topicId: 'topic_math_sub',
          topicName: 'Subtraction',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK
        TopicScore(
          topicId: 'topic_math_mul',
          topicName: 'Multiplication',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK
        TopicScore(
          topicId: 'topic_math_div',
          topicName: 'Division',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK
        TopicScore(
          topicId: 'topic_math_frac',
          topicName: 'Fractions',
          totalMarks: 20,
          obtainedMarks: 6,
        ), // WEAK
      ],
    ),
    // student_30: Komal Rawat -> NOT ASSESSED
  ];

  // ==========================================
  // 8. REMEDIAL ACTIONS DATA
  // ==========================================
  static final List<RemedialAction> remedialActions = [
    RemedialAction(
      id: 'remedial_1',
      studentId: 'student_1',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      topicName: 'Subtraction',
      activityDescription: 'Two-digit subtraction with borrowing using visual base-10 blocks and step-by-step number line exercises.',
      hasQuiz: true,
      assignedDate: DateTime(2026, 10, 1),
      dueDate: DateTime(2026, 10, 10),
      status: RemedialStatus.inProgress,
      teacherNote: 'Aarav is beginning to grasp borrowing with concrete objects. Needs consistent reinforcement on crossing out tens.',
      parentInstruction: 'Please sit with Aarav for 15 minutes each evening and practice 4 subtraction problems using actual spoons or pebbles.',
    ),
    RemedialAction(
      id: 'remedial_2',
      studentId: 'student_1',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      topicName: 'Phonics & Sounds',
      activityDescription: 'Short vowel identification and CVC sound blending using picture-word association cards.',
      hasQuiz: true,
      assignedDate: DateTime(2026, 9, 20),
      dueDate: DateTime(2026, 9, 30),
      status: RemedialStatus.completed,
      teacherNote: 'Great improvement in rhyming word games. Aarav achieved 80% on the follow-up phonics checkpoint quiz!',
      parentInstruction: 'Encourage Aarav to read aloud labels and street signs when going for evening walks.',
    ),
    RemedialAction(
      id: 'remedial_3',
      studentId: 'student_1',
      subjectId: 'subject_math',
      topicId: 'topic_math_frac',
      topicName: 'Fractions',
      activityDescription: 'Interactive paper-folding activity to conceptualize 1/2, 1/3, and 1/4 as equal parts of a whole.',
      hasQuiz: true,
      assignedDate: DateTime(2026, 10, 5),
      dueDate: DateTime(2026, 10, 18),
      status: RemedialStatus.assigned,
      teacherNote: 'Introduce hands-on cutting before symbolic fractional notation (p/q).',
      parentInstruction: 'While serving meals or cutting fruits like apples, ask Aarav to divide them into 2 or 4 equal pieces.',
    ),
    RemedialAction(
      id: 'remedial_4',
      studentId: 'student_6',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      topicName: 'Division',
      activityDescription: 'Concept of equal distribution and repeated subtraction using grouping counters.',
      hasQuiz: true,
      assignedDate: DateTime(2026, 10, 2),
      dueDate: DateTime(2026, 10, 12),
      status: RemedialStatus.inProgress,
      teacherNote: 'Bhavik needs more practice connecting multiplication tables with division steps.',
      parentInstruction: 'Help Bhavik distribute 20 dry beans equally into 4 small bowls and count how many beans each bowl receives.',
    ),
    RemedialAction(
      id: 'remedial_5',
      studentId: 'student_10',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_sentences',
      topicName: 'Sentences (વાક્ય રચના)',
      activityDescription: 'Flashcard sentence rearrangement and punctuation practice (પૂર્ણવિરામ અને પ્રશ્નાર્થચિહ્ન).',
      hasQuiz: true,
      assignedDate: DateTime(2026, 9, 22),
      dueDate: DateTime(2026, 10, 4),
      status: RemedialStatus.needsFollowUp,
      teacherNote: 'Pooja still leaves sentences incomplete without terminal punctuation. Supplemental worksheet assigned.',
      parentInstruction: 'રોજ સાંજે 3 સરળ વાક્યો બોલાવીને નોટબુકમાં લખાવો અને છેલ્લે પૂર્ણવિરામ મૂકવાની ટેવ પાડો.',
    ),
    RemedialAction(
      id: 'remedial_6',
      studentId: 'student_11',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_water',
      topicName: 'Water & Conservation',
      activityDescription:
          'Home water audit chart and drawing the water cycle diagram.',
      hasQuiz: true,
      assignedDate: DateTime(2026, 10, 3),
      dueDate: DateTime(2026, 10, 14),
      status: RemedialStatus.inProgress,
      teacherNote:
          'Demonstrated high enthusiasm in the classroom water demonstration.',
      parentInstruction: 'Discuss with Meet where the water in your tap comes from and show how to turn off leaking taps.',
    ),
    RemedialAction(
      id: 'remedial_7',
      studentId: 'student_16',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      topicName: 'Plants & Trees',
      activityDescription: 'School garden leaf collection, root observation, and labeling parts of a flowering plant.',
      hasQuiz: true,
      assignedDate: DateTime(2026, 9, 25),
      dueDate: DateTime(2026, 10, 5),
      status: RemedialStatus.completed,
      teacherNote: 'Jayesh successfully labeled all 5 parts of the plant and scored 100% on the quiz.',
      parentInstruction: 'Water potted plants at home together and observe new leaves sprouting.',
    ),
    RemedialAction(
      id: 'remedial_8',
      studentId: 'student_21',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_vocab',
      topicName: 'Vocabulary',
      activityDescription: 'Illustrated picture dictionary making for 20 household and classroom items.',
      hasQuiz: true,
      assignedDate: DateTime(2026, 10, 6),
      dueDate: DateTime(2026, 10, 16),
      status: RemedialStatus.assigned,
      teacherNote: 'Encourage bilingual vocabulary flashcards (English word with Gujarati translation).',
      parentInstruction: 'Point to everyday items like chair, plate, door and practice saying their English words together.',
    ),
  ];

  // ==========================================
  // 9. QUIZ QUESTIONS (50+ questions covering required topics)
  // ==========================================
  static final List<QuizQuestion> quizQuestions = [
    // -------------------------------------------------------------------------
    // TOPIC 1: Math - Subtraction (topic_math_sub) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_sub_1',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      difficulty: 'easy',
      questionText: 'What is 45 - 18?',
      options: ['27', '37', '23', '33'],
      correctAnswerIndex: 0,
      explanation: 'Borrow 1 ten from 4 tens to make 15 ones. 15 - 8 = 7 ones. 3 tens - 1 ten = 2 tens. Answer is 27.',
    ),
    const QuizQuestion(
      id: 'q_sub_2',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      difficulty: 'easy',
      questionText: 'Aarav has 32 marbles. He gives 14 marbles to his friend Rahul. How many marbles are left with Aarav?',
      options: ['16', '18', '22', '20'],
      correctAnswerIndex: 1,
      explanation: '32 - 14 = 18. Aarav has 18 marbles remaining.',
    ),
    const QuizQuestion(
      id: 'q_sub_3',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      difficulty: 'medium',
      questionText: 'Subtract 25 from 70:',
      options: ['55', '45', '50', '35'],
      correctAnswerIndex: 1,
      explanation: '70 - 25 = 45. Regroup 7 tens into 6 tens and 10 ones. 10 - 5 = 5; 6 - 2 = 4.',
    ),
    const QuizQuestion(
      id: 'q_sub_4',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      difficulty: 'medium',
      questionText: 'What is 504 - 267?',
      options: ['247', '237', '337', '227'],
      correctAnswerIndex: 1,
      explanation: '504 - 267 = 237. Regroup across zero: 5 hundreds become 4 hundreds, 9 tens, 14 ones.',
    ),
    const QuizQuestion(
      id: 'q_sub_5',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      difficulty: 'hard',
      questionText: 'A fruit seller had 150 apples. He sold 38 apples in the morning and 12 spoiled apples were discarded. How many fresh apples remain?',
      options: ['110', '100', '102', '98'],
      correctAnswerIndex: 1,
      explanation:
          'Total removed = 38 + 12 = 50. Remaining apples = 150 - 50 = 100.',
    ),
    const QuizQuestion(
      id: 'q_sub_6',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      difficulty: 'hard',
      questionText: 'What number must be added to 345 to get 500?',
      options: ['165', '145', '155', '255'],
      correctAnswerIndex: 2,
      explanation: '500 - 345 = 155.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 2: Math - Division (topic_math_div) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_div_1',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      difficulty: 'easy',
      questionText: 'Share 24 mangoes equally among 4 children. How many mangoes does each child receive?',
      options: ['5', '6', '7', '8'],
      correctAnswerIndex: 1,
      explanation: '24 ÷ 4 = 6. Each child gets 6 mangoes.',
    ),
    const QuizQuestion(
      id: 'q_div_2',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      difficulty: 'easy',
      questionText: 'What is 18 ÷ 3?',
      options: ['4', '5', '6', '7'],
      correctAnswerIndex: 2,
      explanation: 'Since 3 × 6 = 18, 18 ÷ 3 = 6.',
    ),
    const QuizQuestion(
      id: 'q_div_3',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      difficulty: 'medium',
      questionText: 'Calculate: 72 ÷ 8 = ?',
      options: ['7', '8', '9', '6'],
      correctAnswerIndex: 2,
      explanation: '8 × 9 = 72, so 72 ÷ 8 = 9.',
    ),
    const QuizQuestion(
      id: 'q_div_4',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      difficulty: 'medium',
      questionText: 'A factory packs 90 pencils in boxes of 9 pencils each. How many boxes are needed?',
      options: ['8', '10', '12', '9'],
      correctAnswerIndex: 1,
      explanation: '90 ÷ 9 = 10 boxes.',
    ),
    const QuizQuestion(
      id: 'q_div_5',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      difficulty: 'hard',
      questionText:
          'When 47 is divided by 5, what is the quotient and the remainder?',
      options: [
        'Quotient = 8, Remainder = 7',
        'Quotient = 9, Remainder = 2',
        'Quotient = 9, Remainder = 4',
        'Quotient = 8, Remainder = 2',
      ],
      correctAnswerIndex: 1,
      explanation:
          '5 × 9 = 45. 47 - 45 = 2. So Quotient = 9 and Remainder = 2.',
    ),
    const QuizQuestion(
      id: 'q_div_6',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      difficulty: 'hard',
      questionText: 'What is 144 ÷ 12?',
      options: ['11', '12', '13', '14'],
      correctAnswerIndex: 1,
      explanation: '12 × 12 = 144, hence 144 ÷ 12 = 12.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 3: Math - Fractions (topic_math_frac) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_frac_1',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_frac',
      difficulty: 'easy',
      questionText: 'If a roti is cut into 2 equal parts, what fraction does 1 part represent?',
      options: ['1/4', '1/2', '2/1', '1/3'],
      correctAnswerIndex: 1,
      explanation: 'One of two equal parts is written as 1/2 (one half).',
    ),
    const QuizQuestion(
      id: 'q_frac_2',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_frac',
      difficulty: 'easy',
      questionText: 'What fraction of a shape is shaded if 1 out of 4 equal parts is colored?',
      options: ['1/3', '1/4', '3/4', '4/1'],
      correctAnswerIndex: 1,
      explanation: 'One part shaded out of 4 total equal parts equals 1/4 (one quarter).',
    ),
    const QuizQuestion(
      id: 'q_frac_3',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_frac',
      difficulty: 'medium',
      questionText: 'In the fraction 3/7, what is the numerator?',
      options: ['7', '3', '10', '4'],
      correctAnswerIndex: 1,
      explanation: 'In any fraction a/b, the top number "a" is the numerator and the bottom number "b" is the denominator.',
    ),
    const QuizQuestion(
      id: 'q_frac_4',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_frac',
      difficulty: 'medium',
      questionText: 'Which of the following fractions is greater: 1/2 or 1/4?',
      options: [
        '1/4 is greater',
        '1/2 is greater',
        'Both are equal',
        'Cannot be compared',
      ],
      correctAnswerIndex: 1,
      explanation: 'When denominators are smaller for the same numerator, the parts are larger. 1/2 (50%) is greater than 1/4 (25%).',
    ),
    const QuizQuestion(
      id: 'q_frac_5',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_frac',
      difficulty: 'hard',
      questionText: 'What is 2/7 + 3/7?',
      options: ['5/14', '5/7', '6/7', '1/7'],
      correctAnswerIndex: 1,
      explanation: 'With like denominators, add the numerators directly: (2 + 3) / 7 = 5/7.',
    ),
    const QuizQuestion(
      id: 'q_frac_6',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_frac',
      difficulty: 'hard',
      questionText: 'A pizza is cut into 8 equal slices. Rohan ate 3 slices. What fraction of the pizza did Rohan eat?',
      options: ['3/8', '5/8', '8/3', '1/8'],
      correctAnswerIndex: 0,
      explanation: 'Rohan ate 3 slices out of a total 8 slices, which is 3/8 of the pizza.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 4: English - Phonics & Sounds (topic_eng_phonics) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_phon_1',
      classId: 'class_3',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      difficulty: 'easy',
      questionText: 'Which word has the short "a" sound as heard in "cat"?',
      options: ['Cake', 'Bat', 'Car', 'Ball'],
      correctAnswerIndex: 1,
      explanation: '"Bat" has the short vowel /æ/ sound matching "cat".',
    ),
    const QuizQuestion(
      id: 'q_phon_2',
      classId: 'class_3',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      difficulty: 'easy',
      questionText: 'Which word begins with the "sh" sound?',
      options: ['Sun', 'Ship', 'Chip', 'Skip'],
      correctAnswerIndex: 1,
      explanation: '"Ship" starts with the digraph "sh" (/ʃ/ sound).',
    ),
    const QuizQuestion(
      id: 'q_phon_3',
      classId: 'class_3',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      difficulty: 'medium',
      questionText: 'Which word rhymes with "pin"?',
      options: ['Pan', 'Pen', 'Tin', 'Pun'],
      correctAnswerIndex: 2,
      explanation: '"Pin" and "Tin" share the same ending sound "-in".',
    ),
    const QuizQuestion(
      id: 'q_phon_4',
      classId: 'class_4',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      difficulty: 'medium',
      questionText: 'In which of the following words is the letter "k" silent?',
      options: ['King', 'Kite', 'Knife', 'Kangaroo'],
      correctAnswerIndex: 2,
      explanation: 'In "Knife", the letter "k" is silent before "n" and pronounced /naɪf/.',
    ),
    const QuizQuestion(
      id: 'q_phon_5',
      classId: 'class_4',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      difficulty: 'hard',
      questionText: 'Which word has the digraph "ch" pronounced like "k"?',
      options: ['Chair', 'School', 'Child', 'Church'],
      correctAnswerIndex: 1,
      explanation: 'In "School", the "ch" makes the hard /k/ sound.',
    ),
    const QuizQuestion(
      id: 'q_phon_6',
      classId: 'class_4',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      difficulty: 'hard',
      questionText: 'Choose the word that rhymes with "light":',
      options: ['Late', 'Bright', 'Lid', 'Leaf'],
      correctAnswerIndex: 1,
      explanation:
          '"Bright" and "Light" end with the exact "-ight" rhyme sound.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 5: English - Vocabulary (topic_eng_vocab) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_voc_1',
      classId: 'class_3',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_vocab',
      difficulty: 'easy',
      questionText: 'What is the opposite (antonym) of the word "Hot"?',
      options: ['Warm', 'Cold', 'Bright', 'Sun'],
      correctAnswerIndex: 1,
      explanation: 'The opposite of "Hot" is "Cold".',
    ),
    const QuizQuestion(
      id: 'q_voc_2',
      classId: 'class_3',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_vocab',
      difficulty: 'easy',
      questionText: 'A baby dog is known as a:',
      options: ['Kitten', 'Calf', 'Puppy', 'Cub'],
      correctAnswerIndex: 2,
      explanation: 'A young dog is called a puppy.',
    ),
    const QuizQuestion(
      id: 'q_voc_3',
      classId: 'class_3',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_vocab',
      difficulty: 'medium',
      questionText: 'A person who cures sick people in a hospital is called a:',
      options: ['Teacher', 'Doctor', 'Tailor', 'Farmer'],
      correctAnswerIndex: 1,
      explanation:
          'A doctor diagnoses and treats patients in a clinic or hospital.',
    ),
    const QuizQuestion(
      id: 'q_voc_4',
      classId: 'class_4',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_vocab',
      difficulty: 'medium',
      questionText: 'What is the plural form of the word "Leaf"?',
      options: ['Leafs', 'Leaves', 'Leafes', 'Leaven'],
      correctAnswerIndex: 1,
      explanation: 'Nouns ending in "-f" often change to "-ves" in plural: Leaf -> Leaves.',
    ),
    const QuizQuestion(
      id: 'q_voc_5',
      classId: 'class_4',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_vocab',
      difficulty: 'hard',
      questionText: 'Which word has the same meaning (synonym) as "Joyful"?',
      options: ['Angry', 'Sad', 'Happy', 'Afraid'],
      correctAnswerIndex: 2,
      explanation: '"Joyful" and "Happy" both describe feeling or expressing great pleasure.',
    ),
    const QuizQuestion(
      id: 'q_voc_6',
      classId: 'class_4',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_vocab',
      difficulty: 'hard',
      questionText: 'Choose the correct word to fill in the blank: "The stars _____ in the night sky."',
      options: ['Twinkle', 'Roar', 'Bark', 'Flow'],
      correctAnswerIndex: 0,
      explanation: 'Stars sparkle or twinkle in the night sky.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 6: Gujarati - Sentences (topic_guj_sentences) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_guj_sen_1',
      classId: 'class_3',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_sentences',
      difficulty: 'easy',
      questionText:
          'યોગ્ય ક્રમમાં ગોઠવી સાચું વાક્ય બનાવો: "જાય / શાળાએ / રમેશ / છે."',
      options: [
        'શાળાએ છે જાય રમેશ.',
        'રમેશ શાળાએ જાય છે.',
        'જાય છે રમેશ શાળાએ.',
        'છે શાળાએ રમેશ જાય.',
      ],
      correctAnswerIndex: 1,
      explanation: 'ગુજરાતી વાક્ય રચના: કર્તા (રમેશ) + કર્મ (શાળાએ) + ક્રિયાપદ (જાય છે).',
    ),
    const QuizQuestion(
      id: 'q_guj_sen_2',
      classId: 'class_3',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_sentences',
      difficulty: 'easy',
      questionText: 'ખાલી જગ્યા પૂરો: "મોર આપણું રાષ્ટ્રીય પક્ષી _____."',
      options: ['હતું', 'છે', 'નથી', 'થશે'],
      correctAnswerIndex: 1,
      explanation: 'વર્તમાનકાળમાં સાચું સહાયક ક્રિયાપદ "છે" આવે.',
    ),
    const QuizQuestion(
      id: 'q_guj_sen_3',
      classId: 'class_3',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_sentences',
      difficulty: 'medium',
      questionText: 'નીચેનામાંથી પ્રશ્નાર્થ વાક્ય કયું છે?',
      options: [
        'બાગમાં સુંદર ફૂલો ખીલ્યા છે.',
        'તમારું નામ શું છે?',
        'સૂરજ પૂર્વમાં ઊગે છે.',
        'આજે રજાનો દિવસ છે.',
      ],
      correctAnswerIndex: 1,
      explanation: '"તમારું નામ શું છે?" એ પ્રશ્ન પૂછતું વાક્ય છે અને તેમાં પ્રશ્નાર્થચિહ્ન છે.',
    ),
    const QuizQuestion(
      id: 'q_guj_sen_4',
      classId: 'class_4',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_sentences',
      difficulty: 'medium',
      questionText: '"ગાય આપણને દૂધ આપે છે." - આ વાક્યમાં ક્રિયાપદ કયું છે?',
      options: ['ગાય', 'આપણને', 'દૂધ', 'આપે છે'],
      correctAnswerIndex: 3,
      explanation: 'વાક્યમાં જે શબ્દ ક્રિયા દર્શાવે તેને ક્રિયાપદ કહેવાય. અહીં "આપે છે" ક્રિયાપદ છે.',
    ),
    const QuizQuestion(
      id: 'q_guj_sen_5',
      classId: 'class_4',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_sentences',
      difficulty: 'hard',
      questionText: 'સાચી વિરામચિહ્નવાળી વાક્યરચના કઈ છે?',
      options: [
        'અરે વાહ તમે ખૂબ સુંદર ચિત્ર દોર્યું.',
        'અરે વાહ! તમે ખૂબ સુંદર ચિત્ર દોર્યું.',
        'અરે વાહ? તમે ખૂબ સુંદર ચિત્ર દોર્યું?',
        'અરે વાહ; તમે ખૂબ સુંદર ચિત્ર દોર્યું',
      ],
      correctAnswerIndex: 1,
      explanation: 'આશ્ચર્ય કે પ્રશંસા દર્શાવવા ઉદ્ગારચિહ્ન (!) વપરાય છે.',
    ),
    const QuizQuestion(
      id: 'q_guj_sen_6',
      classId: 'class_4',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_sentences',
      difficulty: 'hard',
      questionText: 'વિરોધી અર્થ આપતું વાક્ય પૂરું કરો: "દિવસ દરમિયાન અજવાળું હોય છે, જ્યારે રાત્રે _____ હોય છે."',
      options: ['પ્રકાશ', 'અંધારું', 'તડકો', 'ગરમી'],
      correctAnswerIndex: 1,
      explanation: 'અજવાળાનો વિરોધી શબ્દ અંધારું થાય.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 7: Gujarati - Reading (topic_guj_reading) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_guj_read_1',
      classId: 'class_3',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_reading',
      difficulty: 'easy',
      questionText: 'નીચેનામાંથી સાચી જોડણીવાળો શબ્દ શોધો:',
      options: ['પુસ્તક', 'પુશતક', 'પૂસ્તક', 'પુસતક'],
      correctAnswerIndex: 0,
      explanation: '"પુસ્તક" સાચી ગુજરાતી જોડણી છે.',
    ),
    const QuizQuestion(
      id: 'q_guj_read_2',
      classId: 'class_3',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_reading',
      difficulty: 'easy',
      questionText: 'કમળ ક્યાં ખીલે છે?',
      options: ['ઝાડ ઉપર', 'કાદવ અને પાણીમાં', 'રેતીમાં', 'ઘરમાં'],
      correctAnswerIndex: 1,
      explanation: 'કમળ જળચર વનસ્પતિ છે જે તળાવના કાદવ અને પાણીમાં ખીલે છે.',
    ),
    const QuizQuestion(
      id: 'q_guj_read_3',
      classId: 'class_3',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_reading',
      difficulty: 'medium',
      questionText: 'વાંચીને જવાબ આપો: "સિંહ જંગલનો રાજા કહેવાય છે. તે ગુફામાં રહે છે." સિંહનું રહેઠાણ કયું છે?',
      options: ['માળો', 'દર', 'ગુફા', 'તળાવ'],
      correctAnswerIndex: 2,
      explanation: 'વાક્યમાં સ્પષ્ટ લખ્યું છે કે તે ગુફામાં રહે છે.',
    ),
    const QuizQuestion(
      id: 'q_guj_read_4',
      classId: 'class_4',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_reading',
      difficulty: 'medium',
      questionText: '"સૂર્ય પૂર્વ દિશામાં ઊગે છે અને પશ્ચિમ દિશામાં આથમે છે." સૂર્ય કઈ દિશામાં આથમે છે?',
      options: ['પૂર્વ', 'પશ્ચિમ', 'ઉત્તર', 'દક્ષિણ'],
      correctAnswerIndex: 1,
      explanation: 'સૂર્ય પશ્ચિમ દિશામાં આથમે છે.',
    ),
    const QuizQuestion(
      id: 'q_guj_read_5',
      classId: 'class_4',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_reading',
      difficulty: 'hard',
      questionText: '"ઝાડ આપણને મીઠા ફળ, છાંયડો અને શુદ્ધ ઓક્સિજન આપે છે." આ ફકરાનો મુખ્ય સંદેશ શું છે?',
      options: [
        'ઝાડ કાપી નાખવા જોઈએ.',
        'વૃક્ષો આપણા સાચા મિત્રો છે અને તેનું જતન કરવું જોઈએ.',
        'ફળ ન ખાવા જોઈએ.',
        'બાગમાં ન જવું જોઈએ.',
      ],
      correctAnswerIndex: 1,
      explanation: 'વૃક્ષો આપણને જીવવા માટે જરૂરી વસ્તુઓ આપે છે એટલે તેનું રક્ષણ કરવું જોઈએ.',
    ),
    const QuizQuestion(
      id: 'q_guj_read_6',
      classId: 'class_4',
      subjectId: 'subject_guj',
      topicId: 'topic_guj_reading',
      difficulty: 'hard',
      questionText: '"પરિશ્રમ એ જ પારસમણિ છે." આ કહેવત શાનું મહત્વ સમજાવે છે?',
      options: ['ઊંઘવાનું', 'મહેનત કરવાનું', 'રમવાનું', 'ખર્ચ કરવાનું'],
      correctAnswerIndex: 1,
      explanation: 'પરિશ્રમ એટલે કે સખત મહેનત કરવાથી જ સફળતા મળે છે.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 8: EVS - Water & Conservation (topic_evs_water) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_evs_wat_1',
      classId: 'class_3',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_water',
      difficulty: 'easy',
      questionText: 'What is the main natural source of fresh water on Earth?',
      options: ['Sea', 'Rain', 'Drain', 'Swimming Pool'],
      correctAnswerIndex: 1,
      explanation:
          'Rain is the primary natural source of fresh water on our planet.',
    ),
    const QuizQuestion(
      id: 'q_evs_wat_2',
      classId: 'class_3',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_water',
      difficulty: 'easy',
      questionText: 'Which of the following habits helps in saving water?',
      options: [
        'Keeping the tap running while brushing teeth',
        'Turning off the tap tightly after every use',
        'Washing bicycles with a hosepipe',
        'Spilling glasses of clean water',
      ],
      correctAnswerIndex: 1,
      explanation: 'Turning off taps properly prevents water wastage.',
    ),
    const QuizQuestion(
      id: 'q_evs_wat_3',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_water',
      difficulty: 'medium',
      questionText: 'What form does water take when it freezes at 0°C?',
      options: ['Liquid water', 'Solid ice', 'Gas steam', 'Smoke'],
      correctAnswerIndex: 1,
      explanation: 'Water solidifies into ice at 0 degrees Celsius.',
    ),
    const QuizQuestion(
      id: 'q_evs_wat_4',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_water',
      difficulty: 'medium',
      questionText: 'The process in which liquid water turns into water vapor due to heat from the sun is called:',
      options: ['Condensation', 'Evaporation', 'Precipitation', 'Freezing'],
      correctAnswerIndex: 1,
      explanation:
          'Solar heat causes surface water to evaporate into water vapor.',
    ),
    const QuizQuestion(
      id: 'q_evs_wat_5',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_water',
      difficulty: 'hard',
      questionText: 'What is the technique called where rainwater from rooftops is collected and stored in underground tanks?',
      options: [
        'Water distillation',
        'Rainwater Harvesting',
        'Drip Irrigation',
        'Deforestation',
      ],
      correctAnswerIndex: 1,
      explanation: 'Rainwater harvesting captures and stores rooftop rainwater for domestic use and groundwater recharge.',
    ),
    const QuizQuestion(
      id: 'q_evs_wat_6',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_water',
      difficulty: 'hard',
      questionText: 'Which of the following actions causes serious water pollution in our rivers and lakes?',
      options: [
        'Planting trees near banks',
        'Dumping plastic garbage and untreated industrial waste into water bodies',
        'Building rain reservoirs',
        'Boiling drinking water at home',
      ],
      correctAnswerIndex: 1,
      explanation: 'Chemical and plastic waste pollutes rivers, harming aquatic organisms and drinking water.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 9: EVS - Plants & Trees (topic_evs_plants) - 6 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_evs_plt_1',
      classId: 'class_3',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      difficulty: 'easy',
      questionText: 'Which part of the plant grows below the soil?',
      options: ['Flower', 'Leaf', 'Root', 'Fruit'],
      correctAnswerIndex: 2,
      explanation: 'Roots grow downward into the soil to anchor the plant and absorb moisture.',
    ),
    const QuizQuestion(
      id: 'q_evs_plt_2',
      classId: 'class_3',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      difficulty: 'easy',
      questionText:
          'Which part of the plant is also called the "kitchen of the plant"?',
      options: ['Root', 'Leaf', 'Stem', 'Bark'],
      correctAnswerIndex: 1,
      explanation:
          'Leaves produce food for the plant using sunlight and chlorophyll.',
    ),
    const QuizQuestion(
      id: 'q_evs_plt_3',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      difficulty: 'medium',
      questionText: 'What is the green coloring substance in leaves called?',
      options: ['Chlorophyll', 'Oxygen', 'Petal', 'Stoma'],
      correctAnswerIndex: 0,
      explanation: 'Chlorophyll is the green pigment responsible for absorbing sunlight for photosynthesis.',
    ),
    const QuizQuestion(
      id: 'q_evs_plt_4',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      difficulty: 'medium',
      questionText: 'Which gas do green plants absorb from the air to manufacture food during daytime?',
      options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Helium'],
      correctAnswerIndex: 1,
      explanation: 'Plants absorb carbon dioxide (CO2) from the atmosphere and release oxygen (O2).',
    ),
    const QuizQuestion(
      id: 'q_evs_plt_5',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      difficulty: 'hard',
      questionText: 'Which of the following is an example of an edible plant stem that we consume as food?',
      options: ['Carrot', 'Potato', 'Spinach', 'Tomato'],
      correctAnswerIndex: 1,
      explanation: 'Potatoes and ginger are underground modified stems (tubers/rhizomes) stored with nutrients.',
    ),
    const QuizQuestion(
      id: 'q_evs_plt_6',
      classId: 'class_4',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      difficulty: 'hard',
      questionText: 'Tiny pores located on the underside of green leaves through which gases are exchanged are called:',
      options: ['Roots', 'Stomata', 'Veins', 'Sepals'],
      correctAnswerIndex: 1,
      explanation: 'Stomata (plural of stoma) are microscopic openings that allow carbon dioxide intake and transpiration.',
    ),

    // -------------------------------------------------------------------------
    // TOPIC 10: Math - Addition (topic_math_add) - 5 Questions
    // -------------------------------------------------------------------------
    const QuizQuestion(
      id: 'q_add_1',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_add',
      difficulty: 'easy',
      questionText: 'What is 28 + 15?',
      options: ['43', '42', '33', '53'],
      correctAnswerIndex: 0,
      explanation: '8 + 5 = 13 (carry 1). 2 + 1 + 1 = 4. The total is 43.',
    ),
    const QuizQuestion(
      id: 'q_add_2',
      classId: 'class_3',
      subjectId: 'subject_math',
      topicId: 'topic_math_add',
      difficulty: 'easy',
      questionText: 'In a school garden, there are 34 red roses and 27 yellow roses. How many roses are there in total?',
      options: ['51', '61', '62', '71'],
      correctAnswerIndex: 1,
      explanation: '34 + 27 = 61 roses in total.',
    ),
    const QuizQuestion(
      id: 'q_add_3',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_add',
      difficulty: 'medium',
      questionText: 'Add: 256 + 189 = ?',
      options: ['445', '435', '455', '345'],
      correctAnswerIndex: 0,
      explanation: '256 + 189 = 445.',
    ),
    const QuizQuestion(
      id: 'q_add_4',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_add',
      difficulty: 'medium',
      questionText: 'What is 450 + 550?',
      options: ['900', '1000', '1100', '950'],
      correctAnswerIndex: 1,
      explanation: '450 + 550 = 1000.',
    ),
    const QuizQuestion(
      id: 'q_add_5',
      classId: 'class_4',
      subjectId: 'subject_math',
      topicId: 'topic_math_add',
      difficulty: 'easy',
      questionText: 'What is the sum of any number and zero (e.g. 125 + 0)?',
      options: ['0', '125', '1', 'Cannot be determined'],
      correctAnswerIndex: 1,
      explanation: 'The additive identity property states that adding zero to any number results in the same number.',
    ),
  ];

  // ==========================================
  // 10. QUIZ ATTEMPTS DATA
  // ==========================================
  static final List<QuizAttempt> quizAttempts = [
    QuizAttempt(
      id: 'attempt_1',
      studentId: 'student_1',
      subjectId: 'subject_eng',
      topicId: 'topic_eng_phonics',
      date: DateTime(2026, 9, 29, 14, 30),
      remedialActionId: 'remedial_2',
      totalQuestions: 5,
      correctAnswers: 4,
      answers: const [
        QuizAnswer(questionId: 'q_phon_1', selectedIndex: 1, isCorrect: true),
        QuizAnswer(questionId: 'q_phon_2', selectedIndex: 1, isCorrect: true),
        QuizAnswer(questionId: 'q_phon_3', selectedIndex: 2, isCorrect: true),
        QuizAnswer(questionId: 'q_phon_4', selectedIndex: 0, isCorrect: false),
        QuizAnswer(questionId: 'q_phon_6', selectedIndex: 1, isCorrect: true),
      ],
    ),
    QuizAttempt(
      id: 'attempt_2',
      studentId: 'student_1',
      subjectId: 'subject_math',
      topicId: 'topic_math_sub',
      date: DateTime(2026, 10, 4, 11, 15),
      remedialActionId: 'remedial_1',
      totalQuestions: 5,
      correctAnswers: 3,
      answers: const [
        QuizAnswer(questionId: 'q_sub_1', selectedIndex: 0, isCorrect: true),
        QuizAnswer(questionId: 'q_sub_2', selectedIndex: 1, isCorrect: true),
        QuizAnswer(questionId: 'q_sub_3', selectedIndex: 0, isCorrect: false),
        QuizAnswer(questionId: 'q_sub_4', selectedIndex: 1, isCorrect: true),
        QuizAnswer(questionId: 'q_sub_5', selectedIndex: 0, isCorrect: false),
      ],
    ),
    QuizAttempt(
      id: 'attempt_3',
      studentId: 'student_16',
      subjectId: 'subject_evs',
      topicId: 'topic_evs_plants',
      date: DateTime(2026, 10, 4, 15, 0),
      remedialActionId: 'remedial_7',
      totalQuestions: 5,
      correctAnswers: 5,
      answers: const [
        QuizAnswer(
          questionId: 'q_evs_plt_1',
          selectedIndex: 2,
          isCorrect: true,
        ),
        QuizAnswer(
          questionId: 'q_evs_plt_2',
          selectedIndex: 1,
          isCorrect: true,
        ),
        QuizAnswer(
          questionId: 'q_evs_plt_3',
          selectedIndex: 0,
          isCorrect: true,
        ),
        QuizAnswer(
          questionId: 'q_evs_plt_4',
          selectedIndex: 1,
          isCorrect: true,
        ),
        QuizAnswer(
          questionId: 'q_evs_plt_5',
          selectedIndex: 1,
          isCorrect: true,
        ),
      ],
    ),
    QuizAttempt(
      id: 'attempt_4',
      studentId: 'student_6',
      subjectId: 'subject_math',
      topicId: 'topic_math_div',
      date: DateTime(2026, 10, 6, 10, 30),
      remedialActionId: 'remedial_4',
      totalQuestions: 5,
      correctAnswers: 2,
      answers: const [
        QuizAnswer(questionId: 'q_div_1', selectedIndex: 1, isCorrect: true),
        QuizAnswer(questionId: 'q_div_2', selectedIndex: 0, isCorrect: false),
        QuizAnswer(questionId: 'q_div_3', selectedIndex: 1, isCorrect: false),
        QuizAnswer(questionId: 'q_div_4', selectedIndex: 1, isCorrect: true),
        QuizAnswer(questionId: 'q_div_5', selectedIndex: 0, isCorrect: false),
      ],
    ),
  ];

  // ==========================================
  // 11. STATIC HELPER METHODS
  // ==========================================

  // Users
  static UserModel? getUserByEmail(String email) {
    try {
      return demoUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static UserModel? getUserById(String id) {
    try {
      return demoUsers.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // Schools and Blocks
  static SchoolModel? getSchoolById(String schoolId) {
    try {
      return schools.firstWhere((s) => s.id == schoolId);
    } catch (_) {
      return null;
    }
  }

  static BlockModel? getBlockById(String blockId) {
    try {
      return blocks.firstWhere((b) => b.id == blockId);
    } catch (_) {
      return null;
    }
  }

  static ClassModel? getClassById(String classId) {
    try {
      return classes.firstWhere((c) => c.id == classId);
    } catch (_) {
      return null;
    }
  }

  static List<ClassModel> getClassesForSchool(String schoolId) {
    return classes.where((c) => c.schoolId == schoolId).toList();
  }

  static List<ClassModel> getClassesForTeacher(String teacherId) {
    return classes.where((c) => c.teacherId == teacherId).toList();
  }

  // Students
  static StudentModel? getStudentById(String studentId) {
    try {
      return students.firstWhere((s) => s.id == studentId);
    } catch (_) {
      return null;
    }
  }

  static List<StudentModel> getStudentsByClass(String classId) {
    return students.where((s) => s.classId == classId).toList();
  }

  static List<StudentModel> getStudentsBySchool(String schoolId) {
    return students.where((s) => s.schoolId == schoolId).toList();
  }

  static List<StudentModel> getStudentsForParent(String parentId) {
    return students.where((s) => s.parentId == parentId).toList();
  }

  // Subjects and Topics
  static SubjectModel? getSubjectById(String subjectId) {
    try {
      return subjects.firstWhere((s) => s.id == subjectId);
    } catch (_) {
      return null;
    }
  }

  static TopicModel? getTopicById(String topicId) {
    for (final s in subjects) {
      for (final t in s.topics) {
        if (t.id == topicId) return t;
      }
    }
    return null;
  }

  // Assessments
  static List<AssessmentModel> getAssessmentsForStudent(String studentId) {
    return assessments.where((a) => a.studentId == studentId).toList();
  }

  static List<AssessmentModel> getAssessmentsForClass(String classId) {
    final studentIds = getStudentsByClass(classId).map((s) => s.id).toSet();
    return assessments.where((a) => studentIds.contains(a.studentId)).toList();
  }

  static AssessmentModel? getLatestAssessmentForStudentAndSubject(
    String studentId,
    String subjectId,
  ) {
    final list = assessments
        .where((a) => a.studentId == studentId && a.subjectId == subjectId)
        .toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.first;
  }

  // Remedial Actions
  static List<RemedialAction> getRemedialActionsForStudent(String studentId) {
    return remedialActions.where((r) => r.studentId == studentId).toList();
  }

  static List<RemedialAction> getRemedialActionsForClass(String classId) {
    final studentIds = getStudentsByClass(classId).map((s) => s.id).toSet();
    return remedialActions
        .where((r) => studentIds.contains(r.studentId))
        .toList();
  }

  // Quizzes
  static List<QuizQuestion> getQuestionsForTopic(
    String topicId, {
    String? classId,
  }) {
    return quizQuestions.where((q) {
      final matchesTopic = q.topicId == topicId;
      if (classId == null) return matchesTopic;
      return matchesTopic && q.classId == classId;
    }).toList();
  }

  static List<QuizAttempt> getAttemptsForStudent(String studentId) {
    return quizAttempts.where((a) => a.studentId == studentId).toList();
  }

  // ==========================================
  // 12. PERFORMANCE SUMMARY DERIVATIONS
  // ==========================================

  static StudentPerformanceSummary getStudentPerformanceSummary(
    String studentId,
  ) {
    final subjectPerformances = <SubjectPerformance>[];
    final weakTopics = <String>[];
    double totalPercentageSum = 0;
    int assessedSubjectsCount = 0;

    for (final subject in subjects) {
      final latest = getLatestAssessmentForStudentAndSubject(
        studentId,
        subject.id,
      );
      if (latest != null) {
        assessedSubjectsCount++;
        totalPercentageSum += latest.percentage;

        final topicPerformances = latest.topicScores.map((score) {
          final level = PerformanceClassification.classify(score.percentage);
          if (level == PerformanceLevel.weak) {
            weakTopics.add('${subject.name}: ${score.topicName}');
          }
          return TopicPerformance(
            topicId: score.topicId,
            topicName: score.topicName,
            percentage: score.percentage,
            level: level,
          );
        }).toList();

        subjectPerformances.add(
          SubjectPerformance(
            subjectId: subject.id,
            subjectName: subject.name,
            latestPercentage: latest.percentage,
            level: PerformanceClassification.classify(latest.percentage),
            assessmentDate: latest.date,
            topicPerformances: topicPerformances,
          ),
        );
      } else {
        // Not assessed in this subject
        subjectPerformances.add(
          SubjectPerformance(
            subjectId: subject.id,
            subjectName: subject.name,
            latestPercentage: null,
            level: PerformanceLevel.notAssessed,
            assessmentDate: null,
            topicPerformances: const [],
          ),
        );
      }
    }

    if (assessedSubjectsCount == 0) {
      return StudentPerformanceSummary(
        studentId: studentId,
        overallPercentage: null,
        overallLevel: PerformanceLevel.notAssessed,
        subjectsAssessed: 0,
        totalSubjects: subjects.length,
        subjectPerformances: subjectPerformances,
        weakTopics: const [],
        plainLanguageSummary: 'Baseline diagnostic assessments have not yet been recorded for this student.',
        recommendedActions: const [
          'Schedule a baseline diagnostic assessment across core subjects.',
          'Review classroom participation with the class teacher.',
        ],
      );
    }

    final overallPercentage = totalPercentageSum / assessedSubjectsCount;
    final overallLevel = PerformanceClassification.classify(overallPercentage);

    // Formulate personalized plain-language summary and actionable recommendations
    final student = getStudentById(studentId);
    final studentName = student?.name ?? 'The student';

    String plainLanguageSummary;
    final recommendedActions = <String>[];

    if (overallLevel == PerformanceLevel.weak) {
      plainLanguageSummary =
          '$studentName needs immediate focused remedial support. Significant learning gaps exist in ${weakTopics.take(3).join(', ')}.';
      recommendedActions.add(
        'Assign daily 15-minute hands-on foundational practice modules.',
      );
      recommendedActions.add(
        'Involve parent in home-based counting and phonetic reading routines.',
      );
      recommendedActions.add(
        'Conduct weekly formative mini-quizzes to verify mastery.',
      );
    } else if (overallLevel == PerformanceLevel.average) {
      if (weakTopics.isNotEmpty) {
        plainLanguageSummary =
            '$studentName is performing moderately well overall (${overallPercentage.toStringAsFixed(1)}%), but requires targeted revision in ${weakTopics.take(2).join(' and ')}.';
        recommendedActions.add(
          'Provide targeted practice sheets for weak learning objectives.',
        );
        recommendedActions.add(
          'Pair with a peer learning buddy for collaborative problem solving.',
        );
      } else {
        plainLanguageSummary =
            '$studentName shows consistent steady progress across core subjects with satisfactory foundational understanding.';
        recommendedActions.add(
          'Introduce slightly more challenging problem sets to foster critical thinking.',
        );
      }
    } else {
      plainLanguageSummary =
          '$studentName demonstrates exemplary conceptual understanding (${overallPercentage.toStringAsFixed(1)}%) and is excelling across evaluated topics.';
      recommendedActions.add(
        'Provide enrichment activities and advanced reading materials.',
      );
      recommendedActions.add(
        'Encourage leading small peer-study sessions in class.',
      );
    }

    return StudentPerformanceSummary(
      studentId: studentId,
      overallPercentage: overallPercentage,
      overallLevel: overallLevel,
      subjectsAssessed: assessedSubjectsCount,
      totalSubjects: subjects.length,
      subjectPerformances: subjectPerformances,
      weakTopics: weakTopics,
      plainLanguageSummary: plainLanguageSummary,
      recommendedActions: recommendedActions,
    );
  }

  // Aggregate stats for Class
  static Map<String, dynamic> getClassStatistics(String classId) {
    final classStudents = getStudentsByClass(classId);
    int total = classStudents.length;
    int weak = 0;
    int average = 0;
    int strong = 0;
    int notAssessed = 0;
    double totalPercentageSum = 0;
    int assessedCount = 0;
    final Map<String, int> gapFrequencies = {};

    for (final s in classStudents) {
      final summary = getStudentPerformanceSummary(s.id);
      switch (summary.overallLevel) {
        case PerformanceLevel.weak:
          weak++;
          break;
        case PerformanceLevel.average:
          average++;
          break;
        case PerformanceLevel.strong:
          strong++;
          break;
        case PerformanceLevel.notAssessed:
          notAssessed++;
          break;
      }
      if (summary.overallPercentage != null) {
        totalPercentageSum += summary.overallPercentage!;
        assessedCount++;
      }
      for (final topic in summary.weakTopics) {
        gapFrequencies[topic] = (gapFrequencies[topic] ?? 0) + 1;
      }
    }

    final double avgPercentage = assessedCount > 0
        ? totalPercentageSum / assessedCount
        : 0.0;

    return {
      'classId': classId,
      'totalStudents': total,
      'assessedStudents': assessedCount,
      'weakCount': weak,
      'averageCount': average,
      'strongCount': strong,
      'notAssessedCount': notAssessed,
      'averagePercentage': avgPercentage,
      'weakTopicsFrequency': gapFrequencies,
    };
  }

  // Aggregate stats for School
  static Map<String, dynamic> getSchoolStatistics(String schoolId) {
    final schoolClasses = getClassesForSchool(schoolId);
    int total = 0;
    int weak = 0;
    int average = 0;
    int strong = 0;
    int notAssessed = 0;
    double totalPercentageSum = 0;
    int assessedCount = 0;

    for (final c in schoolClasses) {
      final stats = getClassStatistics(c.id);
      total += stats['totalStudents'] as int;
      weak += stats['weakCount'] as int;
      average += stats['averageCount'] as int;
      strong += stats['strongCount'] as int;
      notAssessed += stats['notAssessedCount'] as int;
      final int cAssessed = stats['assessedStudents'] as int;
      if (cAssessed > 0) {
        totalPercentageSum +=
            (stats['averagePercentage'] as double) * cAssessed;
        assessedCount += cAssessed;
      }
    }

    final double avgPercentage = assessedCount > 0
        ? totalPercentageSum / assessedCount
        : 0.0;

    return {
      'schoolId': schoolId,
      'totalStudents': total,
      'assessedStudents': assessedCount,
      'weakCount': weak,
      'averageCount': average,
      'strongCount': strong,
      'notAssessedCount': notAssessed,
      'averagePercentage': avgPercentage,
    };
  }

  // Aggregate stats for Block
  static Map<String, dynamic> getBlockStatistics(String blockId) {
    int total = 0;
    int weak = 0;
    int average = 0;
    int strong = 0;
    int notAssessed = 0;
    double totalPercentageSum = 0;
    int assessedCount = 0;

    for (final s in schools) {
      final stats = getSchoolStatistics(s.id);
      total += stats['totalStudents'] as int;
      weak += stats['weakCount'] as int;
      average += stats['averageCount'] as int;
      strong += stats['strongCount'] as int;
      notAssessed += stats['notAssessedCount'] as int;
      final int sAssessed = stats['assessedStudents'] as int;
      if (sAssessed > 0) {
        totalPercentageSum +=
            (stats['averagePercentage'] as double) * sAssessed;
        assessedCount += sAssessed;
      }
    }

    final double avgPercentage = assessedCount > 0
        ? totalPercentageSum / assessedCount
        : 0.0;

    return {
      'blockId': blockId,
      'totalSchools': schools.length,
      'totalStudents': total,
      'assessedStudents': assessedCount,
      'weakCount': weak,
      'averageCount': average,
      'strongCount': strong,
      'notAssessedCount': notAssessed,
      'averagePercentage': avgPercentage,
    };
  }
}
