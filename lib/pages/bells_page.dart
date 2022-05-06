import 'package:auto_bell/db_handler.dart';
import 'package:auto_bell/inheited_widgets.dart';
import 'package:auto_bell/models/bell.dart';
import 'package:auto_bell/pages/bell_add_page.dart';
import 'package:auto_bell/pages/bell_editor.dart';
import 'package:auto_bell/pages/settings_page.dart';
import 'package:auto_bell/settings.dart';
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
  final DBHandler _dbHandler = DBHandler.instance;
  final Settings _settings = Settings.instance;
  bool _enableBG = true;
  bool _changingOrder = false;

  Future<void> _updateBells() async {
    List<Map<String, dynamic>> bellsData = await _dbHandler.getBells();
    List<Bell> newBells = [];
    for (var bellData in bellsData) {
      newBells.add(
        Bell()..fromMap(bellData, intAsBool: true, listAsStrings: true),
      );
    }
    for (var bell in bells) {
      bell.dispose();
    }
    setState(() {
      bells = newBells;
    });
  }

  void _moveBell(int oldPosition, int newPosition) {
    setState(() {
      if (oldPosition < newPosition) {
        newPosition -= 1;
      }
      final Bell bell = bells.removeAt(oldPosition);
      bells.insert(newPosition, bell);
    });
    _dbHandler.moveBell(oldPosition, newPosition);
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh({bool settingsOnly = false}) {
    _settings.getBGEnabled.then((value) {
      setState(() {
        _enableBG = value;
      });
    });
    if (!settingsOnly) _updateBells();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: "Bells Page",
        suffixTools: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: _changingOrder ? 'save order' : 'reorder',
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _changingOrder = !_changingOrder;
                    // why we are refreshing here is because we need to diactivate all the bells and activate them again
                    // just in case if bell starts and doesnt dispose
                    if (!_changingOrder) _refresh();
                  });
                },
                child: _changingOrder
                    ? const Icon(Icons.check_circle)
                    : const Icon(Icons.reorder),
              ),
            ),
            Tooltip(
              message: 'refresh',
              child: TextButton(
                onPressed: () {
                  _refresh();
                },
                child: const Icon(Icons.refresh),
              ),
            ),
            Tooltip(
              message: 'settings',
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  ).then((value) => _refresh(settingsOnly: true));
                },
                child: const Icon(Icons.settings),
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey),
                  overlayColor: MaterialStateProperty.all<Color>(
                      Colors.grey.withOpacity(0.1)),
                ),
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
              bell.position = bells.length;
              _dbHandler.insertBell(bell).then((bellId) {
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
                    _dbHandler.updateBell(value).then((value) {
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
      body: Stack(
        children: [
          Visibility(
            visible: _enableBG,
            child: const Opacity(
              child: Center(
                child: Image(
                  image: AssetImage('assets/icmuTransparent.png'),
                ),
              ),
              opacity: 0.1,
            ),
          ),
          Scrollbar(
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              // its using a inherited widget (BellCardData) because we have to disable shaking without rebuilding the widget
              child: BellCardData(
                shake: _changingOrder,
                child: ReorderableListView(
                  padding: const EdgeInsets.all(8),
                  onReorder: (int oldIndex, int newIndex) {
                    debugPrint("Reordered $oldIndex to $newIndex");
                    _moveBell(oldIndex, newIndex);
                  },
                  proxyDecorator: (
                    Widget child,
                    int index,
                    Animation<double> animation,
                  ) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.grabbing,
                      child: BellCardData(
                        shake: false,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    );
                  },
                  buildDefaultDragHandles: false,
                  children: [
                    for (int i = 0; i < bells.length; i++)
                      ReorderableDragStartListener(
                        enabled: _changingOrder,
                        index: i,
                        key: ValueKey(bells[i].id),
                        child: MouseRegion(
                          cursor: _changingOrder
                              ? SystemMouseCursors.grab
                              : SystemMouseCursors.click,
                          child: BellCard(
                            bell: bells[i],
                            disableActions: _changingOrder,
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
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color(0xffff4473)),
                                        overlayColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color(0xffff4473)
                                                    .withOpacity(0.1)),
                                      ),
                                      child: const Text("Delete"),
                                      onPressed: () {
                                        _dbHandler
                                            .deleteBell(bell)
                                            .then((value) {
                                          _updateBells();
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color(0xff53a679)),
                                        overlayColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color(0xff53a679)
                                                    .withOpacity(0.1)),
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
                            onEnabled: (Bell bell) async {
                              await _dbHandler.updateBell(
                                  bell..activateOnInit = !bell.activateOnInit);
                              await _updateBells();
                            },
                            onDisabled: (Bell bell) async {
                              await _dbHandler.updateBell(
                                  bell..activateOnInit = !bell.activateOnInit);
                              await _updateBells();
                            },
                            onPlay: (Bell bell) async {
                              if (!bell.activated) {
                                await bell.activateBell(
                                    force: true, disableTimer: true);
                              }
                              await bell.playBell();
                            },
                            onStop: (Bell bell) async {
                              await bell.stopBell();
                              if (!bell.activated) {
                                await bell.activateBell(
                                    force: true, disableTimer: true);
                              }
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
                                  _dbHandler.updateBell(value).then((value) {
                                    setState(() {
                                      _updateBells();
                                    });
                                  });
                                }
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
