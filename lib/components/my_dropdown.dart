import 'package:flutter/material.dart';

class MyDropDown extends StatefulWidget {
  final String hintText;
  final List<String> options;
  final Function(String?)? onChanged;  // The callback function to pass selected value

  const MyDropDown({
    super.key,
    required this.hintText,
    required this.options,
    this.onChanged,
  });

  @override
  _MyDropDownState createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? selectedValue;  // Internal state for managing selected value

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: widget.hintText,
          border: OutlineInputBorder(),
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
            selectedValue = newValue;  // Update the selected value internally
          });
          if (widget.onChanged != null) {
            widget.onChanged!(newValue);  // Call parent callback with the new value
          }
        },
      ),
    );
  }
}
