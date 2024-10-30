import 'package:dip_app_2/components/my_button_2.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/matching/filter_results.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:dip_app_2/components/my_dropdown.dart'; // Import your custom dropdown
import 'package:dip_app_2/components/my_multiselect.dart'; // Import your multi-select widget

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  FirestoreService firestoreService = FirestoreService();
  List<Map<String, dynamic>> filteredUsers = [];

  // User-selected filters
  String selectedGender = 'N/A';
  String selectedCourse = 'N/A';
  String selectedYear = 'N/A';
  String selectedHall = 'N/A';
  String selectedStudentType = 'N/A';
  String selectedCountry = 'N/A';

  // Multi-selection for languages and interests
  List<String> selectedLanguages = [];
  List<String> selectedInterests = [];

  // Available options for languages and interests
  final List<String> languages = [
    'N/A',
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
    'N/A',
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

  // Function to filter users
  void filterUsers() async {
    List<Map<String, dynamic>> users = await firestoreService.getFilteredUsers(
      gender: selectedGender != 'N/A' ? selectedGender : null,
      course: selectedCourse != 'N/A' ? selectedCourse : null,
      year: selectedYear != 'N/A' ? selectedYear : null,
      hall: selectedHall != 'N/A' ? selectedHall : null,
      studentType: selectedStudentType != 'N/A' ? selectedStudentType : null,
      country: selectedCountry != 'N/A' ? selectedCountry : null,
      selectedLanguages:
          selectedLanguages.isNotEmpty && !selectedLanguages.contains('N/A')
              ? selectedLanguages
              : null, // Ignore if empty or contains only 'N/A'
      selectedInterests:
          selectedInterests.isNotEmpty && !selectedInterests.contains('N/A')
              ? selectedInterests
              : null, // Ignore if empty or contains only 'N/A'
    );

    // Navigate to FilterResultsPage with filtered users
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterResultsPage(filteredUsers: users),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Select Filters',
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
      bottomNavigationBar: MyNavigationBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Using MyDropDown for Gender
              MyDropDown(
                titlename: 'Gender:',
                hintText: 'Select Gender',
                options: ['N/A', 'Male', 'Female'],
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
                options: [
                  'N/A',
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
                options: ['N/A', 'Year 1', 'Year 2', 'Year 3', 'Year 4'],
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
                options: [
                  'N/A',
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
                options: ['N/A', 'Local', 'International', 'Exchange'],
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
                options: [
                  'N/A',
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

              const SizedBox(height: 10),

              // Filter button
              Center(
                child: MyButton2(
                  color: Color.fromARGB(255, 137, 201, 220),
                  onTap: filterUsers,
                  text: "Filter Users",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
