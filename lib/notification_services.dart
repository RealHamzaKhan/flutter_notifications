
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/home_screen.dart';
import 'package:notifications/message_screen.dart';

class NotificationServices{
  FirebaseMessaging messaging=FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
  void requestPermissions()async{
    //This will ask the user for the permissions
    NotificationSettings settings=await messaging.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      //provisional means when the user get the notification for the first time then the permissions will be asked

      provisional: true,
      //I left all the others because they are true by default
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("Permission granted");
    }
    else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print("Provional permission granted");
    }
    else{
      //If the user didnt grant permissions open the notification settings
      AppSettings.openAppSettings(type: AppSettingsType.notification);
      print("Permissions denied");
    }
  }
  //This function will get device token on which we will send notification on the device
  Future<String?> getDeviceNotificationToken()async{
    String? token=await messaging.getToken();
    // print("token");
    // print(token);
    return token;
  }
  //This function check whether the token is expired or not
  //if the token is expired it will get updated
  void isTokenValid(){
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("Token refreshed");
     });
  }


  //This function listen to the notifications
  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      initLocalNotification(context, message);
      showNotification(message);
     });
  }
//This function initialize the local notifications for andriod and ios
  void initLocalNotification(BuildContext context,RemoteMessage message)async{
    var androidInititializationSettings=const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings=const DarwinInitializationSettings();
    var initializationSettings=InitializationSettings(
      android: androidInititializationSettings,
      iOS: iosInitializationSettings
    );
   await _flutterLocalNotificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse: (paylaod){
    //because this only works for andriod foreground
    if(Platform.isAndroid){
      handleNotification(context, message);
    }
    
   });
   
  }

//This function decide the details of notifications for android and ios and show noification
  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel androidNotificationChannel=AndroidNotificationChannel(
      Random.secure().nextInt(10000).toString(), "High importance notification",
      importance: Importance.max,
      playSound: true,
      showBadge: true,
      );
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
      androidNotificationChannel.id.toString(), androidNotificationChannel.name.toString(),
      importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker",
      channelDescription: "Channel description",
      );

      //for ios
      DarwinNotificationDetails darwinNotificationDetails=const DarwinNotificationDetails(
        presentAlert: true ,
      presentBadge: true ,
      presentSound: true

      );
      NotificationDetails notificationDetails=NotificationDetails(android: androidNotificationDetails,iOS: darwinNotificationDetails);
      Future.delayed(Duration.zero,(){
        _flutterLocalNotificationsPlugin.show(0, message.notification!.title.toString(),
         message.notification!.body.toString(), notificationDetails);
      });
  }
  Future<void> setupInteractMessage(BuildContext context)async{

  //when app is terminated 
  RemoteMessage? initialMessage=await FirebaseMessaging.instance.getInitialMessage();
  if(initialMessage != null){
    handleNotification(context, initialMessage);
  }
  //when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((event) { 
    handleNotification(context, event);
  });
}
//This function is used to handle notification that on pressing this notification what you want to do
//also message.data is coming with notification known as payload which comes with notification
Future<void> handleNotification(BuildContext context,RemoteMessage message)async{
  print(message.data['key']);
  print(message.data['name']);
  Navigator.push(context, MaterialPageRoute(builder: (context)=> MessageScreen(name: message.data['name'],)));
}

}



