import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('ko_KR', null).then((_) {
    runApp(MyApp());
  });
}

final Map<String, int> todayWorkout = {
  '러닝': 0,
  '걷기': 0,
  '자전거 타기': 0,
  '수영': 0,
  '요가': 0,
  '웨이트': 0,
  '기타': 0,
};

final Map<String, int> workHistory = {
  '2024-06-19': 55,
  '2024-06-20': 50,
  '2024-06-23': 80,
  '2024-06-24': 50,
  '2024-06-25': 35,
  '2024-06-27': 70,
  '2024-06-28': 60,
};

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

  bool showImageButtons = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Tab 변경 시 상태 업데이트
    });
    _loadContacts(); // JSON 데이터를 불러오는 함수 호출
  }


  void toggleImageButtons() {
    setState(() {
      showImageButtons = !showImageButtons;
    });
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
          // 이미지 탭
          imageGalleryTab(),
          // 운동 탭
          const HealthRecordWidget(),
          // // 케어 탭
          CareTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              key: ValueKey<int>(0),
              onPressed: () => _addOrEditContact(),
              tooltip: '연락처 추가',
              child: const Icon(Icons.add),
            )
          : _tabController.index == 1
              ? Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showImageButtons
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FloatingActionButton(
                                  key: ValueKey<int>(1),
                                  onPressed: _pickImageCam,
                                  child: const Icon(Icons.add_a_photo),
                                ),
                                const SizedBox(height: 16),
                                FloatingActionButton(
                                  key: ValueKey<int>(2),
                                  onPressed: _pickImageGal,
                                  child: const Icon(Icons.photo_library),
                                ),
                                const SizedBox(height: 16),
                                FloatingActionButton(
                                  key: ValueKey<int>(3),
                                  onPressed: toggleImageButtons,
                                  child: const Icon(Icons.remove),
                                ),
                              ],
                            )
                          : FloatingActionButton(
                              key: ValueKey<int>(4),
                              onPressed: toggleImageButtons,
                              child: const Icon(Icons.add),
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
                  '아직 추가된 이미지가 없습니다.',
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

class HealthDetailPage extends StatefulWidget {
  final String title;
  final String data;

  HealthDetailPage({Key? key, required this.title, required this.data})
      : super(key: key);

  @override
  _HealthDetailPageState createState() => _HealthDetailPageState();
}

class _HealthDetailPageState extends State<HealthDetailPage> {
  late TextEditingController _numericController;
  late String unit;
  late List<FlSpot> chartData;

  @override
  void initState() {
    super.initState();
    // Split the data into numeric and unit parts
    List<String> dataParts = widget.data.split(' ');
    String numericPart = dataParts[0];
    unit = dataParts.length > 1 ? dataParts[1] : '';
    _numericController = TextEditingController(text: numericPart);
    _updateChartData(); // Initialize chart data
  }

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  void _updateChartData() {
    int currentDayIndex = DateTime.now().weekday -
        1; // Get current day index (0 for Monday, ..., 6 for Sunday)

    // Example: Update chartData based on current day index
    double numericData =
        double.tryParse(_numericController.text) ?? 0; // Parse numeric data

    chartData = [
      FlSpot(0, 5),
      FlSpot(1, 4),
      FlSpot(2, 3),
      FlSpot(3, 5),
      FlSpot(4, 6),
      FlSpot(5, 4),
      FlSpot(6, 7),
    ];

    // Update the value for the current day index
    chartData[currentDayIndex] =
        FlSpot(currentDayIndex.toDouble(), numericData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              _getIconForTitle(widget.title),
              size: 100,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                // Numeric part of the data (editable)
                Expanded(
                  child: TextField(
                    controller: _numericController,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: 'Update ${widget.title}'),
                  ),
                ),
                SizedBox(width: 10),
                // Unit part of the data (non-editable)
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String updatedData = '${_numericController.text} $unit';
                Navigator.pop(context, updatedData); // Pass updated data back
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: buildChart(chartData), // Build the chart with the data
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case '수면시간':
        return Icons.nights_stay;
      case '심박수':
        return Icons.favorite;
      case '칼로리':
        return Icons.local_fire_department;
      case '혈당':
        return Icons.bloodtype;
      case '걸음수':
        return Icons.directions_walk;
      case '체중':
        return Icons.monitor_weight_outlined;
      default:
        return Icons.info;
    }
  }

  Widget buildChart(List<FlSpot> chartData) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            color: Colors.deepPurple, // Specify line color here
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                TextStyle style = TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                switch (value.toInt()) {
                  case 0:
                    return Text('월', style: style);
                  case 1:
                    return Text('화', style: style);
                  case 2:
                    return Text('수', style: style);
                  case 3:
                    return Text('목', style: style);
                  case 4:
                    return Text('금', style: style);
                  case 5:
                    return Text('토', style: style);
                  case 6:
                    return Text('일', style: style);
                  default:
                    return Text('', style: style);
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide left side titles
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right side titles
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }
}

class CareTab extends StatefulWidget {
  const CareTab({Key? key}) : super(key: key);

  @override
  _CareTabState createState() => _CareTabState();
}

class _CareTabState extends State<CareTab> {
  List<String> dataItems = [
    '8 hours',
    '70 bpm',
    '300 kcal',
    '100 mg/dL',
    '10000 steps',
    '65 kg'
  ]; // Initial data items

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          String title = '';
          IconData icon = Icons.info;
          Color startColor = Colors.blue.shade200;
          Color endColor = Colors.blue.shade400;

          switch (index) {
            case 0:
              title = '수면시간';
              icon = Icons.nights_stay;
              startColor = Colors.deepPurple.shade200;
              endColor = Colors.purple.shade400;
              break;
            case 1:
              title = '심박수';
              icon = Icons.favorite;
              startColor = Colors.deepPurple.shade200;
              endColor = Colors.purple.shade400;
              break;
            case 2:
              title = '칼로리';
              icon = Icons.local_fire_department;
              startColor = Colors.deepPurple.shade200;
              endColor = Colors.purple.shade400;
              break;
            case 3:
              title = '혈당';
              icon = Icons.bloodtype;
              startColor = Colors.deepPurple.shade200;
              endColor = Colors.purple.shade400;
              break;
            case 4:
              title = '걸음수';
              icon = Icons.directions_walk;
              startColor = Colors.deepPurple.shade200;
              endColor = Colors.purple.shade400;
              break;
            case 5:
              title = '체중';
              icon = Icons.monitor_weight_outlined;
              startColor = Colors.deepPurple.shade200;
              endColor = Colors.purple.shade400;
              break;
            default:
              title = '건강 데이터';
              break;
          }

          return GestureDetector(
            onTap: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HealthDetailPage(title: title, data: dataItems[index]),
                ),
              );
              if (updatedData != null) {
                // Update data if it's not null
                setState(() {
                  dataItems[index] = updatedData;
                });
              }
            },
            child: buildHealthCard(
              context,
              title,
              dataItems[index],
              icon,
              startColor,
              endColor,
              index, // Pass index to buildHealthCard
            ),
          );
        },
      ),
    );
  }

  Widget buildHealthCard(
    BuildContext context,
    String title,
    String data,
    IconData icon,
    Color startColor,
    Color endColor,
    int index,
  ) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () async {
            final updatedData = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HealthDetailPage(title: title, data: data),
              ),
            );
            if (updatedData != null) {
              setState(() {
                dataItems[index] = updatedData;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 48.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    data,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                Navigator.of(context).pop();
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
  void _addWorkout(String type, int duration) {
    setState(() {
      todayWorkout[type] = (todayWorkout[type] ?? 0) + duration;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      workHistory[today] = (workHistory[today] ?? 0) + duration;
    });
  }

  Future<void> _showAddWorkoutDialog() async {
    String selectedType = '러닝';
    TextEditingController _durationController = TextEditingController();
    String _localSelectedType = selectedType; // 로컬 변수로 초기화

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('운동 추가'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    value: _localSelectedType,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _localSelectedType =
                            newValue!; // StatefulBuilder의 setState
                      });
                    },
                    items: todayWorkout.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: '시간 (분)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            },
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
                  _addWorkout(
                      _localSelectedType, int.parse(_durationController.text));
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
    double totalDuration =
        todayWorkout.values.fold(0, (sum, element) => sum + element);
    return todayWorkout.entries.map((entry) {
      return PieChartSectionData(
        value: (totalDuration > 0) ? (entry.value / totalDuration) * 100 : 0,
        title: '${(entry.value / totalDuration * 100).toStringAsFixed(1)}%',
        color: Colors.primaries[todayWorkout.keys.toList().indexOf(entry.key) %
            Colors.primaries.length],
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  void detailPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => WorkoutDetailsPage(todayWorkout)),
    );
  }

  void showHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => WorkoutHistoryPage(workHistory)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalMinutes =
        todayWorkout.values.fold(0, (sum, element) => sum + element);
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    List<Widget> legends =
        todayWorkout.entries.where((entry) => entry.value > 0).map((entry) {
      return Text(
        '${entry.key}: ${entry.value}분',
        style: TextStyle(
            color: Colors.primaries[
                todayWorkout.keys.toList().indexOf(entry.key) %
                    Colors.primaries.length]),
      );
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _getSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 70,
                ),
              ),
            ),
            totalMinutes > 0
                ? Text('총 시간: $hours시간 $minutes분',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                : Text('아직 운동을 하지 않았습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: legends.take(3).toList(),
            ),
            if (legends.length > 3)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: legends.skip(3).toList(),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: detailPage,
                  child: const Text('세부 내용'),
                ),
                ElevatedButton(
                  onPressed: _showAddWorkoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('운동 추가'),
                ),
                ElevatedButton(
                  onPressed: showHistory,
                  child: const Text('히스토리'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutDetailsPage extends StatelessWidget {
  final Map<String, int> todayWorkout;

  WorkoutDetailsPage(this.todayWorkout);

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, int>> nonZeroWorkouts =
        todayWorkout.entries.where((entry) => entry.value > 0).toList();
    int totalCalories = nonZeroWorkouts.fold(0, (sum, entry) {
      return sum + _calculateCalories(entry.key, entry.value);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 운동'),
      ),
      body: nonZeroWorkouts.isEmpty
          ? Center(
              child: const Text('아직 운동을 시작하지 않았습니다'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: nonZeroWorkouts.length,
                    itemBuilder: (context, index) {
                      String type = nonZeroWorkouts[index].key;
                      int duration = nonZeroWorkouts[index].value;
                      int calories =
                          _calculateCalories(type, duration); // 소모 칼로리 계산

                      return ListTile(
                        title: Text(type),
                        subtitle: Text(
                            '시간: $duration분, 소모 칼로리: ${calories.toStringAsFixed(2)} kcal'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '총 소모 칼로리: ${totalCalories} kcal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  int _calculateCalories(String type, int duration) {
    if (type == '러닝')
      return duration * 10;
    else if (type == '자전거 타기')
      return duration * 6;
    else if (type == '수영')
      return duration * 13;
    else if (type == '걷기')
      return duration * 5;
    else if (type == '요가')
      return duration * 3;
    else if (type == '웨이트') return duration * 6;
    return duration * 5; // 기타
  }
}

class WorkoutHistoryPage extends StatelessWidget {
  final Map<String, int> workHistory;

  WorkoutHistoryPage(this.workHistory);

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, int>> sortedEntries = workHistory.entries.toList()
      ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

    int totalMinutesLastWeek = 0;
    DateTime? lastDate;
    int streak = 0;
    int consecutiveDays = 0;

    for (var entry in sortedEntries) {
      DateTime date = DateTime.parse(entry.key);
      if (date.isAfter(DateTime.now().subtract(Duration(days: 7)))) {
        totalMinutesLastWeek += entry.value;
      }
      if (lastDate == null || lastDate.difference(date).inDays == 1) {
        streak++;
        lastDate = date;
      } else if (lastDate.difference(date).inDays > 1) {
        break;
      }
    }
    consecutiveDays = streak;

    int hoursLastWeek = totalMinutesLastWeek ~/ 60;
    int minutesLastWeek = totalMinutesLastWeek % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 히스토리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  String dateStr = sortedEntries[index].key;
                  int duration = sortedEntries[index].value;
                  DateTime date = DateTime.parse(dateStr);
                  String formattedDate =
                      DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(date);

                  return ListTile(
                    title: Text(formattedDate),
                    subtitle:
                        Text('운동 시간: ${duration ~/ 60}시간 ${duration % 60}분'),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    '$consecutiveDays일 연속 운동 완료!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '최근 일주일간 $hoursLastWeek시간 $minutesLastWeek분 만큼 운동했습니다.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
