import 'package:get_it/get_it.dart';
import 'package:moksha_beta/services/push_notif.dart';



GetIt locator = GetIt.instance;

void setupLocator(){
  locator.registerLazySingleton(() => PushNotificationService());
}