import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:companies_work_system/constants/constants.dart';
import 'package:companies_work_system/screens/task_details.dart';
import 'package:companies_work_system/services/global_method.dart';
import 'package:companies_work_system/widgets/drawer_widget.dart';
import 'package:companies_work_system/widgets/tasks_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? taskCategory;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.data['type'] == 'comment') {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(
              taskId: message.data['task_id'],
              uploadedBy: message.data['uploaded_by'],
            ),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    globalMethods.registerNotification(context);
    setupInteractedMessage();
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Tasks',
          style: TextStyle(color: Colors.pink),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showTaskCategoryDialog(context, size);
            },
            icon: const Icon(
              Icons.filter_list_outlined,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('taskCategory', isEqualTo: taskCategory)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              return TaskWidget(
                taskTitle: snapshot.data?.docs[index]['taskTitle'] ?? '',
                taskDescription:
                    snapshot.data?.docs[index]['taskDescription'] ?? '',
                taskId: snapshot.data?.docs[index]['taskId'] ?? '',
                uploadedBy: snapshot.data?.docs[index]['uploadedBy'] ?? '',
                isDone: snapshot.data?.docs[index]['isDone'] ?? false,
              );
            },
          );
        },
      ),
    );
  }

  void showTaskCategoryDialog(context, size) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Task category',
              style: TextStyle(color: Colors.pink.shade300, fontSize: 20),
            ),
            content: SizedBox(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Constants.taskCategoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        if (kDebugMode) {
                          print(
                              'taskCategoryList[index] ${Constants.taskCategoryList[index]}');
                        }
                        setState(() {
                          taskCategory = Constants.taskCategoryList[index];
                        });
                        Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : null;
                      },
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.red[200],
                              )),
                          Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  Constants.taskCategoryList[index],
                                  style: const TextStyle(
                                      color: Color(0xFF00325A),
                                      fontSize: 20,
                                      // fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                ),
                              )),
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Close'),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      taskCategory = null;
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text('Cancel filter'))
            ],
          );
        });
  }
}
