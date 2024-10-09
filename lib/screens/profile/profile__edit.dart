import 'package:dip_app_2/components/my_button.dart';
import 'package:dip_app_2/components/my_dropdown.dart';
import 'package:dip_app_2/components/my_textfield.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditPage extends StatefulWidget {
  
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // text controllers
  final TextEditingController _nameController = TextEditingController();

  // initializing variables
  String? selectedYear;
  String? selectedCourse;
  String? selectedCountry;
  String? selectedGender;
  String? selectedHall; 
  String? selectedInterests;
  String? selectedLanguages;
  String? selectedStudentType;

  Future<void> completeProfile(BuildContext context) async {
    // get AuthService
    final authService = AuthService();

    // initiallize user
    User? user = authService.getCurrentUser();

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'year': selectedYear,
        'course': selectedCourse,
        'country': selectedCountry,
        'gender': selectedGender,
        'hall': selectedHall,
        'interests': selectedInterests,
        'languages': selectedLanguages,
        'studentType': selectedStudentType,
        'profileComplete': true,  // Set profile as complete
      }, SetOptions(merge: true));

      // Navigate to HomePage after completing the profile
      Navigator.pushReplacementNamed(context, '/auth_wrapper');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: Center(
        child: ListView(
          children: [
            MyTextField(
              hintText: 'Name',
              obscureText: false, 
              controller: _nameController,
            ),

            MyDropDown(
              hintText: 'Select Year', 
              options: ['Year 1', 'Year 2', 'Year 3', 'Year 4'],
              onChanged: (value) {
                selectedYear = value;
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
                'Mathematics'],
              onChanged: (value) {
                selectedCourse = value;
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
              onChanged: (value) {
                selectedCountry = value;
              },
            ),

            MyDropDown(
              hintText: 'Select Gender', 
              options: ['Male', 'Female'],
              onChanged: (value) {
                selectedGender = value;
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
                'Saraca'],
              onChanged: (value) {
                selectedHall = value;
              },
            ),

            MyDropDown(
              hintText: 'Select Interests', 
              options: [
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
                'Coding',
                'Robotics'],
              onChanged: (value) {
                selectedInterests = value;
              },
            ),

            MyDropDown(
              hintText: 'Select Languages', 
              options: [
                'English', 
                'Chinese',
                'Tamil',
                'Malay',
                'Spanish',
                'French',
                'Japanese',
                'Korean',
                'German'],
              onChanged: (value) {
                selectedLanguages = value;
              },
            ),

            MyDropDown(
              hintText: 'Select Student Type', 
              options: ['International', 'Local', 'Exchange'],
              onChanged: (value) {
                selectedStudentType = value;
              },
            ),


            const SizedBox(height: 20),

            // sign up button 
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
