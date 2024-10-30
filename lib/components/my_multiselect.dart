import 'package:flutter/material.dart';

class MyMultiSelect extends StatefulWidget {
  final String hintText;
  final List<String> options;
  final List<String> selectedValues;
  final String titlename;
  final Function(List<String>)
      onSelectionChanged; // Callback to update the selected values

  const MyMultiSelect({
    super.key,
    required this.hintText,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
    required this.titlename,
  });

  @override
  _MyMultiSelectState createState() => _MyMultiSelectState();
}

class _MyMultiSelectState extends State<MyMultiSelect> {
  // Function to show the multi-select dialog
  Future<void> _showMultiSelectDialog() async {
    List<String> tempSelectedValues =
        List.from(widget.selectedValues); // Copy of selected values

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(widget.hintText),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.options.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: tempSelectedValues.contains(option),
                      controlAffinity: ListTileControlAffinity
                          .leading, // Checkbox on the left
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedValues.add(option);
                          } else {
                            tempSelectedValues.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    widget.onSelectionChanged(
                        tempSelectedValues); // Pass the updated values back to parent
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("OK"),
                ),
                TextButton(
                  onPressed: () {
                    widget.onSelectionChanged([]); // Clear all selections
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("Clear"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build a field to show selected values for multi-select
  Widget _buildMultiSelectField() {
    return GestureDetector(
      onTap: _showMultiSelectDialog, // Trigger the dialog on tap
      child: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.selectedValues.isNotEmpty
              ? widget.selectedValues.join(", ")
              : widget.hintText,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
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

            // Multiselect field with rounded corners
            Center(child: _buildMultiSelectField()),
          ],
        ),
      ),
    );
  }
}
