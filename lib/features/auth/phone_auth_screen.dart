import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import '../../main.dart';

class PhoneAuthScreen extends StatefulWidget {
  final ValueChanged<BuildContext> onAuthenticated;

  const PhoneAuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  bool otpRequested = false;
  bool loading = false;
  bool isEmailMode = true;

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> requestOtp() async {
    if (phoneController.text.trim().isEmpty) {
      showMessage(context, 'Enter your phone number.');
      return;
    }

    setState(() => loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      loading = false;
      otpRequested = true;
    });

    showMessage(context, 'Demo mode: use OTP 123456.');
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim() != '123456') {
      showMessage(context, 'Incorrect demo OTP.');
      return;
    }

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);

    if (!mounted) return;

    widget.onAuthenticated(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: AppColors.emerald,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Safe Space',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Born in Kenya. Built for the world.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Your community starts here.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connect, share ideas, discover opportunities '
                  'and build meaningful communities.',
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),

                Wrap(
  spacing: 10,
  children: [
    ChoiceChip(
      label: const Text('Email'),
      selected: isEmailMode,
      onSelected: (_) {
        setState(() => isEmailMode = true);
      },
    ),
    ChoiceChip(
      label: const Text('Phone'),
      selected: !isEmailMode,
      onSelected: (_) {
        setState(() => isEmailMode = false);
      },
    ),
  ],
),

const SizedBox(height: 20),
                
                const SizedBox(height: 10),

if (isEmailMode)
  TextField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.email_outlined),
      labelText: 'Email address',
      hintText: 'you@example.com',
    ),
  )
else
  TextField(
    controller: phoneController,
    keyboardType: TextInputType.phone,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.phone_outlined),
      labelText: 'Phone number',
      hintText: '+254...',
    ),
  ),

const SizedBox(height: 16),
                if (otpRequested) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: 'Demo OTP',
                      hintText: 'Enter 123456',
                      counterText: '',
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: loading
                        ? null
                        : otpRequested
                            ? verifyOtp
                            : requestOtp,
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            otpRequested
                                ? 'Verify and continue'
                                : 'Continue',
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Prototype login — no SMS is sent yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message)),
    );
}

