import 'package:flutter/material.dart';

class NewCustomTextField extends StatefulWidget {
  final TextEditingController controller;
  String? selectedFontFamily = 'Arial';
  InputDecoration? decoration;
  FocusNode? focusNode;
  int? maxLines;
  int? minLines;
  Function(String)? onSubmitted;
  // String? hintText;
  NewCustomTextField({
    required this.controller,
    this.selectedFontFamily,
    this.decoration,
    this.focusNode,
    this.maxLines,
    this.minLines,
    this.onSubmitted,
    // this.hintText,
  });
  @override
  _NewCustomTextFieldState createState() => _NewCustomTextFieldState();
}

class _NewCustomTextFieldState extends State<NewCustomTextField> {
  // final TextEditingController controller = TextEditingController();
  // String selectedFontFamily = 'Arial';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom TextField'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: widget.controller,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              maxLength: null,
              onSubmitted: widget.onSubmitted,
              focusNode: widget.focusNode,
              decoration: widget.decoration,
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: widget.selectedFontFamily,
              onChanged: (String? newValue) {
                setState(() {
                  widget.selectedFontFamily = newValue!;
                });
              },
              items: <String>[
                'Arial',
                'Times New Roman',
                'Courier New',
                'Verdana',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                children: _getSpans(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _getSpans() {
    List<TextSpan> spans = [];
    String text = widget.controller.text;
    String selectedText = widget.controller.selection.textInside(text);
    if (selectedText.isNotEmpty) {
      int startIndex = widget.controller.selection.start;
      int endIndex = widget.controller.selection.end;
      spans.add(
        TextSpan(
          text: text.substring(0, startIndex),
        ),
      );
      spans.add(
        TextSpan(
          text: selectedText,
          style: TextStyle(fontFamily: widget.selectedFontFamily),
        ),
      );
      spans.add(
        TextSpan(
          text: text.substring(endIndex),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: text,
        ),
      );
    }
    return spans;
  }
}
