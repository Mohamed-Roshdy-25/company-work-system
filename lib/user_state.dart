import 'package:companies_work_system/screens/auth/login.dart';
import 'package:companies_work_system/screens/tasks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.data == null) {
            return const LoginScreen();
          } else if (userSnapshot.hasData) {

            return const TasksScreen();
          } else if (userSnapshot.hasError) {
            return const Center(
              child: Text(
                'An error has been occured',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
            );
          }
          return const Scaffold(
            body: Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
            ),
          );
        });
  }
}
