class Representative {
  final String fullName;
  final String designation;
  final String email;
  final bool emailVerified;
  final String phoneNumber;
  final bool phoneVerified;

  const Representative({
    required this.fullName,
    required this.designation,
    required this.email,
    this.emailVerified = false,
    required this.phoneNumber,
    this.phoneVerified = false,
  });

  factory Representative.empty() => const Representative(
    fullName: '',
    designation: '',
    email: '',
    emailVerified: false,
    phoneNumber: '',
    phoneVerified: false,
  );

  factory Representative.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Representative.empty();
    return Representative(
      fullName: map['fullName'] as String? ?? map['full_name'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      email: map['email'] as String? ?? map['official_email'] as String? ?? '',
      emailVerified: map['emailVerified'] as bool? ?? map['email_verified'] as bool? ?? false,
      phoneNumber: map['phoneNumber'] as String? ?? map['phone_number'] as String? ?? '',
      phoneVerified: map['phoneVerified'] as bool? ?? map['phone_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'designation': designation,
    'email': email,
    'emailVerified': emailVerified,
    'phoneNumber': phoneNumber,
    'phoneVerified': phoneVerified,
  };

  Representative copyWith({
    String? fullName,
    String? designation,
    String? email,
    bool? emailVerified,
    String? phoneNumber,
    bool? phoneVerified,
  }) {
    return Representative(
      fullName: fullName ?? this.fullName,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }
}