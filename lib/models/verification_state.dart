class ChannelVerification {
  final bool verified;
  final DateTime? verifiedAt;

  const ChannelVerification({
    this.verified = false,
    this.verifiedAt,
  });

  factory ChannelVerification.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChannelVerification();
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      if (value.runtimeType.toString() == 'Timestamp') return (value as dynamic).toDate();
      return null;
    }

    return ChannelVerification(
      verified: map['verified'] as bool? ?? false,
      verifiedAt: parseDateTime(map['verifiedAt'] ?? map['verified_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'verified': verified,
    'verifiedAt': verifiedAt?.millisecondsSinceEpoch,
  };
}

class VerificationState {
  final ChannelVerification email;
  final ChannelVerification phone;

  const VerificationState({
    this.email = const ChannelVerification(),
    this.phone = const ChannelVerification(),
  });

  factory VerificationState.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const VerificationState();
    return VerificationState(
      email: ChannelVerification.fromMap(
        map['email'] != null ? Map<String, dynamic>.from(map['email'] as Map) : null,
      ),
      phone: ChannelVerification.fromMap(
        map['phone'] != null ? Map<String, dynamic>.from(map['phone'] as Map) : null,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email.toMap(),
    'phone': phone.toMap(),
  };

  VerificationState copyWith({
    ChannelVerification? email,
    ChannelVerification? phone,
  }) {
    return VerificationState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}