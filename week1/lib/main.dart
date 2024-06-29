import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class ImageTuple {
  final File image;
  final String author;
  final DateTime timeStamp;
  String comments;

  ImageTuple(this.image, this.author, this.timeStamp, this.comments);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 지연 후 페이지 이동
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            SizedBox(height: 20),
            Text(
              'Health Tracker',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> contacts = []; // JSON 데이터를 담을 리스트
  List<ImageTuple> _images = [];
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  final List<String> quotes = [
    "오늘 할 운동을 내일로 미루지 말자",
    "지금이 가장 중요한 순간이다",
    "매일 조금씩 더 나아지자",
    "포기하지 마라",
    "너 자신을 믿어라"
  ];

  String currentQuote = "오늘 할 운동을 내일로 미루지 말자";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Tab 변경 시 상태 업데이트
    });
    _loadContacts(); // JSON 데이터를 불러오는 함수 호출
  }

  Future<void> _loadContacts() async {
    try {
      final String response = await DefaultAssetBundle.of(context)
          .loadString('assets/contacts.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        contacts = data
            .map<Map<String, String>>((e) =>
                {"name": e["name"] as String, "phone": e["phone"] as String})
            .toList();
      });
    } catch (e) {
      print('Error loading contacts.json: $e');
    }
  }

  Future<void> _pickImageCam() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _images
            .add(ImageTuple(File(pickedFile.path), "수지", DateTime.now(), ""));
      });
    }
  }

  Future<void> _pickImageGal() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images
            .add(ImageTuple(File(pickedFile.path), "수지", DateTime.now(), ""));
      });
    }
  }

  void _showRandomQuote() {
    final random = Random();
    final randomIndex = random.nextInt(quotes.length);
    setState(() {
      currentQuote = quotes[randomIndex];
    });
  }

  void _addOrEditContact({Map<String, String>? contact, int? index}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return ContactInputDialog(contact: contact);
      },
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          contacts[index] = result;
        } else {
          contacts.add(result);
        }
      });
    }
  }

  void _deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Tracker',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Contact'),
            Tab(text: 'Image'),
            Tab(text: 'Health'),
            Tab(text: 'Care'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              accountName: Text("수지"),
              accountEmail: Text("suzi@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            ListTile(
              title: Text(currentQuote),
              onTap: () {
                _showRandomQuote();
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(contacts[index]['name']!),
                  subtitle: Text(contacts[index]['phone']!),
                  leading:
                      const Icon(Icons.contact_phone, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailPage(
                          name: contacts[index]['name']!,
                          phone: contacts[index]['phone']!,
                          onEdit: () => _addOrEditContact(
                              contact: contacts[index], index: index),
                          onDelete: () => _deleteContact(index),
                          onUpdate: (updatedContact) {
                            setState(() {
                              contacts[index] = updatedContact;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          imageGalleryTab(),
          const HealthRecordWidget(), // tab 3
          const HealthRecordWidget(), // tab 4
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _addOrEditContact(),
              tooltip: '연락처 추가',
              child: const Icon(Icons.add),
            )
          : _tabController.index == 1
              ? Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Positioned(
                      bottom: 8,
                      right: 70,
                      child: FloatingActionButton(
                        onPressed: _pickImageCam,
                        child: const Icon(Icons.add_a_photo),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton(
                        onPressed: _pickImageGal,
                        child: const Icon(Icons.photo_library),
                      ),
                    ),
                  ],
                )
              : null,
    );
  }

  Widget imageGalleryTab() {
    return _images.isEmpty
        ? Center(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  'No images added yet',
                  style: TextStyle(color: Colors.grey[700], fontSize: 18),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    showImage(index);
                  },
                  child: Image.file(_images[index].image, fit: BoxFit.cover),
                );
              },
            ),
          );
  }

  // 눌러서 이미지 확대, 다시 한 번 터치 시 꺼짐
  void showImage(int index) {
    ImageTuple imageTuple = _images[index];
    File image = imageTuple.image;
    TextEditingController commentController = TextEditingController();
    bool commentAdded = imageTuple.comments.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: Image.file(image, fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${imageTuple.author}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${DateFormat('yyyy년 MM월 dd일 - HH:mm').format(imageTuple.timeStamp)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (commentAdded)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  children: [
                                    Text(
                                      imageTuple.comments,
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.white),
                                          onPressed: () {
                                            setState(() {
                                              commentController.text =
                                                  imageTuple.comments;
                                              commentAdded = false;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white),
                                          onPressed: () {
                                            setState(() {
                                              commentController.text = '';
                                              imageTuple.comments = '';
                                              commentAdded = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (!commentAdded)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: commentController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your comment',
                                        hintStyle:
                                            TextStyle(color: Colors.white54),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          imageTuple.comments =
                                              commentController.text;
                                          commentAdded = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Add Comment'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(index);
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'delete',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.undo, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }
}

class ContactInputDialog extends StatefulWidget {
  final Map<String, String>? contact;

  const ContactInputDialog({Key? key, this.contact}) : super(key: key);

  @override
  _ContactInputDialogState createState() => _ContactInputDialogState();
}

class _ContactInputDialogState extends State<ContactInputDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!['name']!;
      _phoneController.text = widget.contact!['phone']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact != null ? '연락처 수정' : '연락처 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: '전화번호'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text;
            final phone = _phoneController.text;

            if (name.isNotEmpty && phone.isNotEmpty) {
              Navigator.of(context).pop({'name': name, 'phone': phone});
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<Map<String, String>> onUpdate;

  const ContactDetailPage({
    Key? key,
    required this.name,
    required this.phone,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.deepPurple,
            onPressed: () async {
              final updatedContact = await showDialog<Map<String, String>>(
                context: context,
                builder: (context) {
                  return ContactInputDialog(
                      contact: {'name': name, 'phone': phone});
                },
              );

              if (updatedContact != null) {
                onUpdate(updatedContact);
                Navigator.of(context).pop(); // Pop the dialog
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.deepPurple,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('연락처 삭제'),
                  content: const Text('연락처를 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        onDelete();
                        Navigator.of(context).pop();
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.contact_emergency,
                size: 80,
                color: Colors.deepPurple,
              ),
              SizedBox(height: 16),
              Text(
                '$name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '$phone',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('tel:$phone')),
                icon: const Icon(Icons.call),
                label: const Text('전화걸기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthRecordWidget extends StatefulWidget {
  const HealthRecordWidget({Key? key}) : super(key: key);

  @override
  _HealthRecordWidgetState createState() => _HealthRecordWidgetState();
}

class _HealthRecordWidgetState extends State<HealthRecordWidget> {
  final Map<String, int> todayWorkout = {
    '러닝': 0,
    '걷기': 0,
    '자전거 타기': 0,
    '수영': 0,
    '요가': 0,
    '웨이트': 0,
    '기타': 0,
  };

  final Map<String, int> workHistory = {};

  void _addWorkout(String type, int duration) {
    setState(() {
      todayWorkout[type] = (todayWorkout[type] ?? 0) + duration;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      workHistory[today] = (workHistory[today] ?? 0) + duration;
    });
  }

  Future<void> _showAddWorkoutDialog() async {
    final TextEditingController _durationController = TextEditingController();
    String selectedType = '러닝';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('운동 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: '시간 (분)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
                items: todayWorkout.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('추가'),
              onPressed: () {
                if (_durationController.text.isNotEmpty) {
                  _addWorkout(selectedType, int.parse(_durationController.text));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _getSections() {
    double totalDuration = todayWorkout.values.fold(0, (sum, element) => sum + element);
    return todayWorkout.entries.map((entry) {
      return PieChartSectionData(
        value: (totalDuration > 0) ? (entry.value / totalDuration) * 100 : 0,
        title: '${entry.key} ${(entry.value / totalDuration * 100).toStringAsFixed(1)}%',
        color: Colors.primaries[todayWorkout.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _getSections(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {}, // TODO: Implement details view
                child: const Text('세부 내용'),
              ),
              ElevatedButton(
                onPressed: _showAddWorkoutDialog,
                child: const Text('운동 추가'),
              ),
              ElevatedButton(
                onPressed: () {}, // TODO: Implement history view
                child: const Text('히스토리'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}