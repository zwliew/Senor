import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const _title = 'Senor';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: _title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIdx = 0;

  void _handleNavigationItemTap(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  Widget _buildSelectedPageWidget() {
    switch (_selectedIdx) {
      case 1:
        return DiscoverPage();
      case 0:
      default:
        return MessagesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _buildSelectedPageWidget(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Messages'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Discover'),
          )
        ],
        currentIndex: _selectedIdx,
        fixedColor: Colors.blue,
        onTap: _handleNavigationItemTap,
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  static const _peers = [
    'Timmy',
    'Samantha',
    'Zac',
    'Linda',
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the Messages page
    return ListView(
      children: _peers.map((name) => ListTile(title: Text(name))).toList(),
    );
  }
}

class DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement the Discover page
    return Center(
      child: Text('Discover'),
    );
  }
}
