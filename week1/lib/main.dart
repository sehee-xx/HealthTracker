import 'package:flutter/material.dart';

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
            const Center(child: Text('Content of Tab 2')),
            const Center(child: Text('Content of Tab 3')),
          ],
        ),
      ),
    );
  }
}
