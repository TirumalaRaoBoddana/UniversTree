import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../routing/app_routes.dart';
import '../../../models/college_registration.dart';
import '../../../models/registration_status.dart';
import '../../../models/representative.dart';
import '../../../models/institution_details.dart';
import '../../../models/institution_location.dart';
import '../../../models/registration_document.dart';
import '../../../models/institution_website.dart';
import '../../../models/verification_state.dart';
import '../../../repositories/college_registration_repository.dart';
import '../../../services/verification_service.dart';
import '../../../services/registration_auth_service.dart';
import '../../../services/institution_location_service.dart';
import '../../../services/document_upload_service.dart';
import '../../../services/smtp_service.dart';
import '../../../core/validators/website_validator.dart';

enum DomainMatchStatus { exact, subdomainMatch, mismatch, unknown }

extension DomainMatchStatusExtension on DomainMatchStatus {
  static DomainMatchStatus evaluate(String emailDomain, String webDomain) {
    final cleanEmail = emailDomain.trim().toLowerCase();
    final cleanWeb = webDomain.trim().toLowerCase();

    if (cleanEmail.isEmpty || cleanWeb.isEmpty) return DomainMatchStatus.unknown;
    if (cleanEmail == cleanWeb) return DomainMatchStatus.exact;
    if (cleanEmail.endsWith('.$cleanWeb') || cleanWeb.endsWith('.$cleanEmail')) {
      return DomainMatchStatus.subdomainMatch;
    }
    return DomainMatchStatus.mismatch;
  }
}

class CollegeRegistrationController extends ChangeNotifier {
  final CollegeRegistrationRepository _repository;
  final EmailVerificationService _emailService;
  final PhoneVerificationService _phoneService;
  final RegistrationAuthService _authService;
  final InstitutionLocationService _locationService;
  final DocumentUploadService _uploadService;

  CollegeRegistration? _activeRegistration;

  bool _isLoading = true;
  String? _errorMessage;
  int _currentStep = 0;
  bool _isEditingResubmission = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController emailOtpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController phoneOtpController = TextEditingController();
  final TextEditingController instNameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController locationSearchController = TextEditingController();

  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  final TextEditingController adminPasswordController = TextEditingController();

  GoogleMapController? mapController;
  Set<Marker> mapMarkers = {};
  bool isManuallyEdited = false;

  String? _sentEmailOtp;
  String selectedCountryCode = '+91';
  String detectedDomain = '';

  InstitutionLocation? selectedLocation;
  List<InstitutionSearchResult> searchResults = [];
  bool isLocationLoading = false;
  Timer? _searchDebounce;

  Map<String, double> uploadProgress = {};

  String? nameError;
  String? designationError;
  String? emailError;
  String? phoneError;

  static const List<String> _blockedPersonalDomains = [
    'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com',
    'icloud.com', 'aol.com', 'protonmail.com', 'ymail.com',
    'live.com', 'proton.me'
  ];

  CollegeRegistrationController({
    CollegeRegistrationRepository? repository,
    EmailVerificationService? emailService,
    PhoneVerificationService? phoneService,
    RegistrationAuthService? authService,
    InstitutionLocationService? locationService,
    DocumentUploadService? uploadService,
  })  : _repository = repository ?? FirestoreCollegeRegistrationRepository(),
        _emailService = emailService ?? EmailVerificationService(),
        _phoneService = phoneService ?? PhoneVerificationService(),
        _authService = authService ?? RegistrationAuthService(),
        _locationService = locationService ?? InstitutionLocationService(),
        _uploadService = uploadService ?? DocumentUploadService() {
    _initializeRegistration();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentStep => _currentStep;

  bool get isAnonymousSession => _authService.isAnonymous;

  CollegeRegistration? get activeRegistration => _activeRegistration;

  bool get isSubmitted =>
      !_isEditingResubmission &&
          (_activeRegistration?.status.isUnderAdministrativeReview == true ||
              _activeRegistration?.status.isTerminal == true);

  bool get isEmailVerified =>
      (_activeRegistration?.representative.emailVerified ?? false) ||
          (_activeRegistration?.verification.email.verified ?? false);

  bool get isPhoneVerified =>
      (_activeRegistration?.representative.phoneVerified ?? false) ||
          (_activeRegistration?.verification.phone.verified ?? false);

  List<RegistrationDocument> get uploadedDocuments => _activeRegistration?.documents ?? [];

  List<InstitutionWebsite> get additionalWebsites =>
      _activeRegistration?.institution.websites.where((w) => !w.isPrimary).toList() ?? [];

  set currentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  set errorMessage(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // ===========================================================================
  // WEBSITE MANAGEMENT METHODS
  // ===========================================================================

  void syncPrimaryWebsiteUrl(String url) {
    if (_activeRegistration == null) return;
    final cleaned = url.trim();
    final existingWebsites = List<InstitutionWebsite>.from(_activeRegistration!.institution.websites);

    final primaryIndex = existingWebsites.indexWhere((w) => w.isPrimary);
    if (primaryIndex != -1) {
      existingWebsites[primaryIndex] = existingWebsites[primaryIndex].copyWith(
        url: cleaned,
        updatedAt: DateTime.now(),
      );
    } else {
      existingWebsites.insert(
        0,
        InstitutionWebsite(
          id: 'website_primary',
          type: 'Official College/University Website',
          url: cleaned,
          description: 'Main institutional website',
          isPrimary: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    _activeRegistration = _activeRegistration!.copyWith(
      institution: _activeRegistration!.institution.copyWith(
        website: cleaned,
        websites: existingWebsites,
      ),
    );
    notifyListeners();
  }

  Future<void> addWebsite({
    required String type,
    required String url,
    String? description,
  }) async {
    if (_activeRegistration == null) return;

    final newWeb = InstitutionWebsite(
      id: 'web_${DateTime.now().millisecondsSinceEpoch}',
      type: type.trim(),
      url: url.trim(),
      description: description?.trim(),
      isPrimary: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final existingWebsites = List<InstitutionWebsite>.from(_activeRegistration!.institution.websites);
    existingWebsites.add(newWeb);

    _activeRegistration = _activeRegistration!.copyWith(
      institution: _activeRegistration!.institution.copyWith(
        websites: existingWebsites,
      ),
    );
    notifyListeners();
    await _repository.saveStep(_activeRegistration!);
  }

  Future<void> removeWebsite(String id) async {
    if (_activeRegistration == null) return;

    final existingWebsites = List<InstitutionWebsite>.from(_activeRegistration!.institution.websites);
    existingWebsites.removeWhere((w) => w.id == id && !w.isPrimary);

    _activeRegistration = _activeRegistration!.copyWith(
      institution: _activeRegistration!.institution.copyWith(
        websites: existingWebsites,
      ),
    );
    notifyListeners();
    await _repository.saveStep(_activeRegistration!);
  }

  // ===========================================================================
  // INITIALIZATION & RESUME LOGIC
  // ===========================================================================

  Future<void> _initializeRegistration() async {
    _setLoading(true);
    try {
      await _authService.ensureActiveSession();
      CollegeRegistration? existingDraft = await _repository.getActiveRegistration();

      if (existingDraft != null) {
        _activeRegistration = existingDraft;
        if (!existingDraft.status.isTerminal && !isSubmitted) {
          _restoreStateFromModel(existingDraft);
        }
      } else {
        _activeRegistration = await _repository.createDraft();
        _currentStep = 0;
      }
    } catch (e) {
      // 🌟 Temporarily unmask the error to see EXACTLY what Firebase is blocking
      _errorMessage = 'Dev Error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActiveRegistration() async {
    await _initializeRegistration();
  }

  void _restoreStateFromModel(CollegeRegistration draft) {
    _currentStep = draft.currentStep > 0 ? draft.currentStep - 1 : 0;

    nameController.text = draft.representative.fullName;
    designationController.text = draft.representative.designation;
    emailController.text = draft.representative.email;

    final phone = draft.representative.phoneNumber.trim();
    if (phone.startsWith('+91 ')) {
      selectedCountryCode = '+91';
      phoneController.text = phone.substring(4).trim();
    } else if (phone.startsWith('+1 ')) {
      selectedCountryCode = '+1';
      phoneController.text = phone.substring(3).trim();
    } else if (phone.startsWith('+44 ')) {
      selectedCountryCode = '+44';
      phoneController.text = phone.substring(4).trim();
    } else {
      phoneController.text = phone;
    }

    instNameController.text = draft.institution.name;
    websiteController.text = draft.institution.website;
    detectedDomain = draft.institution.officialDomain;

    if (draft.location.placeId.isNotEmpty) {
      selectedLocation = draft.location;
      addressLine1Controller.text = draft.location.addressLine1;
      addressLine2Controller.text = draft.location.addressLine2 ?? '';
      cityController.text = draft.location.city;
      districtController.text = draft.location.district;
      stateController.text = draft.location.state;
      postalCodeController.text = draft.location.postalCode;
      isManuallyEdited = draft.location.isConfirmed;

      _updateMapCameraAndMarker(
        draft.location.latitude ?? 13.0827,
        draft.location.longitude ?? 80.2707,
        draft.location.formattedAddress,
      );
    }
  }

  void unlockForEditing() {
    if (_activeRegistration?.status == RegistrationStatus.additionalInformationRequired) {
      _isEditingResubmission = true;
      _currentStep = 0;
      _errorMessage = 'Updates requested by reviewer: ${_activeRegistration?.review.requestedChanges ?? 'Please review and update your information.'}';
      notifyListeners();
    }
  }

  Future<bool> saveAndJump(int targetStep) async {
    if (_activeRegistration == null) return false;

    final success = await nextStep();

    if (success) {
      _currentStep = targetStep;

      RegistrationStatus updatedStatus = _activeRegistration!.status;
      if (targetStep == 6) updatedStatus = RegistrationStatus.readyForReview;
      else if (targetStep == 1 && !isEmailVerified) updatedStatus = RegistrationStatus.emailVerificationPending;
      else if (targetStep == 2 && !isPhoneVerified) updatedStatus = RegistrationStatus.phoneVerificationPending;

      _activeRegistration = _activeRegistration!.copyWith(
        currentStep: _currentStep + 1,
        status: updatedStatus,
      );

      await _repository.saveStep(_activeRegistration!);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ===========================================================================
  // STATE MACHINE & TRANSITIONS
  // ===========================================================================

  Future<bool> nextStep() async {
    if (_activeRegistration == null) return false;

    _errorMessage = null;
    bool canProceed = false;

    switch (_currentStep) {
      case 0:
        canProceed = _validateRepresentative();
        if (canProceed) {
          RegistrationStatus targetStatus = RegistrationStatus.emailVerificationPending;
          if (isEmailVerified && isPhoneVerified) {
            targetStatus = _activeRegistration!.status;
          } else if (isEmailVerified) {
            targetStatus = RegistrationStatus.phoneVerificationPending;
          }

          _activeRegistration = _activeRegistration!.copyWith(
            status: targetStatus,
            representative: Representative(
              fullName: nameController.text.trim(),
              designation: designationController.text.trim(),
              email: emailController.text.trim().toLowerCase(),
              phoneNumber: '${selectedCountryCode.trim()} ${phoneController.text.trim()}',
              emailVerified: isEmailVerified,
              phoneVerified: isPhoneVerified,
            ),
          );
        }
        break;
      case 1:
        canProceed = isEmailVerified;
        if (!canProceed) _errorMessage = 'Please verify your official email address to proceed.';
        if (canProceed) {
          _activeRegistration = _activeRegistration!.copyWith(
            status: isPhoneVerified ? _activeRegistration!.status : RegistrationStatus.phoneVerificationPending,
          );
        }
        break;
      case 2:
        canProceed = isPhoneVerified;
        if (!canProceed) _errorMessage = 'Please verify your office phone number to proceed.';
        if (canProceed) {
          _activeRegistration = _activeRegistration!.copyWith(
            status: _activeRegistration!.institution.name.isNotEmpty
                ? _activeRegistration!.status
                : RegistrationStatus.institutionDetails,
          );
        }
        break;
      case 3:
        canProceed = await _validateInstitutionDomain();
        if (canProceed) {
          final repEmailDomain = emailController.text.trim().split('@').last.toLowerCase();
          final matchStatus = DomainMatchStatusExtension.evaluate(repEmailDomain, detectedDomain);

          final institutionName = instNameController.text.trim();
          final primaryWebsiteUrl = websiteController.text.trim();

          String sName = _activeRegistration!.institution.shortName;
          if (sName.isEmpty || _activeRegistration!.institution.name != institutionName) {
            sName = _generateShortName(institutionName);
          }

          var currentWebsites = List<InstitutionWebsite>.from(_activeRegistration!.institution.websites);
          if (currentWebsites.isEmpty) {
            currentWebsites.add(
              InstitutionWebsite(
                id: 'website_primary',
                type: 'Official College/University Website',
                url: primaryWebsiteUrl,
                description: 'Main institutional website',
                isPrimary: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          } else {
            final idx = currentWebsites.indexWhere((w) => w.isPrimary);
            if (idx != -1) {
              currentWebsites[idx] = currentWebsites[idx].copyWith(
                url: primaryWebsiteUrl,
                updatedAt: DateTime.now(),
              );
            }
          }

          _activeRegistration = _activeRegistration!.copyWith(
            status: _activeRegistration!.location.placeId.isNotEmpty
                ? _activeRegistration!.status
                : RegistrationStatus.locationPending,
            institution: InstitutionDetails(
              name: institutionName,
              shortName: sName,
              website: primaryWebsiteUrl,
              officialDomain: detectedDomain,
              websites: currentWebsites,
            ),
            review: _activeRegistration!.review.copyWith(
              reviewerNotes: matchStatus == DomainMatchStatus.mismatch
                  ? 'Note: Representative email domain does not match the official institution website domain.'
                  : _activeRegistration!.review.reviewerNotes,
            ),
          );
        }
        break;
      case 4:
        canProceed = validateLocationForm();
        if (canProceed && selectedLocation != null) {
          final updatedAddress1 = addressLine1Controller.text.trim();
          final updatedAddress2 = addressLine2Controller.text.trim();
          final updatedCity = cityController.text.trim();
          final updatedDistrict = districtController.text.trim();
          final updatedState = stateController.text.trim();
          final updatedPostal = postalCodeController.text.trim();

          final formatted = '$updatedAddress1, ${updatedAddress2.isNotEmpty ? '$updatedAddress2, ' : ''}$updatedCity, $updatedState $updatedPostal';

          selectedLocation = InstitutionLocation(
            placeId: selectedLocation!.placeId,
            latitude: selectedLocation!.latitude ?? 13.0827,
            longitude: selectedLocation!.longitude ?? 80.2707,
            formattedAddress: formatted,
            addressLine1: updatedAddress1,
            addressLine2: updatedAddress2.isNotEmpty ? updatedAddress2 : null,
            city: updatedCity,
            district: updatedDistrict,
            state: updatedState,
            country: selectedLocation!.country,
            postalCode: updatedPostal,
            isConfirmed: true,
          );

          _activeRegistration = _activeRegistration!.copyWith(
            status: _activeRegistration!.documents.isNotEmpty
                ? _activeRegistration!.status
                : RegistrationStatus.documentsPending,
            location: selectedLocation,
          );
        }
        break;
      case 5:
        final hasAuth = uploadedDocuments.any((d) => d.type == 'Proof of Authority');
        final hasRecog = uploadedDocuments.any((d) => d.type == 'Institution Recognition');
        canProceed = hasAuth && hasRecog;
        if (!canProceed) _errorMessage = 'Please upload all required authorization documents before proceeding.';
        if (canProceed) {
          final isChangesRequired = _activeRegistration!.status == RegistrationStatus.additionalInformationRequired;
          _activeRegistration = _activeRegistration!.copyWith(
            status: isChangesRequired
                ? RegistrationStatus.additionalInformationRequired
                : RegistrationStatus.readyForReview,
          );
        }
        break;
      default:
        canProceed = false;
    }

    if (canProceed) {
      _setLoading(true);
      try {
        _currentStep++;
        _activeRegistration = _activeRegistration!.copyWith(currentStep: _currentStep + 1);
        await _repository.saveStep(_activeRegistration!);
        return true;
      } catch (e) {
        _errorMessage = 'We could not save your progress right now. Please check your connection and try again.';
        _currentStep--;
        return false;
      } finally {
        _setLoading(false);
      }
    }

    notifyListeners();
    return false;
  }

  // ===========================================================================
  // LOCATION SEARCH & MAP INTEGRATION
  // ===========================================================================

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (selectedLocation != null) {
      _updateMapCameraAndMarker(
        selectedLocation!.latitude ?? 13.0827,
        selectedLocation!.longitude ?? 80.2707,
        selectedLocation!.formattedAddress,
      );
    }
  }

  void _updateMapCameraAndMarker(double lat, double lng, String title) {
    final pos = LatLng(lat, lng);
    mapMarkers = {
      Marker(
        markerId: const MarkerId('institution_marker'),
        position: pos,
        infoWindow: InfoWindow(title: title),
      ),
    };
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 15.0));
    notifyListeners();
  }

  void onLocationSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 600), () async {
      isLocationLoading = true;
      notifyListeners();
      try {
        searchResults = await _locationService.searchInstitutions(query);
      } catch (e) {
        _errorMessage = 'We couldn\'t find any matching locations right now.';
      } finally {
        isLocationLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> selectSearchResult(InstitutionSearchResult result) async {
    isLocationLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final details = await _locationService.getPlaceDetails(result.placeId);
      if (details != null) {
        selectedLocation = details;
        addressLine1Controller.text = details.addressLine1;
        addressLine2Controller.text = details.addressLine2 ?? '';
        cityController.text = details.city;
        districtController.text = details.district;
        stateController.text = details.state;
        postalCodeController.text = details.postalCode;
        isManuallyEdited = false;

        _updateMapCameraAndMarker(
          details.latitude ?? 13.0827,
          details.longitude ?? 80.2707,
          details.formattedAddress,
        );
        searchResults = [];
        locationSearchController.clear();
      } else {
        _errorMessage = 'We couldn\'t retrieve the details for this location. Please try selecting another spot.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred while loading location details. Please try again.';
    } finally {
      isLocationLoading = false;
      notifyListeners();
    }
  }

  void markAddressAsEdited() {
    isManuallyEdited = true;
    notifyListeners();
  }

  bool validateLocationForm() {
    if (selectedLocation == null) {
      _errorMessage = 'Please search and select your campus location from the list.';
      notifyListeners();
      return false;
    }

    if (addressLine1Controller.text.trim().length < 3) {
      _errorMessage = 'Please enter a valid street or campus address.';
      notifyListeners();
      return false;
    }
    if (cityController.text.trim().length < 2) {
      _errorMessage = 'Please enter a valid city name.';
      notifyListeners();
      return false;
    }
    if (stateController.text.trim().length < 2) {
      _errorMessage = 'Please enter a valid state name.';
      notifyListeners();
      return false;
    }
    final postal = postalCodeController.text.trim();
    if (postal.length < 4 || postal.length > 10) {
      _errorMessage = 'Please enter a valid postal or PIN code.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    return true;
  }

  void clearSelectedLocation() {
    selectedLocation = null;
    locationSearchController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    districtController.clear();
    stateController.clear();
    postalCodeController.clear();
    mapMarkers.clear();
    notifyListeners();
  }

  // ===========================================================================
  // VERIFICATIONS & INVALIDATION
  // ===========================================================================

  void onEmailChanged(String value) {
    if (_activeRegistration != null && isEmailVerified) {
      if (value.trim().toLowerCase() != _activeRegistration!.representative.email.toLowerCase()) {
        _activeRegistration = _activeRegistration!.copyWith(
          representative: _activeRegistration!.representative.copyWith(emailVerified: false),
          verification: _activeRegistration!.verification.copyWith(
            email: const ChannelVerification(verified: false, verifiedAt: null),
          ),
        );
        emailOtpController.clear();
      }
    }
    if (emailError != null) {
      emailError = null;
    }
    notifyListeners();
  }

  void _invalidatePhoneIfChanged() {
    if (_activeRegistration != null && isPhoneVerified) {
      final currentFullPhone = '${selectedCountryCode.trim()} ${phoneController.text.trim()}';
      if (currentFullPhone != _activeRegistration!.representative.phoneNumber) {
        _activeRegistration = _activeRegistration!.copyWith(
          representative: _activeRegistration!.representative.copyWith(phoneVerified: false),
          verification: _activeRegistration!.verification.copyWith(
            phone: const ChannelVerification(verified: false, verifiedAt: null),
          ),
        );
        phoneOtpController.clear();
      }
    }
  }

  void onPhoneChanged(String val) {
    _invalidatePhoneIfChanged();
    if (phoneError != null) {
      phoneError = null;
    }
    notifyListeners();
  }

  void onCountryCodeChanged(String val) {
    selectedCountryCode = val;
    _invalidatePhoneIfChanged();
    notifyListeners();
  }

  Future<bool> sendEmailOtp() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      if (isAnonymousSession) {
        if (adminPasswordController.text.trim().length < 8) {
          _errorMessage = 'Please create a secure password with at least 8 characters.';
          return false;
        }
      }

      final targetEmail = emailController.text.trim().toLowerCase();

      final deliverability = await SmtpService.checkDeliverability(targetEmail);
      if (deliverability.isRejected) {
        _errorMessage = deliverability.message;
        return false;
      }

      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString();

      final success = await SmtpService.sendOtpEmail(
        recipientEmail: targetEmail,
        recipientName: nameController.text.trim(),
        otpCode: otp,
      );

      if (success) {
        _sentEmailOtp = otp;
        return true;
      } else {
        _errorMessage = 'We couldn\'t send the verification email right now. Please check your email address and try again.';
        return false;
      }

    } catch (e) {
      _errorMessage = 'We encountered an issue sending your verification code. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyEmailOtp() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final enteredOtp = emailOtpController.text.trim();

      if (_sentEmailOtp != null && enteredOtp == _sentEmailOtp) {
        if (isAnonymousSession) {
          await _authService.linkEmailPasswordCredential(
            email: emailController.text.trim(),
            password: adminPasswordController.text,
          );
        }

        _activeRegistration = _activeRegistration!.copyWith(
          status: RegistrationStatus.emailVerified,
          representative: _activeRegistration!.representative.copyWith(
            emailVerified: true,
            email: emailController.text.trim().toLowerCase(),
          ),
          verification: _activeRegistration!.verification.copyWith(
            email: ChannelVerification(verified: true, verifiedAt: DateTime.now()),
          ),
        );
        await _repository.saveStep(_activeRegistration!);
        _sentEmailOtp = null;
        return true;
      } else {
        _errorMessage = 'The verification code entered is incorrect. Please check and try again.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'We couldn\'t verify your code right now. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPhoneOtp() async {
    _setLoading(true);
    _errorMessage = null;
    final cleanNumber = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final e164Phone = '${selectedCountryCode.trim()}$cleanNumber';

    await _phoneService.sendSmsOtp(
      phoneNumber: e164Phone,
      onCodeSent: (String verId) => _setLoading(false),
      onError: (String error) {
        _errorMessage = 'We couldn\'t send the text message right now. Please check your phone number and try again.';
        _setLoading(false);
      },
    );
  }

  Future<bool> verifyPhoneOtp() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final cleanNumber = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final e164Phone = '${selectedCountryCode.trim()}$cleanNumber';

      final success = await _phoneService.verifyOtp(
        e164Phone,
        phoneOtpController.text.trim(),
      );
      if (success) {
        _activeRegistration = _activeRegistration!.copyWith(
          status: RegistrationStatus.phoneVerified,
          representative: _activeRegistration!.representative.copyWith(phoneVerified: true),
          verification: _activeRegistration!.verification.copyWith(
            phone: ChannelVerification(verified: true, verifiedAt: DateTime.now()),
          ),
        );
        await _repository.saveStep(_activeRegistration!);
      }
      return success;
    } catch (e) {
      _errorMessage = 'The verification code entered is incorrect. Please check and try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // DOCUMENT UPLOADS
  // ===========================================================================

  Future<void> pickAndUploadDocument(String documentType) async {
    _errorMessage = null;
    try {
      final doc = await _uploadService.pickAndUploadDocument(
        requestId: _activeRegistration!.requestId,
        documentType: documentType,
        uid: _activeRegistration!.applicantUid,
        onProgress: (progress) {
          uploadProgress[documentType] = progress;
          notifyListeners();
        },
      );

      if (doc != null) {
        final currentDocs = List<RegistrationDocument>.from(uploadedDocuments);
        final existingIndex = currentDocs.indexWhere((d) => d.type == documentType);
        if (existingIndex != -1) {
          final oldDoc = currentDocs[existingIndex];
          await _uploadService.deleteDocument(oldDoc.storagePath);
          currentDocs.removeAt(existingIndex);
        }

        currentDocs.add(doc);
        _activeRegistration = _activeRegistration!.copyWith(documents: currentDocs);
        await _repository.saveStep(_activeRegistration!);
      }
    } catch (e) {
      _errorMessage = 'We couldn\'t upload your document. Please ensure the file is under 3MB and try again.';
    } finally {
      uploadProgress.remove(documentType);
      notifyListeners();
    }
  }

  Future<void> removeDocument(int index) async {
    final currentDocs = List<RegistrationDocument>.from(uploadedDocuments);
    if (index >= 0 && index < currentDocs.length) {
      final doc = currentDocs[index];
      currentDocs.removeAt(index);
      _activeRegistration = _activeRegistration!.copyWith(documents: currentDocs);
      notifyListeners();
      try {
        await _uploadService.deleteDocument(doc.storagePath);
        await _repository.saveStep(_activeRegistration!);
      } catch (_) {}
    }
  }

  // ===========================================================================
  // SUBMISSION
  // ===========================================================================

  Future<bool> submitFinalApplication() async {
    if (_activeRegistration == null) return false;

    final canSubmit = _activeRegistration!.status == RegistrationStatus.readyForReview ||
        _activeRegistration!.status == RegistrationStatus.additionalInformationRequired;

    if (!canSubmit) {
      _errorMessage = 'Please complete all required steps before submitting your application.';
      return false;
    }

    _setLoading(true);
    try {
      final isResubmission = _activeRegistration!.status == RegistrationStatus.additionalInformationRequired;
      await _repository.submitRegistration(_activeRegistration!.requestId);

      _isEditingResubmission = false;

      _activeRegistration = _activeRegistration!.copyWith(
        status: isResubmission ? RegistrationStatus.resubmitted : RegistrationStatus.submitted,
        currentStep: 8,
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'We could not submit your application right now. Please try again later.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // ROBUST VALIDATION
  // ===========================================================================

  bool _validateRepresentative() {
    bool isValid = true;

    final name = nameController.text.trim();
    if (name.isEmpty || name.length < 2) {
      nameError = 'Please enter your full name.';
      isValid = false;
    } else {
      nameError = null;
    }

    final designation = designationController.text.trim();
    if (designation.isEmpty || designation.length < 2) {
      designationError = 'Please enter your official designation.';
      isValid = false;
    } else {
      designationError = null;
    }

    final email = emailController.text.trim().toLowerCase();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (email.isEmpty) {
      emailError = 'Official institution email is required.';
      isValid = false;
    } else if (!emailRegex.hasMatch(email)) {
      emailError = 'Please enter a valid email address format.';
      isValid = false;
    } else {
      final domain = email.split('@')[1];
      if (_blockedPersonalDomains.contains(domain)) {
        emailError = 'Personal email addresses are not allowed. Please enter your official college email.';
        isValid = false;
      } else {
        emailError = null;
      }
    }

    final cleanPhone = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (selectedCountryCode == '+91') {
      final phoneRegex = RegExp(r'^[5-9][0-9]{9}$');
      if (!phoneRegex.hasMatch(cleanPhone)) {
        phoneError = 'Please enter a valid 10-digit mobile number.';
        isValid = false;
      } else {
        phoneError = null;
      }
    } else {
      if (cleanPhone.length < 7 || cleanPhone.length > 15) {
        phoneError = 'Please enter a valid phone number.';
        isValid = false;
      } else {
        phoneError = null;
      }
    }

    notifyListeners();
    return isValid;
  }

  Future<bool> _validateInstitutionDomain() async {
    final name = instNameController.text.trim();
    final rawUrl = websiteController.text.trim();

    if (name.length < 3) {
      _errorMessage = 'Please enter the official name of your institution.';
      return false;
    }

    final validation = WebsiteValidator.validate(rawUrl);
    if (!validation.isValid) {
      _errorMessage = 'Please enter a valid official website address.';
      return false;
    }

    final uri = Uri.tryParse(validation.normalizedUrl);
    if (uri == null || uri.host.isEmpty) {
      _errorMessage = 'Please enter a valid website link.';
      return false;
    }

    final extractedDomain = uri.host.replaceFirst(RegExp(r'^www\.'), '').toLowerCase();

    if (_blockedPersonalDomains.contains(extractedDomain)) {
      _errorMessage = 'Personal website domains cannot be used for official institution registration.';
      return false;
    }

    _setLoading(true);
    try {
      final isDuplicate = await _repository.checkDomainExists(extractedDomain, _activeRegistration!.requestId);
      if (isDuplicate) {
        _errorMessage = 'An active or approved registration already exists for this institution domain.';
        return false;
      }
      detectedDomain = extractedDomain;
      return true;
    } catch (e) {
      _errorMessage = 'We couldn\'t verify this institution domain right now. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearNameError() {
    nameError = null;
    notifyListeners();
  }

  void clearDesignationError() {
    designationError = null;
    notifyListeners();
  }

  Future<void> restartRegistration(BuildContext context) async {
    _setLoading(true);
    await _authService.signOut();
    if (context.mounted) {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    designationController.dispose();
    emailController.dispose();
    emailOtpController.dispose();
    phoneController.dispose();
    phoneOtpController.dispose();
    instNameController.dispose();
    websiteController.dispose();
    locationSearchController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    adminPasswordController.dispose();
    mapController?.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  String _generateShortName(String fullName) {
    if (fullName.trim().isEmpty) return '';

    final cleanName = fullName.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    final stopWords = {'of', 'the', 'and', 'for', 'in', 'at', 'a', 'an'};

    List<String> words = cleanName
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty && !stopWords.contains(w.toLowerCase()))
        .toList();

    if (words.isEmpty) {
      return fullName.substring(0, min(3, fullName.length)).toUpperCase();
    }

    if (words.length == 1) {
      return words[0].substring(0, min(3, words[0].length)).toUpperCase();
    }

    return words.take(6).map((w) => w[0].toUpperCase()).join('');
  }
}