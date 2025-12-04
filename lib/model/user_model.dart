
class User {
  final int userId;
  final int empInfoId;
  final String userName;
  final String empMasterCode;
  final String userType;
  final String loginName;
  final String password;
  final String userEmail;
  final String roleType;
  final String empRole;
  final String desigName;

  User({
    required this.userId,
    required this.empInfoId,
    required this.userName,
    required this.empMasterCode,
    required this.userType,
    required this.loginName,
    required this.password,
    required this.userEmail,
    required this.roleType,
    required this.empRole,
    required this.desigName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] is int ? json['userId'] as int : int.tryParse('${json['userId'] ?? 0}') ?? 0,
      empInfoId: json['empInfoId'] is int ? json['empInfoId'] as int : int.tryParse('${json['empInfoId'] ?? 0}') ?? 0,
      userName: (json['userName'] ?? '').toString(),
      empMasterCode: (json['empMasterCode'] ?? '').toString(),
      userType: (json['userType'] ?? '').toString(),
      loginName: (json['loginName'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      userEmail: (json['userEmail'] ?? '').toString(),
      roleType: (json['roleType'] ?? '').toString(),
      empRole: (json['empRole'] ?? '').toString(),
      desigName: (json['desigName'] ?? '').toString(),
    );
  }
}
