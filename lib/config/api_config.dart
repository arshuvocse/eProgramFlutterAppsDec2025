class ApiConfig {
  static const String baseUrl = 'http://203.31.169.147:985/api';

  static const String login = '$baseUrl/User/userLogin';
  static const String saveUserLocationTracking = '$baseUrl/User/SaveUserLocationTracking';
  static const String punchInfo = '$baseUrl/Attendance/GetPunchInOutInfo';
  static const String savePunch = '$baseUrl/Attendance/SavePunch';
  static const String dashboardTiles = '$baseUrl/Dashboard/Tiles';
  static const String providerList = '$baseUrl/Provider/GetProviderList';
  static const String checklistAssignments = '$baseUrl/CheckListInfo/assignment-screen';
  static const String saveChecklist = '$baseUrl/CheckListInfo/SaveCheckListInfo';
  static const String checklistSubmissionWithAnswers =
      '$baseUrl/CheckListInfo/submission-with-answers';
  static const String saveLeave = '$baseUrl/Leave/SaveLeave';
  static String seedData(int id) => '$baseUrl/seed-data/$id';
  static const String seedDataPrograms = '$baseUrl/seed-data/programs';
  static const String seedDataProviderGroups = '$baseUrl/seed-data/provider-groups';
  static const String seedDataProviderDoctorTypes = '$baseUrl/seed-data/provider-doctor-types';
  static const String seedDataAcademicQualifications = '$baseUrl/seed-data/academic-qualifications';
  static const String seedDataProfessionalQualifications =
      '$baseUrl/seed-data/professional-qualifications';
}
