import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- الكلاسات المساعدة (WorkExperienceEntry, EducationEntry, LanguageEntry) ---
class WorkExperienceEntry {
  String jobTitle;
  String companyName;
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrentJob;
  String description;

  late TextEditingController jobTitleController;
  late TextEditingController companyNameController;
  late TextEditingController descriptionController;

  WorkExperienceEntry({
    String jobTitle = '',
    String companyName = '',
    this.startDate,
    this.endDate,
    this.isCurrentJob = false,
    String description = '',
  })  : jobTitle = jobTitle,
        companyName = companyName,
        description = description {
    jobTitleController = TextEditingController(text: jobTitle);
    companyNameController = TextEditingController(text: companyName);
    descriptionController = TextEditingController(text: description);
  }

  Map<String, dynamic> toMap() {
    return {
      'jobTitle': jobTitleController.text,
      'companyName': companyNameController.text,
      'startDate': startDate?.toIso8601String(),
      'endDate': isCurrentJob ? null : endDate?.toIso8601String(),
      'isCurrentJob': isCurrentJob,
      'description': descriptionController.text,
    };
  }

  factory WorkExperienceEntry.fromMap(Map<String, dynamic> map) {
    return WorkExperienceEntry(
      jobTitle: map['jobTitle'] ?? '',
      companyName: map['companyName'] ?? '',
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      isCurrentJob: map['isCurrentJob'] ?? false,
      description: map['description'] ?? '',
    );
  }

  void dispose() {
    jobTitleController.dispose();
    companyNameController.dispose();
    descriptionController.dispose();
  }
}

class EducationEntry {
  String degreeName;
  String institutionName;
  DateTime? graduationDate;

  late TextEditingController degreeController;
  late TextEditingController institutionController;

  EducationEntry({
    String degreeName = '',
    String institutionName = '',
    this.graduationDate,
  })  : degreeName = degreeName,
        institutionName = institutionName {
    degreeController = TextEditingController(text: degreeName);
    institutionController = TextEditingController(text: institutionName);
  }

  Map<String, dynamic> toMap() {
    return {
      'degreeName': degreeController.text,
      'institutionName': institutionController.text,
      'graduationDate': graduationDate?.toIso8601String(),
    };
  }

  factory EducationEntry.fromMap(Map<String, dynamic> map) {
    return EducationEntry(
      degreeName: map['degreeName'] ?? '',
      institutionName: map['institutionName'] ?? '',
      graduationDate: map['graduationDate'] != null ? DateTime.tryParse(map['graduationDate']) : null,
    );
  }

  void dispose() {
    degreeController.dispose();
    institutionController.dispose();
  }
}

class LanguageEntry {
  String languageName;
  String proficiencyLevel;

  LanguageEntry({required this.languageName, required this.proficiencyLevel});

  Map<String, dynamic> toMap() {
    return {
      'languageName': languageName,
      'proficiencyLevel': proficiencyLevel,
    };
  }

  factory LanguageEntry.fromMap(Map<String, dynamic> map) {
    return LanguageEntry(
      languageName: map['languageName'] ?? '',
      proficiencyLevel: map['proficiencyLevel'] ?? '',
    );
  }
}
// --- نهاية الكلاسات المساعدة ---

class EditProfileScreen extends StatefulWidget {
  final String? triggeredByQuestId; // لتحديد المهمة التي أدت لفتح هذه الصفحة
  const EditProfileScreen({super.key, this.triggeredByQuestId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingOnSave = false;
  bool _isFetchingInitialData = true;

  // Controllers للحقول النصية الأساسية
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _professionalSummaryController = TextEditingController();
  final TextEditingController _portfolioLinkController = TextEditingController();
  final TextEditingController _linkedInLinkController = TextEditingController();
  String _email = ""; // الإيميل لا يحتاج Controller لأنه readOnly

  // قوائم للبيانات الديناميكية
  final List<WorkExperienceEntry> _workExperiences = [];
  final List<EducationEntry> _educations = [];
  final List<String> _skills = [];
  final TextEditingController _skillController = TextEditingController(); // لإضافة مهارة جديدة
  final List<LanguageEntry> _languages = [];
  final TextEditingController _languageNameController = TextEditingController(); // لإضافة لغة جديدة
  String? _selectedProficiency;
  final List<String> _proficiencyLevels = ['مبتدئ', 'متوسط', 'متقدم', 'لغة أم/بطلاقة'];

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _currentUserDataFromFirestore; // لتخزين بيانات Firestore الحالية للمستخدم

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    // التخلص من كل الـ Controllers
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _professionalSummaryController.dispose();
    _portfolioLinkController.dispose();
    _linkedInLinkController.dispose();
    _skillController.dispose();
    _languageNameController.dispose();
    for (var exp in _workExperiences) {
      exp.dispose();
    }
    for (var edu in _educations) {
      edu.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() { _isFetchingInitialData = true; });
    final user = _auth.currentUser;
    if (user == null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المستخدم غير مسجل!'), backgroundColor: Colors.red));
        setState(() { _isFetchingInitialData = false; });
      }
      return;
    }

    _email = user.email ?? "";
    _fullNameController.text = user.displayName ?? ""; 

    try {
      final docSnap = await _firestore.collection('user_profiles').doc(user.uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        _currentUserDataFromFirestore = data; 

        _fullNameController.text = data['fullName'] ?? _fullNameController.text;
        _phoneNumberController.text = data['phoneNumber'] ?? '';
        _professionalSummaryController.text = data['professionalSummary'] ?? '';
        _portfolioLinkController.text = data['portfolioLink'] ?? '';
        _linkedInLinkController.text = data['linkedInLink'] ?? '';

        if (data['skills'] != null) { _skills.clear(); _skills.addAll(List<String>.from(data['skills'])); }
        if (data['languages'] != null) { _languages.clear(); _languages.addAll( (data['languages'] as List<dynamic>) .map((langMap) => LanguageEntry.fromMap(langMap as Map<String, dynamic>)) .toList() ); }
        if (data['workExperience'] != null) { _workExperiences.clear(); _workExperiences.addAll( (data['workExperience'] as List<dynamic>) .map((expMap) => WorkExperienceEntry.fromMap(expMap as Map<String, dynamic>)) .toList() ); }
        if (data['education'] != null) { _educations.clear(); _educations.addAll( (data['education'] as List<dynamic>) .map((eduMap) => EducationEntry.fromMap(eduMap as Map<String, dynamic>)) .toList() ); }
      
      } else {
        print('No profile data found in Firestore for this user. Initializing default user data.');
        _currentUserDataFromFirestore = { // تهيئة بيانات افتراضية إذا لم يوجد مستند
          'level': 1,
          'xp': 0,
          'completedQuests': [],
        };
      }
    } catch (e) {
      print('Error loading profile: $e');
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في جلب البيانات: ${e.toString()}'), backgroundColor: Colors.red));
      }
       _currentUserDataFromFirestore = { // تهيئة افتراضية في حالة الخطأ أيضاً
          'level': 1,
          'xp': 0,
          'completedQuests': [],
        };
    }
    // إضافة عنصر فارغ إذا كانت القائمة فارغة بعد محاولة الجلب أو لعدم وجود بيانات
    if (_workExperiences.isEmpty) { _workExperiences.add(WorkExperienceEntry()); }
    if (_educations.isEmpty) { _educations.add(EducationEntry()); }
    
    if(mounted){ setState(() { _isFetchingInitialData = false; }); }
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected, {DateTime? initialDate, DatePickerMode initialDatePickerMode = DatePickerMode.year}) async {
    final DateTime? picked = await showDatePicker( 
      context: context, 
      initialDate: initialDate ?? DateTime.now(), 
      firstDate: DateTime(1950), 
      lastDate: DateTime(DateTime.now().year + 10), // يسمح بسنوات مستقبلية للتخرج المتوقع
      initialDatePickerMode: initialDatePickerMode, 
    );
    if (picked != null) { 
      onDateSelected(picked); 
    }
  }

  void _addSkill() { 
    if (_skillController.text.isNotEmpty && !_skills.contains(_skillController.text.trim())) { 
      setState(() { 
        _skills.add(_skillController.text.trim()); 
        _skillController.clear(); 
      }); 
    } 
  }
  void _removeSkill(String skillToRemove) { 
    setState(() { 
      _skills.remove(skillToRemove); 
    }); 
  }
  void _addLanguage() { 
    if (_languageNameController.text.isNotEmpty && _selectedProficiency != null) { 
      bool alreadyExists = _languages.any((lang) => lang.languageName == _languageNameController.text.trim() && lang.proficiencyLevel == _selectedProficiency); 
      if (!alreadyExists) { 
        setState(() { 
          _languages.add(LanguageEntry( 
            languageName: _languageNameController.text.trim(), 
            proficiencyLevel: _selectedProficiency!, 
          )); 
          _languageNameController.clear(); 
          _selectedProficiency = null; 
        }); 
      } else { 
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar( content: Text('هذه اللغة والمستوى مضافة بالفعل'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
        ); 
      } 
    } else { 
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar( content: Text('الرجاء إدخال اسم اللغة واختيار المستوى'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
      ); 
    } 
  }
  void _removeLanguage(LanguageEntry languageToRemove) { 
    setState(() { 
      _languages.remove(languageToRemove); 
    }); 
  }
  void _pickCVFile() { 
    print('Pick CV File button tapped'); 
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar( 
      const SnackBar( content: Text('خاصية رفع السيرة الذاتية (قيد التطوير)'), backgroundColor: Colors.blueGrey, duration: Duration(seconds: 2)),
    ); 
  }

  void _addWorkExperience() { 
    setState(() { 
      _workExperiences.add(WorkExperienceEntry()); 
    }); 
  }
  void _removeWorkExperience(int index) {
    if (index < _workExperiences.length) { 
      _workExperiences[index].dispose(); 
    }
    setState(() { 
      _workExperiences.removeAt(index); 
    });
  }

  void _addEducation() { 
    setState(() { 
      _educations.add(EducationEntry()); 
    }); 
  }
  void _removeEducation(int index) {
    if (index < _educations.length) { 
      _educations[index].dispose(); 
    }
    setState(() { 
      _educations.removeAt(index); 
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text('الرجاء تصحيح الأخطاء في النموذج'), backgroundColor: Colors.red, duration: Duration(seconds: 3) ),);
      return;
    }
    setState(() { _isLoadingOnSave = true; });
    final user = _auth.currentUser;
    if (user == null) {
      if(mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('خطأ: المستخدم غير مسجل الدخول!'), backgroundColor: Colors.red),);
        setState(() { _isLoadingOnSave = false; });
      }
      return;
    }

    // جلب الـ XP والمستوى الحاليين والمهام المكتملة من _currentUserDataFromFirestore
    int currentXp = _currentUserDataFromFirestore?['xp'] ?? 0;
    int currentLevel = _currentUserDataFromFirestore?['level'] ?? 1;
    List<String> completedQuests = _currentUserDataFromFirestore?['completedQuests'] != null
                                  ? List<String>.from(_currentUserDataFromFirestore!['completedQuests'])
                                  : [];
    
    bool newQuestCompletedThisSave = false;
    String questCompletionMessage = 'تم حفظ بيانات الملف الشخصي بنجاح!';

    // تجميع البيانات من الـ Controllers والقوائم
    List<Map<String, dynamic>> workExperiencesToSave = _workExperiences
        .map((exp) => exp.toMap())
        .where((expMap) => (expMap['jobTitle'] as String).trim().isNotEmpty || (expMap['companyName'] as String).trim().isNotEmpty)
        .toList();
    
    List<Map<String, dynamic>> educationsToSave = _educations
        .map((edu) => edu.toMap())
        .where((eduMap) => (eduMap['degreeName'] as String).trim().isNotEmpty || (eduMap['institutionName'] as String).trim().isNotEmpty)
        .toList();

    List<String> skillsToSave = _skills.where((s) => s.trim().isNotEmpty).toList();

    // التحقق من إكمال المهام
    if (widget.triggeredByQuestId == 'complete_profile_experience' &&
        !completedQuests.contains('complete_profile_experience') &&
        workExperiencesToSave.isNotEmpty) {
      currentXp += 50;
      completedQuests.add('complete_profile_experience');
      newQuestCompletedThisSave = true;
      print("Awarded 50 XP for completing experience quest.");
    }

    if (widget.triggeredByQuestId == 'complete_profile_skills' &&
        !completedQuests.contains('complete_profile_skills') &&
        skillsToSave.length >= 3) {
      currentXp += 75;
      completedQuests.add('complete_profile_skills');
      newQuestCompletedThisSave = true;
      print("Awarded 75 XP for completing skills quest.");
    }
    
    // منطق ترقية المستوى
    int xpNeededForNextLevel = (currentLevel * 150) + 200; 
    if (currentXp >= xpNeededForNextLevel && xpNeededForNextLevel > 0) {
      currentLevel++;
      print("User Leveled Up to Level $currentLevel!");
      questCompletionMessage += ' ولقد ارتقيت إلى المستوى $currentLevel!';
    } else if (newQuestCompletedThisSave) {
       questCompletionMessage += ' لقد كسبت نقاط خبرة!';
    }

    // تجهيز البيانات النهائية للحفظ في Firestore
    Map<String, dynamic> profileDataToSaveInFirestore = {
      'fullName': _fullNameController.text.trim(),
      'email': _email.trim().toLowerCase(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'professionalSummary': _professionalSummaryController.text.trim(),
      'skills': skillsToSave,
      'languages': _languages.map((lang) => lang.toMap()).toList(),
      'workExperience': workExperiencesToSave,
      'education': educationsToSave,
      'portfolioLink': _portfolioLinkController.text.trim(),
      'linkedInLink': _linkedInLinkController.text.trim(),
      'lastUpdatedAt': Timestamp.now(),
      'xp': currentXp,
      'level': currentLevel,
      'completedQuests': completedQuests,
    };

    try {
      await _firestore.collection('user_profiles').doc(user.uid).set(profileDataToSaveInFirestore, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( content: Text(questCompletionMessage), backgroundColor: Colors.green, duration: const Duration(seconds: 3) ),
        );
        Navigator.of(context).pop(true); // إرجاع true للإشارة إلى أنه تم تحديث
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('حدث خطأ أثناء حفظ البيانات: ${e.toString()}'), backgroundColor: Colors.red, duration: const Duration(seconds: 3) ),);
      }
    }

    if(mounted){ setState(() { _isLoadingOnSave = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingInitialData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تعديل الملف الشخصي'),
          backgroundColor: Colors.indigo,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        backgroundColor: Colors.indigo,
        leading: IconButton( icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop(), ),
        actions: [ IconButton( icon: const Icon(Icons.save_outlined), tooltip: 'حفظ التغييرات', onPressed: _isLoadingOnSave ? null : _saveProfile, ), ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- قسم المعلومات الشخصية ---
              Text( 'المعلومات الشخصية', style: textTheme.titleLarge?.copyWith(color: Colors.indigo[700]), ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration( labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline), ),
                validator: (value) { if (value == null || value.isEmpty) { return 'الرجاء إدخال الاسم الكامل'; } if (value.length < 3) { return 'الاسم يجب أن يكون 3 أحرف على الأقل';} return null; },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email, // الإيميل يُعرض ولا يُعدل
                readOnly: true,
                decoration: InputDecoration( labelText: 'البريد الإلكتروني (غير قابل للتعديل)', prefixIcon: const Icon(Icons.email_outlined), filled: true, fillColor: Colors.grey[200], ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration( labelText: 'رقم الهاتف الجوال (اختياري)', prefixIcon: Icon(Icons.phone_android_outlined), ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              
              // --- قسم الملخص الاحترافي ---
              Text( 'ملخص احترافي / "من أنا؟"', style: textTheme.titleLarge?.copyWith(color: Colors.indigo[700]), ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professionalSummaryController,
                decoration: const InputDecoration( labelText: 'اكتب نبذة عنك، مهاراتك الرئيسية، وأهدافك المهنية', hintText: 'مثال: مطور تطبيقات بخبرة 3 سنوات في Flutter...', alignLabelWithHint: true, ),
                maxLines: 5,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),

              // --- قسم الخبرة المهنية ---
              Text( 'الخبرة المهنية', style: textTheme.titleLarge?.copyWith(color: Colors.indigo[700]), ),
              const SizedBox(height: 10),
              if (_workExperiences.isEmpty && !_isFetchingInitialData)
                const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("لم تقم بإضافة أي خبرات مهنية بعد.", style: TextStyle(color: Colors.grey)))),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workExperiences.length,
                itemBuilder: (context, index) {
                  WorkExperienceEntry exp = _workExperiences[index];
                  TextEditingController startDateController = TextEditingController(text: exp.startDate != null ? DateFormat('yyyy/MM').format(exp.startDate!) : '');
                  TextEditingController endDateController = TextEditingController(text: exp.isCurrentJob ? 'حتى الآن' : (exp.endDate != null ? DateFormat('yyyy/MM').format(exp.endDate!) : ''));
                  
                  return Card(
                    key: ValueKey('experience_${exp.hashCode}_$index'), // استخدام hashCode لـ Key أكثر تفرداً
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: exp.jobTitleController,
                            decoration: InputDecoration(labelText: 'المسمى الوظيفي #${index + 1}', prefixIcon: const Icon(Icons.work_outline)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: exp.companyNameController,
                            decoration: InputDecoration(labelText: 'اسم الشركة #${index + 1}', prefixIcon: const Icon(Icons.business_outlined)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: startDateController,
                                  decoration: InputDecoration(labelText: 'تاريخ البداية #${index + 1}', hintText: 'YYYY/MM', prefixIcon: const Icon(Icons.calendar_today_outlined)),
                                  readOnly: true,
                                  onTap: () {
                                    _selectDate(context, (date) {
                                      setState(() {
                                        exp.startDate = date;
                                        startDateController.text = DateFormat('yyyy/MM').format(date);
                                      });
                                    }, initialDate: exp.startDate);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: endDateController,
                                  decoration: InputDecoration(labelText: 'تاريخ النهاية #${index + 1}', hintText: 'YYYY/MM أو "الآن"', prefixIcon: const Icon(Icons.calendar_today_outlined)),
                                  readOnly: true,
                                  enabled: !exp.isCurrentJob,
                                  onTap: () {
                                    if (!exp.isCurrentJob) {
                                      _selectDate(context, (date) {
                                        setState(() {
                                          exp.endDate = date;
                                          endDateController.text = DateFormat('yyyy/MM').format(date);
                                        });
                                      }, initialDate: exp.endDate);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          CheckboxListTile(
                            title: const Text("أنا أعمل في هذا المنصب حالياً"),
                            value: exp.isCurrentJob,
                            onChanged: (bool? value) {
                              setState(() {
                                exp.isCurrentJob = value ?? false;
                                if (exp.isCurrentJob) {
                                  exp.endDate = null;
                                  endDateController.text = 'حتى الآن';
                                } else {
                                  //  عند إلغاء التحديد، لا نغير endDateController.text إلا إذا كان المستخدم قد اختار تاريخاً جديداً
                                  endDateController.text = exp.endDate != null ? DateFormat('yyyy/MM').format(exp.endDate!) : '';
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: exp.descriptionController,
                            decoration: InputDecoration(labelText: 'الوصف #${index + 1}', hintText: 'مهامك وإنجازاتك...'),
                            maxLines: 3,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              label: const Text('حذف هذه الخبرة', style: TextStyle(color: Colors.redAccent)),
                              onPressed: () => _removeWorkExperience(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon( icon: const Icon(Icons.add_circle_outline), label: const Text('إضافة خبرة مهنية أخرى'), style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo), onPressed: _addWorkExperience, ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),

              // --- قسم التعليم والتكوين ---
              Text( 'التعليم والتكوين', style: textTheme.titleLarge?.copyWith(color: Colors.indigo[700]), ),
              const SizedBox(height: 10),
              if (_educations.isEmpty && !_isFetchingInitialData)
                const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("لم تقم بإضافة أي شهادات أو تكوين بعد.", style: TextStyle(color: Colors.grey)))),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _educations.length,
                itemBuilder: (context, index) {
                  EducationEntry edu = _educations[index];
                  TextEditingController gradDateController = TextEditingController(text: edu.graduationDate != null ? DateFormat('yyyy/MM').format(edu.graduationDate!) : '');
                  
                  return Card(
                    key: ValueKey('education_${edu.hashCode}_$index'),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: edu.degreeController,
                            decoration: InputDecoration(labelText: 'اسم الشهادة / الدبلوم #${index + 1}', prefixIcon: const Icon(Icons.school_outlined)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: edu.institutionController,
                            decoration: InputDecoration(labelText: 'اسم المؤسسة التعليمية #${index + 1}', prefixIcon: const Icon(Icons.account_balance_outlined)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: gradDateController,
                            decoration: InputDecoration(labelText: 'تاريخ التخرج (شهر/سنة) #${index + 1}', hintText: 'YYYY/MM', prefixIcon: const Icon(Icons.calendar_month_outlined)),
                            readOnly: true,
                            onTap: () {
                              _selectDate(context, (date) {
                                setState(() {
                                  edu.graduationDate = date;
                                  gradDateController.text = DateFormat('yyyy/MM').format(date);
                                });
                              }, initialDate: edu.graduationDate, initialDatePickerMode: DatePickerMode.year);
                            },
                          ),
                           Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              label: const Text('حذف هذه الشهادة', style: TextStyle(color: Colors.redAccent)),
                              onPressed: () => _removeEducation(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon( icon: const Icon(Icons.add_circle_outline), label: const Text('إضافة شهادة / تكوين آخر'), style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo), onPressed: _addEducation, ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              
              // --- قسم المهارات ---
              Text( 'المهارات', style: textTheme.titleLarge?.copyWith(color: Colors.indigo[700]), ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillController,
                      decoration: const InputDecoration(
                        labelText: 'أضف مهارة',
                        hintText: 'مثال: Flutter, Photoshop, Communication',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _addSkill,
                    tooltip: 'إضافة مهارة',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_skills.isEmpty && !_isFetchingInitialData)
                const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("لم تقم بإضافة أي مهارات بعد.", style: TextStyle(color: Colors.grey)))),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    onDeleted: () {
                      _removeSkill(skill);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              
              // --- قسم اللغات ---
              Text( 'اللغات', style: textTheme.titleLarge?.copyWith(color: Colors.indigo[700]), ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _languageNameController,
                      decoration: const InputDecoration(
                        labelText: 'اللغة',
                        hintText: 'مثال: الإنجليزية، الفرنسية',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'المستوى',
                      ),
                      value: _selectedProficiency,
                      hint: const Text('اختر المستوى'),
                      isExpanded: true,
                      items: _proficiencyLevels.map((String level) {
                        return DropdownMenuItem<String>(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProficiency = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _addLanguage,
                    tooltip: 'إضافة لغة',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_languages.isEmpty && !_isFetchingInitialData)
                const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("لم تقم بإضافة أي لغات بعد.", style: TextStyle(color: Colors.grey)))),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _languages.map((langEntry) {
                  return Chip(
                    label: Text('${langEntry.languageName} (${langEntry.proficiencyLevel})'),
                    onDeleted: () {
                      _removeLanguage(langEntry);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              
              // --- قسم ملفات وروابط ---
              Text( 'ملفات وروابط', style: textTheme.titleLarge?.copyWith(color: Colors.indigo[700]), ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('رفع السيرة الذاتية (PDF)'),
                onPressed: _pickCVFile,
              ),
              const SizedBox(height: 8),
              Text( 'ملف PDF، الحجم الأقصى 5 ميجابايت', style: textTheme.bodySmall, ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _portfolioLinkController,
                decoration: const InputDecoration(
                  labelText: 'رابط معرض الأعمال (اختياري)',
                  prefixIcon: Icon(Icons.link_outlined),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkedInLinkController,
                decoration: const InputDecoration(
                  labelText: 'رابط بروفايل LinkedIn (اختياري)',
                  prefixIcon: Icon(Icons.link_outlined),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 30),

              // زر الحفظ
              if (_isLoadingOnSave)
                const Center(child: CircularProgressIndicator())
              else
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save), // سيأخذ لونه من ElevatedButtonTheme
                    label: const Text('حفظ التغييرات'), // سيأخذ لونه ونمطه من ElevatedButtonTheme
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}