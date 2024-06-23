import '../model/online_nearby_drivers.dart';

class ManageDriversMethods {
  static List<OnlineNearbyHospitalsDrivers> nearbyOnlineDriversList = [];

  static void removeDriverFromList(String driverID) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidHospitalDriver == driverID);

    if (nearbyOnlineDriversList.length > 0) {
      nearbyOnlineDriversList.removeAt(index);
    }
  }

  static void updateOnlineNearbyDriversLocation(OnlineNearbyHospitalsDrivers nearbyOnlineDriverInformation) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidHospitalDriver == nearbyOnlineDriverInformation.uidHospitalDriver);

    nearbyOnlineDriversList[index].latHospitalDriver = nearbyOnlineDriverInformation.latHospitalDriver;
    nearbyOnlineDriversList[index].lngHospitalDriver = nearbyOnlineDriverInformation.lngHospitalDriver;
  }
}
