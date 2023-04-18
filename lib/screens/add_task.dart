// ignore_for_file: avoid_print, unused_field

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:companies_work_system/constants/constants.dart';
import 'package:companies_work_system/services/global_method.dart';
import 'package:companies_work_system/firebase_notification_api.dart';
import 'package:companies_work_system/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _categoryController =
      TextEditingController(text: 'Task Category');
  final TextEditingController _titleController =
      TextEditingController(text: '');

  final TextEditingController _descriptionController =
      TextEditingController(text: '');
  final TextEditingController _deadlineDateController =
      TextEditingController(text: 'pick up a date');
  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timestamp? _deadlineDateTimeStamp;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    globalMethods.registerNotification(context);
  }

  @override
  void dispose() {
    super.dispose();
    _categoryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineDateController.dispose();
  }

  _startDelay() {
    _timer = Timer(const Duration(seconds: 3), () {
      FirebaseMessaging.instance.subscribeToTopic('work');
    });
  }

  void uploadFct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    User? user = _auth.currentUser;
    String uid = user!.uid;
    if (isValid) {
      if (_deadlineDateController.text == 'pick up a date' ||
          _categoryController.text == 'Task Category') {
        globalMethods.showErrorDialog(
            error: 'Please pick up everything', context: context);
        return;
      }
      try {
        String taskId = const Uuid().v4();
        await FirebaseFirestore.instance.collection('tasks').doc(taskId).set({
          'taskId': taskId,
          'uploadedBy': uid,
          'taskTitle': _titleController.text,
          'taskDescription': _descriptionController.text,
          'deadlineDate': _deadlineDateController.text,
          'deadlineDateTimeStamp': _deadlineDateTimeStamp,
          'taskCategory': _categoryController.text,
          'taskComments': [],
          'isDone': false,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
            msg: "Task has been uploaded successfully",
            toastLength: Toast.LENGTH_LONG,
            fontSize: 16.0);
        _descriptionController.clear();
        _titleController.clear();
        setState(() {
          _categoryController.text = 'Task Category';
          _deadlineDateController.text = 'pick up a date';
        });

        DocumentSnapshot<Map<String, dynamic>> taskDoc = await FirebaseFirestore
            .instance
            .collection('tasks')
            .doc(taskId)
            .get();
        String uploadedById = taskDoc.get('uploadedBy');

        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        String userId = userDoc.get('id');

        if (userId == uploadedById) {
          FirebaseMessaging.instance.unsubscribeFromTopic('work');
        }

        fireApi.sendNotifyFromFirebase(
            title: 'New Task is uploaded',
            body: 'click me to go to tasks screen',
            sendNotifyTo: "/topics/work", type: 'task');
      } catch (error) {
        globalMethods.showErrorDialog(
            error: error.toString(), context: context);
      }
    } else {
      globalMethods.showErrorDialog(
          error: 'Form is not valid', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Constants.darkBlue),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'All field are required',
                      style: TextStyle(
                          fontSize: 25,
                          color: Constants.darkBlue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textsWidget(textLabel: 'Task category*'),
                      _textFormFields(
                          valueKey: 'TaskCategory',
                          controller: _categoryController,
                          enabled: false,
                          fct: () {
                            showTaskCategoryDialog(size);
                          },
                          maxLength: 100),
                      textsWidget(textLabel: 'Task title*'),
                      _textFormFields(
                          valueKey: 'TaskTitle',
                          controller: _titleController,
                          enabled: true,
                          fct: () {},
                          maxLength: 100),
                      textsWidget(textLabel: 'Task Description*'),
                      _textFormFields(
                          valueKey: 'TaskDescription',
                          controller: _descriptionController,
                          enabled: true,
                          fct: () {},
                          maxLength: 1000),
                      textsWidget(textLabel: 'Task Deadline date*'),
                      _textFormFields(
                          valueKey: 'DeadlineDate',
                          controller: _deadlineDateController,
                          enabled: false,
                          fct: () {
                            _pickDate();
                          },
                          maxLength: 100),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: MaterialButton(
                            onPressed: () {
                              uploadFct();
                              _startDelay();
                            },
                            color: Colors.pink.shade700,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                                side: BorderSide.none),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Upload',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
        _deadlineDateController.text =
            '${picked!.year}-${picked!.month}-${picked!.day}';
      });
    }
  }

  textsWidget({String? textLabel}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        textLabel!,
        style: TextStyle(
            fontSize: 18,
            color: Colors.pink.shade800,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  void showTaskCategoryDialog(size) {
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
                        setState(() {
                          _categoryController.text =
                              Constants.taskCategoryList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Flexible(
                              flex: 1,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.red[200],
                              )),
                          Flexible(
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
            ],
          );
        });
  }

  _textFormFields(
      {required String valueKey,
      required TextEditingController controller,
      required bool enabled,
      required Function fct,
      required int maxLength}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Field is missing';
            }
            return null;
          },
          enabled: enabled,
          key: ValueKey(valueKey),
          style: TextStyle(
              color: Constants.darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontStyle: FontStyle.italic),
          maxLines: valueKey == 'TaskDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.pink.shade800),
            ),
            // focusedErrorBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: Colors.red),
            // )
          ),
        ),
      ),
    );
  }
}
