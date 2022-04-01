import 'package:auto_bell/db_handler.dart';
import 'package:auto_bell/models/bell.dart';
import 'package:auto_bell/pages/bell_add_page.dart';
import 'package:auto_bell/pages/bell_editor.dart';
import 'package:auto_bell/pages/settings_page.dart';
import 'package:auto_bell/widgets/bell_card.dart';
import 'package:auto_bell/widgets/title_bar.dart';
import 'package:flutter/material.dart';

class BellPage extends StatefulWidget {
  const BellPage({Key? key}) : super(key: key);

  @override
  State<BellPage> createState() => _BellPageState();
}

class _BellPageState extends State<BellPage> {
  List<Bell> bells = [];
  DBHandler dbHandler = DBHandler.instance;

  void _updateBells() {
    dbHandler.getBells().then((List<Map<String, dynamic>> value) {
      List<Bell> newBells = [];
      for (var bellData in value) {
        newBells.add(
          Bell()..fromMap(bellData, intAsBool: true, listAsStrings: true),
        );
      }
      setState(() {
        bells = newBells;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _updateBells();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: "Bells Page",
        suffixTools: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                _updateBells();
              },
              child: const Icon(Icons.refresh),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              child: const Icon(Icons.settings),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                overlayColor: MaterialStateProperty.all<Color>(
                    Colors.grey.withOpacity(0.1)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff53a679),
        tooltip: "add new bell",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewBellPage(),
            ),
          ).then((bell) {
            if (bell != null) {
              dbHandler.insertBell(bell).then((bellId) {
                setState(() {
                  _updateBells();
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BellEditingPage(
                      bell: bell..id = bellId,
                    ),
                  ),
                ).then((value) {
                  if (value != null) {
                    dbHandler.updateBell(value).then((value) {
                      setState(() {
                        _updateBells();
                      });
                    });
                  }
                });
              });
            }
          });
        },
        child: const Icon(Icons.add_alert),
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            for (int i = 0; i < bells.length; i++)
              BellCard(
                bell: bells[i],
                onDelete: (Bell bell) async {
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      elevation: 2,
                      backgroundColor: const Color(0xff21252b),
                      title: const Text("Delete that Bell?"),
                      content: const Text(
                          "Are you sure you want to delete that bell?"),
                      actions: <Widget>[
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xffff4473)),
                            overlayColor: MaterialStateProperty.all<Color>(
                                const Color(0xffff4473).withOpacity(0.1)),
                          ),
                          child: const Text("Delete"),
                          onPressed: () {
                            dbHandler.deleteBell(bell).then((value) {
                              _updateBells();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xff53a679)),
                            overlayColor: MaterialStateProperty.all<Color>(
                                const Color(0xff53a679).withOpacity(0.1)),
                          ),
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                onEnabled: (Bell bell) {
                  dbHandler
                      .updateBell(bell..activateOnInit = !bell.activateOnInit)
                      .then((value) {
                    _updateBells();
                  });
                },
                onDisabled: (Bell bell) {
                  dbHandler
                      .updateBell(bell..activateOnInit = !bell.activateOnInit)
                      .then((value) {
                    _updateBells();
                  });
                },
                onPlay: (Bell bell) {
                  if (!bell.activated) {
                    bell.activateBell(force: true, disableTimer: true);
                  }
                  bell.playBell();
                },
                onStop: (Bell bell) {
                  bell.stopBell().then((value) {
                    if (!bell.activated) {
                      bell.activateBell(force: true, disableTimer: true);
                    }
                  });
                },
                onTap: (Bell bell) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BellEditingPage(
                        bell: bell,
                      ),
                    ),
                  ).then((value) {
                    if (value != null) {
                      dbHandler.updateBell(value).then((value) {
                        setState(() {
                          _updateBells();
                        });
                      });
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
