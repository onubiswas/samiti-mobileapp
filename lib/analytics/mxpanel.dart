import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

Mixpanel? _mixpanel;


Future<void> initMixpanel() async {

    // _mixpanel = MixpanelAnalytics(
    //     token: '69fbfab069130ddbe0357c9c8cb59c33',
    //     // userId$: Stream<String>.value(userId),
    //     // shouldAnonymize: true,
    //     verbose: true,
    // );

    _mixpanel = await Mixpanel.init(
      "69fbfab069130ddbe0357c9c8cb59c33", 
      trackAutomaticEvents: true);
}

void mxTrack(String eventName, Map<String, dynamic> properties) async {
   _mixpanel?.track(eventName, properties:properties);
}

void mxIdentify(String user) async {
 _mixpanel?.identify(user);
  _mixpanel?.registerSuperProperties({
        'userId': user,
        // 'phoneNumber': mobileNumber!,
      });
}



