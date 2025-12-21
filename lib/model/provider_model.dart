class ProviderModel {
  final int? id; // local row id
  final int providerId;
  final int programId;
  final String programName;
  final String providerCode;
  final String providerName;
  final String mobileNo;
  final String nid;
  final String email;
  final String networkId;
  final int providerTypeId;
  final String empType;
  final String gender;
  final String dateOfBirth;
  final String presentAddress;
  final String division;
  final String district;
  final String upazila;
  final String unionName;
  final int divisionId;
  final int districtId;
  final int upazilaId;
  final int unionId;
  final String wardOrMarket;
  final String remarks;

  const ProviderModel({
    this.id,
    required this.providerId,
    required this.programId,
    required this.programName,
    required this.providerCode,
    required this.providerName,
    required this.mobileNo,
    required this.nid,
    required this.email,
    required this.networkId,
    required this.providerTypeId,
    required this.empType,
    required this.gender,
    required this.dateOfBirth,
    required this.presentAddress,
    required this.division,
    required this.district,
    required this.upazila,
    required this.unionName,
    required this.divisionId,
    required this.districtId,
    required this.upazilaId,
    required this.unionId,
    required this.wardOrMarket,
    required this.remarks,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'providerId': providerId,
        'programId': programId,
        'programName': programName,
        'providerCode': providerCode,
        'providerName': providerName,
        'mobileNo': mobileNo,
        'nid': nid,
        'email': email,
        'networkId': networkId,
        'providerTypeId': providerTypeId,
        'empType': empType,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'presentAddress': presentAddress,
        'division': division,
        'district': district,
        'upazila': upazila,
        'unionName': unionName,
        'divisionId': divisionId,
        'districtId': districtId,
        'upazilaId': upazilaId,
        'unionId': unionId,
        'wardOrMarket': wardOrMarket,
        'remarks': remarks,
      };

  factory ProviderModel.fromMap(Map<String, dynamic> m) => ProviderModel(
        id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}'),
        providerId: _asInt(m['providerId']),
        programId: _asInt(m['programId']),
        programName: (m['programName'] ?? '') as String,
        providerCode: (m['providerCode'] ?? '') as String,
        providerName: (m['providerName'] ?? '') as String,
        mobileNo: (m['mobileNo'] ?? '') as String,
        nid: (m['nid'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        networkId: (m['networkId'] ?? '') as String,
        providerTypeId: _asInt(m['providerTypeId']),
        empType: (m['empType'] ?? '') as String,
        gender: (m['gender'] ?? '') as String,
        dateOfBirth: (m['dateOfBirth'] ?? '') as String,
        presentAddress: (m['presentAddress'] ?? '') as String,
        division: (m['division'] ?? '') as String,
        district: (m['district'] ?? '') as String,
        upazila: (m['upazila'] ?? '') as String,
        unionName: (m['unionName'] ?? '') as String,
        divisionId: _asInt(m['divisionId']),
        districtId: _asInt(m['districtId']),
        upazilaId: _asInt(m['upazilaId']),
        unionId: _asInt(m['unionId']),
        wardOrMarket: (m['wardOrMarket'] ?? '') as String,
        remarks: (m['remarks'] ?? '') as String,
      );
}

int _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
