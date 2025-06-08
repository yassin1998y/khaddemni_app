import 'package:flutter/material.dart';

int _userPoints = 2000; // رصيد وهمي للمستخدم

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<Map<String, dynamic>> storeItems = const [
    {'id': 'cv_template_pro', 'name': 'قالب سيرة ذاتية احترافي', 'price': 500, 'icon': Icons.article_outlined, 'description': 'قالب سيرة ذاتية مصمم باحترافية عالية لزيادة فرص قبولك.'},
    {'id': 'profile_frame_gold', 'name': 'إطار صورة بروفايل ذهبي', 'price': 300, 'icon': Icons.photo_camera_front_outlined, 'description': 'اجعل صورة بروفايلك مميزة بإطار ذهبي أنيق.'},
    {'id': 'cv_color_pack_vibrant', 'name': 'باقة ألوان "نابضة بالحياة" للسيرة الذاتية', 'price': 200, 'icon': Icons.color_lens_outlined, 'description': 'مجموعة ألوان جذابة لتخصيص سيرتك الذاتية.'},
    {'id': 'enable_comments', 'name': 'تفعيل خاصية التعليق على الأخبار', 'price': 1000, 'icon': Icons.comment_outlined, 'description': 'شارك بآرائك وتعليقاتك على آخر الأخبار والمقالات.'},
    {'id': 'profile_boost_24h', 'name': 'تعزيز البروفايل لمدة 24 ساعة', 'price': 750, 'icon': Icons.trending_up_outlined, 'description': 'اجعل بروفايلك يظهر في أعلى نتائج البحث لدى الشركات لمدة 24 ساعة.'},
  ];

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(item['icon'], color: Colors.purple[400], size: 28),
              const SizedBox(width: 10),
              Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['description'] ?? 'لا يوجد وصف لهذا العنصر.'),
              const SizedBox(height: 16),
              Text(
                'السعر: ${item['price']} نقطة',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('رصيدك الحالي: $_userPoints نقطة', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إغلاق'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('شراء الآن', style: TextStyle(color: Colors.white)),
              onPressed: () {
                //  ⭐  التصحيح هنا  ⭐
                final price = item['price'] as num; //  نتأكد أن السعر هو رقم
                if (_userPoints >= price) {
                  setState(() {
                    _userPoints -= price.toInt(); //  تحويل السعر إلى int قبل الخصم
                  });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم شراء "${item['name']}" بنجاح! رصيدك الجديد: $_userPoints نقطة.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // TODO: لاحقاً، سنقوم بتحديث حالة ملكية هذا العنصر للمستخدم في قاعدة البيانات
                  print('User bought: ${item['name']}. Remaining points: $_userPoints');
                } else {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('عذراً، رصيدك غير كافٍ لشراء "${item['name']}".'),
                      backgroundColor: Colors.red,
                    ),
                  );
                   print('Not enough points to buy: ${item['name']}');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متجر خدّمني'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'رصيدك: $_userPoints نقطة',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.8,
          ),
          itemCount: storeItems.length,
          itemBuilder: (context, index) {
            final item = storeItems[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: InkWell(
                onTap: () {
                  _showItemDetails(context, item);
                },
                borderRadius: BorderRadius.circular(15.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 50, color: Colors.purple[300]),
                      const SizedBox(height: 15),
                      Text(
                        item['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item['price']} نقطة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                           _showItemDetails(context, item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('تفاصيل'),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}