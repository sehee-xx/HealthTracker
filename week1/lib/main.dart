import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 연락처 데이터
  final List<Map<String, String>> contacts = [
    {"name": "짱구", "phone": "010-1234-5678"},
    {"name": "철수", "phone": "010-2345-6789"},
    {"name": "유리", "phone": "010-3456-7890"},
    {"name": "맹구", "phone": "010-4567-8901"},
    {"name": "훈이", "phone": "010-5678-9012"},
    {"name": "흰둥이", "phone": "010-6789-0123"},
    {"name": "짱구", "phone": "010-1234-5678"},
    {"name": "철수", "phone": "010-2345-6789"},
    {"name": "유리", "phone": "010-3456-7890"},
    {"name": "맹구", "phone": "010-4567-8901"},
    {"name": "훈이", "phone": "010-5678-9012"},
    {"name": "흰둥이", "phone": "010-6789-0123"}
  ];

  // 이미지 데이터
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();


  
  Future<void> _pickImage() async {
    // image 개수 제한
    // if (_images.length >= 20) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('You can only upload up to 20 images.')),
    //   );
    //   return;
    // }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }


    // 건강 데이터
    final List<Map<String, String>> healthData = [
      {"title": "걸음수", "value": "8,000"},
      {"title": "소모 칼로리", "value": "2,500 kcal"},
      {"title": "심박수", "value": "75 bpm"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Health Tracker',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Contact'),
              Tab(text: 'Image'),
              Tab(text: 'Health'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(contacts[index]['name']!),
                    subtitle: Text(contacts[index]['phone']!),
                    leading: const Icon(Icons.contact_phone,
                        color: Colors.deepPurple),
                  ),
                );
              },
            ),
            imageGalleryTab(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text('걸음수'),
                      subtitle: Text('8,000'),
                      leading:
                          Icon(Icons.directions_walk, color: Colors.deepPurple),
                    ),
                  ),
                  const Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text('소모 칼로리'),
                      subtitle: Text('2,500 kcal'),
                      leading: Icon(Icons.local_fire_department,
                          color: Colors.deepPurple),
                    ),
                  ),
                  const Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text('심박수'),
                      subtitle: Text('75 bpm'),
                      leading: Icon(Icons.favorite, color: Colors.deepPurple),
                    ),
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
          ],
        ),
         floatingActionButton: FloatingActionButton(
          onPressed: _pickImage,
          tooltip: 'Pick Image',
          child: Icon(Icons.add_a_photo),
        ),

      ),
    );
  }

  Widget imageGalleryTab() {
    return _images.isEmpty ? Center(
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
          return Image.file(_images[index], fit:BoxFit.cover);
        },
      ),
    );
  }
}
