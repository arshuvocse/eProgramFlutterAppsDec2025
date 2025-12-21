class User {
  // Core fields (match latest login API)
  final int userId;
  final String userName;
  final String userType;
  final String loginName;
  final String password;
  final String userCode;
  final int roleTypeId;
  final bool isApprove;
  final bool isForward;
  final String roleType;
  final String versionName;
  final String desigName;
  final int supervisorId;
  final int areaOfficeId;

  // Legacy/compat fields still used elsewhere in the app
  final int empInfoId;
  final String empMasterCode;
  final String userEmail;
  final String empRole;

  User({
    required this.userId,
    required this.userName,
    required this.userType,
    required this.loginName,
    required this.password,
    required this.userCode,
    required this.roleTypeId,
    required this.isApprove,
    required this.isForward,
    required this.roleType,
    required this.versionName,
    required this.desigName,
    required this.supervisorId,
    required this.areaOfficeId,
    this.empInfoId = 0,
    this.empMasterCode = '',
    this.userEmail = '',
    this.empRole = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
    bool asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final str = (v ?? '').toString().toLowerCase();
      return str == 'true' || str == '1';
    }

    final userId = asInt(json['userId']);
    final empInfoId = asInt(json['empInfoId']);

    return User(
      userId: userId,
      userName: (json['userName'] ?? '').toString(),
      userType: (json['userType'] ?? '').toString(),
      loginName: (json['loginName'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      userCode:
          (json['userCode'] ?? json['user_code'] ?? json['userCodeId'] ?? '')
              .toString(),
      roleTypeId: asInt(json['roleTypeId']),
      isApprove: asBool(json['isApprove']),
      isForward: asBool(json['isForward']),
      roleType: (json['roleType'] ?? '').toString(),
      versionName: (json['versionName'] ?? '').toString(),
      desigName: (json['desigName'] ?? '').toString(),
      supervisorId: asInt(json['supervisorId']),
      areaOfficeId: asInt(json['areaOfficeId']),
      empInfoId: empInfoId != 0
          ? empInfoId
          : userId, // fallback for downstream usage
      empMasterCode: (json['empMasterCode'] ?? json['userCode'] ?? '')
          .toString(),
      userEmail: (json['userEmail'] ?? json['email'] ?? '').toString(),
      empRole: (json['empRole'] ?? '').toString(),
    );
  }
}
