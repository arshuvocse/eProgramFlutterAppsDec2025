class ApiConfig {
  static const String baseUrl = 'http://103.244.247.179:182/api';

  static const String login = '$baseUrl/User/userLogin';
  static const String saveUserLocationTracking = '$baseUrl/User/SaveUserLocationTracking';
  static const String punchInfo = '$baseUrl/Attendance/GetPunchInOutInfo';
  static const String savePunch = '$baseUrl/Attendance/SavePunch';
  static const String dashboardTiles = '$baseUrl/Dashboard/Tiles';
  }
