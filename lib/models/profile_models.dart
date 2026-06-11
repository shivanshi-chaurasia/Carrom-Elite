class BankDetailsModel {
  final String holderName;
  final String bankName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String? upiId;

  BankDetailsModel({
    required this.holderName,
    required this.bankName,
    required this.accountNumber,
    required this.confirmAccountNumber,
    required this.ifscCode,
    this.upiId,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) => BankDetailsModel(
        holderName: json['holderName']?.toString() ?? '',
        bankName: json['bankName']?.toString() ?? '',
        accountNumber: json['accountNumber']?.toString() ?? '',
        confirmAccountNumber: json['confirmAccountNumber']?.toString() ?? '',
        ifscCode: json['ifscCode']?.toString() ?? '',
        upiId: json['upiId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'holderName': holderName,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'confirmAccountNumber': confirmAccountNumber,
        'ifscCode': ifscCode,
        'upiId': upiId,
      };

  factory BankDetailsModel.mock() => BankDetailsModel(
        holderName: 'Rajan Mehta',
        bankName: '',
        accountNumber: '',
        confirmAccountNumber: '',
        ifscCode: '',
        upiId: '',
      );
}

class KycModel {
  final String aadhaarStatus; // 'Pending', 'Verified', 'Action Required'
  final String panStatus;
  final String aadhaarFrontPath;
  final String aadhaarBackPath;
  final String panPath;

  KycModel({
    required this.aadhaarStatus,
    required this.panStatus,
    this.aadhaarFrontPath = '',
    this.aadhaarBackPath = '',
    this.panPath = '',
  });

  factory KycModel.fromJson(Map<String, dynamic> json) => KycModel(
        aadhaarStatus: json['aadhaarStatus']?.toString() ?? 'Pending',
        panStatus: json['panStatus']?.toString() ?? 'Pending',
        aadhaarFrontPath: json['aadhaarFrontPath']?.toString() ?? '',
        aadhaarBackPath: json['aadhaarBackPath']?.toString() ?? '',
        panPath: json['panPath']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'aadhaarStatus': aadhaarStatus,
        'panStatus': panStatus,
        'aadhaarFrontPath': aadhaarFrontPath,
        'aadhaarBackPath': aadhaarBackPath,
        'panPath': panPath,
      };

  factory KycModel.mock() => KycModel(
        aadhaarStatus: 'Pending',
        panStatus: 'Pending',
      );
}

class NotificationSettingsModel {
  final bool pushEnabled;
  final bool promoEnabled;
  final bool matchEnabled;
  final bool rewardEnabled;

  NotificationSettingsModel({
    required this.pushEnabled,
    required this.promoEnabled,
    required this.matchEnabled,
    required this.rewardEnabled,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) => NotificationSettingsModel(
        pushEnabled: json['pushEnabled'] == true,
        promoEnabled: json['promoEnabled'] == true,
        matchEnabled: json['matchEnabled'] == true,
        rewardEnabled: json['rewardEnabled'] == true,
      );

  Map<String, dynamic> toJson() => {
        'pushEnabled': pushEnabled,
        'promoEnabled': promoEnabled,
        'matchEnabled': matchEnabled,
        'rewardEnabled': rewardEnabled,
      };

  factory NotificationSettingsModel.mock() => NotificationSettingsModel(
        pushEnabled: true,
        promoEnabled: false,
        matchEnabled: true,
        rewardEnabled: true,
      );
}
