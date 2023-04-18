import 'package:companies_work_system/screens/add_task.dart';

import 'package:companies_work_system/screens/all_workers.dart';
import 'package:companies_work_system/screens/profile.dart';
import 'package:companies_work_system/screens/tasks.dart';
import 'package:companies_work_system/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
   DrawerWidget({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            decoration: const BoxDecoration(color: Colors.cyan),
            child: Column(
              children: const [
                SizedBox(
                  height: 20,
                ),
                Flexible(
                    child: Text(
                  'Work OS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontStyle: FontStyle.italic),
                ))
              ],
            )),
        const SizedBox(
          height: 30,
        ),
        _listTiles(
            label: 'All tasks',
            fct: () {
              _navigateToTaskScreen(context);
            },
            icon: Icons.task_outlined),
        _listTiles(
            label: 'My account',
            fct: () {
              _navigateToProfileScreen(context);
            },
            icon: Icons.settings_outlined),
        _listTiles(
            label: 'Registered workers',
            fct: () {
              _navigateToAllWorkerScreen(context);
            },
            icon: Icons.workspaces_outline),
        _listTiles(
            label: 'Add task',
            fct: () {
              _navigateToAddTaskScreen(context);
            },
            icon: Icons.add_task_outlined),
        const Divider(
          thickness: 1,
        ),
        _listTiles(
            label: 'Logout',
            fct: () {
              _logout(context);
            },
            icon: Icons.logout_outlined),
      ],
    ));
  }

  void _navigateToProfileScreen(context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user!.uid;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userID: uid,),
      ),
    );
  }

  void _navigateToAllWorkerScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AllWorkersScreen(),
      ),
    );
  }

  void _navigateToAddTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  }

  void _navigateToTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TasksScreen(),
      ),
    );
  }

  void _logout(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Sign out'),
                ),
              ],
            ),
            content: const Text(
              'Do you wanna Sign out',
              style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                  onPressed: () {
                    _auth.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const UserState()));
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }

  Widget _listTiles(
      {required String label, required Function fct, required IconData icon}) {
    return ListTile(
      onTap: () {
        fct();
      },
      leading: Icon(
        icon,
      ),
      title: Text(
        label,
        style: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic),
      ),
    );
  }
}
