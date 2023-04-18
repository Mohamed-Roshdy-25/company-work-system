import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:companies_work_system/services/global_method.dart';
import 'package:companies_work_system/widgets/all_workers_widget.dart';
import 'package:companies_work_system/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';


class AllWorkersScreen extends StatefulWidget {
  const AllWorkersScreen({Key? key}) : super(key: key);

  @override
  State<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends State<AllWorkersScreen> {

  @override
  void initState() {
    super.initState();
    globalMethods.registerNotification(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'All worker',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AllWorkersWidget(
                      userID: snapshot.data!.docs[index]['id'],
                      userName: snapshot.data!.docs[index]['name'],
                      userEmail: snapshot.data!.docs[index]['email'],
                      positionInCompany: snapshot.data!.docs[index]
                      ['positionInCompany'],
                      phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                      userImageUrl: snapshot.data!.docs[index]['userImageUrl'],
                    );
                  });
            } else {
              return const Center(
                child: Text('No user found'),
              );
            }
          }
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }
}

