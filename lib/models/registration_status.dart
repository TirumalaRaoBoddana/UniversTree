enum RegistrationStatus {
  draft('draft'),
  emailVerificationPending('email_verification_pending'),
  emailVerified('email_verified'),
  phoneVerificationPending('phone_verification_pending'),
  phoneVerified('phone_verified'),
  institutionDetails('institution_details'),
  locationPending('location_pending'),
  documentsPending('documents_pending'),
  readyForReview('ready_for_review'),
  submitted('submitted'),
  underReview('under_review'),
  additionalInformationRequired('additional_information_required'),
  resubmitted('resubmitted'), // Added explicitly for the correction loop
  approved('approved'),
  rejected('rejected'),
  suspended('suspended'),
  cancelled('cancelled');

  final String value;
  const RegistrationStatus(this.value);

  static RegistrationStatus fromString(String? status) {
    if (status == null) return RegistrationStatus.draft;
    final normalized = status.trim().toLowerCase();
    return RegistrationStatus.values.firstWhere(
          (e) => e.value == normalized,
      orElse: () => RegistrationStatus.draft,
    );
  }

  bool get isEditable =>
      this == RegistrationStatus.draft ||
          this == RegistrationStatus.emailVerificationPending ||
          this == RegistrationStatus.emailVerified ||
          this == RegistrationStatus.phoneVerificationPending ||
          this == RegistrationStatus.phoneVerified ||
          this == RegistrationStatus.institutionDetails ||
          this == RegistrationStatus.locationPending ||
          this == RegistrationStatus.documentsPending ||
          this == RegistrationStatus.readyForReview ||
          this == RegistrationStatus.additionalInformationRequired; // Editable if changes requested

  bool get isTerminal =>
      this == RegistrationStatus.approved ||
          this == RegistrationStatus.rejected ||
          this == RegistrationStatus.cancelled;

  bool get isUnderAdministrativeReview =>
      this == RegistrationStatus.submitted ||
          this == RegistrationStatus.underReview ||
          this == RegistrationStatus.additionalInformationRequired ||
          this == RegistrationStatus.resubmitted; // Added
}