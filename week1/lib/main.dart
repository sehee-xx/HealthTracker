import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math'; // Import the dart:math library for random number generation
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class ImageTuple {
  final File image;
  final String author;
  final DateTime timeStamp;

  ImageTuple(this.image, this.author, this.timeStamp);
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
      home: const SplashScreen(), // 초기 화면으로 SplashScreen 사용
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
            // CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Health Tracker',
              style: TextStyle(
                color: Colors.deepPurple, // 보라색 글씨
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

  String currentQuote = "오늘 할 운동을 내일로 미루지 말자"; // Default quote

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(ImageTuple(File(pickedFile.path), "수지", DateTime.now()));
      });
    }
  }

  // Function to select a random quote
  void _showRandomQuote() {
    final random = Random();
    final randomIndex = random.nextInt(quotes.length);
    setState(() {
      currentQuote = quotes[randomIndex];
    });
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
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          imageGalleryTab(),
          HealthRecordWidget(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _pickImage,
              tooltip: 'Pick Image',
              child: const Icon(Icons.add_a_photo),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.file(image),
                        SizedBox(height: 10),
                        Text(
                          '${imageTuple.author}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${DateFormat('yyyy년 mm월 dd일 - HH:mm').format(imageTuple.timeStamp)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
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
            ],
          ),
        );
      },
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  final String name;
  final String phone;

  const ContactDetailPage({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Container(
        color: Colors.deepPurple[50], // 연한 보라색 배경색
        width: double.infinity, // 전체 너비 채우기
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 주축 방향에서 가운데 정렬
          crossAxisAlignment: CrossAxisAlignment.center, // 교차축 방향에서 가운데 정렬
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              phone,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final url =
                    'tel:${Uri.encodeFull(phone)}'; // tel: 프로토콜을 사용하여 전화 걸기
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url'; // URL을 열 수 없는 경우 예외 처리
                }
              },
              icon: const Icon(Icons.phone),
              label: const Text('전화하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class HealthRecordWidget extends StatefulWidget {
  const HealthRecordWidget({super.key});

  @override
  _HealthRecordWidgetState createState() => _HealthRecordWidgetState();
}

class _HealthRecordWidgetState extends State<HealthRecordWidget> {
  int stepsCount = 8000;
  double calorieBurned = 2500.0;
  int heartRate = 75;

  void updateSteps(int steps) {
    setState(() {
      stepsCount = steps;
    });
  }

  void updateCalories(double calories) {
    setState(() {
      calorieBurned = calories;
    });
  }

  void updateHeartRate(int rate) {
    setState(() {
      heartRate = rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            HealthItemCard(
              icon: Icons.directions_walk,
              title: '걸음수',
              value: '$stepsCount',
              unit: 'steps',
              onPressed: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) {
                    return NumberInputDialog(
                      title: '걸음수 수정',
                      initialValue: stepsCount,
                    );
                  },
                );
                if (result != null) updateSteps(result);
              },
            ),
            HealthItemCard(
              icon: Icons.local_fire_department,
              title: '소모 칼로리',
              value: '$calorieBurned',
              unit: 'kcal',
              onPressed: () async {
                final result = await showDialog<double>(
                  context: context,
                  builder: (context) {
                    return NumberInputDialog(
                      title: '소모 칼로리 수정',
                      initialValue: calorieBurned,
                      isDouble: true,
                    );
                  },
                );
                if (result != null) updateCalories(result);
              },
            ),
            HealthItemCard(
              icon: Icons.favorite,
              title: '심박수',
              value: '$heartRate',
              unit: 'bpm',
              onPressed: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) {
                    return NumberInputDialog(
                      title: '심박수 수정',
                      initialValue: heartRate,
                    );
                  },
                );
                if (result != null) updateHeartRate(result);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your onPressed code here!
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Button color
                foregroundColor: Colors.white, // Text color
              ),
              child: const Text('자세한 정보 보기'),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final VoidCallback onPressed;

  const HealthItemCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text('$title: $value $unit'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.deepPurple),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class NumberInputDialog extends StatefulWidget {
  final String title;
  final dynamic initialValue;
  final bool isDouble;

  const NumberInputDialog({
    required this.title,
    required this.initialValue,
    this.isDouble = false,
    super.key,
  });

  @override
  _NumberInputDialogState createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<NumberInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.isDouble
          ? widget.initialValue.toString()
          : widget.initialValue.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: widget.isDouble
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: const InputDecoration(hintText: 'Enter value'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            if (widget.isDouble) {
              final value = double.tryParse(_controller.text);
              if (value != null) {
                Navigator.of(context).pop(value);
              }
            } else {
              final value = int.tryParse(_controller.text);
              if (value != null) {
                Navigator.of(context).pop(value);
              }
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class PhoneCallPage extends StatelessWidget {
  const PhoneCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '전화 연결 중입니다...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('전화 끊기'),
            ),
          ],
        ),
      ),
    );
  }
}
