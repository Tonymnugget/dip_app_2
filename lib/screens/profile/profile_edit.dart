import 'package:dip_app_2/components/my_biotext.dart';
import 'package:dip_app_2/components/my_button_2.dart';
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

  // var to store name
  String? name;

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
          name = userData['name'];
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Complete Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : Center(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                children: [
                  // profile card
                  Center(
                    child: Container(
                      width: 350,
                      height: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.secondary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
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
                          const SizedBox(height: 8),

                          // Name
                          Text(
                            '$name',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  MyBioField(
                    hintText: "Edit Bio",
                    obscureText: false,
                    controller: _bioController,
                  ),

                  MyDropDown(
                    titlename: 'Gender:',
                    hintText: 'Select Gender',
                    initialValue: selectedGender,
                    options: ['Male', 'Female'],
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),

                  // Using MyDropDown for Course
                  MyDropDown(
                    titlename: 'Field of Study:',
                    hintText: 'Select Course',
                    initialValue: selectedCourse,
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
                    onChanged: (value) {
                      setState(() {
                        selectedCourse = value!;
                      });
                    },
                  ),

                  // Using MyDropDown for Year
                  MyDropDown(
                    titlename: 'Academic Year:',
                    hintText: 'Select Year',
                    initialValue: selectedYear,
                    options: ['Year 1', 'Year 2', 'Year 3', 'Year 4'],
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),

                  // Using MyDropDown for Hall
                  MyDropDown(
                    titlename: 'Accomodation:',
                    hintText: 'Select Hall',
                    initialValue: selectedHall,
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
                      'Saraca',
                      'Off Campus'
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedHall = value!;
                      });
                    },
                  ),

                  // Using MyDropDown for Student Type
                  MyDropDown(
                    titlename: 'Enrolment Type:',
                    hintText: 'Select Student Type',
                    initialValue: selectedStudentType,
                    options: ['Local', 'International', 'Exchange'],
                    onChanged: (value) {
                      setState(() {
                        selectedStudentType = value!;
                      });
                    },
                  ),

                  // Using MyDropDown for Country
                  MyDropDown(
                    titlename: 'Home Country:',
                    hintText: 'Select Country',
                    initialValue: selectedCountry,
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
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value!;
                      });
                    },
                  ),

                  // Multi-select for Languages using MyMultiSelect
                  MyMultiSelect(
                    titlename: 'Language Spoken:',
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
                    titlename: 'Interests:',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: MyButton2(
                      color: Color.fromARGB(255, 124, 227, 144),
                      text: "Complete profile",
                      onTap: () => completeProfile(context),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
