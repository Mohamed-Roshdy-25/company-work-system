import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseNotificationApi {
  int _messageCount = 0;

   sendNotifyFromFirebase({
    required String title,
    required String body,
    required String sendNotifyTo,
     required String type,
     String? taskID,
     String? uploadedBy,
  })async{
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAH6d6nrM:APA91bGjzTVGmZUE1wqyDpJ_pw_4OULN-oq-KkiXeSprcd8SWmGNgDaDI3ahpZaY7dXfPVxR6vuju7KfiMRHo683kgt8-mtW4U5VsFLUdf4464c1H9sEQ3SmUaX7KO7n3y-KJ5QnFwBM',
      },

      body: constructFCMPayload(body: body, title: title,sendNotifyTo: sendNotifyTo, type: type, taskID: taskID,uploadedBy: uploadedBy),
    );
  }


  String constructFCMPayload({
    required String title,
    required String body,
    required String sendNotifyTo,
    required String type,
     String? taskID,
     String? uploadedBy,
  }) {
    _messageCount++;
    return jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': body,
          'title': title,
          'android_channel_id':'business'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status':'done',
          'type':type,
          'task_id':taskID,
          'uploaded_by':uploadedBy,
          'count': _messageCount.toString(),
          'body': body,
          'title': title,
        },
        'to': sendNotifyTo,
      },
    );
  }
}

FirebaseNotificationApi fireApi = FirebaseNotificationApi();