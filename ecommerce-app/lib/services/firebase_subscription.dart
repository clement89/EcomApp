
import 'package:Nesto/utils/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseTopicSubscription {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;

  void subscribeToTopic({String topic}) async {
    try {
      String topicName = "STORE_CODE-" + topic;
      //log("TOPIC SUBSCRIBED: $topicName", name: "subscribeToTopic");
logNestoCustom(message:"TOPIC SUBSCRIBED: $topicName", logType: LogType.debug);

      await _messaging.subscribeToTopic(topicName);
    } catch (e) {
      //log("TOPIC SUB ERR: $e", name: "FirebaseTopicSubscription");
logNestoCustom(message:"TOPIC SUB ERR: $e", logType: LogType.error);

    }
  }

  void unSubscribeToTopic({String topic}) async {
    try {
      String topicName = "STORE_CODE-" + topic;
      //log("TOPIC UN-SUBSCRIBED: $topicName", name: "subscribeToTopic");
logNestoCustom(message:"TOPIC UN-SUBSCRIBED: $topicName", logType: LogType.debug);

      await _messaging.unsubscribeFromTopic(topicName);
    } catch (e) {
      //log("TOPIC SUB ERR: $e", name: "FirebaseTopicSubscription");
logNestoCustom(message:"TOPIC SUB ERR: $e", logType: LogType.error);

    }
  }
}
