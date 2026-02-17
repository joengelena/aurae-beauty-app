import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/logic/profile_provider.dart';
import 'package:motorix_app/presentation/widgets/common/select_single_image.dart';
import 'package:motorix_app/utils/feedback_helpers.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  bool isFormValid = false;
  bool hasChanges = false;
  List<String> locationOptions = [];
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadLocationOptions();

    // Initialize controllers with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      final user = profileProvider.currentUser;

      if (user != null) {
        firstNameController.text = user.firstName;
        lastNameController.text = user.lastName;
        phoneNumberController.text = user.phoneNumber;
        selectedLocation = user.location;

        // Add listeners after initializing values
        firstNameController.addListener(_validateForm);
        lastNameController.addListener(_validateForm);
        phoneNumberController.addListener(_validateForm);
      }

      // Clear any previous update state
      profileProvider.clearUpdateState();
    });
  }

  Future<void> _loadLocationOptions() async {
    try {
      final attributes = await ListingsServices().getListingAttributes();
      final locationAttribute = attributes.firstWhere(
        (attr) => attr.name == 'location',
        orElse: () => ListingAttribute(name: 'location', attributeValues: []),
      );
      setState(() {
        locationOptions = locationAttribute.attributeValues;
      });
    } catch (e) {
      debugPrint('⚠️ Failed to load location options: $e');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.currentUser;

    if (user == null) return;

    final valid =
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        selectedLocation != null;

    // Check if any values changed (including photo)
    final changed =
        firstNameController.text != user.firstName ||
        lastNameController.text != user.lastName ||
        phoneNumberController.text != user.phoneNumber ||
        selectedLocation != user.location ||
        profileProvider.isPhotoChanged;

    if (valid != isFormValid || changed != hasChanges) {
      setState(() {
        isFormValid = valid;
        hasChanges = changed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.currentUser;

    if (user == null) {
      return Center(child: Text('Unable to load profile data'));
    }

    // Show success message and navigate back
    if (profileProvider.updateSuccess &&
        profileProvider.updateMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FeedbackHelpers.showSuccessSnackBar(
            context,
            profileProvider.updateMessage,
          );
          profileProvider.clearUpdateState();
          context.go('/profile');
        }
      });
    }

    return Center(
      child: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  Center(
                    child: Text(
                      'Edit Profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),

                  if (profileProvider.updateErrorMessage.isNotEmpty &&
                      !profileProvider.isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        profileProvider.updateErrorMessage,
                        style: TextStyle(color: themeRed, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SelectSingleImage(
                    imageBytes: profileProvider.profilePhotoBytes,
                    imageUrl: user.profilePhotoUrl,
                    onImageSelected: (bytes, mimeType) {
                      profileProvider.setProfilePhoto(bytes, mimeType);
                      _validateForm();
                    },
                    onImageDeleted: () {
                      profileProvider.removeProfilePhoto();
                      _validateForm();
                    },
                    aspectRatio: 1.0,
                  ),

                  TextFormField(
                    controller: firstNameController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),

                  TextFormField(
                    controller: lastNameController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),

                  TextFormField(
                    controller: phoneNumberController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),

                  DropdownButtonFormField<String>(
                    initialValue: selectedLocation,
                    decoration: InputDecoration(labelText: 'Location'),
                    items:
                        locationOptions.map((location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                        _validateForm();
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  FilledButton(
                    onPressed:
                        profileProvider.isLoading || !isFormValid || !hasChanges
                            ? null
                            : () {
                              if (_formKey.currentState!.validate() &&
                                  selectedLocation != null) {
                                profileProvider.updateUserProfile(
                                  firstNameController.text.trim(),
                                  lastNameController.text.trim(),
                                  phoneNumberController.text.trim(),
                                  selectedLocation!,
                                );
                              }
                            },
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor:
                          (isFormValid && hasChanges)
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                    ),
                    child:
                        profileProvider.isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text('Save Changes'),
                  ),

                  OutlinedButton(
                    onPressed:
                        profileProvider.isLoading
                            ? null
                            : () {
                              context.go('/profile');
                            },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Cancel'),
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
