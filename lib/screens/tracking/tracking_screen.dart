import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // بيانات وهمية حالياً
  final List<Map<String, String>> appliedJobs = [
    {'title': 'مطور Flutter', 'company': 'شركة ألفا', 'status': 'تمت المشاهدة'},
    {'title': 'مصمم واجهات مستخدم', 'company': 'شركة بيتا', 'status': 'قيد المراجعة'},
    {'title': 'مهندس برمجيات', 'company': 'شركة جاما', 'status': 'تم الإرسال'},
  ];

  final List<Map<String, String>> savedJobs = [
    {'title': 'مدير تسويق رقمي', 'company': 'شركة دلتا', 'location': 'تونس العاصمة'},
    {'title': 'محلل بيانات', 'company': 'شركة إبسيلون', 'location': 'صفاقس'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // لدينا تبويبين
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متابعاتي'),
        backgroundColor: Colors.green, // لون مختلف لهذه الصفحة
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Arial'), // سنقوم بتخصيص الخط لاحقاً
          tabs: const [
            Tab(text: 'تقديماتي'),
            Tab(text: 'العروض المحفوظة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // محتوى تبويب "تقديماتي"
          _buildAppliedJobsList(),
          // محتوى تبويب "العروض المحفوظة"
          _buildSavedJobsList(),
        ],
      ),
    );
  }

  Widget _buildAppliedJobsList() {
    if (appliedJobs.isEmpty) {
      return const Center(
        child: Text('لم تقم بالتقديم على أي وظائف بعد.', style: TextStyle(fontSize: 18)),
      );
    }
    return ListView.builder(
      itemCount: appliedJobs.length,
      itemBuilder: (context, index) {
        final job = appliedJobs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.work_history_outlined, color: Colors.green),
            title: Text(job['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(job['company']!),
            trailing: Chip( // لعرض حالة التقديم
              label: Text(job['status']!),
              backgroundColor: _getStatusColor(job['status']!),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              // لاحقاً: يمكن الانتقال لتفاصيل العرض أو حالة التقديم
              print('Tapped on applied job: ${job['title']}');
            },
          ),
        );
      },
    );
  }

  Widget _buildSavedJobsList() {
    if (savedJobs.isEmpty) {
      return const Center(
        child: Text('لم تقم بحفظ أي عروض بعد.', style: TextStyle(fontSize: 18)),
      );
    }
    return ListView.builder(
      itemCount: savedJobs.length,
      itemBuilder: (context, index) {
        final job = savedJobs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.bookmark_border_outlined, color: Colors.blueAccent),
            title: Text(job['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${job['company']} - ${job['location']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                // لاحقاً: سنقوم ببرمجة حذف العرض من القائمة المحفوظة
                print('Delete saved job: ${job['title']}');
              },
            ),
            onTap: () {
              // لاحقاً: يمكن الانتقال لتفاصيل العرض
              print('Tapped on saved job: ${job['title']}');
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'تمت المشاهدة':
        return Colors.blueAccent;
      case 'قيد المراجعة':
        return Colors.orangeAccent;
      case 'تم الإرسال':
        return Colors.grey;
      case 'مرفوض':
        return Colors.redAccent;
      case 'مقبول':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}