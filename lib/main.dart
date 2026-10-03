import 'package:flutter/material.dart';

void main() {
  runApp(const IdentityApp());
}

class IdentityApp extends StatelessWidget {
  const IdentityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليل الهويات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// نموذج بيانات الشخص
class PersonIdentity {
  final String id;
  final String fullName;
  final String idCardNumber;
  final String fatherName;
  final String motherName;
  final String address;

  PersonIdentity({
    required this.id,
    required this.fullName,
    required this.idCardNumber,
    required this.fatherName,
    required this.motherName,
    required this.address,
  });
}

// الشاشة الرئيسية مع خانة البحث
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // قائمة تجريبية أولية
  final List<PersonIdentity> _allPersons = [
    PersonIdentity(
      id: '1',
      fullName: 'محمد العلوي',
      idCardNumber: 'AB123456',
      fatherName: 'أحمد',
      motherName: 'فاطمة',
      address: 'بركان، شارع محمد الخامس',
    ),
    PersonIdentity(
      id: '2',
      fullName: 'عمر بنجلون',
      idCardNumber: 'CD789012',
      fatherName: 'إبراهيم',
      motherName: 'خديجة',
      address: 'أكليم، حي السلام',
    ),
  ];

  List<PersonIdentity> _filteredPersons = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredPersons = _allPersons;
    _searchController.addListener(_filterSearch);
  }

  void _filterSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPersons = _allPersons.where((person) {
        final name = person.fullName.toLowerCase();
        final idCard = person.idCardNumber.toLowerCase();
        // البحث بالاسم الكامل أو رقم بطاقة التعريف
        return name.contains(query) || idCard.contains(query);
      }).toList();
    });
  }

  void _addNewPerson(PersonIdentity newPerson) {
    setState(() {
      _allPersons.add(newPerson);
      _filterSearch(); // تحديث النتائج فوراً
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الهويات الشخصية'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // خانة البحث الفوري
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ابحث بالاسم الكامل أو رقم البطاقة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            // قائمة الهويات
            Expanded(
              child: _filteredPersons.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد نتائج مطابقة',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredPersons.length,
                      itemBuilder: (context, index) {
                        final person = _filteredPersons[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                person.fullName.isNotEmpty
                                    ? person.fullName[0]
                                    : '?',
                                style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              person.fullName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                'CIN: ${person.idCardNumber} | ${person.address}'),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 16),
                            onTap: () {
                              // الانتقال لصفحة التفاصيل
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(person: person),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // الانتقال لشاشة الإضافة وانتظار النتيجة
          final newPerson = await Navigator.push<PersonIdentity>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPersonScreen(),
            ),
          );
          if (newPerson != null) {
            _addNewPerson(newPerson);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// شاشة إضافة شخص جديد بالحقول المطلوبة
class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _idCardController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة هوية جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل *'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'يرجى إدخال الاسم الكامل' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idCardController,
                decoration:
                    const InputDecoration(labelText: 'رقم بطاقة التعريف *'),
                validator: (value) => value == null || value.isEmpty
                    ? 'يرجى إدخال رقم البطاقة'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(labelText: 'اسم الأب'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(labelText: 'اسم الأم'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final person = PersonIdentity(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      fullName: _fullNameController.text,
                      idCardNumber: _idCardController.text,
                      fatherName: _fatherNameController.text,
                      motherName: _motherNameController.text,
                      address: _addressController.text,
                    );
                    Navigator.pop(context, person);
                  }
                },
                child: const Text('حفظ الهوية', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة تفاصيل الشخص
class DetailScreen extends StatelessWidget {
  final PersonIdentity person;

  const DetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.fullName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      person.fullName.isNotEmpty ? person.fullName[0] : '?',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                _buildDetailRow('الاسم الكامل:', person.fullName),
                _buildDetailRow('رقم بطاقة التعريف:', person.idCardNumber),
                _buildDetailRow('اسم الأب:', person.fatherName),
                _buildDetailRow('اسم الأم:', person.motherName),
                _buildDetailRow('العنوان:', person.address),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value.toString() : 'غير متوفر',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
