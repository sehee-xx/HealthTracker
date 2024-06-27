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
            const Center(child: Text('Content of Tab 3')),
          ],
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
