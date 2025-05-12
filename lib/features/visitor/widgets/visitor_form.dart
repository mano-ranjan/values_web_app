import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitorForm extends StatefulWidget {
  const VisitorForm({super.key});

  @override
  State<VisitorForm> createState() => _VisitorFormState();
}

class _VisitorFormState extends State<VisitorForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitVisitorInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // First try to insert the visitor data
      final response =
          await supabase.from('visitors').insert({
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
          }).select();

      print('Visitor data inserted successfully: $response');

      if (mounted) {
        try {
          // Then try to store the submission status
          await supabase.storage
              .from('visitor_preferences')
              .uploadBinary(
                'visitor_submitted.txt',
                Uint8List.fromList('submitted'.codeUnits),
                fileOptions: const FileOptions(upsert: true),
              );

          print('Visitor submission status stored successfully');

          Navigator.of(context).pop();
        } catch (storageError) {
          print('Error storing visitor submission status: $storageError');
          // Even if storage fails, we still want to close the form since the data was saved
          Navigator.of(context).pop();
        }
      }
    } on PostgrestException catch (e) {
      print('Postgrest error during visitor submission: ${e.message}');
      setState(() {
        _errorMessage = 'Database error: ${e.message}';
      });
    } catch (e) {
      print('Unexpected error during visitor submission: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button from dismissing
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.deepNavy,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Welcome to VALUES Junior College',
                        style: GoogleFonts.poppins(
                          color: AppTheme.surfaceColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Please provide your information to continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppTheme.deepNavy.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_errorMessage != null)
                            InkWell(
                              onTap: () {
                                print(
                                  'the error is sjdhcbsjdhc $_errorMessage',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              labelStyle: GoogleFonts.poppins(
                                color: AppTheme.deepNavy.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppTheme.lavender.withOpacity(0.1),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: GoogleFonts.poppins(
                                color: AppTheme.deepNavy.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppTheme.lavender.withOpacity(0.1),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.poppins(
                                color: AppTheme.deepNavy.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppTheme.lavender.withOpacity(0.1),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number (Optional)',
                              labelStyle: GoogleFonts.poppins(
                                color: AppTheme.deepNavy.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppTheme.lavender.withOpacity(0.1),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitVisitorInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.coral,
                              foregroundColor: AppTheme.surfaceColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Continue to Website',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
