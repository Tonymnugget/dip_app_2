import 'package:dip_app_2/screens/matching/filter_results.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {

  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  FirebaseService firebaseService = FirebaseService();
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
    'German'];
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
    'Robotics'];

  void filterUsers() async {
  List<Map<String, dynamic>> users = await firebaseService.getFilteredUsers(
    gender: selectedGender != 'N/A' ? selectedGender : null,
    course: selectedCourse != 'N/A' ? selectedCourse : null,
    year: selectedYear != 'N/A' ? selectedYear : null,
    hall: selectedHall != 'N/A' ? selectedHall : null,
    studentType: selectedStudentType != 'N/A' ? selectedStudentType : null,
    country: selectedCountry != 'N/A' ? selectedCountry : null,
    selectedLanguages: selectedLanguages.isNotEmpty && !selectedLanguages.contains('N/A') 
        ? selectedLanguages 
        : null, // Ignore if empty or contains only 'N/A'
    selectedInterests: selectedInterests.isNotEmpty && !selectedInterests.contains('N/A') 
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
      appBar: AppBar(title: const Text('Select Filters')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Filter for Gender
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Gender:'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: selectedGender,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue!;
                  });
                },
                items: <String>['N/A', 'Male', 'Female'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Filter for Course
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Course:'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: selectedCourse,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCourse = newValue!;
                  });
                },
                items: <String>[
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
                  'Mathematics'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Filter for Year
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Year:'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: selectedYear,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYear = newValue!;
                  });
                },
                items: <String>['N/A', 'Year 1', 'Year 2', 'Year 3', 'Year 4'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Filter for Hall
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Hall:'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: selectedHall,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedHall = newValue!;
                  });
                },
                items: <String>[
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
                  'Saraca'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Filter for Student Type
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Student Type:'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: selectedStudentType,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStudentType = newValue!;
                  });
                },
                items: <String>['N/A', 'Local', 'International', 'Exchange'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Multi-select for Languages
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Languages:'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: Text("Select Languages"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: languages.map((language) {
                                return CheckboxListTile(
                                  title: Text(language),
                                  value: selectedLanguages.contains(language),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedLanguages.add(language);
                                      } else {
                                        selectedLanguages.remove(language);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            actions: [
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(selectedLanguages.isNotEmpty ? selectedLanguages.join(", ") : "Select Languages"),
                ),
              ),
            ),

            // Multi-select for Interests
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Interests:'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: Text("Select Interests"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: interests.map((interest) {
                                return CheckboxListTile(
                                  title: Text(interest),
                                  value: selectedInterests.contains(interest),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedInterests.add(interest);
                                      } else {
                                        selectedInterests.remove(interest);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            actions: [
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(selectedInterests.isNotEmpty ? selectedInterests.join(", ") : "Select Interests"),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Filter button
            Center(
              child: ElevatedButton(
                onPressed: filterUsers,
                child: const Text('Filter Users'),
              ),
            ),

            const SizedBox(height: 20),

            // Display filtered users
            filteredUsers.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredUsers[index]['name']),
                          subtitle: Text(filteredUsers[index]['course']),
                        );
                      },
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No users found with the selected filters.'),
                  ),
          ],
        ),
      ),
    );
  }
}