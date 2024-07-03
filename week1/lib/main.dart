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
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image/flutter_image.dart';

void main() {
  initializeDateFormatting('ko_KR', null).then((_) {
    runApp(MyApp());
  });
}

class ImageTuple {
  final File image;
  final String author;
  final DateTime timeStamp;
  String comments;

  ImageTuple(this.image, this.author, this.timeStamp, this.comments);

  Map<String, dynamic> toJson() => {
        'imagePath': image.path,
        'author': author,
        'timeStamp': timeStamp.toIso8601String(),
        'comments': comments,
      };

  factory ImageTuple.fromJson(Map<String, dynamic> json) => ImageTuple(
        File(json['imagePath']),
        json['author'],
        DateTime.parse(json['timeStamp']),
        json['comments'],
      );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
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
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    });

    // clearPreferences();
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/splash.json',
                repeat: true,
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<Map<String, String>> contacts = []; // JSON 데이터를 담을 리스트
  final ImagePicker _picker = ImagePicker();
  List<ImageTuple> _images = [];
  List<ImageTuple> defaultImageset = [];
  late TabController _tabController;

  final List<String> quotes = [
    "오늘 할 운동을 내일로 미루지 말자",
    "지금이 가장 중요한 순간이다",
    "매일 조금씩 더 나아지자",
    "포기하지 마라",
    "너 자신을 믿어라",
  ];

  String currentQuote = "오늘 할 운동을 내일로 미루지 말자";

  bool showImageButtons = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Tab 변경 시 상태 업데이트
    });
    _loadContacts(); // JSON 데이터를 불러오는 함수 호출
    _loadInitialImages(); // 디폴트 이미지 추가
    _loadImages();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    // 추가된 코드: GifController 해제
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void toggleImageButtons() {
    setState(() {
      showImageButtons = !showImageButtons;
      if (showImageButtons) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contactsJson = prefs.getString('contacts');
    print("Loaded contacts from SharedPreferences: $contactsJson");

    if (contactsJson == null || contactsJson.isEmpty) {
      print("SharedPreferences is empty. Loading from assets.");
      try {
        String assetContactsJson =
            await rootBundle.loadString('assets/contacts.json');
        print("Loaded contacts from assets: $assetContactsJson");
        await prefs.setString('contacts', assetContactsJson);
        contactsJson = assetContactsJson;
        print("Contacts saved to SharedPreferences: $contactsJson");
      } catch (e) {
        print("Error loading contacts from assets: $e");
        return; // 에러가 발생한 경우에는 더 이상 진행하지 않도록 리턴합니다.
      }
    }

    if (contactsJson != null && contactsJson.isNotEmpty) {
      try {
        List<dynamic> contactsList = json.decode(contactsJson);
        print("Decoded contacts list: $contactsList");
        setState(() {
          contacts = contactsList.map<Map<String, String>>((contact) {
            print("Mapping contact: $contact");
            return {
              'name': contact['name'],
              'phone': contact['phone'],
            };
          }).toList();
        });
        print("Contacts set in state: $contacts");
      } catch (e) {
        print("Error decoding contacts JSON: $e");
      }
    } else {
      print("contactsJson is null or empty after loading from assets.");
    }
  }

  Future<void> _saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String contactsJson = json.encode(contacts);
    await prefs.setString('contacts', contactsJson);
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
        _saveContacts(); // Save contacts to SharedPreferences
      });
    }
  }

  void _deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
      _saveContacts(); // Save contacts to SharedPreferences
    });
    Navigator.of(context).pop();
  }

  Future<void> _pickImageCam() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _addImage(File(pickedFile.path), "수지", "");
      showImageButtons = false;
    }
  }

  Future<void> _pickImageGal() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _addImage(File(pickedFile.path), "수지", "");
      showImageButtons = false;
    }
  }

  void _showRandomQuote() {
    final random = Random();
    final randomIndex = random.nextInt(quotes.length);
    setState(() {
      currentQuote = quotes[randomIndex];
    });
  }

  Future<void> _loadInitialImages() async {
    final List<String> imagePaths = [
      'assets/pics/image0.jpg',
      'assets/pics/image1.jpg',
      'assets/pics/image2.jpg',
      'assets/pics/image3.jpg',
      'assets/pics/image4.jpg'
    ];

    final List<DateTime> imageTimes = [
      DateTime(2024, 5, 19, 12, 13),
      DateTime(2024, 6, 19, 18, 12),
      DateTime(2024, 6, 28, 7, 38),
      DateTime(2024, 6, 30, 20, 1),
      DateTime(2024, 7, 1, 16, 0)
    ];

    final List<String> imageComments = [
      '아침 식사!',
      '30분 러닝',
      '식단 완료',
      '야간 산책!',
      '오운완'
    ];

    for (int i = imagePaths.length - 1; i >= 0; i--) {
      final byteData = await rootBundle.load(imagePaths[i]);
      final file = File('${(await getTemporaryDirectory()).path}/image$i.jpg');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      setState(() {
        defaultImageset.add(
          ImageTuple(
            file,
            '수지',
            imageTimes[i],
            imageComments[i],
          ),
        );
      });
    }
  }

  Future<void> _loadImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('images') ?? [];
    if (jsonList.isEmpty) {
      setState(() {
        _images = defaultImageset;
      });
    } else {
      setState(() {
        _images = jsonList
            .map((jsonStr) => ImageTuple.fromJson(json.decode(jsonStr)))
            .toList();
      });
    }
  }

  Future<void> _addImage(File imageFile, String author, String comments) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ImageTuple newImage =
        ImageTuple(imageFile, author, DateTime.now(), comments);
    setState(() {
      _images.insert(0, newImage);
      List<String> jsonList =
          _images.map((image) => json.encode(image.toJson())).toList();
      prefs.setStringList('images', jsonList);
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
              title: Text(
                currentQuote,
                style: TextStyle(fontSize: 14), // 폰트 크기 조정
              ),
              onTap: () {
                _showRandomQuote();
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_page, color: Colors.deepPurple),
              title: Text(
                'Contact',
                style: TextStyle(fontSize: 14), // 폰트 크기 조정
              ),
              onTap: () {
                _tabController.index = 0;
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.deepPurple),
              title: Text(
                'Image',
                style: TextStyle(fontSize: 14), // 폰트 크기 조정
              ),
              onTap: () {
                _tabController.index = 1;
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
              title: Text(
                'Health',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                _tabController.index = 2;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.health_and_safety, color: Colors.deepPurple),
              title: Text(
                'Care',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                _tabController.index = 3;
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Lottie.asset(
                'assets/running_man.json',
                width: 300,
                height: 300,
                repeat: true,
                frameRate: FrameRate(30),
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  leading:
                      const Icon(Icons.contact_phone, color: Colors.deepPurple),
                  title: Text(
                    contacts[index]['name']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    contacts[index]['phone']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.deepPurple,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailPage(
                          name: contacts[index]['name']!,
                          phone: contacts[index]['phone']!,
                          onUpdate: (updatedContact) {
                            setState(() {
                              contacts[index] = updatedContact;
                            });
                            _saveContacts();
                          },
                          onDelete: () {
                            setState(() {
                              contacts.removeAt(index);
                            });
                            _saveContacts();
                            Navigator.of(context).pop();
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
          ImageGalleryTab(images: _images),
          // 운동 탭
          const HealthRecordWidget(),
          // 케어 탭
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
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: FloatingActionButton(
                                    key: ValueKey<int>(1),
                                    onPressed: _pickImageCam,
                                    child: const Icon(Icons.add_a_photo),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: FloatingActionButton(
                                    key: ValueKey<int>(2),
                                    onPressed: _pickImageGal,
                                    child: const Icon(Icons.photo_library),
                                  ),
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
}

class ImageGalleryTab extends StatefulWidget {
  final List<ImageTuple> images;
  ImageGalleryTab({required this.images});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGalleryTab> {
  List<ImageTuple> _images = [];
  List<ImageTuple> _filteredImages = [];
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _images = widget.images;
    _filteredImages = _images;
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
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
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                editComment(index, '');
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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                                            editComment(
                                                index, commentController.text);

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
                          top: 0,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              _confirmDelete(context, index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
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
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  Future<void> editComment(int index, String newComment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _images[index].comments = newComment;
      List<String> jsonList =
          _images.map((image) => json.encode(image.toJson())).toList();
      prefs.setStringList('images', jsonList);
    });
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '정말 삭제하겠습니까?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _deleteImage(context, index);
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteImage(BuildContext context, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _filteredImages.removeAt(index);
      List<String> jsonList =
          _images.map((image) => json.encode(image.toJson())).toList();
      prefs.setStringList('images', jsonList);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  void _filterImages(DateTime? filterDate) {
    setState(() {
      if (filterDate == null) {
        _filteredImages = _images;
      } else {
        _filteredImages = _images.where((image) {
          return image.timeStamp.isAfter(filterDate);
        }).toList();
      }
    });
  }

  void _selectFilterDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _filterDate) {
      setState(() {
        _filterDate = picked;
        _filterImages(picked);
      });
    }
  }

  void _applyFilter(int days) {
    DateTime filterDate = DateTime.now().subtract(Duration(days: days));
    _filterImages(filterDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case '오늘':
                  _applyFilter(1);
                  break;
                case '7일':
                  _applyFilter(7);
                  break;
                case '30일':
                  _applyFilter(30);
                  break;
                case '날짜 선택':
                  _selectFilterDate(context);
                  break;
                case '전체':
                  _filterImages(null);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: '오늘',
                child: Text('오늘'),
              ),
              const PopupMenuItem<String>(
                value: '7일',
                child: Text('7일'),
              ),
              const PopupMenuItem<String>(
                value: '30일',
                child: Text('30일'),
              ),
              const PopupMenuItem<String>(
                value: '전체',
                child: Text('전체'),
              ),
              const PopupMenuItem<String>(
                value: '날짜 선택',
                child: Text('날짜 선택'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _filteredImages.isEmpty
                ? Center(
                    child: Text(
                      '아직 추가된 이미지가 없습니다.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: _filteredImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            showImage(index);
                          },
                          child: Image.file(_filteredImages[index].image,
                              fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
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
  List<FlSpot> chartData = [];
  double minY = 0;
  double maxY = 30; // 기본값, 데이터에 따라 다르게 설정

  @override
  void initState() {
    super.initState();
    List<String> dataParts = widget.data.split(' ');
    String numericPart = dataParts[0];
    unit = dataParts.length > 1 ? dataParts[1] : '';
    _numericController = TextEditingController(text: numericPart);
    _initializeChartData();
    _loadChartData();
  }

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  void _initializeChartData() {
    int currentDayIndex = DateTime.now().weekday - 1;
    double numericData = double.tryParse(_numericController.text) ?? 0;

    // 데이터에 따라 y축 범위 설정
    switch (widget.title) {
      case '수면시간':
        minY = 0;
        maxY = 12;
        break;
      case '심박수':
        minY = 40;
        maxY = 120;
        break;
      case '칼로리':
        minY = 0;
        maxY = 2000;
        break;
      case '혈당':
        minY = 50;
        maxY = 150;
        break;
      case '걸음수':
        minY = 0;
        maxY = 20000;
        break;
      case '체중':
        minY = 10;
        maxY = 150;
        break;
      default:
        minY = 0;
        maxY = 10;
        break;
    }

    // 차트 데이터 초기화 (평균값으로 설정)
    double initialValue = (minY + maxY) / 2;
    chartData = List.generate(7, (index) {
      return FlSpot(index.toDouble(), initialValue);
    });

    // 현재 요일의 데이터를 입력 값으로 업데이트
    chartData[currentDayIndex] =
        FlSpot(currentDayIndex.toDouble(), numericData);
  }

  Future<void> _loadChartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedChartData = prefs.getString('${widget.title}_chartData');

    if (savedChartData != null) {
      List<dynamic> data = json.decode(savedChartData);
      setState(() {
        chartData =
            data.map((e) => FlSpot(e[0].toDouble(), e[1].toDouble())).toList();
      });
    }
  }

  Future<void> _saveChartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<List<double>> data =
        chartData.map((spot) => [spot.x, spot.y]).toList();
    await prefs.setString('${widget.title}_chartData', json.encode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드가 나타날 때 화면 조정
      appBar: AppBar(),
      body: SingleChildScrollView(
        // 스크롤 가능하도록 설정
        child: Padding(
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
                  Expanded(
                    child: TextField(
                      controller: _numericController,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: '오늘의 ${widget.title} 수정'),
                    ),
                  ),
                  SizedBox(width: 10),
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
                  double newValue =
                      double.tryParse(_numericController.text) ?? 0;
                  if (newValue < minY) newValue = minY;
                  if (newValue > maxY) newValue = maxY;
                  _updateChartData(newValue);
                  Navigator.pop(context, updatedData);
                  _saveChartData();
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
              Container(
                height: 300, // 고정 높이 설정
                child: buildChart(chartData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateChartData(double newValue) {
    int currentDayIndex = DateTime.now().weekday - 1;

    setState(() {
      chartData[currentDayIndex] = FlSpot(currentDayIndex.toDouble(), newValue);
    });
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
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            color: Colors.deepPurple,
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
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
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
    '600 kcal',
    '100 mg/dL',
    '10000 steps',
    '65 kg'
  ]; // Initial data items

  @override
  void initState() {
    super.initState();
    _loadDataItems();
  }

  Future<void> _loadDataItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = ['수면시간', '심박수', '칼로리', '혈당', '걸음수', '체중'];

    for (int i = 0; i < keys.length; i++) {
      String? value = prefs.getString(keys[i]);
      if (value != null) {
        setState(() {
          dataItems[i] = value;
        });
      }
    }
  }

  Future<void> _saveDataItem(String title, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(title, data);
  }

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
                  builder: (_) => HealthDetailPage(
                    title: title,
                    data: dataItems[index],
                  ),
                ),
              );
              if (updatedData != null) {
                // Update data if it's not null
                setState(() {
                  dataItems[index] = updatedData;
                });
                _saveDataItem(title, updatedData);
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
              _saveDataItem(title, updatedData);
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
                    size: 44.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    data,
                    style: const TextStyle(
                      fontSize: 14.0,
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
  // final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<Map<String, String>> onUpdate;

  const ContactDetailPage({
    Key? key,
    required this.name,
    required this.phone,
    // required this.onEdit,
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
  Map<String, int> todayWorkout = {
    '러닝': 0,
    '걷기': 0,
    '자전거 타기': 0,
    '수영': 0,
    '요가': 0,
    '웨이트': 0,
    '기타': 0,
  };

  Map<String, int> workHistory = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final String? todayWorkoutString = prefs.getString('todayWorkout');
    final String? workHistoryString = prefs.getString('workHistory');
    
    final Map<String, int> loadedTodayWorkout = todayWorkoutString != null
      ? Map<String, int>.from(json.decode(todayWorkoutString))
      : {};
    final Map<String, int> loadedWorkHistory = workHistoryString != null
      ? Map<String, int>.from(json.decode(workHistoryString))
      : {
        '2024-06-19': 55,
        '2024-06-20': 50,
        '2024-06-23': 80,
        '2024-06-24': 50,
        '2024-06-25': 35,
        '2024-06-27': 70,
        '2024-06-28': 60,
        '2024-06-30': 40,
        '2024-07-01': 45,
        '2024-07-02': 50,
      };

    final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      if (loadedWorkHistory.containsKey(todayKey)) {
        todayWorkout = loadedTodayWorkout;
      }
      workHistory = loadedWorkHistory;
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('todayWorkout', json.encode(todayWorkout));
    prefs.setString('workHistory', json.encode(workHistory));
  }

  void _addWorkout(String type, int duration) {
    setState(() {
      todayWorkout[type] = (todayWorkout[type] ?? 0) + duration;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      workHistory[today] = (workHistory[today] ?? 0) + duration;
    });
    _saveData();
  }

  void _editWorkout(String type, int duration) {
    setState(() {
      if (todayWorkout.containsKey(type)) {
        todayWorkout[type] = duration;
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        workHistory[today] =
            todayWorkout.values.fold(0, (sum, element) => sum + element);
      }
    });
    _saveData();
  }

  Future<void> _showAddWorkoutDialog({String? typeToEdit}) async {
    String selectedType = typeToEdit ?? '러닝';
    TextEditingController _durationController = TextEditingController();
    String _localSelectedType = selectedType;

    if (typeToEdit != null) {
      _durationController.text = todayWorkout[typeToEdit].toString();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(typeToEdit == null ? '운동 추가' : '운동 수정'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    value: _localSelectedType,
                    isExpanded: true,
                    onChanged: typeToEdit == null
                        ? (String? newValue) {
                            setState(() {
                              _localSelectedType = newValue!;
                            });
                          }
                        : null,
                    items: <String>[
                      '러닝',
                      '자전거 타기',
                      '수영',
                      '걷기',
                      '요가',
                      '웨이트',
                      '기타'
                    ].map<DropdownMenuItem<String>>((String value) {
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
              child: Text(typeToEdit == null ? '추가' : '수정'),
              onPressed: () {
                if (_durationController.text.isNotEmpty) {
                  if (typeToEdit == null) {
                    _addWorkout(_localSelectedType,
                        int.parse(_durationController.text));
                  } else {
                    _editWorkout(_localSelectedType,
                        int.parse(_durationController.text));
                  }
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

  void _showEditWorkoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('운동 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: todayWorkout.entries
                .where((entry) => entry.value > 0)
                .map((entry) {
              return ListTile(
                title: Text('${entry.key}: ${entry.value}분'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showAddWorkoutDialog(typeToEdit: entry.key);
                  },
                ),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
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
                  Colors.primaries.length],
        ),
      );
    }).toList();

    return Scaffold(
      appBar: totalMinutes > 0
          ? AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showEditWorkoutDialog,
                  color: Colors.deepPurple,
                ),
              ],
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: totalMinutes > 0
            ? Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              height: 200, // Adjust the height as needed
                              child: PieChart(
                                PieChartData(
                                  sections: _getSections(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 70,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: legends,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '총 시간: $hours시간 $minutes분',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              )
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(
                      //   Icons.sentiment_dissatisfied,
                      //   color: Colors.deepPurple,
                      //   size: 80,
                      // ),
                      SizedBox(
                        child: Image.asset('assets/sad.gif'),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '아직 오늘 운동을 시작하지 않았습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _showAddWorkoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          textStyle: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: Text('운동 시작하기'),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: detailPage,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              textStyle: TextStyle(fontSize: 14),
                            ),
                            child: const Text('세부 내용'),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: showHistory,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              textStyle: TextStyle(fontSize: 14),
                            ),
                            child: const Text('히스토리'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: nonZeroWorkouts.isEmpty
          ? Center(
              child: Text(
                '아직 오늘 운동을 시작하지 않았습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
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

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: ListTile(
                          title: Text(type),
                          subtitle: Text(
                              '시간: $duration분, 소모 칼로리: ${calories.toStringAsFixed(2)} kcal'),
                          leading: _getIconForWorkout(type),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '총 소모 칼로리: ${totalCalories} kcal',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
    );
  }

  Icon _getIconForWorkout(String type) {
    switch (type) {
      case '러닝':
        return Icon(Icons.directions_run, color: Colors.deepPurple);
      case '자전거 타기':
        return Icon(Icons.directions_bike, color: Colors.deepPurple);
      case '수영':
        return Icon(Icons.pool, color: Colors.deepPurple);
      case '걷기':
        return Icon(Icons.directions_walk, color: Colors.deepPurple);
      case '요가':
        return Icon(Icons.self_improvement, color: Colors.deepPurple);
      case '웨이트':
        return Icon(Icons.fitness_center, color: Colors.deepPurple);
      default:
        return Icon(Icons.stream, color: Colors.deepPurple);
    }
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

class WorkoutHistoryPage extends StatefulWidget {
  final Map<String, int> workHistory;

  WorkoutHistoryPage(this.workHistory);

  @override
  _WorkoutHistoryPageState createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  String? selectedMonth;
  List<MapEntry<String, int>> sortedEntries = [];
  List<MapEntry<String, int>> filteredEntries = [];

  @override
  void initState() {
    super.initState();
    sortedEntries = widget.workHistory.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));
    filteredEntries = sortedEntries;
  }

  void _filterEntriesByMonth(String? month) {
    setState(() {
      selectedMonth = month;
      if (month == null) {
        filteredEntries = sortedEntries;
      } else {
        filteredEntries = sortedEntries.where((entry) {
          DateTime date = DateTime.parse(entry.key);
          String entryMonth = DateFormat('yyyy-MM').format(date);
          return entryMonth == month;
        }).toList();
      }
    });
  }

  List<DropdownMenuItem<String>> _getMonthDropdownItems() {
    List<String> months = sortedEntries
        .map((entry) {
          DateTime date = DateTime.parse(entry.key);
          return DateFormat('yyyy-MM').format(date);
        })
        .toSet()
        .toList();

    return months.map((month) {
      return DropdownMenuItem<String>(
        value: month,
        child: Text(month),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == '전체') {
                _filterEntriesByMonth(null);
              } else {
                _filterEntriesByMonth(result);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: '전체',
                child: Text('전체'),
              ),
              ..._getMonthDropdownItems().map((item) {
                return PopupMenuItem<String>(
                  value: item.value,
                  child: item.child,
                );
              }).toList(),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                String dateStr = filteredEntries[index].key;
                int duration = filteredEntries[index].value;
                DateTime date = DateTime.parse(dateStr);
                String formattedDate =
                    DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(date);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(formattedDate),
                    subtitle:
                        Text('운동 시간: ${duration ~/ 60}시간 ${duration % 60}분'),
                    leading: const Icon(Icons.fitness_center,
                        color: Colors.deepPurple),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '$consecutiveDays일 연속 운동 완료!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                SizedBox(height: 8),
                Text(
                  '최근 일주일간 $hoursLastWeek시간 $minutesLastWeek분 만큼 운동했습니다.',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
