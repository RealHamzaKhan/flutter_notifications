import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notifications/notification_services.dart';
import 'package:http/http.dart' as http;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationServices notificationServices=NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestPermissions();
    notificationServices.firebaseInit(context);
    notificationServices.isTokenValid();
    notificationServices.getDeviceNotificationToken();
    notificationServices.setupInteractMessage(context);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: Center(
        child: TextButton(onPressed: ()async{
          notificationServices.getDeviceNotificationToken().then((value)async{
            var body={
              'to':' foJW6PbvRMqx5QZ3_cnkHv:APA91bFb07NUDttyUMoHoYBq2ONgcDPs1x5Seo7fVzz8kZ_Q7W3ZL79YboMUS707hfYbD1ds6g2mBkVL_BDaEF-VACysAM0E2LidLQ3bve4U90uYHTLe3QsdeaQmKzyA0M6IKE_sEET7',
              'priority':'high',
              'notification':{
                'title':'Hamza',
                'body':'How are you there'
              },
              'data':{
                //type is already defined in flutter messaging compaign
                'type':'1234',
                'name':'hamza'
              },
            };
            await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: {
              'Content-Type':'application/json; charset=UTF-8',
              'Authorization':'key=AAAAs4d9iVo:APA91bGZh0ixS97Tf_Yj3lpXS9Xeeu4dI__QfQBV1E8k1DKm4EkFpt1IKIMMAb6jthXe4inkGjov8MHfusPMvQH0o5WQ5Bs-kHat3tXAEzknSLbF-O9iCg97hAMQQ5O5IgTRzOQusRTi'

            },
            body: jsonEncode(body)
            );
          });
        }, child: Text("Send Notification")),
      ),
    );
  }
}