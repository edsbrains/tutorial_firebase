import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final CollectionReference _movieCollection =
      Firestore.instance.collection("movie_collection");

  final _textMovieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: _movieCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return _mainContent(snapshot.data.documents[index]);
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                _textMovieController.clear();
                return AlertDialog(
                  title: Text("Add movie to vote"),
                  content: TextField(controller: _textMovieController),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Save'),
                      onPressed: () {
                        _movieCollection.document().setData({
                          "name": _textMovieController.text,
                          "votes": 0
                        }).whenComplete(() => Navigator.of(context).pop());
                      },
                    ),
                  ],
                );
              });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListTile _mainContent(DocumentSnapshot data) {
    return ListTile(
        onTap: () {
          data.reference.updateData({"votes": data["votes"] + 1});
        },
        onLongPress: () {
          DocumentSnapshot dataView = data;

          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Remove movie"),
                  content:
                      Text(dataView["name"], style: TextStyle(fontSize: 18)),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Delete'),
                      onPressed: () {
                        dataView.reference.delete();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        },
        title: Text(data["name"], style: TextStyle(fontSize: 24)),
        trailing:
            Text(data["votes"].toString(), style: TextStyle(fontSize: 24)));
  }
}
