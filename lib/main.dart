import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  //const HomePage({Key? key}) : super(key: key);

  var items = <Item>[];

  //HomePage({Key? key}) : super(key: key) {
  //items = [];
  // items.add(Item(title: "Banana", done: false));
  // items.add(Item(title: "Maça", done: true));
  // items.add(Item(title: "Abacaxi", done: false));
  //}

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskControler = TextEditingController();

  void add() {
    if (newTaskControler.text.isEmpty) return;
    setState(
      () {
        widget.items.add(
          Item(
            title: newTaskControler.text,
            done: false,
          ),
        );
        newTaskControler.text = "";
        save();
      },
    );
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decode = jsonDecode(data);
      List<Item> result = decode.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  Future save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskControler,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          decoration: const InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            key: Key(item.title!),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            child: CheckboxListTile(
              title: Text(item.title!),
              value: item.done,
              onChanged: (value) {
                setState(
                  () {
                    item.done = value!;
                    save();
                  },
                );
              },
            ),
            onDismissed: (direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
