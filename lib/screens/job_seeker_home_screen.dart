import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; //  قد نحتاجه هنا أيضاً لتنسيق أي تواريخ إذا عرضناها مباشرة
import 'package:khaddemni_app/screens/profile/edit_profile_screen.dart';
import 'package:khaddemni_app/screens/search/search_screen.dart';
import 'package:khaddemni_app/screens/store/store_screen.dart';
import 'package:khaddemni_app/screens/tracking/tracking_screen.dart';
import 'package:khaddemni_app/screens/quests/quests_screen.dart';

class JobSeekerHomeScreen extends StatefulWidget {
  const JobSeekerHomeScreen({super.key});

  @override
  State<JobSeekerHomeScreen> createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
  int _selectedIndex = 0;

  // قائمة الويدجتس (الصفحات) التي سيعرضها الشريط السفلي
  // MainContentPlaceholder أصبح StatefulWidget وسيدير حالته الخاصة بجلب البيانات
  static const List<Widget> _widgetOptions = <Widget>[
    MainContentPlaceholder(), 
    SearchScreen(),
    StoreScreen(),
    TrackingScreen(),
    QuestsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print('Selected index: $_selectedIndex');
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context); // لم نعد نحتاجه هنا مباشرة

    return Scaffold(
      appBar: AppBar(
        title: const Text("صفحتي الرئيسية"),
        // backgroundColor سيأتي من الثيم العام في main.dart
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            tooltip: 'الإشعارات',
            onPressed: () {
              print('Notifications pressed');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('صفحة الإشعارات (قيد التطوير)')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'القائمة',
            onPressed: () {
              print('Menu pressed');
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('القائمة المنسدلة (قيد التطوير)')),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem( icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية', ),
          BottomNavigationBarItem( icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'بحث', ),
          BottomNavigationBarItem( icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'المتجر', ),
          BottomNavigationBarItem( icon: Icon(Icons.track_changes_outlined), activeIcon: Icon(Icons.track_changes), label: 'متابعة', ),
          BottomNavigationBarItem( icon: Icon(Icons.task_alt_outlined), activeIcon: Icon(Icons.task_alt), label: 'المهام', ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // الألوان والخطوط ستأتي من bottomNavigationBarTheme في main.dart
      ),
    );
  }
}

// ---  MainContentPlaceholder أصبح StatefulWidget  ---
class MainContentPlaceholder extends StatefulWidget {
  const MainContentPlaceholder({super.key});

  @override
  State<MainContentPlaceholder> createState() => _MainContentPlaceholderState();
}

class _MainContentPlaceholderState extends State<MainContentPlaceholder> {
  String _userName = "جاري التحميل...";
  int _userLevel = 1;
  int _currentXp = 0;
  int _nextLevelXp = 200; // قيمة افتراضية أولية
  bool _isLoadingUserData = true;
  List<Map<String, dynamic>> _suggestedQuests = []; //  ⭐  ستصبح قائمة متغيرة  ⭐

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  ⭐  البيانات الوهمية الأصلية للمهام المقترحة (كمرجع) ⭐
  final List<Map<String, dynamic>> _baseSuggestedQuests = const [
    { 'id': 'complete_profile_experience', 'title': 'أضف خبرتك المهنية الأولى', 'xp': '+50 XP', 'icon': Icons.add_business_outlined, 'action_type': 'navigate_to_edit_profile_experience', 'isCompletedField': 'workExperience' }, //  حقل لتتبع الإكمال
    { 'id': 'complete_profile_skills', 'title': 'أكمل قسم المهارات (3 مهارات على الأقل)', 'xp': '+75 XP', 'icon': Icons.stars_outlined, 'action_type': 'navigate_to_edit_profile_skills', 'isCompletedField': 'skills' },
    { 'id': 'perform_first_search', 'title': 'ابحث عن وظيفتك الأولى', 'xp': '+20 XP', 'icon': Icons.search_outlined, 'action_type': 'navigate_to_search_screen', 'isCompletedField': 'firstSearchPerformed' }, // مثال لحقل مختلف
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() { _isLoadingUserData = true; });
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) { setState(() { _userName = "مستخدم غير معروف"; _isLoadingUserData = false; });}
      return;
    }

    try {
      final docSnap = await _firestore.collection('user_profiles').doc(user.uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        if (mounted) {
          setState(() {
            _userName = data['fullName'] ?? user.displayName ?? 'اسم المستخدم';
            _userLevel = data['level'] ?? 1;
            _currentXp = data['xp'] ?? 0;
            
            //  منطق أكثر تطوراً لحساب XP المستوى التالي يمكن وضعه هنا
            _nextLevelXp = (_userLevel * 150) + 200; 
             if (_currentXp >= _nextLevelXp && _nextLevelXp > 0) {
                _nextLevelXp = _currentXp + 100; 
             }
            _isLoadingUserData = false;

            //  ⭐  تحديث قائمة المهام المقترحة بناءً على المهام المكتملة  ⭐
            List<String> completedQuestsFromDB = data['completedQuests'] != null
                                                ? List<String>.from(data['completedQuests'])
                                                : [];
            _suggestedQuests = _baseSuggestedQuests.where((quest) {
              return !completedQuestsFromDB.contains(quest['id']);
            }).toList();
            //  إذا أردت إظهار المهام المكتملة بعلامة صح، يمكنك تعديل هذا المنطق

          });
        }
      } else {
        if (mounted) {
          setState(() {
            _userName = user.displayName ?? "مستخدم جديد";
            _userLevel = 1; _currentXp = 0; _nextLevelXp = 200;
            _suggestedQuests = List.from(_baseSuggestedQuests); //  عرض كل المهام إذا لا يوجد بروفايل
            _isLoadingUserData = false;
          });
        }
        print('User document not found in Firestore for MainContent. Using Auth/default values.');
      }
    } catch (e) {
      print('Error loading user data in MainContent: $e');
      if (mounted) {
        setState(() { _userName = "خطأ تحميل"; _suggestedQuests = []; _isLoadingUserData = false; });
      }
    }
  }

  // دالة لمعالجة الضغط على المهمة
  void _handleQuestTap(BuildContext context, Map<String, dynamic> quest) async {
    print('Tapped on suggested quest: ${quest['title']} - Action: ${quest['action_type']} - ID: ${quest['id']}');
    bool? profileWasUpdated;

    switch (quest['action_type']) {
      case 'navigate_to_edit_profile_experience':
      case 'navigate_to_edit_profile_skills':
      case 'navigate_to_edit_profile': // اسم عام إذا أردنا
        profileWasUpdated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(
              triggeredByQuestId: quest['id'] as String?, //  ⭐  تمرير معرّف المهمة  ⭐
            ),
          ),
        );
        break;
      case 'navigate_to_search_screen':
        // هذا يتطلب طريقة للتحكم في _selectedIndex في _JobSeekerHomeScreenState
        // وهو ما يفعله شريط التنقل السفلي. يمكننا إرشاد المستخدم للضغط على أيقونة البحث.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('للبحث، الرجاء الضغط على أيقونة البحث في الشريط السفلي.')),
          );
        }
        break;
      default:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('إجراء غير معروف للمهمة: ${quest['title']}')),
          );
        }
    }

    if (profileWasUpdated == true && mounted) {
      print("Profile was updated from EditProfileScreen, refreshing user data in MainContentPlaceholder...");
      _loadUserData(); //  ⭐  إعادة تحميل البيانات لتحديث الـ XP والمستوى والمهام المقترحة  ⭐
    }
  }

  Widget _getOfficeWidget(BuildContext context, int level) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    IconData officeIcon;
    String officeTitle;
    String officeDescription;

    if (level >= 10) {
      officeIcon = Icons.business_center_outlined; 
      officeTitle = "مكتب المدير التنفيذي!";
      officeDescription = "لقد وصلت إلى القمة! استمر في الإلهام.";
    } else if (level >= 5) {
      officeIcon = Icons.laptop_mac_outlined; 
      officeTitle = "مكتبك يتطور!";
      officeDescription = "عمل رائع! إنجازاتك تتحدث عن نفسها.";
    } else {
      officeIcon = Icons.desk_outlined; 
      officeTitle = "مكتبك الافتراضي";
      officeDescription = "رحلتك المهنية تبدأ هنا. أكمل المهام لترقية مكتبك!";
    }
    return Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon( officeIcon, size: 100, color: theme.colorScheme.primary.withOpacity(0.7), ), const SizedBox(height: 16), Text( officeTitle, textAlign: TextAlign.center, style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.9)), ), const SizedBox(height: 8), Text( officeDescription, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)), ), ], );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_isLoadingUserData) {
      return const Center(child: CircularProgressIndicator());
    }

    double progressPercent = (_nextLevelXp > 0 && _currentXp <= _nextLevelXp) 
                            ? (_currentXp / _nextLevelXp).clamp(0.0, 1.0) 
                            : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- الجزء العلوي لمعلومات المستخدم ---
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.primary.withOpacity(0.05),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary,
                  // TODO: لاحقاً، سنعرض صورة المستخدم الفعلية هنا
                  child: const Icon(Icons.person_outline, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المستوى: $_userLevel',
                        style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_currentXp / $_nextLevelXp XP',
                        style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- قسم المشهد التفاعلي (المكتب) ---
          Container(
            width: double.infinity,
            color: theme.cardTheme.color?.withOpacity(0.5), // استخدام لون البطاقة مع شفافية
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: _getOfficeWidget(context, _userLevel),
          ),

          // --- القسم: المهام المقترحة ---
          if (_suggestedQuests.isNotEmpty) //  ⭐  إظهار القسم فقط إذا كانت هناك مهام مقترحة  ⭐
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "مهام مقترحة لك:",
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestedQuests.length,
                    itemBuilder: (ctx, index) {
                      final quest = _suggestedQuests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: ListTile(
                          leading: Icon(quest['icon'], color: theme.colorScheme.primary, size: 28),
                          title: Text(quest['title'], style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                          trailing: Text(quest['xp'], style: textTheme.bodyMedium?.copyWith(color: Colors.green[700], fontWeight: FontWeight.bold)),
                          onTap: () {
                            _handleQuestTap(context, quest);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          else if (!_isLoadingUserData) //  إذا لا توجد مهام مقترحة وبعد انتهاء التحميل
             Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "رائع! يبدو أنك أنجزت كل المهام المقترحة حالياً.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ),
            ),
        ],
      ),
    );
  }
}