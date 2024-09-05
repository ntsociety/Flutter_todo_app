import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<dynamic> todos = [];

  TextEditingController _titreTextController = TextEditingController();
  TextEditingController _dateTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTodosData();
  }

  void _refreshPage() {
    setState(() {});
  }

  displayMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[700],
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

// get todos from sharedPreences
  getTodosData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? todosData = prefs.getString('todosData');
    if (todosData != null) {
      setState(() {
        todos = jsonDecode(todosData);
      });
    }
  }

  void addTodo(VoidCallback voidCallback) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // le dernier élément de la liste
    int id = 1;
    if (todos.isNotEmpty) {
      var lastTodo = todos.last;
      id = lastTodo['id'] + 1;
    }

    todos.add({
      'id': id,
      'titre': _titreTextController.text.toString(),
      'date': _dateTextController.text.toString(),
      'is_completed': false,
    });

    // add todos to SharedPreferences
    await prefs.setString('todosData', jsonEncode(todos));

    cleanField();
    // fermer modal
    Navigator.pop(context);

    // afficher message
    displayMessage("Tâche ajouté avec succès!");
    voidCallback();
  }

  void cleanField() {
    _titreTextController.clear();
    _dateTextController.clear();
  }

  showAddTodoForm(VoidCallback voidCallback) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ajouter une tâche",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                // formulaire
                TextField(
                  controller: _titreTextController,
                  decoration: InputDecoration(
                    labelText: "Titre de la tâche",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _dateTextController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Date"),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (_titreTextController.text != "") {
                      addTodo(_refreshPage);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Ajouter",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          );
        });
  }

  showEditTodoForm(Map todo, VoidCallback voidCallback) {
    _titreTextController.text = todo['titre'];
    _dateTextController.text = todo['date'];
    bool is_completed = todo['is_completed'];
    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Modifier la tâche",
                      style: TextStyle(fontSize: 20),
                    ),
                    InkWell(
                        onTap: () {
                          cleanField();
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 30,
                        ))
                  ],
                ),
                SizedBox(height: 20),
                // formulaire
                TextField(
                  controller: _titreTextController,
                  decoration: InputDecoration(
                    labelText: "Titre de la tâche",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _dateTextController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Date"),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        updateTodo(todo['id'], _refreshPage);
                      },
                      child: Text(
                        "Modifier",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.red)),
                      onPressed: () {
                        deleteTodo(todo['id'], _refreshPage);
                      },
                      child: Text(
                        "Supprimer",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
          );
        });
  }

  // update
  updateTodo(int id, VoidCallback voidCallback) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var todo in todos) {
      if (todo['id'] == id) {
        todo.addAll({
          'titre': _titreTextController.text.trim().toString(),
          'date': _dateTextController.text.trim(),
        });

        // add todos to SharedPreferences
        await prefs.setString('todosData', jsonEncode(todos));
        break;
      }
    }
    cleanField();
    Navigator.pop(context);
    displayMessage("Tâche modifié avec succès!");
    voidCallback();
  }

  // delete
  deleteTodo(int id, VoidCallback voidCallback) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    todos.removeWhere((todo) => todo['id'] == id);
    // add todos to SharedPreferences
    await prefs.setString('todosData', jsonEncode(todos));
    cleanField();
    Navigator.pop(context);
    displayMessage("Tâche supprimé avec succès!");
    voidCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liste de tâches",
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: todos.length,
        itemBuilder: (context, index) {
          var todo = todos[index];
          return Column(
            children: [
              ListTile(
                leading: InkWell(
                  onTap: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    setState(() {
                      todo.addAll({
                        'is_completed': !todo['is_completed'],
                      });
                    });
                    // add todos to SharedPreferences
                    await prefs.setString('todosData', jsonEncode(todos));
                  },
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: todo['is_completed']
                          ? Image.asset("images/checked.png")
                          : Image.asset("images/uncheck.png"),
                    ),
                  ),
                ),
                title: Text(
                  "${todo['titre']}",
                  style: TextStyle(
                    decoration: todo['is_completed']
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Text("${todo['date']}"),
                trailing: InkWell(
                  onTap: () {
                    showEditTodoForm(todo, _refreshPage);
                    print(todo);
                  },
                  child: Icon(
                    Icons.info_outline,
                    size: 30,
                  ),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: CircleAvatar(
        child: InkWell(
          onTap: () async {
            await showAddTodoForm(_refreshPage);
          },
          child: Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ),
    );
  }
}
