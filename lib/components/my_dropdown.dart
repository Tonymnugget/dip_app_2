import 'package:flutter/material.dart';

class MyDropDown extends StatefulWidget {
  final String hintText;
  final List<String> options;
  final Function(String?)?
      onChanged; // The callback function to pass selected value
  final String? initialValue;

  const MyDropDown({
    super.key,
    required this.hintText,
    required this.options,
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
      child: DropdownButtonFormField<String>(
        dropdownColor: Color.fromARGB(255, 217, 217, 217),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
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
            selectedValue = newValue; // Update the selected value internally
          });
          if (widget.onChanged != null) {
            widget.onChanged!(
                newValue); // Call parent callback with the new value
          }
        },
      ),
    );
  }
}
