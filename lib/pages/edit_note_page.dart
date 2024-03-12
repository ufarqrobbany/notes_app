import 'dart:developer';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/darcula.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notes_app/common/constants.dart';
import 'package:notes_app/helpers/adaptive.dart';
import 'package:notes_app/helpers/database_helper.dart';
import 'package:notes_app/helpers/note_color.dart';
import 'package:notes_app/helpers/utility.dart';
import 'package:notes_app/models/note_list_model.dart';
import 'package:notes_app/models/notes_model.dart';
import 'package:notes_app/pages/app.dart';
import 'package:notes_app/widgets/color_palette_button.dart';
import 'package:notes_app/widgets/new_custom_textfield.dart';
import 'package:notes_app/widgets/note_edit_list_textfield.dart';
import 'package:notes_app/widgets/small_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scribble/scribble.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:uuid/uuid.dart';
import 'package:notes_app/helpers/globals.dart' as globals;
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditNotePage extends StatefulWidget {
  final Notes note;
  final noteType;

  EditNotePage({Key? key, required this.note, @required this.noteType})
      : super(key: EditNotePage.staticGlobalKey);

  static final GlobalKey<_EditNotePageState> staticGlobalKey =
      new GlobalKey<_EditNotePageState>();

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();
  late CodeController _codeController;
  Map<String, TextStyle>? themes = atomOneDarkTheme;
  TextEditingController _noteTitleController = new TextEditingController();
  TextEditingController _noteTextController = new TextEditingController();
  TextEditingController _noteListTextController = new TextEditingController();
  bool _noteListCheckValue = false;
  String currentEditingNoteId = "";
  String _noteListJsonString = "";
  final dbHelper = DatabaseHelper.instance;
  var uuid = Uuid();
  late Notes note;
  bool isCheckList = false;
  List<NoteListItem> _noteListItems = [];
  NoteType _noteType = NoteType.Normal;
  String tema = '';

  final scribbleStateProvider =
      StateNotifierProvider.autoDispose<ScribbleNotifier, ScribbleState>(
    (ref) => ScribbleNotifier(),
  );

  void _saveNote() async {
    if (currentEditingNoteId.isEmpty) {
      setState(() {
        note = new Notes(
          uuid.v1(),
          DateTime.now().toString(),
          _noteTitleController.text,
          _noteTextController.text,
          '',
          0,
          0,
          _noteListJsonString,
          //todo here
          // [],
        );
      });
      await dbHelper.insertNotes(note).then((value) {
        // loadNotes();
      });
    } else {
      setState(() {
        note = Notes(
          currentEditingNoteId,
          DateTime.now().toString(),
          _noteTitleController.text,
          _noteTextController.text,
          '',
          0,
          0,
          _noteListJsonString,
          //todo here
          // [],
        );
      });
      await dbHelper.updateNotes(note).then((value) {
        // loadNotes();
      });
    }
  }

  void onSubmitListItem() async {
    _noteListItems.add(new NoteListItem(_noteListTextController.text, 'false'));
    _noteListTextController.text = "";
    print(_noteListCheckValue);
  }

  void codeController() {
    setState(() {
      _codeController = CodeController(
          text: note.noteText,
          language: dart,
          theme: themes,
          onChange: (p0) {
            contentFocusNode.requestFocus();
          });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      note = widget.note;
      _noteTextController.text = note.noteText;
      _noteTitleController.text = note.noteTitle;
      currentEditingNoteId = note.noteId;
      isCheckList = note.noteList.contains('{');
      // _codeController = CodeController(
      //   text: note.noteText,
      //   // language: dart,
      //   theme: githubTheme,
      // );
    });
    codeController();
    titleFocusNode.requestFocus();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // NoteType noteType =
    //     widget.noteType == null ? NoteType.Normal : widget.noteType;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Builder(builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: SAppBar(
              // title: Text(_noteType.toString().replaceAll('NoteType.', '')),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _noteType == NoteType.Normal,
                    child: IconButton(
                      onPressed: () {
                        // setState(() {
                        //   _noteType = NoteType.Code;
                        // });
                      },
                      color: globals.themeMode == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      icon: Icon(Iconsax.note),
                    ),
                  ),
                  // InkWell(
                  //   onLongPress: () {
                  //     _showOptionsSheet(context);
                  //   },
                  //   child: Visibility(
                  //     visible: _noteType == NoteType.Code,
                  //     child: IconButton(
                  //       onPressed: () {
                  //         setState(() {
                  //           _noteType = NoteType.Normal;
                  //         });
                  //       },
                  //       color: globals.themeMode == ThemeMode.dark
                  //           ? Colors.white
                  //           : Colors.black,
                  //       icon: Icon(Iconsax.code),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              onTap: _onBackPressed,
              action: [
                // Center(
                //   child: Visibility(
                //     visible: _noteType == NoteType.Code,
                //     child: DropdownButton<String>(
                //       dropdownColor: FlexColor.aquaBlueDarkPrimary,
                //       elevation: 0,
                //       isDense: false,
                //       alignment: AlignmentDirectional.centerEnd,
                //       icon: Icon(
                //         Icons.color_lens_outlined,
                //         size: 25,
                //       ),
                //       iconEnabledColor: globals.themeMode == ThemeMode.dark
                //           ? Colors.white
                //           : Colors.black,
                //       hint: Text(
                //         "$tema ",
                //         style: TextStyle(
                //           color: globals.themeMode == ThemeMode.dark
                //               ? Colors.white
                //               : Colors.black,
                //         ),
                //       ),
                //       borderRadius: BorderRadius.circular(20),
                //       items: <String>[
                //         'Atom',
                //         'Monokai-sublime',
                //         'VS',
                //         'Darcula'
                //       ].map((String value) {
                //         return DropdownMenuItem<String>(
                //           onTap: () {
                //             setState(() {
                //               if (value == "Monokai-sublime") {
                //                 themes = monokaiSublimeTheme;
                //               } else if (value == "Atom") {
                //                 themes = atomOneDarkTheme;
                //               } else if (value == "VS") {
                //                 themes = vsTheme;
                //               } else if (value == "Darcula") {
                //                 themes = darculaTheme;
                //               }
                //             });
                //           },
                //           value: value,
                //           child: Text(
                //             value,
                //             style: TextStyle(color: Colors.white),
                //           ),
                //         );
                //       }).toList(),
                //       onChanged: (value) {
                //         tema = value.toString();
                //       },
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   width: 10,
                // )
              ],
            ),
          ),
          body: GestureDetector(
            onTap: () {
              contentFocusNode.requestFocus();
            },
            child: _noteType == NoteType.Code
                ? Padding(
                    padding: kGlobalCardPadding,
                    child: ListView(
                      children: [
                        TextField(
                          controller: _noteTitleController,
                          focusNode: titleFocusNode,
                          onSubmitted: (value) {
                            contentFocusNode.requestFocus();
                          },
                          decoration: InputDecoration(
                            hintText: 'Title',
                            // label: Text('Title'),
                            // isCollapsed: true,
                            fillColor: Colors.transparent,
                            enabledBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            focusedBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                        ),

                        Divider(
                          thickness: 1.2,
                          endIndent: 5,
                          indent: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CodeField(
                              // controller: CodeController(
                              //   text: note.noteText,
                              //   language: dart,
                              //   theme: themes,
                              //   onChange: (p0) {
                              //     contentFocusNode.requestFocus();
                              //   },
                              // ),
                              controller: _codeController,
                              maxLines: null,
                              wrap: true,
                              enabled: true,
                              lineNumberStyle: LineNumberStyle(
                                  width: 30,
                                  margin: 5,
                                  textStyle: TextStyle(
                                    color: globals.themeMode == ThemeMode.dark
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                              focusNode: contentFocusNode,
                              // expands: false,
                              background: globals.themeMode == ThemeMode.dark
                                  ? Colors.black
                                  : Colors.white,
                              textStyle: TextStyle(
                                fontFamily: 'SourceCode',
                                // color: globals.themeMode == ThemeMode.dark
                                //     ? Colors.white
                                //     : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        if (isCheckList)
                          ...List.generate(
                              _noteListItems.length, generatenoteListItems),
                        // ListView.builder(
                        //   itemBuilder: (context, index) {
                        //     return ListTile();
                        //   },
                        //   shrinkWrap: true,
                        //   physics: NeverScrollableScrollPhysics(),
                        // ),
                        Visibility(
                          visible: isCheckList,
                          child: NoteEditListTextField(
                            checkValue: _noteListCheckValue,
                            controller: _noteListTextController,
                            onSubmit: () => onSubmitListItem(),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: kGlobalCardPadding,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final screenHeight = constraints.maxHeight;
                        final lineHeight =
                            20.0; // Adjust this value based on your font size and style
                        final minLines = (screenHeight / lineHeight).floor();
                        return ListView(
                          children: [
                            TextField(
                              // minLines: minLines,
                              controller: _noteTitleController,
                              focusNode: titleFocusNode,
                              onSubmitted: (value) {
                                contentFocusNode.requestFocus();
                              },
                              style: TextStyle(
                                fontSize: 25,
                              ),
                              maxLines:
                                  null, // Allow the TextField to expand freely
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 12),
                                hintText: 'Title',
                                hintStyle: TextStyle(
                                  fontSize: 25,
                                ),
                                // label: Text('Title'),
                                // isCollapsed: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            TextField(
                              // minLines: minLines,
                              controller: _noteTextController,
                              focusNode: titleFocusNode,
                              onSubmitted: (value) {
                                contentFocusNode.requestFocus();
                              },
                              style: TextStyle(
                                fontSize: 15,
                              ),
                              maxLines:
                                  null, // Allow the TextField to expand freely
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 12),
                                hintText: 'texts',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                ),
                                // label: Text('Title'),
                                // isCollapsed: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            // NewCustomTextField(
                            //   controller: _noteTextController,
                            //   focusNode: contentFocusNode,
                            //   maxLines: null,
                            //   minLines: null,
                            //   onSubmitted: (value) {
                            //     contentFocusNode.requestFocus();
                            //   },
                            //   decoration: InputDecoration(
                            //     hintText: 'Content',
                            //     fillColor: Colors.transparent,
                            //     enabledBorder: OutlineInputBorder(
                            //         borderSide: BorderSide.none),
                            //     focusedBorder: OutlineInputBorder(
                            //         borderSide: BorderSide.none),
                            //   ),
                            // ),
                            // Stack(
                            //   alignment: Alignment.center,
                            //   children: [
                            //     TextField(
                            //       controller: _noteTextController,
                            //       focusNode: contentFocusNode,
                            //       maxLines: minLines,
                            //       minLines: null,
                            //       onSubmitted: (value) {
                            //         contentFocusNode.requestFocus();
                            //       },
                            //       decoration: InputDecoration(
                            //         hintText: 'Content',
                            //         fillColor: Colors.transparent,
                            //         enabledBorder: OutlineInputBorder(
                            //             borderSide: BorderSide.none),
                            //         focusedBorder: OutlineInputBorder(
                            //             borderSide: BorderSide.none),
                            //       ),
                            //     ),
                            //     Container(
                            //       width: double.infinity,
                            //       height: screenHeight,
                            //       child: SfSignaturePad(
                            //         minimumStrokeWidth: 1,
                            //         maximumStrokeWidth: 5,
                            //         strokeColor: Colors.black,
                            //         backgroundColor: Colors.transparent,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // // Consumer(builder: (context, WidgetRef reff, __) {
                            //   return Scribble(
                            //     notifier:
                            //         reff.watch(scribbleStateProvider.notifier),
                            //   );
                            // })
                          ],
                        );
                      },
                    )
                    // ListView(
                    //   children: [
                    //     // Padding(
                    //     //   padding: kGlobalOuterPadding,
                    //     //   child: Container(
                    //     //     child: NoteEditTextField(
                    //     //       controller: _noteTitleController,
                    //     //       hint: 'Title',
                    //     //       focusNode: titleFocusNode,
                    //     //       onSubmitFocusNode: contentFocusNode,
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //     TextField(
                    //       controller: _noteTitleController,
                    //       focusNode: titleFocusNode,
                    //       onSubmitted: (value) {
                    //         contentFocusNode.requestFocus();
                    //       },
                    //       decoration: InputDecoration(
                    //         hintText: 'Title',
                    //         // label: Text('Title'),
                    //         // isCollapsed: true,
                    //         fillColor: Colors.transparent,
                    //         enabledBorder:
                    //             OutlineInputBorder(borderSide: BorderSide.none),
                    //         focusedBorder:
                    //             OutlineInputBorder(borderSide: BorderSide.none),
                    //       ),
                    //     ),
                    //     // SizedBox(
                    //     //   height: 5,
                    //     // ),
                    //     // Divider(
                    //     //   thickness: 1.2,
                    //     //   endIndent: 10,
                    //     //   indent: 10,
                    //     // ),
                    //     // TextField(
                    //     //   controller: _noteTextController,
                    //     //   focusNode: contentFocusNode,
                    //     //   maxLines: null,
                    //     //   onSubmitted: (value) {
                    //     //     contentFocusNode.requestFocus();
                    //     //   },
                    //     //   decoration: InputDecoration(
                    //     //     hintText: 'sad',
                    //     //     border: OutlineInputBorder(
                    //     //         borderSide:
                    //     //             BorderSide(width: 10, color: Colors.white)),
                    //     //   ),
                    //     // ),
                    //     // SizedBox(
                    //     //   height: 5,
                    //     // ),
                    //     // CodeField(
                    //     //   controller: _codeController!,
                    //     //   textStyle: TextStyle(fontFamily: 'SourceCode'),
                    //     // ),

                    //     TextField(
                    //       controller: _noteTextController,
                    //       focusNode: contentFocusNode,
                    //       maxLines: null,
                    //       minLines: null,
                    //       onSubmitted: (value) {
                    //         contentFocusNode.requestFocus();
                    //       },
                    //       decoration: InputDecoration(
                    //         hintText: 'Content',
                    //         fillColor: Colors.transparent,
                    //         enabledBorder:
                    //             OutlineInputBorder(borderSide: BorderSide.none),
                    //         focusedBorder:
                    //             OutlineInputBorder(borderSide: BorderSide.none),
                    //       ),
                    //     ),
                    //     // Padding(
                    //     //   padding: kGlobalOuterPadding,
                    //     //   child: Container(
                    //     //     child: NoteEditTextField(
                    //     //       controller: _noteTextController,
                    //     //       hint: 'Content',
                    //     //       focusNode: contentFocusNode,
                    //     //       isContentField: true,
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //     if (isCheckList)
                    //       ...List.generate(
                    //           _noteListItems.length, generatenoteListItems),
                    //     // ListView.builder(
                    //     //   itemBuilder: (context, index) {
                    //     //     return ListTile();
                    //     //   },
                    //     //   shrinkWrap: true,
                    //     //   physics: NeverScrollableScrollPhysics(),
                    //     // ),
                    //     Visibility(
                    //       visible: isCheckList,
                    //       child: NoteEditListTextField(
                    //         checkValue: _noteListCheckValue,
                    //         controller: _noteListTextController,
                    //         onSubmit: () => onSubmitListItem(),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    ),
          ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: SizedBox(
          //   height: 40,
          //   width: MediaQuery.of(context).size.width * 0.95,
          //   child: FloatingActionButton(
          //     onPressed: () {},
          //     backgroundColor: Colors.black,
          //     isExtended: false,
          //     mini: false,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceAround,
          //       mainAxisSize: MainAxisSize.max,
          //       children: [
          //         IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.edit,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // bottomNavigationBar: BottomAppBar(
          //   child: Container(
          //     // padding: EdgeInsets.all(value),
          //     margin: EdgeInsets.only(
          //         bottom: MediaQuery.of(context).viewInsets.bottom),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         IconButton(
          //           onPressed: () {
          //             setState(() {
          //               isCheckList = !isCheckList;
          //             });
          //           },
          //           icon: Icon(isCheckList
          //               ? Icons.text_format
          //               : Icons.check_box_outlined),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        );
      }),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    var isDesktop = isDisplayDesktop(context);
    Notes _note;
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        constraints: isDesktop
            ? BoxConstraints(maxWidth: 450, minWidth: 400)
            : BoxConstraints(),
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 480,
                child: Container(
                  child: Padding(
                    padding: kGlobalOuterPadding,
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.of(context).pop();
                            // setState(() {
                            //   _noteTextController.text =
                            //       Utility.stripTags(_note.noteText);
                            //   _noteTitleController.text = _note.noteTitle;
                            //   currentEditingNoteId = _note.noteId;
                            // });
                            // _showEdit(context, _note);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.edit_2),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Edit'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          // onTap: () {
                          //   Navigator.pop(context);
                          //   _showColorPalette(context, _note);
                          // },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.color_swatch),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Color Palette'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.pop(context);
                            // _assignLabel(_note);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.tag),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Assign Labels'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                // currentEditingNoteId = _note.noteId;
                              });
                              // _archiveNote(1);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Iconsax.archive_add),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Archive'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                // currentEditingNoteId = _note.noteId;
                              });
                              // _archiveNote(0);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Iconsax.archive_minus),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Unarchive'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              // currentEditingNoteId = _note.noteId;
                            });
                            // _confirmDelete();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.note_remove),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.close_circle),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget generatenoteListItems(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      child: Row(
        children: [
          Icon(Icons.check_box),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
            child: Text(_noteListItems[index].value),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if (_noteTitleController.text.isNotEmpty ||
        _noteTextController.text.isNotEmpty) {
      _saveNote();
      log('saved');
      Navigator.pop(context, note);
    } else {
      log('unsaved');
      Navigator.pop(context, false);
    }
    return true;
  }
}
