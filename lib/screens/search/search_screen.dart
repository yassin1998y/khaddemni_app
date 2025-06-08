import 'package:flutter/material.dart';

//  ⭐  نموذج بيانات وهمي لعرض الشغل (سننشئ له ملفاً خاصاً لاحقاً) ⭐
class JobOffer {
  final String title;
  final String companyName;
  final String location;
  final String contractType; // مثال: "CDI", "Freelance"
  final String postedDate; // مثال: "منذ 3 أيام"
  final String logoUrl; //  رابط وهمي لشعار الشركة

  JobOffer({
    required this.title,
    required this.companyName,
    required this.location,
    required this.contractType,
    required this.postedDate,
    this.logoUrl = 'https://via.placeholder.com/50', //  شعار افتراضي
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  //  ⭐  قائمة وهمية لعروض الشغل  ⭐
  final List<JobOffer> _searchResults = [
    JobOffer(title: 'مطور Flutter أول', companyName: 'شركة تك ماسترز', location: 'تونس العاصمة', contractType: 'CDI', postedDate: 'منذ يومين'),
    JobOffer(title: 'مسؤول تسويق رقمي', companyName: 'ميديا لينك', location: 'صفاقس', contractType: 'Freelance', postedDate: 'منذ 5 أيام'),
    JobOffer(title: 'مهندس برمجيات Java', companyName: 'حلول ويب متقدمة', location: 'سوسة', contractType: 'CDI', postedDate: 'منذ أسبوع'),
    JobOffer(title: 'مصمم جرافيك مبدع', companyName: 'استوديو الإبداع', location: 'تونس العاصمة', contractType: 'CDD', postedDate: 'منذ 10 دقائق'),
  ];

  List<JobOffer> _filteredResults = []; //  لنتائج البحث المفلترة

  @override
  void initState() {
    super.initState();
    _filteredResults = _searchResults; //  في البداية، نعرض كل النتائج
    _searchController.addListener(_performSearch); //  للبحث مع كل تغيير في النص
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredResults = _searchResults; //  إذا كان البحث فارغاً، اعرض كل النتائج
      });
      return;
    }
    setState(() {
      _filteredResults = _searchResults.where((job) {
        return job.title.toLowerCase().contains(query) ||
               job.companyName.toLowerCase().contains(query) ||
               job.location.toLowerCase().contains(query);
      }).toList();
    });
     // التحذير بخصوص print هنا يمكن تجاهله في مرحلة التطوير
    print('Searching for: $query, Found: ${_filteredResults.length} results');
  }

  void _showFiltersDialog() {
    // لاحقاً: سنعرض هنا نافذة منبثقة تحتوي على خيارات الفلترة
    print('Show filters dialog');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فلاتر البحث (قيد التطوير)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن وظيفة'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            tooltip: 'فلاتر البحث',
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: Column( //  ⭐  استخدمنا Column هنا ⭐
        children: [
          // حقل البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن وظيفة، مهارة، شركة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // يمكن إزالة زر الإرسال إذا كان البحث يتم مع كل تغيير
                // suffixIcon: IconButton(
                //   icon: const Icon(Icons.send),
                //   onPressed: _performSearch,
                // ),
              ),
              // onSubmitted: (value) => _performSearch(), // البحث عند الضغط على Enter لا يزال يعمل
            ),
          ),

          // منطقة عرض نتائج البحث
          Expanded(
            child: _filteredResults.isEmpty
                ? const Center( //  ⭐  حالة عدم وجود نتائج  ⭐
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد نتائج تطابق بحثك',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder( //  ⭐  عرض النتائج في ListView  ⭐
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) {
                      final job = _filteredResults[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          leading: CircleAvatar( //  لعرض شعار الشركة
                            backgroundColor: Colors.grey[200],
                            // backgroundImage: NetworkImage(job.logoUrl), //  سنستخدم صورة من الإنترنت لاحقاً
                            child: job.logoUrl.isNotEmpty && job.logoUrl.startsWith('http')
                                ? ClipOval(child: Image.network(job.logoUrl, fit: BoxFit.cover, width: 50, height: 50, errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_outlined, size: 30)))
                                : const Icon(Icons.business_outlined, size: 30), // أيقونة احتياطية
                          ),
                          title: Text(
                            job.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(job.companyName, style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(job.location, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.work_outline, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(job.contractType, style: const TextStyle(fontSize: 13)),
                                  const Spacer(), // لدفع تاريخ النشر لليمين
                                  Text(job.postedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true, // للسماح بمساحة أكبر للـ subtitle
                          onTap: () {
                            // لاحقاً: الانتقال لصفحة تفاصيل عرض الشغل
                            print('Tapped on job: ${job.title}');
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)));
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}