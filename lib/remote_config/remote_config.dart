import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigClass {
  final remoteConfig = FirebaseRemoteConfig.instance;

  Future initializeConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 20),
        minimumFetchInterval: const Duration(seconds: 30)));

    await remoteConfig.fetchAndActivate();
    bool temp = remoteConfig.getBool("showButton");
    return temp;
  }
}
