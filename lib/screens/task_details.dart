import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:companies_work_system/constants/constants.dart';
import 'package:companies_work_system/firebase_notification_api.dart';
import 'package:companies_work_system/screens/profile.dart';
import 'package:companies_work_system/services/global_method.dart';
import 'package:companies_work_system/widgets/comments_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  final String uploadedBy;

  const TaskDetailsScreen(
      {super.key, required this.taskId, required this.uploadedBy});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _authorName;
  String? _authorPosition;
  String? taskDescription;
  String? taskTitle;
  bool? _isDone;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? deadlineDate;
  String? postedDate;
  String? userImageUrl;
  bool isDeadlineAvailable = false;
  bool _isLoading = false;
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  var contentsInfo = TextStyle(
      fontWeight: FontWeight.normal, fontSize: 15, color: Constants.darkBlue);

  @override
  void initState() {
    super.initState();
    getTaskDetails();
  }

  void getTaskDetails() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uploadedBy)
          .get();

      setState(() {
        _authorName = userDoc.get('name');
        _authorPosition = userDoc.get('positionInCompany');
        userImageUrl = userDoc.get('userImageUrl');
      });

      final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();
      setState(() {
        taskDescription = taskDatabase.get('taskDescription');
        _isDone = taskDatabase.get('isDone');
        deadlineDate = taskDatabase.get('deadlineDate');
        deadlineDateTimeStamp = taskDatabase.get('deadlineDateTimeStamp');
        postedDateTimeStamp = taskDatabase.get('createdAt');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
        var deadlineDateDate = deadlineDateTimeStamp?.toDate();
        isDeadlineAvailable =
            deadlineDateDate?.isAfter(DateTime.now()) ?? false;
      });
    } catch (error) {
      globalMethods.showErrorDialog(error: error.toString(), context: context);
    } finally {
      _isLoading = false;
    }
  }

  void getTaskState() async {
    try {
      final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();
      setState(() {
        _isDone = taskDatabase.get('isDone');
      });
    } catch (error) {
      globalMethods.showErrorDialog(error: error.toString(), context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Back',
            style: TextStyle(
                color: Constants.darkBlue,
                fontStyle: FontStyle.italic,
                fontSize: 20),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Text(
                'Fetching data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      taskTitle ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Constants.darkBlue),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'uploaded by',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Constants.darkBlue),
                                ),
                                const Spacer(),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.pink.shade800,
                                    ),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          userImageUrl ??
                                              'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
                                        ),
                                        fit: BoxFit.fill),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfileScreen(
                                              userID: widget.uploadedBy,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        _authorName ?? '',
                                        style: contentsInfo,
                                      ),
                                    ),

                                    Text(
                                      _authorPosition ?? '',
                                      style: contentsInfo,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Uploaded on:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Constants.darkBlue),
                                ),
                                Text(
                                  postedDate ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: Constants.darkBlue),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Deadline date:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Constants.darkBlue),
                                ),
                                Text(
                                  deadlineDate ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                isDeadlineAvailable
                                    ? 'Still have enough time'
                                    : "No time left",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                    color: isDeadlineAvailable
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Done state:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Constants.darkBlue),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextButton(
                                    child: Text('Done',
                                        style: TextStyle(
                                            decoration: _isDone == true
                                                ? TextDecoration.underline
                                                : TextDecoration.none,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            color: Constants.darkBlue)),
                                    onPressed: () {
                                      User? user = _auth.currentUser;
                                      String uid = user!.uid;
                                      if (uid == widget.uploadedBy) {
                                        FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(widget.taskId)
                                            .update({'isDone': true});
                                        getTaskState();
                                      } else {
                                        globalMethods.showErrorDialog(
                                            error:
                                                'You can\'t perform this action',
                                            context: context);
                                      }
                                    },
                                  ),
                                ),
                                Opacity(
                                  opacity: _isDone == true ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                Flexible(
                                  child: TextButton(
                                    child: Text('Not done',
                                        style: TextStyle(
                                          decoration: _isDone == false
                                              ? TextDecoration.underline
                                              : TextDecoration.none,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 15,
                                          color: Constants.darkBlue,
                                        )),
                                    onPressed: () {
                                      User? user = _auth.currentUser;
                                      String uid = user!.uid;
                                      if (uid == widget.uploadedBy) {
                                        FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(widget.taskId)
                                            .update({'isDone': false});
                                        getTaskState();
                                      } else {
                                        globalMethods.showErrorDialog(
                                            error:
                                                'You can\'t perform this action',
                                            context: context);
                                      }
                                    },
                                  ),
                                ),
                                Opacity(
                                  opacity: _isDone == false ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Task description:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Constants.darkBlue),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              taskDescription ?? '',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Constants.darkBlue,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: _isCommenting
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: TextField(
                                            maxLength: 200,
                                            controller: _commentController,
                                            style: TextStyle(
                                              color: Constants.darkBlue,
                                            ),
                                            keyboardType: TextInputType.text,
                                            maxLines: 6,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              errorBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.red),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.pink),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  MaterialButton(
                                                    onPressed: () async {
                                                      if (_commentController.text.length < 7) {
                                                        globalMethods
                                                            .showErrorDialog(
                                                                error:
                                                                    'Comment can\'t be less than 7 characters',
                                                                context:
                                                                    context);
                                                      }
                                                      else {
                                                        final commentId = const Uuid().v4();

                                                        User? user = _auth.currentUser;

                                                        String uid = user!.uid;

                                                        final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

                                                        FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).update({'taskComments': FieldValue
                                                            .arrayUnion([
                                                            {
                                                              'userId': userDoc.get('id'),
                                                              'commentId': commentId,
                                                              'name': userDoc.get('name'),
                                                              'commentBody': _commentController.text,
                                                              'time': Timestamp.now(),
                                                              'userImageUrl': userDoc.get('userImageUrl'),
                                                            }
                                                          ])
                                                        });

                                                        await Fluttertoast.showToast(
                                                            msg: "comment has been uploaded successfully",
                                                            toastLength: Toast.LENGTH_LONG,
                                                            fontSize: 16.0,
                                                        );

                                                        DocumentSnapshot<Map<String, dynamic>> userDocument = await FirebaseFirestore.instance.collection('users').doc(widget.uploadedBy).get();

                                                        String commenterName = userDoc.get('name');

                                                        String token = userDocument.get('token');

                                                        if(widget.uploadedBy != uid) {
                                                          fireApi.sendNotifyFromFirebase(title: 'comment from $commenterName', body: _commentController.text, sendNotifyTo: token, type: 'comment', taskID: widget.taskId,uploadedBy: widget.uploadedBy);
                                                        }

                                                        _commentController.clear();
                                                      }
                                                    },
                                                    color: Colors.pink.shade700,
                                                    elevation: 10,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        13),
                                                            side: BorderSide
                                                                .none),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 14),
                                                      child: Text(
                                                        'Post',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            // fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _isCommenting =
                                                              !_isCommenting;
                                                        });
                                                      },
                                                      child:
                                                          const Text('Cancel')),
                                                ],
                                              ),
                                            ))
                                      ],
                                    )
                                  : Center(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _isCommenting = !_isCommenting;
                                          });
                                        },
                                        color: Colors.pink.shade700,
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            side: BorderSide.none),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Text(
                                            'Add a comment',
                                            style: TextStyle(
                                                color: Colors.white,
                                                // fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(widget.taskId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Container();
                                  }

                                  return ListView.separated(
                                      reverse: true,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (ctx, index) {
                                        return CommentWidget(
                                          commentId:
                                              snapshot.data?['taskComments']
                                                  [index]['commentId'],
                                          commentBody:
                                              snapshot.data?['taskComments']
                                                  [index]['commentBody'],
                                          commenterId:
                                              snapshot.data?['taskComments']
                                                  [index]['userId'],
                                          commenterName:
                                              snapshot.data?['taskComments']
                                                  [index]['name'],
                                          commenterImageUrl:
                                              snapshot.data?['taskComments']
                                                  [index]['userImageUrl'],
                                          taskId: snapshot.data?['taskId'],
                                          comment: snapshot.data?['taskComments']
                                        [index], taskOwner: widget.uploadedBy,
                                        );
                                      },
                                      separatorBuilder: (ctx, index) {
                                        return const Divider(
                                          thickness: 1,
                                        );
                                      },
                                      itemCount: snapshot
                                          .data?['taskComments'].length);
                                }),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
