import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/registration_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../../routing/app_routes.dart';
import '../controllers/college_registration_controller.dart';
import '../../../models/registration_document.dart';
import '../../../models/institution_location.dart';
import '../../../core/validators/website_validator.dart';

class CollegeRegistrationScreen extends StatelessWidget {
  const CollegeRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollegeRegistrationController(),
      child: const _CollegeRegistrationBody(),
    );
  }
}

class _CollegeRegistrationBody extends StatefulWidget {
  const _CollegeRegistrationBody();

  @override
  State<_CollegeRegistrationBody> createState() =>
      _CollegeRegistrationBodyState();
}

class _CollegeRegistrationBodyState extends State<_CollegeRegistrationBody> {
  bool _phoneCodeSent = false;
  bool _emailCodeSent = false;

  // 🌟 NEW: Manages the obscure state for the password field
  bool _obscureAdminPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = Provider.of<CollegeRegistrationController>(context, listen: false);
      if (controller.currentStep > 0 || controller.nameController.text.isNotEmpty) {
        if (controller.isEmailVerified) _emailCodeSent = false;
        if (controller.isPhoneVerified) _phoneCodeSent = false;
        setState(() {});
      }
    });
  }

  static const List<String> _steps = [
    'Representative',
    'Email',
    'Phone',
    'Institution',
    'Location',
    'Documents',
    'Review',
  ];

  static const List<IconData> _stepIcons = [
    Icons.person_outline,
    Icons.email_outlined,
    Icons.phone_outlined,
    Icons.account_balance_outlined,
    Icons.location_on_outlined,
    Icons.description_outlined,
    Icons.check_circle_outline,
  ];

  Future<void> _sendPhoneCode(CollegeRegistrationController controller) async {
    if (_phoneCodeSent) setState(() => _phoneCodeSent = false);
    await controller.sendPhoneOtp();
    if (!mounted) return;

    if (controller.errorMessage == null && controller.phoneError == null) {
      setState(() => _phoneCodeSent = true);
    } else {
      setState(() => _phoneCodeSent = false);
      if (controller.phoneError != null) controller.currentStep = 0;
      controller.phoneOtpController.clear();
    }
  }

  Future<void> _verifyPhoneCode(CollegeRegistrationController controller) async {
    final verified = await controller.verifyPhoneOtp();
    if (!mounted) return;
    if (verified) await controller.nextStep();
  }

  void _showAddWebsiteDialog(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    final typeController = TextEditingController();
    final urlController = TextEditingController();
    final descController = TextEditingController();
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Institutional Website', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dialogError != null) ...[
                  Text(dialogError!, style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Website Type *',
                    hintText: 'e.g. Student Management System, LMS',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Website Address (URL) *',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final typeText = typeController.text.trim();
                final url = urlController.text.trim();

                if (typeText.isEmpty) {
                  setDialogState(() => dialogError = 'Website type is required.');
                  return;
                }
                if (url.isEmpty) {
                  setDialogState(() => dialogError = 'Website address is required.');
                  return;
                }

                final validation = WebsiteValidator.validate(url);
                if (!validation.isValid) {
                  setDialogState(() => dialogError = validation.errorMessage);
                  return;
                }

                await controller.addWebsite(
                  type: typeText,
                  url: validation.normalizedUrl,
                  description: descController.text.trim(),
                );

                if (ctx.mounted) Navigator.of(ctx).pop();
                setState(() {});
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CONTEXTUAL LOADING UI LOGIC
  // ===========================================================================
  Widget _buildLoadingState(int step, bool isDark, {required bool isInitialLoad}) {
    if (isInitialLoad) {
      return _StepLoadingState(
        title: 'Preparing your workspace...',
        subtitle: 'Retrieving registration session securely.',
        icon: Icons.account_balance_rounded,
        isDark: isDark,
      );
    }
    switch (step) {
      case 0:
        return _StepLoadingState(
          title: 'Securing Identity...',
          subtitle: 'Saving official representative details.',
          icon: Icons.admin_panel_settings_rounded,
          isDark: isDark,
        );
      case 1:
        return _StepLoadingState(
          title: 'Authenticating Email...',
          subtitle: 'Communicating with secure mail servers.',
          icon: Icons.mark_email_read_rounded,
          isDark: isDark,
        );
      case 2:
        return _StepLoadingState(
          title: 'Verifying Device...',
          subtitle: 'Processing encrypted SMS gateway handshake.',
          icon: Icons.phonelink_lock_rounded,
          isDark: isDark,
        );
      case 3:
        return _StepLoadingState(
          title: 'Validating Institution...',
          subtitle: 'Checking domain registry and portal credentials.',
          icon: Icons.domain_verification_rounded,
          isDark: isDark,
        );
      case 4:
        return _StepLoadingState(
          title: 'Syncing Coordinates...',
          subtitle: 'Establishing secure geospatial campus boundaries.',
          icon: Icons.satellite_alt_rounded,
          isDark: isDark,
        );
      case 5:
        return _StepLoadingState(
          title: 'Encrypting Documents...',
          subtitle: 'Uploading to isolated secure storage vaults.',
          icon: Icons.enhanced_encryption_rounded,
          isDark: isDark,
        );
      case 6:
        return _StepLoadingState(
          title: 'Finalizing Application...',
          subtitle: 'Submitting to the governance review queue.',
          icon: Icons.send_to_mobile_rounded,
          isDark: isDark,
        );
      default:
        return _StepLoadingState(
          title: 'Processing...',
          subtitle: 'Please wait a moment.',
          icon: Icons.sync_rounded,
          isDark: isDark,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollegeRegistrationController>(
      builder: (context, controller, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0B1220)
              : const Color(0xFFF7F9FC),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 600
                    ? AppSpacing.md
                    : AppSpacing.lg;
                final maxWidth = constraints.maxWidth > 1200
                    ? 1120.0
                    : constraints.maxWidth;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                      ),
                      child: (controller.isLoading && !controller.isSubmitted && controller.nameController.text.isEmpty)
                          ? _buildLoadingState(controller.currentStep, isDark, isInitialLoad: true)
                          : controller.isSubmitted
                          ? _ApplicationTrackingView(controller: controller, isDark: isDark)
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _RegistrationTopBar(
                            isDark: isDark,
                            onBack: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.welcome);
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _RegistrationIntro(isDark: isDark),
                          const SizedBox(height: AppSpacing.xl),
                          _TrackerContent(
                            currentStep: controller.currentStep,
                            steps: _steps,
                            icons: _stepIcons,
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (controller.errorMessage != null) ...[
                            _ErrorBanner(
                              message: controller.errorMessage!,
                              isDark: isDark,
                              onRestart: () => controller.restartRegistration(context),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          if (controller.isLoading)
                            _buildLoadingState(controller.currentStep, isDark, isInitialLoad: false)
                          else ...[
                            _buildStepHeader(context, controller, isDark),
                            const SizedBox(height: AppSpacing.md),
                            _buildContentSurface(context, controller, isDark),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepHeader(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    final titles = [
      'Representative information',
      'Verify official email',
      'Verify office phone',
      'Institution details',
      'Institution location',
      'Authorization documents',
      'Review and submit',
    ];

    final descriptions = [
      'Provide the details of the official representative registering the institution.',
      'Verify that the representative uses an official institution email address.',
      'Verify the official office phone number using a Firebase SMS code.',
      'Tell us about the institution you are registering.',
      'Search for and select the institution location using Google Maps.',
      'Upload documents that establish authorization to register the institution.',
      'Review the submitted information before sending the application.',
    ];

    final index = controller.currentStep.clamp(0, titles.length - 1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titles[index],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                descriptions[index],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : const Color(0xFF667085),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSurface(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    return AppCard(
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 600 ? AppSpacing.md : AppSpacing.lg,
        ),
        child: _buildCurrentStep(context, controller, isDark),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    switch (controller.currentStep) {
      case 0: return _buildRepresentativeStep(context, controller, isDark);
      case 1: return _buildEmailVerificationStep(context, controller, isDark);
      case 2: return _buildPhoneVerificationStep(context, controller, isDark);
      case 3: return _buildInstitutionStep(context, controller, isDark);
      case 4: return _buildLocationStep(context, controller, isDark);
      case 5: return _buildDocumentsStep(context, controller, isDark);
      case 6: return _buildReviewStep(context, controller, isDark);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildRepresentativeStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: controller.nameController,
          label: 'Representative full name',
          hint: 'Enter your full name',
          prefixIcon: const Icon(Icons.person_outline),
          errorText: controller.nameError,
          maxLength: 60,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-\']")),
          ],
          onChanged: (_) {
            controller.clearNameError();
            setState(() {});
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.designationController,
          label: 'Designation',
          hint: 'e.g. Director, Principal, Registrar',
          prefixIcon: const Icon(Icons.badge_outlined),
          errorText: controller.designationError,
          maxLength: 80,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\.\,\&]")),
          ],
          onChanged: (_) {
            controller.clearDesignationError();
            setState(() {});
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.emailController,
          label: 'Official institution email',
          hint: 'name@institution.edu',
          prefixIcon: const Icon(Icons.email_outlined),
          suffixIcon: controller.isEmailVerified
              ? const Icon(Icons.verified_rounded, color: AppColors.success)
              : null,
          errorText: controller.emailError,
          keyboardType: TextInputType.emailAddress,
          maxLength: 100,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r"\s")),
          ],
          onChanged: (value) {
            controller.onEmailChanged(value);
            if (_emailCodeSent) {
              setState(() => _emailCodeSent = false);
            } else {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _PhoneField(
          controller: controller,
          countryCode: controller.selectedCountryCode,
          errorText: controller.phoneError,
          onCountryCodeChanged: (value) {
            controller.onCountryCodeChanged(value);
            if (_phoneCodeSent) {
              setState(() => _phoneCodeSent = false);
            }
          },
          onChanged: (value) {
            controller.onPhoneChanged(value);
            if (_phoneCodeSent) {
              setState(() => _phoneCodeSent = false);
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _NavigationActionBar(
          controller: controller,
          continueLabel: 'Continue to Email Verification',
          continueIcon: Icons.arrow_forward_rounded,
          isLoading: controller.isLoading,
          isDark: isDark,
          onContinue: () async {
            final success = await controller.nextStep();
            if (!mounted) return;
            if (success) {
              setState(() {
                _emailCodeSent = false;
                _phoneCodeSent = false;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmailVerificationStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VerificationHeader(
          icon: Icons.mark_email_read_outlined,
          title: 'Verify your official email',
          description: 'We will send a 6-digit secure verification code to the official institution email address provided.',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.lg),
        _IdentityCard(
          icon: Icons.email_outlined,
          label: 'Official email address',
          value: controller.emailController.text.trim(),
          isDark: isDark,
          trailing: controller.isEmailVerified ? const _EmailVerificationStatusBadge(verified: true) : null,
        ),
        if (!controller.isEmailVerified) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                controller.currentStep = 0;
                controller.errorMessage = 'Please enter your correct official institutional email address.';
                setState(() => _emailCodeSent = false);
              },
              icon: const Icon(Icons.edit_note_rounded, size: 16),
              label: const Text(
                'Wrong or missing email? Edit in Step 1',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],

        // 🌟 NEW: Renders the Password field if the user is an anonymous draft user
        if (controller.isAnonymousSession && !controller.isEmailVerified) ...[
          const SizedBox(height: AppSpacing.md),
          _InfoBox(
            icon: Icons.security_rounded,
            text: 'Create a password to secure your administrator account. You will use this along with your email to log into the dashboard.',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: controller.adminPasswordController,
            label: 'Administrator Password *',
            hint: 'Minimum 8 characters',
            obscureText: _obscureAdminPassword,
            enabled: !_emailCodeSent, // Prevents editing while waiting for OTP
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureAdminPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              onPressed: () => setState(() => _obscureAdminPassword = !_obscureAdminPassword),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        if (controller.isEmailVerified)
          _VerifiedState(
            title: 'Email verified',
            message: 'The official institution email has been successfully verified.',
            isDark: isDark,
          )
        else if (!_emailCodeSent)
          AppButton(
            label: 'Send Email Code',
            icon: Icons.send_outlined,
            isLoading: controller.isLoading,
            onPressed: () async {
              final success = await controller.sendEmailOtp();
              if (mounted && success) {
                setState(() => _emailCodeSent = true);
              }
            },
          )
        else
          _OtpVerificationWidget(
            title: 'Enter Email Verification Code',
            description: 'Enter the 6-digit code sent to ${controller.emailController.text.trim()}.',
            controller: controller.emailOtpController,
            isDark: isDark,
            isLoading: controller.isLoading,
            resendSeconds: 60,
            onVerify: () async {
              final verified = await controller.verifyEmailOtp();
              if (mounted && verified) await controller.nextStep();
            },
            onResend: () async {
              controller.emailOtpController.clear();
              return await controller.sendEmailOtp();
            },
          ),

        const SizedBox(height: AppSpacing.lg),
        _NavigationActionBar(
          controller: controller,
          continueLabel: 'Proceed to Phone Verification',
          continueIcon: Icons.arrow_forward_rounded,
          isLoading: controller.isLoading,
          isDark: isDark,
          onContinue: controller.isEmailVerified ? () async {
            await controller.nextStep();
          } : null,
        ),
      ],
    );
  }

  Widget _buildPhoneVerificationStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    final formattedPhone = '${controller.selectedCountryCode} ${controller.phoneController.text.trim()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VerificationHeader(
          icon: Icons.phone_android_outlined,
          title: 'Verify your office phone',
          description: 'We will send a one-time password by SMS to the official office phone number provided above.',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.lg),
        _IdentityCard(
          icon: Icons.phone_outlined,
          label: 'Official office phone',
          value: formattedPhone,
          isDark: isDark,
          trailing: controller.isPhoneVerified ? const _PhoneVerificationStatusBadge(verified: true) : null,
        ),
        if (!controller.isPhoneVerified) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                controller.currentStep = 0;
                controller.errorMessage = 'Please enter your correct office phone number.';
                setState(() => _phoneCodeSent = false);
              },
              icon: const Icon(Icons.edit_note_rounded, size: 16),
              label: const Text('Wrong phone number? Edit in Step 1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _InfoBox(
          icon: Icons.sms_outlined,
          text: 'A 6-digit verification code will be sent by Firebase SMS to this official office number. Enter the code below after it arrives.',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (controller.isPhoneVerified)
          _VerifiedState(
            title: 'Phone verified',
            message: 'The official office phone number has been successfully verified.',
            isDark: isDark,
          )
        else if (!_phoneCodeSent)
          AppButton(
            label: 'Send SMS Code',
            icon: Icons.sms_outlined,
            isLoading: controller.isLoading,
            onPressed: () => _sendPhoneCode(controller),
          )
        else
          _OtpVerificationWidget(
            title: 'Enter SMS verification code',
            description: 'Enter the 6-digit code sent to $formattedPhone.',
            controller: controller.phoneOtpController,
            isDark: isDark,
            isLoading: controller.isLoading,
            resendSeconds: 60,
            onVerify: () => _verifyPhoneCode(controller),
            onResend: () async {
              controller.phoneOtpController.clear();
              await controller.sendPhoneOtp();
              if (!mounted) return false;
              return controller.errorMessage == null;
            },
          ),
        const SizedBox(height: AppSpacing.lg),
        if (!controller.isPhoneVerified)
          _SecurityNote(
            icon: Icons.lock_outline,
            text: 'The SMS verification code confirms that you have access to the official office phone number.',
            isDark: isDark,
          ),
        const SizedBox(height: AppSpacing.lg),
        _NavigationActionBar(
          controller: controller,
          continueLabel: 'Proceed to Institution Details',
          continueIcon: Icons.arrow_forward_rounded,
          isLoading: controller.isLoading,
          isDark: isDark,
          onContinue: controller.isPhoneVerified ? () async {
            await controller.nextStep();
          } : null,
        ),
      ],
    );
  }

  Widget _buildInstitutionStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Section A: Institution Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: controller.instNameController,
          label: 'Official Institution Name *',
          hint: 'e.g. Example Institute of Technology',
          prefixIcon: const Icon(Icons.account_balance_outlined),
          maxLength: 120,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\.\,\&\(\)]"))],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.websiteController,
          label: 'Official Institution Website *',
          hint: 'https://www.example.edu',
          prefixIcon: const Icon(Icons.language_outlined),
          keyboardType: TextInputType.url,
          maxLength: 200,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
          onChanged: (val) {
            controller.syncPrimaryWebsiteUrl(val);
            setState(() {});
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Section B: Institutional Websites & Digital Platforms',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _showAddWebsiteDialog(context, controller, isDark),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Website'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Manage your portals including LMS, SMS, admissions, library, and research platforms.', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade600)),
        const SizedBox(height: AppSpacing.md),
        ...controller.additionalWebsites.map((web) {
          if (web == null) return const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        web.type,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                        onPressed: () => setState(() => controller.removeWebsite(web.id)),
                      ),
                    ],
                  ),
                  Text(web.url, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                  if (web.description != null && web.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(web.description!, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600)),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        _NavigationActionBar(
          controller: controller,
          continueLabel: 'Continue to Location',
          continueIcon: Icons.arrow_forward_rounded,
          isLoading: controller.isLoading,
          isDark: isDark,
          onContinue: () async {
            if (controller.instNameController.text.trim().isEmpty || controller.websiteController.text.trim().isEmpty) {
              controller.errorMessage = 'Official institution name and website are required.';
              setState(() {});
              return;
            }
            await controller.nextStep();
          },
        ),
      ],
    );
  }

  Widget _buildLocationStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    final double currentLat = controller.selectedLocation?.latitude ?? 13.0827;
    final double currentLng = controller.selectedLocation?.longitude ?? 80.2707;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Institution Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Search for your college or university to identify its exact geographical location on the map.',
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF667085)),
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: controller.locationSearchController,
          hint: 'Search your college or university...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.isLocationLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onChanged: controller.onLocationSearchChanged,
        ),

        if (controller.searchResults.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final result = controller.searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  title: Text(result.institutionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(result.secondaryAddress, style: const TextStyle(fontSize: 12)),
                  onTap: () async {
                    await controller.selectSearchResult(result);
                  },
                );
              },
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              onMapCreated: controller.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLat, currentLng),
                zoom: 14.0,
              ),
              markers: controller.mapMarkers.isNotEmpty
                  ? controller.mapMarkers
                  : {
                Marker(
                  markerId: const MarkerId('default_marker'),
                  position: LatLng(currentLat, currentLng),
                  infoWindow: const InfoWindow(title: 'Select your institution above'),
                ),
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
        ),

        if (controller.selectedLocation != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Review Institution Address', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),

          AppTextField(
            controller: controller.addressLine1Controller,
            label: 'Address Line 1 *',
            onChanged: (_) => controller.markAddressAsEdited(),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: controller.addressLine2Controller,
            label: 'Address Line 2 (Optional)',
            onChanged: (_) => controller.markAddressAsEdited(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.cityController,
                  label: 'City / Town *',
                  onChanged: (_) => controller.markAddressAsEdited(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: controller.districtController,
                  label: 'District',
                  onChanged: (_) => controller.markAddressAsEdited(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.stateController,
                  label: 'State *',
                  onChanged: (_) => controller.markAddressAsEdited(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: controller.postalCodeController,
                  label: 'Postal / PIN Code *',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => controller.markAddressAsEdited(),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.lg),
        _NavigationActionBar(
          controller: controller,
          continueLabel: 'Continue to Documents',
          continueIcon: Icons.arrow_forward_rounded,
          isLoading: controller.isLoading,
          isDark: isDark,
          onContinue: () async {
            if (controller.validateLocationForm()) {
              await controller.nextStep();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDocumentsStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    final hasAuthDoc = controller.uploadedDocuments.any((d) => d.type == 'Proof of Authority');
    final hasRecogDoc = controller.uploadedDocuments.any((d) => d.type == 'Institution Recognition');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoBox(
          icon: Icons.shield_rounded,
          text: 'Documents are securely stored and reviewed only by authorized Universtree platform administrators.',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Documents & Authorization', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        AppSpacing.verticalXs,
        Text('Verify Your Institutional Authority', style: TextStyle(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        AppSpacing.verticalMd,
        Text('Upload official documents that prove you are authorized to represent the institution. PDF, JPG, PNG files up to 3 MB are accepted.', style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
        const Divider(height: 32),

        _DocumentUploadSection(
          controller: controller,
          sectionNumber: 1,
          title: 'Proof of Authority',
          isRequired: true,
          description: 'Appointment / Authorization Letter',
          documentType: 'Proof of Authority',
          isDark: isDark,
        ),
        const Divider(height: 32),

        _DocumentUploadSection(
          controller: controller,
          sectionNumber: 2,
          title: 'Institution Recognition',
          isRequired: true,
          description: 'Accreditation / Recognition / Government Approval',
          documentType: 'Institution Recognition',
          isDark: isDark,
        ),
        const Divider(height: 32),

        _DocumentUploadSection(
          controller: controller,
          sectionNumber: 3,
          title: 'Additional Supporting Document',
          isRequired: false,
          description: 'Optional additional evidence',
          documentType: 'Additional Supporting Document',
          isDark: isDark,
        ),

        AppSpacing.verticalLg,

        _NavigationActionBar(
          controller: controller,
          continueLabel: 'Continue to Review',
          continueIcon: Icons.checklist_rtl_rounded,
          isLoading: controller.isLoading,
          isDark: isDark,
          onContinue: () async {
            if (hasAuthDoc && hasRecogDoc) {
              await controller.nextStep();
            } else {
              controller.errorMessage = 'Please upload all required documents before continuing.';
            }
          },
        ),
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context, CollegeRegistrationController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoBox(
          icon: Icons.fact_check_outlined,
          text: 'Review all information carefully. Once submitted, the application will enter the Super Administrator verification workflow.',
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.lg),

        _ReviewSection(
          title: 'Representative',
          icon: Icons.person_outline,
          isDark: isDark,
          onEdit: () => controller.currentStep = 0,
          children: [
            _ReviewRow(label: 'Name', value: controller.nameController.text),
            _ReviewRow(label: 'Designation', value: controller.designationController.text),
            _ReviewRow(label: 'Email', value: controller.emailController.text, verified: controller.isEmailVerified),
            _ReviewRow(label: 'Phone', value: '${controller.selectedCountryCode} ${controller.phoneController.text}', verified: controller.isPhoneVerified),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewSection(
          title: 'Institution',
          icon: Icons.account_balance_outlined,
          isDark: isDark,
          onEdit: () => controller.currentStep = 3,
          children: [
            _ReviewRow(label: 'Name', value: controller.instNameController.text),
            _ReviewRow(label: 'Website', value: controller.websiteController.text),
            _ReviewRow(label: 'Additional Portals', value: '${controller.additionalWebsites.length} portal(s) registered'),
            _ReviewRow(label: 'Secure Domain', value: '@${controller.detectedDomain}', verified: true),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewSection(
          title: 'Location',
          icon: Icons.location_on_outlined,
          isDark: isDark,
          onEdit: () => controller.currentStep = 4,
          children: [
            _ReviewRow(label: 'Address', value: controller.selectedLocation?.formattedAddress ?? 'Not selected'),
            _ReviewRow(label: 'City', value: controller.selectedLocation?.city ?? 'Not available'),
            _ReviewRow(label: 'State', value: controller.selectedLocation?.state ?? 'Not available'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewSection(
          title: 'Documents',
          icon: Icons.description_outlined,
          isDark: isDark,
          onEdit: () => controller.currentStep = 5,
          children: [
            _ReviewRow(label: 'Uploaded', value: '${controller.uploadedDocuments.length} document(s)'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _NavigationActionBar(
          controller: controller,
          continueLabel: 'Submit Official Application',
          continueIcon: Icons.send_rounded,
          isLoading: controller.isLoading,
          isDark: isDark,
          onContinue: () async {
            await controller.submitFinalApplication();
          },
        ),
      ],
    );
  }
}

// =============================================================================
// PHASE 13: APPLICATION TRACKING VIEW
// =============================================================================
class _ApplicationTrackingView extends StatelessWidget {
  final CollegeRegistrationController controller;
  final bool isDark;

  const _ApplicationTrackingView({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final status = controller.activeRegistration?.status ?? RegistrationStatus.submitted;
    final institutionName = controller.activeRegistration?.institution.name ?? controller.instNameController.text.trim();
    final submittedDate = controller.activeRegistration?.review.submittedAt ?? controller.activeRegistration?.createdAt ?? DateTime.now();
    final formattedDate = DateFormat('MMMM d, yyyy • h:mm a').format(submittedDate);

    final isApproved = status == RegistrationStatus.approved;
    final isRejected = status == RegistrationStatus.rejected;
    final isChangesRequired = status == RegistrationStatus.additionalInformationRequired;

    final primaryColor = isApproved
        ? AppColors.success
        : isRejected
        ? AppColors.error
        : isChangesRequired
        ? Colors.purple
        : AppColors.primary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [primaryColor.withValues(alpha: 0.25), const Color(0xFF1E293B)]
                        : [primaryColor.withValues(alpha: 0.12), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        isApproved
                            ? Icons.verified_rounded
                            : isRejected
                            ? Icons.cancel_rounded
                            : isChangesRequired
                            ? Icons.edit_note_rounded
                            : Icons.mark_email_read_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isApproved
                          ? 'Institution Approved!'
                          : isRejected
                          ? 'Application Not Approved'
                          : isChangesRequired
                          ? 'Action Required'
                          : 'Application Submitted!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      institutionName.isNotEmpty ? institutionName : 'Your Institution Workspace',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isApproved
                          ? 'Your college workspace has been successfully provisioned on Universtree.'
                          : isChangesRequired
                          ? 'The platform review team has requested minor corrections to your application.'
                          : 'Your application is securely recorded and pending review by the Universtree Governance Team.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Submitted on $formattedDate',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Workflow',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _TimelineStep(
                      title: 'Application Received',
                      subtitle: 'All documents, location, and details successfully logged.',
                      isCompleted: true,
                      isActive: false,
                      isDark: isDark,
                      date: submittedDate,
                    ),
                    _TimelineDivider(isCompleted: status.value != 'submitted' && status.value != 'resubmitted'),
                    _TimelineStep(
                      title: 'Administrative Review',
                      subtitle: 'Governance team verifies institutional credentials & ownership.',
                      isCompleted: isApproved || isRejected,
                      isActive: status.value == 'submitted' || status.value == 'under_review' || status.value == 'resubmitted' || isChangesRequired,
                      isDark: isDark,
                      icon: isChangesRequired ? Icons.edit_note_rounded : Icons.rate_review_rounded,
                      color: isChangesRequired ? Colors.purple : AppColors.primary,
                    ),
                    _TimelineDivider(isCompleted: isApproved || isRejected, color: isRejected ? AppColors.error : AppColors.primary),
                    _TimelineStep(
                      title: isRejected ? 'Application Rejected' : 'Workspace Activation',
                      subtitle: isRejected
                          ? 'Review the notification email for next steps.'
                          : 'Instant provisioning of college portal & admin privileges.',
                      isCompleted: isApproved || isRejected,
                      isActive: isApproved || isRejected,
                      isDark: isDark,
                      icon: isRejected ? Icons.cancel_rounded : Icons.domain_verification_rounded,
                      color: isRejected ? AppColors.error : AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (isApproved) ...[
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Go to Admin Dashboard',
                    icon: Icons.dashboard_rounded,
                    variant: AppButtonVariant.primary,
                    height: 52,
                    onPressed: () => context.go(AppRoutes.collegeAdminDashboard),
                  ),
                ),
              ] else if (isChangesRequired) ...[
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Edit & Resubmit Application',
                    icon: Icons.edit_note_rounded,
                    variant: AppButtonVariant.primary,
                    height: 52,
                    onPressed: () {
                      controller.unlockForEditing();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Refresh Status',
                    icon: Icons.refresh_rounded,
                    variant: AppButtonVariant.outline,
                    height: 52,
                    isLoading: controller.isLoading,
                    onPressed: () async {
                      await controller.loadActiveRegistration();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status refreshed successfully.'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Refresh Status',
                    icon: Icons.refresh_rounded,
                    variant: AppButtonVariant.primary,
                    height: 52,
                    isLoading: controller.isLoading,
                    onPressed: () async {
                      await controller.loadActiveRegistration();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status refreshed successfully.'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final DateTime? date;
  final bool isCompleted;
  final bool isActive;
  final bool isDark;
  final IconData icon;
  final Color color;

  const _TimelineStep({
    required this.title,
    this.subtitle,
    this.date,
    required this.isCompleted,
    required this.isActive,
    required this.isDark,
    this.icon = Icons.check_circle_rounded,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isCompleted || isActive ? color : (isDark ? Colors.white24 : Colors.grey.shade300);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isCompleted ? displayColor.withValues(alpha: 0.15) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isActive && !isCompleted ? displayColor : Colors.transparent, width: 2),
          ),
          child: Icon(isCompleted ? icon : Icons.circle, size: isCompleted ? 20 : 12, color: displayColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive || isCompleted
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? Colors.white54 : Colors.grey),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ],
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(date!),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMutedLight),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  final bool isCompleted;
  final Color color;

  const _TimelineDivider({required this.isCompleted, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(left: 17, top: 8, bottom: 8),
      alignment: Alignment.centerLeft,
      child: Container(
        width: 2,
        color: isCompleted ? color : Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }
}

// =============================================================================
// UI COMPONENTS
// =============================================================================
class _RegistrationTopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBack;

  const _RegistrationTopBar({
    required this.isDark,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Institution Registration',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF172033),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegistrationIntro extends StatelessWidget {
  final bool isDark;

  const _RegistrationIntro({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 400
        ? 26.0
        : width < 600
        ? 30.0
        : 36.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Register your institution',
            maxLines: 1,
            softWrap: false,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white
                  : const Color(0xFF172033),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760,
          ),
          child: Text(
            'Complete the verification and accreditation process to create your institution workspace on Universtree.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: isDark
                  ? Colors.white70
                  : const Color(0xFF667085),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackerContent extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final List<IconData> icons;
  final bool isDark;

  const _TrackerContent({
    required this.currentStep,
    required this.steps,
    required this.icons,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.md : AppSpacing.lg,
            vertical: compact ? AppSpacing.md : AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: compact
              ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            child: Row(
              children: List.generate(
                steps.length,
                    (index) => _TrackerStep(
                  label: steps[index],
                  icon: icons[index],
                  active: index == currentStep,
                  completed: index < currentStep,
                  isDark: isDark,
                ),
              ),
            ),
          )
              : Row(
            children: List.generate(
              steps.length,
                  (index) {
                final step = _TrackerStep(
                  label: steps[index],
                  icon: icons[index],
                  active: index == currentStep,
                  completed: index < currentStep,
                  isDark: isDark,
                );

                if (index == steps.length - 1) {
                  return step;
                }

                return Expanded(
                  child: Row(
                    children: [
                      step,
                      Expanded(
                        child: _TrackerLine(
                          active: index < currentStep,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TrackerStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool completed;
  final bool isDark;

  const _TrackerStep({
    required this.label,
    required this.icon,
    required this.active,
    required this.completed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = active || completed;

    return SizedBox(
      width: 82,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProgressBadge(
            icon: completed ? Icons.check : icon,
            active: highlighted,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight:
              active ? FontWeight.w700 : FontWeight.w500,
              color: highlighted
                  ? (isDark
                  ? Colors.white
                  : const Color(0xFF172033))
                  : (isDark
                  ? Colors.white54
                  : const Color(0xFF98A2B3)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackerLine extends StatelessWidget {
  final bool active;
  final bool isDark;

  const _TrackerLine({
    required this.active,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(
        left: 4,
        right: 4,
        bottom: 24,
      ),
      color: active
          ? AppColors.primary
          : (isDark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFFE5E7EB)),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDark;

  const _ProgressBadge({
    required this.icon,
    required this.active,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.primary
            : (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF2F4F7)),
      ),
      child: Icon(
        icon,
        size: 17,
        color: active
            ? Colors.white
            : (isDark
            ? Colors.white54
            : const Color(0xFF98A2B3)),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback? onRestart;

  const _ErrorBanner({
    required this.message,
    required this.isDark,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    const baseColor = AppColors.warning;
    final isSessionExpired = message.contains('Security session expired');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? baseColor.withValues(alpha: 0.12)
            : baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: baseColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isDark
                        ? baseColor
                        : const Color(0xFFB45309),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (isSessionExpired && onRestart != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: baseColor,
                foregroundColor: Colors.white,
              ),
              onPressed: onRestart,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Restart Registration'),
            )
          ]
        ],
      ),
    );
  }
}

// =============================================================================
// CONTEXTUAL LOADING UI LOGIC
// =============================================================================
class _StepLoadingState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;

  const _StepLoadingState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Icon(icon, color: AppColors.primary, size: 24),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _VerificationHeader({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.primary.withValues(alpha: 0.10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: isDark
                      ? Colors.white70
                      : const Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Widget? trailing;

  const _IdentityCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? Colors.white54
                        : const Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF172033),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoBox({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.withValues(alpha: 0.08)
            : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: isDark
                    ? Colors.blue.shade100
                    : const Color(0xFF24527A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpVerificationWidget extends StatefulWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final bool isDark;
  final bool isLoading;
  final int resendSeconds;
  final Future<void> Function() onVerify;
  final Future<bool> Function() onResend;

  const _OtpVerificationWidget({
    required this.title,
    required this.description,
    required this.controller,
    required this.isDark,
    required this.isLoading,
    required this.resendSeconds,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<_OtpVerificationWidget> createState() =>
      _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState
    extends State<_OtpVerificationWidget> {
  Timer? _timer;
  int _secondsRemaining = 60;
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.resendSeconds;
    widget.controller.addListener(_onOtpChanged);
    _otpFocusNode.addListener(_onOtpChanged);
    _startTimer();
  }

  @override
  void didUpdateWidget(
      covariant _OtpVerificationWidget oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onOtpChanged);
      widget.controller.addListener(_onOtpChanged);
    }
    if (oldWidget.resendSeconds != widget.resendSeconds) {
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_onOtpChanged);
    _otpFocusNode.removeListener(_onOtpChanged);
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _focusAndShowKeyboard() {
    FocusScope.of(context).requestFocus(_otpFocusNode);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  void _onOtpChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_secondsRemaining <= 1) {
          timer.cancel();
          setState(() {
            _secondsRemaining = 0;
          });
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  void _restartTimer() {
    if (!mounted) return;
    setState(() {
      _secondsRemaining = widget.resendSeconds;
    });
    _startTimer();
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || widget.isLoading) {
      return;
    }
    widget.controller.clear();
    final success = await widget.onResend();
    if (!mounted) return;

    if (success) {
      _restartTimer();
      _otpFocusNode.requestFocus();
    }
  }

  String _digitAt(int index) {
    final value = widget.controller.text;
    if (index >= value.length) {
      return '';
    }
    return value[index];
  }

  @override
  Widget build(BuildContext context) {
    final otp = widget.controller.text;
    final canVerify =
        otp.length == 6 && !widget.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: widget.isDark
                ? Colors.white
                : const Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.4,
            color: widget.isDark
                ? Colors.white70
                : const Color(0xFF667085),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _otpFocusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [
                    AutofillHints.oneTimeCode,
                  ],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) {
                    if (canVerify) {
                      widget.onVerify();
                    }
                  },
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _focusAndShowKeyboard,
              child: Row(
                children: List.generate(
                  6,
                      (index) {
                    final digit = _digitAt(index);
                    final isFocused = _otpFocusNode.hasFocus;
                    final isCurrent = isFocused &&
                        (index == otp.length || (index == 5 && otp.length == 6));

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _focusAndShowKeyboard,
                        child: Container(
                          height: 58,
                          margin: EdgeInsets.only(
                            right: index == 5 ? 0 : 8,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              width: isCurrent ? 2 : 1,
                              color: isCurrent
                                  ? AppColors.primary
                                  : (widget.isDark
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : const Color(0xFFD0D5DD)),
                            ),
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.white,
                            boxShadow: isCurrent
                                ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.20),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                          child: Text(
                            digit,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF172033),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Verify Code',
          icon: Icons.verified_outlined,
          isLoading: widget.isLoading,
          onPressed: canVerify ? widget.onVerify : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: _secondsRemaining > 0
              ? Text(
            'Resend code in ${_secondsRemaining}s',
            style:
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.isDark
                  ? Colors.white54
                  : const Color(0xFF667085),
              fontWeight: FontWeight.w500,
            ),
          )
              : TextButton.icon(
            onPressed:
            widget.isLoading ? null : _handleResend,
            icon: const Icon(Icons.refresh),
            label: const Text('Resend code'),
          ),
        ),
      ],
    );
  }
}

class _VerifiedState extends StatelessWidget {
  final String title;
  final String message;
  final bool isDark;

  const _VerifiedState({
    required this.title,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green.withValues(alpha: 0.08)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.green.shade200
                        : Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: isDark
                        ? Colors.green.shade100
                        : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _SecurityNote({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? Colors.white54
              : const Color(0xFF667085),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.45,
              color: isDark
                  ? Colors.white54
                  : const Color(0xFF667085),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final CollegeRegistrationController controller;
  final String countryCode;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String> onCountryCodeChanged;
  final ValueChanged<String> onChanged;

  const _PhoneField({
    required this.controller,
    required this.countryCode,
    required this.errorText,
    this.enabled = true,
    required this.onCountryCodeChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Official office phone',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText != null
                      ? AppColors.warning
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: countryCode,
                  dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                  items: const [
                    DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                    DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                    DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                  ],
                  onChanged: enabled ? (val) {
                    if (val != null) onCountryCodeChanged(val);
                  } : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: controller.phoneController,
                hint: '9876543210',
                keyboardType: TextInputType.phone,
                errorText: errorText,
                enabled: enabled,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmailVerificationStatusBadge extends StatelessWidget {
  final bool verified;

  const _EmailVerificationStatusBadge({
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    if (!verified) {
      return const SizedBox.shrink();
    }
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified,
          color: Colors.green,
          size: 19,
        ),
        SizedBox(width: 4),
        Text(
          'Verified',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PhoneVerificationStatusBadge extends StatelessWidget {
  final bool verified;

  const _PhoneVerificationStatusBadge({
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    if (!verified) {
      return const SizedBox.shrink();
    }
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified,
          color: Colors.green,
          size: 19,
        ),
        SizedBox(width: 4),
        Text(
          'Verified',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LocationSearchResults extends StatelessWidget {
  final CollegeRegistrationController controller;
  final bool isDark;

  const _LocationSearchResults({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: controller.searchResults.map((result) {
          return ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
            ),
            title: Text(
              result.institutionName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.secondaryAddress.isNotEmpty
                  ? result.secondaryAddress
                  : (result.location?.formattedAddress ?? ''),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              controller.selectSearchResult(result);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _SelectedLocationCard extends StatelessWidget {
  final InstitutionLocation location;
  final bool isDark;

  const _SelectedLocationCard({
    required this.location,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CollegeRegistrationController>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green.withValues(alpha: 0.07)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Extracted Google Location Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.clearSelectedLocation,
                child: const Text('Change Location', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.error, size: 36),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Text(
                            location.addressLine1.isNotEmpty ? location.addressLine1 : 'Institution Marker',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.white.withValues(alpha: 0.8),
                    child: const Text('Google Maps', style: TextStyle(fontSize: 9, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),

          const Divider(height: 24),
          _LocationDetailRow(label: 'City / Locality', value: location.city),
          _LocationDetailRow(label: 'State / Province', value: location.state),
          _LocationDetailRow(label: 'Country', value: location.country),
          _LocationDetailRow(label: 'Postal Code / PIN', value: location.postalCode),
          _LocationDetailRow(label: 'Full Formatted Address', value: location.formattedAddress),
          _LocationDetailRow(
            label: 'Geocoded Coordinates',
            value: '${location.latitude?.toStringAsFixed(6)}, ${location.longitude?.toStringAsFixed(6)}',
          ),
        ],
      ),
    );
  }
}

class _LocationDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _LocationDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not available' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentUploadSection extends StatelessWidget {
  final CollegeRegistrationController controller;
  final int sectionNumber;
  final String title;
  final bool isRequired;
  final String description;
  final String documentType;
  final bool isDark;

  const _DocumentUploadSection({
    required this.controller,
    required this.sectionNumber,
    required this.title,
    required this.isRequired,
    required this.description,
    required this.documentType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final existingDocIndex = controller.uploadedDocuments.indexWhere((d) => d.type == documentType);
    final hasDocument = existingDocIndex != -1;
    final doc = hasDocument ? controller.uploadedDocuments[existingDocIndex] : null;
    final progress = controller.uploadProgress[documentType];
    final isUploading = progress != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$sectionNumber. $title',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 8),
            if (isRequired)
              const Text('*', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            if (isRequired)
              Text(
                'Required',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              )
            else
              Text(
                'Optional',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
          ],
        ),
        AppSpacing.verticalSm,
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        AppSpacing.verticalMd,

        if (isUploading)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Uploading to Secure Storage...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          )
        else if (hasDocument && doc != null)
          _UploadedDocumentCard(
            document: doc,
            isDark: isDark,
            onReplace: () {
              controller.removeDocument(existingDocIndex);
              controller.pickAndUploadDocument(documentType);
            },
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isLoading ? null : () => controller.pickAndUploadDocument(documentType),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Upload Document', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }
}

class _UploadedDocumentCard extends StatelessWidget {
  final RegistrationDocument document;
  final VoidCallback onReplace;
  final bool isDark;

  const _UploadedDocumentCard({
    required this.document,
    required this.onReplace,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = document.originalFileName;
    final sizeKb = (document.sizeBytes / 1024).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 2),
            child: Text(
              '$sizeKb KB • Uploaded successfully',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 28),
              AppButton(
                label: 'Replace',
                variant: AppButtonVariant.outline,
                height: 32,
                icon: Icons.refresh_rounded,
                onPressed: onReplace,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final VoidCallback? onEdit;
  final List<Widget> children;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.isDark,
    this.onEdit,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primary,
                  ),
                )
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool verified;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.verified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style:
              Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Not provided' : value,
                    style:
                    Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (verified)
                  const Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 18,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationActionBar extends StatelessWidget {
  final CollegeRegistrationController controller;
  final String continueLabel;
  final IconData continueIcon;
  final VoidCallback? onContinue;
  final bool isLoading;
  final bool isDark;

  const _NavigationActionBar({
    required this.controller,
    this.continueLabel = 'Continue',
    this.continueIcon = Icons.arrow_forward_rounded,
    this.onContinue,
    this.isLoading = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final showBack = controller.currentStep > 0;
    final showContinue = onContinue != null;

    final bool hasCompletedForm = controller.uploadedDocuments.isNotEmpty;

    int? smartDestination;
    String smartLabel = '';
    IconData smartIcon = Icons.fact_check_outlined;

    if (hasCompletedForm && controller.currentStep < 6) {
      if (!controller.isEmailVerified && controller.currentStep != 1) {
        smartDestination = 1;
        smartLabel = 'Save & Verify Email';
        smartIcon = Icons.mark_email_unread_outlined;
      } else if (controller.isEmailVerified && !controller.isPhoneVerified && controller.currentStep != 2) {
        smartDestination = 2;
        smartLabel = 'Save & Verify Phone';
        smartIcon = Icons.sms_failed_outlined;
      } else if (controller.isEmailVerified && controller.isPhoneVerified) {
        smartDestination = 6;
        smartLabel = 'Save & Return to Review';
        smartIcon = Icons.fact_check_outlined;
      }
    }

    final backButton = SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : () => controller.previousStep(),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text(
          'Back to Previous Step',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.16) : AppColors.borderLight,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (smartDestination != null) ...[
          AppButton(
            label: smartLabel,
            icon: smartIcon,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
            isLoading: isLoading,
            onPressed: () async {
              if (controller.currentStep == 3 && (controller.instNameController.text.trim().isEmpty || controller.websiteController.text.trim().isEmpty)) {
                controller.errorMessage = 'Institution Name and Website are required.';
                return;
              }
              // 🌟 FIX: Check location fields before jumping if currently on Step 4
              if (controller.currentStep == 4) {
                if (!controller.validateLocationForm()) return;
              }

              await controller.saveAndJump(smartDestination!);
            },
          ),
          const SizedBox(height: 12),
        ],
        if (showContinue)
          AppButton(
            label: continueLabel,
            icon: continueIcon,
            isFullWidth: true,
            isLoading: isLoading,
            onPressed: onContinue,
          ),
        if (showContinue && showBack) const SizedBox(height: 12),
        if (showBack) backButton,
      ],
    );
  }
}