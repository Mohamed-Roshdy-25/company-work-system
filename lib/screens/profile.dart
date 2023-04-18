// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:companies_work_system/constants/constants.dart';
import 'package:companies_work_system/screens/image_view_screen.dart';
import 'package:companies_work_system/services/global_method.dart';
import 'package:companies_work_system/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../user_state.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({super.key, required this.userID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var titleTextStyle = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String phoneNumber = "";
  String email = "";
  String name = "";
  String job = "";
  String? imageUrl;
  String joinedAt = "";
  bool _isSameUser = false;

  @override
  void initState() {
    super.initState();
    getUserDate();
    globalMethods.registerNotification(context);
  }

  void getUserDate() async {
    _isLoading = true;
    if (kDebugMode) {
      print('uid ${widget.userID}');
    }
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc == null) {
        return;
      } else {
        setState(() {
          email = userDoc.get('email');
          name = userDoc.get('name');
          phoneNumber = userDoc.get('phoneNumber');
          job = userDoc.get('positionInCompany');
          imageUrl = userDoc.get('userImageUrl');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        User? user = _auth.currentUser;
        String uid = user!.uid;
        setState(() {
          _isSameUser = uid == widget.userID;
        });
        if (kDebugMode) {
          print('_isSameUser $_isSameUser');
        }
      }
    } catch (err) {
      globalMethods.showErrorDialog(error: '$err', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(
              child: Text(
                'Fetching data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Stack(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 80,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                name,
                                style: titleTextStyle,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '$job Since joined $joinedAt',
                                style: TextStyle(
                                  color: Constants.darkBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Contact Info',
                              style: titleTextStyle,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            socialInfo(label: 'Email:', content: email),
                            const SizedBox(
                              height: 10,
                            ),
                            socialInfo(
                                label: 'Phone number:', content: phoneNumber),
                            const SizedBox(
                              height: 30,
                            ),
                            _isSameUser
                                ? Container()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      socialButtons(
                                          color: Colors.green,
                                          icon: FontAwesome.whatsapp,
                                          fct: () {
                                            _openWhatsAppChat();
                                          }),
                                      socialButtons(
                                          color: Colors.red,
                                          icon: Icons.mail_outline_outlined,
                                          fct: () {
                                            _mailTo();
                                          }),
                                      socialButtons(
                                          color: Colors.purple,
                                          icon: Icons.call_outlined,
                                          fct: () {
                                            _callPhoneNumber();
                                          }),
                                    ],
                                  ),
                            const SizedBox(
                              height: 20,
                            ),
                            _isSameUser
                                ? Container()
                                : const Divider(
                                    thickness: 1,
                                  ),
                            const SizedBox(
                              height: 20,
                            ),
                            !_isSameUser
                                ? Container()
                                : Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          await _auth.signOut();
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (ctx) =>
                                                  const UserState(),
                                            ),
                                          );
                                        },
                                        color: Colors.pink.shade700,
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            side: BorderSide.none),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.logout,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 14),
                                              child: Text(
                                                'Logout',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 150,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImageViewScreen(imageUrl ?? ''),
                              ));
                        },
                        child: Container(
                          width: size.width * 0.26,
                          height: size.width * 0.26,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 5,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                    imageUrl == null
                                        ? 'https://cdn.icon-icons.com/icons2/2643/PNG/512/male_boy_person_people_avatar_icon_159358.png'
                                        : imageUrl!,
                                  ),
                                  fit: BoxFit.scaleDown)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _openWhatsAppChat() async {
    //for ios
    // final String whatsappURL_ios ="https://wa.me/$phoneNumber?text=${Uri.parse("hello")}";

    final Uri whatsUrl = Uri.parse('whatsapp://send?phone="$phoneNumber"&text=hello');
    if (await canLaunchUrl(whatsUrl)) {
      await launchUrl(whatsUrl);
    } else {
      Fluttertoast.showToast(msg: 'whatsapp is not installed');
    }
  }

  void _mailTo() async {
    final Uri mailUrl = Uri.parse('mailto:$email');

    if (await canLaunchUrl(mailUrl)) {
      await launchUrl(mailUrl);
    } else {
      throw 'Error occured coulnd\'t open link';
    }
  }

  void _callPhoneNumber() async {
    final Uri phoneUrl = Uri.parse('tel://$phoneNumber');

    if (await canLaunchUrl(phoneUrl)) {
      launchUrl(phoneUrl);
    } else {
      throw "Error occured couldn't open link";
    }
  }

  Widget socialInfo({required String label, required String content}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: TextStyle(
              color: Constants.darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget socialButtons(
      {required Color color, required IconData icon, required Function fct}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }
}
