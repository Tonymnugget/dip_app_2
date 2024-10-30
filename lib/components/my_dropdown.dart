import 'package:flutter/material.dart';

class MyDropDown extends StatefulWidget {
  final String hintText;
  final List<String> options;
  final String titlename;
  final Function(String?)?
      onChanged; // The callback function to pass selected value
  final String? initialValue;

  const MyDropDown({
    super.key,
    required this.hintText,
    required this.options,
    required this.titlename,
    this.onChanged,
    this.initialValue,
  });

  @override
  _MyDropDownState createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? selectedValue; // Internal state for managing selected value

  @override
  void initState() {
    super.initState();

    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Text
            Text(
              widget.titlename,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 400,
              height: 45,
              child: DropdownButtonFormField<String>(
                menuMaxHeight: 300,
                iconSize: 30,
                dropdownColor: Color.fromARGB(255, 217, 217, 217),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondary,
                  labelText: widget.hintText,
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: selectedValue,
                items: widget.options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue =
                        newValue; // Update the selected value internally
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(
                        newValue); // Call parent callback with the new value
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
