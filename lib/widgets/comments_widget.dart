// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:companies_work_system/screens/profile.dart';
import 'package:companies_work_system/services/global_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CommentWidget({
    super.key,
    required this.commentId,
    required this.commentBody,
    required this.commenterImageUrl,
    required this.commenterName,
    required this.commenterId,
    required this.taskId,
    required this.comment,
    required this.taskOwner,
  });

  final String commentId;
  final String commentBody;
  final String commenterImageUrl;
  final String commenterName;
  final String commenterId;
  final String taskOwner;
  final String taskId;
  final dynamic comment;

  final List<Color> _colors = [
    Colors.orangeAccent,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.brown,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actions: [
                  TextButton(
                      onPressed: () async {

                        User? user = _auth.currentUser;

                        String uid = user!.uid;

                        var comments = [];

                        comments.add(comment);

                        if (uid == commenterId || uid == taskOwner) {

                            FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(taskId).update({
                              'taskComments': FieldValue.arrayRemove(comments),
                            });

                            Navigator.pop(context);

                        } else {
                          globalMethods.showErrorDialog(
                              error:
                                  'You don\'t have access to delete this comment',
                              context: context);

                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        ],
                      ))
                ],
              );
            });
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userID: commenterId,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: _colors[3],
                ),
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage(
                      commenterImageUrl,
                    ),
                    fit: BoxFit.fill),
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commenterName,
                    style: const TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    commentBody,
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
