import 'package:dip_app_2/components/my_biotext.dart';
import 'package:dip_app_2/components/my_button.dart';
import 'package:dip_app_2/components/my_dropdown.dart';
import 'package:dip_app_2/components/my_multiselect.dart';
import 'package:dip_app_2/components/user_image_picker.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  //text controllers
  final TextEditingController _bioController = TextEditingController();

  // initializing strings
  String? selectedYear;
  String? selectedCourse;
  String? selectedCountry;
  String? selectedGender;
  String? selectedHall;
  String? selectedStudentType;

  // file
  File? _selectedImage;

  // for existing image URL
  String? _existingImageUrl;

  // Multi-selection for languages and interests
  List<String> selectedLanguages = [];
  List<String> selectedInterests = [];

  // Available options for languages and interests
  final List<String> languages = [
    'English',
    'Chinese',
    'Tamil',
    'Malay',
    'Spanish',
    'French',
    'Japanese',
    'Korean',
    'German'
  ];

  final List<String> interests = [
    'Coding',
    'Traveling',
    'Chemistry',
    'Photography',
    'Piano',
    'Swimming',
    'Cycling',
    'Finance',
    'Literature',
    'Ecology',
    'Volunteering',
    'Investing',
    'Cooking',
    'Guitar',
    'Reading',
    'Running',
    'Yoga',
    'Soccer',
    'Tennis',
    'Basketball',
    'Painting',
    'Chess',
    'Hiking',
    'Construction',
    'Gaming',
    'Robotics'
  ];

  bool isLoading = true; // Added loading flag

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // load existing profile data when page initializes
  }

  Future<void> _loadUserProfile() async {
    final authService = AuthService();
    User? user = authService.getCurrentUser();

    if (user != null) {
      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Update the fields with existing data
        setState(() {
          selectedYear = userData['year'];
          selectedCourse = userData['course'];
          selectedCountry = userData['country'];
          selectedGender = userData['gender'];
          selectedHall = userData['hall'];
          selectedStudentType = userData['studentType'];
          selectedLanguages = List<String>.from(userData['languages'] ?? []);
          selectedInterests = List<String>.from(userData['interests'] ?? []);
          _existingImageUrl = userData['imageUrl'];

          isLoading = false; // Data is loaded, stop loading
        });
      }
    }
  }

  Future<void> completeProfile(BuildContext context) async {
    // get AuthService
    final authService = AuthService();

    // initiallize user
    User? user = authService.getCurrentUser();

    if (user != null) {
      String? imageUrl;

      if (_existingImageUrl != null) {
        imageUrl = _existingImageUrl;
      }

      // upload profile image if selected
      if (_selectedImage != null) {
        final storageref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.uid}.jpg');
        // upload the file
        await storageref.putFile(_selectedImage!);
        imageUrl = await storageref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'year': selectedYear,
        'course': selectedCourse,
        'country': selectedCountry,
        'gender': selectedGender,
        'hall': selectedHall,
        'interests': selectedInterests,
        'languages': selectedLanguages,
        'studentType': selectedStudentType,
        'bio': _bioController.text,
        'profileComplete': true,
        'imageUrl': imageUrl,
      }, SetOptions(merge: true));

      // Navigate to HomePage after completing the profile
      Navigator.pushReplacementNamed(context, '/auth_wrapper');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : Center(
              child: ListView(
                children: [
                  UserImagePicker(
                    onPickImage: (pickedImage) {
                      if (pickedImage != null) {
                        setState(() {
                          _selectedImage = pickedImage;
                        });
                      }
                    },
                    exisitingImageUrl: _existingImageUrl,
                  ),

                  MyBioField(
                    hintText: "Edit Bio",
                    obscureText: false,
                    controller: _bioController,
                  ),

                  MyDropDown(
                    hintText: 'Select Year',
                    options: ['Year 1', 'Year 2', 'Year 3', 'Year 4'],
                    initialValue: selectedYear,
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                      });
                    },
                  ),

                  MyDropDown(
                    hintText: 'Select Course',
                    options: [
                      'Electrical Engineering',
                      'Data Science',
                      'Economics',
                      'Information Systems',
                      'Finance',
                      'Architecture',
                      'Computer Science',
                      'Humanities',
                      'Biological Sciences',
                      'Social Work',
                      'Biomedical Engineering',
                      'Business',
                      'Mechanical Engineering',
                      'Psychology',
                      'Chemical Engineering',
                      'Aerospace Engineering',
                      'Environmental Science',
                      'Civil Engineering',
                      'Mathematics'
                    ],
                    initialValue: selectedCourse,
                    onChanged: (value) {
                      setState(() {
                        selectedCourse = value;
                      });
                    },
                  ),

                  MyDropDown(
                    hintText: 'Select Country',
                    options: [
                      'Singapore',
                      'Malaysia',
                      'India',
                      'Vietnam',
                      'Mexico',
                      'France',
                      'Australia',
                      'Japan',
                      'United States',
                      'Sweden',
                      'Canada',
                      'United Kingdom',
                      'China',
                      'Indonesia',
                      'South Korea',
                      'Spain',
                      'Germany',
                      'Thailand',
                      'Italy',
                      'Brazil',
                      'New Zealand'
                    ],
                    initialValue: selectedCountry,
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value;
                      });
                    },
                  ),

                  MyDropDown(
                    hintText: 'Select Gender',
                    options: ['Male', 'Female'],
                    initialValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),

                  MyDropDown(
                    hintText: 'Select Hall',
                    options: [
                      'Hall 1',
                      'Hall 2',
                      'Hall 3',
                      'Hall 4',
                      'Hall 5',
                      'Hall 6',
                      'Hall 7',
                      'Hall 8',
                      'Hall 9',
                      'Hall 10',
                      'Hall 11',
                      'Hall 12',
                      'Hall 13',
                      'Hall 14',
                      'Hall 15',
                      'Hall 16',
                      'Maple Residency',
                      'Tanjong',
                      'Pioneer',
                      'Tamarind',
                      'Cresent',
                      'Saraca'
                    ],
                    initialValue: selectedHall,
                    onChanged: (value) {
                      setState(() {
                        selectedHall = value;
                      });
                    },
                  ),

                  MyDropDown(
                    hintText: 'Select Student Type',
                    options: ['International', 'Local', 'Exchange'],
                    initialValue: selectedStudentType,
                    onChanged: (value) {
                      setState(() {
                        selectedStudentType = value;
                      });
                    },
                  ),

                  // Multi-select for Languages using MyMultiSelect
                  MyMultiSelect(
                    hintText: 'Select Languages',
                    options: languages,
                    selectedValues: selectedLanguages,
                    onSelectionChanged: (selectedValues) {
                      setState(() {
                        selectedLanguages = selectedValues;
                      });
                    },
                  ),

                  // Multi-select for Interests using MyMultiSelect
                  MyMultiSelect(
                    hintText: 'Select Interests',
                    options: interests,
                    selectedValues: selectedInterests,
                    onSelectionChanged: (selectedValues) {
                      setState(() {
                        selectedInterests = selectedValues;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // submit the new values to firestore
                  MyButton(
                    text: "Complete profile",
                    onTap: () => completeProfile(context),
                  ),
                ],
              ),
            ),
    );
  }
}
