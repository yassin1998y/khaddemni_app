import 'package:flutter/material.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  // بيانات وهمية حالياً للمهام
  final List<Map<String, dynamic>> availableQuests = const [
    {
      'title': 'أكمل ملفك الشخصي بنسبة 100%',
      'reward': '200 XP + 50 عملة',
      'icon': Icons.person_pin_circle_outlined,
      'isCompleted': false,
    },
    {
      'title': 'قدّم على 3 وظائف هذا الأسبوع',
      'reward': '150 XP',
      'icon': Icons.work_outline,
      'isCompleted': true, // مثال لمهمة مكتملة
    },
    {
      'title': 'وثّق مهارتك في "التصميم الجرافيكي"',
      'reward': '300 XP + شارة "مصمم موثق"',
      'icon': Icons.verified_outlined,
      'isCompleted': false,
    },
    {
      'title': 'ادعُ صديقاً للانضمام للتطبيق',
      'reward': '100 XP + 25 عملة',
      'icon': Icons.person_add_alt_1_outlined,
      'isCompleted': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام والتحديات'),
        backgroundColor: Colors.redAccent, // لون مختلف لهذه الصفحة
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: availableQuests.length,
        itemBuilder: (context, index) {
          final quest = availableQuests[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: quest['isCompleted'] ? Colors.green : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Icon(
                quest['icon'],
                size: 40,
                color: quest['isCompleted'] ? Colors.green : Colors.redAccent[100],
              ),
              title: Text(
                quest['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: quest['isCompleted'] ? TextDecoration.lineThrough : null,
                  color: quest['isCompleted'] ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                'المكافأة: ${quest['reward']}',
                style: TextStyle(
                  color: quest['isCompleted'] ? Colors.grey : Colors.black87,
                ),
              ),
              trailing: quest['isCompleted']
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                  : ElevatedButton(
                      onPressed: () {
                        // لاحقاً: سنقوم ببرمجة الانتقال لتفاصيل المهمة أو إكمالها
                        // التحذير بخصوص print هنا يمكن تجاهله في مرحلة التطوير
                        print('Attempting quest: ${quest['title']}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('ابدأ'),
                    ),
              onTap: () {
                // التحذير بخصوص print هنا يمكن تجاهله في مرحلة التطوير
                print('Tapped on quest: ${quest['title']}');
                // لاحقاً: يمكن عرض تفاصيل أكثر عن المهمة
              },
            ),
          );
        },
      ),
    );
  }
}