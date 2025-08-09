import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService{
  static const _deviceKey = 'deviceId';

  //Metodo para obtener el identificador del dispositivo
  static Future<String> getDeviceId() async {
    //Para guardar el id del dispositivo
    var sharedPreference = await SharedPreferences.getInstance();
    String? deviceId = sharedPreference.getString(_deviceKey);

    if(deviceId == null){
      //Para generar el id unico
      deviceId = const Uuid().v4();
      await sharedPreference.setString(_deviceKey, deviceId);
    }

    return deviceId;
  }
}