import 'package:flutter/material.dart';
import 'package:to_do_list/todo_tile.dart';

import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(primarySwatch: Colors.yellow),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    loadTasks();
  }

  Future<void> loadTasks() async {
    final tasks = await dbHelper.getAllTasks();
    setState(() {
      toDoList = tasks.map((task) => [task['taskName'], task['taskCompleted'] == 1]).toList();
    });
  }

  Future<void> refreshData() async {
    await loadTasks(); // Reload tasks from the database
  }

  // List of todo tasks
  List toDoList = [];

  // Checkbox was tapped
  void checkBoxChanged(bool? value, int index) async {
    setState(() {
      toDoList[index][1] = value ?? false;
    });

    // Update the task in the database
    await dbHelper.updateTask({
      'id': index + 1, // assuming index starts from 0
      'taskName': toDoList[index][0],
      'taskCompleted': value == true ? 1 : 0,
    });
  }

  TextEditingController taskController = TextEditingController();

  // Create a new task
  void createNewTask() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.cyan[50],
          content: Padding(
            padding: const EdgeInsets.only(top: 20,bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Get user input
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Add a new task",
                  ),
                ),

                // Add top padding to the button row
                Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          taskController.clear();
                          Navigator.pop(context); // Close the dialog on cancel
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Change the background color
                        ),
                        child: const Text('Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // Handle saving the task here
                          String newTask = taskController.text;
                          if (newTask.isNotEmpty) {
                            await dbHelper.insertTask({
                              'taskName': newTask,
                              'taskCompleted': 0, // Assuming the new task is not completed initially
                            });

                            // Refresh the data after saving a new task
                            await refreshData();
                          }
                          taskController.clear();
                          Navigator.pop(context); // Close the dialog on save
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Change the background color
                        ),
                        child: const Text('Save',
                          style:TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  

  // Dispose of the taskController
  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: const Text(
          'To Do',
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.cyan[50],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan[50],
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body:ListView.builder(
        itemCount: toDoList.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.only(top: 8.0), // Adjust the padding as needed
            child: Dismissible(
              key: Key(toDoList[index][0]),
              onDismissed: (direction) async {
                // Handle item removal from the list
                setState(() {
                  toDoList.removeAt(index);
                });

                // Get the task id from the database
                final taskId = index + 1; // Assuming index starts from 0

                // Delete the task from the database
                await dbHelper.deleteTask(taskId);
              },
              confirmDismiss: (direction) async {
                // Show a confirmation dialog before deletion
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.cyan[50],
                      title: const Text("Confirm Deletion"),
                      content: const Text("Are you sure you want to delete this task?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(
                color: Colors.red, // Swipe background color
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: ToDoTile(
                taskName: toDoList[index][0],
                taskCompleted: toDoList[index][1],
                onChanged: (value) => checkBoxChanged(value, index),
              ),
            ),
          );
        },
      ),
    );
  }
}
