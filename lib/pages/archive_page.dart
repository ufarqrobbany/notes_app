import 'dart:convert';

import 'package:notes_app/common/constants.dart';
import 'package:notes_app/helpers/adaptive.dart';
import 'package:notes_app/helpers/database_helper.dart';
import 'package:notes_app/helpers/note_color.dart';
import 'package:notes_app/helpers/utility.dart';
import 'package:notes_app/models/note_list_model.dart';
import 'package:notes_app/models/notes_model.dart';
import 'package:notes_app/pages/app.dart';
import 'package:notes_app/pages/edit_note_page.dart';
import 'package:notes_app/pages/labels_page.dart';
import 'package:notes_app/pages/note_reader_page.dart';
import 'package:notes_app/widgets/color_palette_button.dart';
import 'package:notes_app/widgets/note_card_grid.dart';
import 'package:notes_app/widgets/note_card_list.dart';
import 'package:notes_app/widgets/note_listview_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes_app/helpers/globals.dart' as globals;
import 'package:universal_platform/universal_platform.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({Key? key}) : super(key: key);

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  late SharedPreferences sharedPreferences;
  List<Notes> notesListAll = [];
  List<Notes> notesList = [];
  bool isLoading = false;
  bool hasData = false;
  late ViewType _viewType;
  bool isAndroid = UniversalPlatform.isAndroid;
  bool isIOS = UniversalPlatform.isIOS;

  TextEditingController _noteTitleController = new TextEditingController();
  TextEditingController _noteTextController = new TextEditingController();
  String currentEditingNoteId = "";
  TextEditingController _searchController = new TextEditingController();
  final dbHelper = DatabaseHelper.instance;

  int selectedPageColor = 1;

  bool isDesktop = false;

  loadArchiveNotes() async {
    setState(() {
      isLoading = true;
    });

    await dbHelper.getNotesArchived(_searchController.text).then((value) {
      setState(() {
        print(value.length);
        isLoading = false;
        hasData = value.length > 0;
        notesList = value;
      });
    });
  }

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      bool isTile = sharedPreferences.getBool("is_tile") ?? false;
      _viewType = isTile ? ViewType.Tile : ViewType.Grid;
    });
  }

  loadNotes() async {
    setState(() {
      isLoading = true;
    });

    if (isAndroid || isIOS) {
      await dbHelper.getNotesAll(_searchController.text).then((value) {
        setState(() {
          isLoading = false;
          hasData = value.length > 0;
          notesList = value;
          notesListAll = value;
        });
      });
    }
  }

  @override
  void initState() {
    getPref();
    loadArchiveNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    isDesktop = isDisplayDesktop(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Archive',
                  style: TextStyle(
                    color: darkModeOn ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                titlePadding: EdgeInsets.only(left: 30, bottom: 15),
              ),
            ),
          ];
        },
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // SizedBox(
              //   height: 56,
              // ),
              // Padding(
              //   padding: kGlobalOuterPadding,
              //   child: Container(
              //     child: Text(
              //       'Archive',
              //       style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              //     ),
              //   ),
              // ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : (hasData
                        ? (_viewType == ViewType.Grid
                            ? StaggeredGridView.countBuilder(
                                crossAxisCount: isDesktop ? 4 : 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                // shrinkWrap: true,
                                physics: BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemCount: notesList.length,
                                staggeredTileBuilder: (index) {
                                  return StaggeredTile.count(
                                      1, index.isOdd ? 0.9 : 1.14);
                                },
                                itemBuilder: (context, index) {
                                  var note = notesList[index];
                                  List<NoteListItem> _noteList = [];
                                  if (note.noteList.contains('{')) {
                                    final parsed = json
                                        .decode(note.noteText)
                                        .cast<Map<String, dynamic>>();
                                    _noteList = parsed
                                        .map<NoteListItem>((json) =>
                                            NoteListItem.fromJson(json))
                                        .toList();
                                  }
                                  return NoteCardGrid(
                                    note: note,
                                    onTap: () {
                                      setState(() {
                                        selectedPageColor = note.noteColor;
                                      });
                                      _showNoteReader(context, note);
                                    },
                                    onLongPress: () {
                                      _showOptionsSheet(context, note);
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: notesList.length,
                                physics: BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemBuilder: (context, index) {
                                  var note = notesList[index];
                                  List<NoteListItem> _noteList = [];
                                  if (note.noteList.contains('{')) {
                                    final parsed = json
                                        .decode(note.noteText)
                                        .cast<Map<String, dynamic>>();
                                    _noteList = parsed
                                        .map<NoteListItem>((json) =>
                                            NoteListItem.fromJson(json))
                                        .toList();
                                  }
                                  return NoteCardList(
                                    note: note,
                                    onTap: () {
                                      setState(() {
                                        selectedPageColor = note.noteColor;
                                      });
                                      _showNoteReader(context, note);
                                    },
                                  );
                                },
                              ))
                        : Container(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 150,
                                ),
                                Icon(
                                  Iconsax.archive_minus,
                                  size: 120,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'empty!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 22),
                                ),
                              ],
                            ),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getDateString() {
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime dt = DateTime.now();
    return formatter.format(dt);
  }

  void _showOptionsSheet(BuildContext context, Notes _note) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    isDesktop = isDisplayDesktop(context);
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
                            setState(() {
                              _noteTextController.text =
                                  Utility.stripTags(_note.noteText);
                              _noteTitleController.text = _note.noteTitle;
                              currentEditingNoteId = _note.noteId;
                            });
                            _showEdit(context, _note);
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 60,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              children: [
                                ColorPaletteButton(
                                  color: NoteColor.getColor(0, darkModeOn),
                                  onTap: () {
                                    _updateColor(_note.noteId, 0);
                                    Navigator.pop(context);
                                  },
                                  isSelected: _note.noteColor == 0,
                                ),
                                ColorPaletteButton(
                                  color: NoteColor.getColor(1, darkModeOn),
                                  onTap: () {
                                    _updateColor(_note.noteId, 1);
                                    Navigator.pop(context);
                                  },
                                  isSelected: _note.noteColor == 1,
                                ),
                                ColorPaletteButton(
                                  color: NoteColor.getColor(2, darkModeOn),
                                  onTap: () {
                                    _updateColor(_note.noteId, 2);
                                    Navigator.pop(context);
                                  },
                                  isSelected: _note.noteColor == 2,
                                ),
                                ColorPaletteButton(
                                  color: NoteColor.getColor(3, darkModeOn),
                                  onTap: () {
                                    _updateColor(_note.noteId, 3);
                                    Navigator.pop(context);
                                  },
                                  isSelected: _note.noteColor == 3,
                                ),
                                ColorPaletteButton(
                                  color: NoteColor.getColor(4, darkModeOn),
                                  onTap: () {
                                    _updateColor(_note.noteId, 4);
                                    Navigator.pop(context);
                                  },
                                  isSelected: _note.noteColor == 4,
                                ),
                                ColorPaletteButton(
                                  color: NoteColor.getColor(5, darkModeOn),
                                  onTap: () {
                                    _updateColor(_note.noteId, 5);
                                    Navigator.pop(context);
                                  },
                                  isSelected: _note.noteColor == 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.pop(context);
                            _assignLabel(_note);
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
                        // Visibility(
                        //   visible: _note.noteArchived == 0,
                        //   child: InkWell(
                        //     borderRadius: BorderRadius.circular(15),
                        //     onTap: () {
                        //       Navigator.of(context).pop();
                        //       setState(() {
                        //         currentEditingNoteId = _note.noteId;
                        //       });
                        //       _archiveNote(1);
                        //     },
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: Row(
                        //         children: <Widget>[
                        //           Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Icon(Iconsax.archive_add),
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Text('Archive'),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Visibility(
                          visible: _note.noteArchived == 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                currentEditingNoteId = _note.noteId;
                              });
                              _unArchiveNote(0);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScrawlApp(),
                                  ));
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
                              currentEditingNoteId = _note.noteId;
                            });
                            _confirmDelete();
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

  void _unArchiveNote(int archive) async {
    await dbHelper.archiveNote(currentEditingNoteId, archive).then((value) {
      loadNotes();
    });
  }

  void _updateColor(String noteId, int noteColor) async {
    print(noteColor);
    await dbHelper.updateNoteColor(noteId, noteColor).then((value) {
      loadNotes();
      setState(() {
        selectedPageColor = noteColor;
      });
    });
  }

  openDialog(Widget page) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: darkModeOn ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: darkModeOn ? Colors.white24 : Colors.black12,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Container(
                decoration: BoxDecoration(
                  color: darkModeOn ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                    maxWidth: 600,
                    minWidth: 400,
                    minHeight: 600,
                    maxHeight: 600),
                padding: EdgeInsets.all(8),
                child: page),
          );
        });
  }

  void _showEdit(BuildContext context, Notes _note) async {
    if (!UniversalPlatform.isDesktop) {
      final res = await Navigator.of(context).push(new CupertinoPageRoute(
          builder: (BuildContext context) => new EditNotePage(
                note: _note,
              )));

      if (res is Notes) loadNotes();
    } else {
      openDialog(EditNotePage(
        note: _note,
      ));
    }
  }

  void _confirmDelete() async {
    isDesktop = isDisplayDesktop(context);
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        constraints: isDesktop
            ? BoxConstraints(maxWidth: 450, minWidth: 400)
            : BoxConstraints(),
        builder: (context) {
          return Container(
            margin: EdgeInsets.only(bottom: 10.0),
            child: Padding(
              padding: kGlobalOuterPadding,
              child: Container(
                height: 160,
                child: Padding(
                  padding: kGlobalOuterPadding,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: kGlobalCardPadding,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: Text('Are you sure you want to delete?'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('No'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: ElevatedButton(
                                onPressed: () {
                                  _deleteNote();
                                  Navigator.pop(context, true);
                                },
                                child: Text('Yes'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _deleteNote() async {
    await dbHelper.deleteNotes(currentEditingNoteId).then((value) {
      loadNotes();
    });
  }

  void _assignLabel(Notes note) async {
    var res = await Navigator.of(context).push(new CupertinoPageRoute(
        builder: (BuildContext context) => new LabelsPage(
              noteid: note.noteId,
              notelabel: note.noteLabel,
            )));
    if (res != null) loadNotes();
  }

  void _showNoteReader(BuildContext context, Notes _note) async {
    isDesktop = isDisplayDesktop(context);
    if (isDesktop) {
      bool res = await showDialog(
          context: context,
          builder: (context) {
            return Container(
              child: Dialog(
                child: Container(
                  width: isDesktop ? 800 : MediaQuery.of(context).size.width,
                  child: NoteReaderPage(
                    note: _note,
                  ),
                ),
              ),
            );
          });
      if (res) loadArchiveNotes();
    } else {
      bool res = await Navigator.of(context).push(new CupertinoPageRoute(
          builder: (BuildContext context) => new NoteReaderPage(
                note: _note,
              )));
      if (res) loadArchiveNotes();
    }
  }
}
