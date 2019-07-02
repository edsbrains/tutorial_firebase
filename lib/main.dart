import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("movies").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return Center(
                child: _mainContent(snapshot.data.documents[index]),
              );
            },
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Padding _mainContent(DocumentSnapshot document) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          document.reference.updateData({"vote": document["vote"] + 1});
        },
        child: Stack(
          children: <Widget>[
            Image.network(document["thumbnailUrl"]),
            Positioned(
              right: 0,
              child: _movieInfo(document["vote"].toString()),
            ),
            Positioned(
              bottom: 0,
              child: _movieInfo(document["name"]),
            )
          ],
        ),
      ),
    );
  }

  Container _movieInfo(String data) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          data,
          style: TextStyle(
              color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
