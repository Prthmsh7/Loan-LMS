class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String kycStatus;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String documentType;
  final String kycDocumentUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = '',
    this.kycStatus = 'pending',
    this.isAdmin = false,
    required this.createdAt,
    required this.updatedAt,
    this.documentType = '',
    this.kycDocumentUrl = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
      kycStatus: map['kycStatus'] ?? 'pending',
      isAdmin: map['isAdmin'] ?? false,
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: map['updatedAt'] is DateTime 
          ? map['updatedAt'] 
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch),
      documentType: map['documentType'] ?? '',
      kycDocumentUrl: map['kycDocumentUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'kycStatus': kycStatus,
      'isAdmin': isAdmin,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'documentType': documentType,
      'kycDocumentUrl': kycDocumentUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? kycStatus,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? documentType,
    String? kycDocumentUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      kycStatus: kycStatus ?? this.kycStatus,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentType: documentType ?? this.documentType,
      kycDocumentUrl: kycDocumentUrl ?? this.kycDocumentUrl,
    );
  }
} 