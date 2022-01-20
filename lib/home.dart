import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late String _userToDo;
  List todoList = [];

  void initFirebase () async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  void initstate() {
    super.initState();

    initFirebase ();

    todoList.addAll(['Buy milk', 'Wash dishes', 'Buy potato']);
  }

  void _menuOpen(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            
            title: Text('Меню'),
          ),
          body: Row(
            children: [
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
                //Navigator.pushAndRemoveUntil(context, '/', (route) => false);
              },
                  child: Text('На главную')),
              Padding(padding: EdgeInsets.only(left: 15)),
              Text('Простое меню'),
            ],
          ),
        );
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text('Список дел'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _menuOpen,
              icon: Icon(Icons.menu_outlined),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(!snapshot.hasData) return Text('нет записей');
          return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index){
                    return Dismissible(
                        key: Key(snapshot.data!.docs[index].id),
                        child: Card(
                          child: ListTile(
                            title: Text(snapshot.data?.docs[index].get('item')),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_sweep,
                                color: Colors.deepPurpleAccent,
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance.collection('items').doc(snapshot.data?.docs[index].id).delete();
                              },
                            ),
                          ),
                        ),
                      onDismissed: (direction) {
                        FirebaseFirestore.instance.collection('items').doc(snapshot.data?.docs[index].id).delete();
                      },
                    );
                },
              );
        },
      ),
      //ListView.builder(
      //     itemCount: todoList.length,
      //   itemBuilder: (BuildContext context, int index){
      //       return Dismissible(
      //           key: Key(todoList[index]),
      //           child: Card(
      //             child: ListTile(
      //               title: Text(todoList[index]),
      //               trailing: IconButton(
      //                 icon: Icon(
      //                   Icons.delete_sweep,
      //                   color: Colors.deepPurpleAccent,
      //                 ),
      //                 onPressed: () {
      //                   setState(() {
      //                     todoList.removeAt(index);
      //                   });
      //                 },
      //               ),
      //             ),
      //           ),
      //         onDismissed: (direction) {
      //             setState(() {
      //               todoList.removeAt(index);
      //             });
      //         },
      //       );
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text('Добавить элемент'),
              content: TextField(
                onChanged: (String value) {
                  _userToDo = value;
                },
              ),
              actions: [
                ElevatedButton(onPressed: () {
                 FirebaseFirestore.instance.collection('items').add({'item': _userToDo});
                  Navigator.of(context).pop();
                },
                    child: Text('Добавить'),
                ),
              ],
            );
          });
        },
        child: Icon(
          Icons.add_box,
          color: Colors.white,
        ),
      ),
    );
  }
}

