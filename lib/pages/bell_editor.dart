import 'package:auto_bell/models/bell.dart';
import 'package:auto_bell/widgets/select_days.dart';
import 'package:auto_bell/widgets/title_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BellEditingPage extends StatefulWidget {
  final Bell bell;
  const BellEditingPage({Key? key, required this.bell}) : super(key: key);

  @override
  State<BellEditingPage> createState() => _BellEditingPageState();
}

class _BellEditingPageState extends State<BellEditingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _changed = false;
  bool _filled = true;
  late TimeOfDay? _time;
  late List<bool> _days;
  String? _audioPath;

  bool _checkFilled() {
    if (_titleController.text == "") return false;
    if (_time == null) return false;
    return true;
  }

  @override
  void initState() {
    if (widget.bell.title != null) _titleController.text = widget.bell.title!;
    if (widget.bell.description != null) {
      _descController.text = widget.bell.description!;
    }
    _time = widget.bell.time;
    _days = widget.bell.days.toList();
    _audioPath = widget.bell.pathToAudio;
    super.initState();
  }

  bool _checkChanged() {
    if (_titleController.text != (widget.bell.title ?? "")) return true;
    if (_descController.text != (widget.bell.description ?? "")) return true;
    if (_time != widget.bell.time) return true;
    if (!listEquals(_days, widget.bell.days)) return true;
    if (_audioPath != widget.bell.pathToAudio) return true;
    return false;
  }

  void _checkForSave() {
    setState(() {
      _changed = _checkChanged();
      _filled = _checkFilled();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_changed) {
          bool exit = false;
          await showDialog(
            context: context,
            builder: (_) => confirmationDialog(
              onCancel: () {
                exit = false;
                Navigator.pop(context);
              },
              onDiscard: () {
                exit = true;
                Navigator.pop(context);
              },
            ),
          );
          return exit;
        }
        return true;
      },
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: _changed && _filled,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            tooltip: "Save",
            child: const Icon(Icons.check),
            onPressed: () {
              Bell bell = widget.bell
                ..title = _titleController.text
                ..description =
                    _descController.text == "" ? null : _descController.text
                ..time = _time
                ..pathToAudio = _audioPath
                ..days = _days;
              Navigator.pop(context, bell);
            },
          ),
        ),
        appBar: TitleBar(
          title: 'editing bell',
          backgroundColor: Theme.of(context).primaryColor,
          closeButtonStyle: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
            overlayColor: MaterialStateProperty.all<Color>(Colors.red),
          ),
          closeButtonColor: Colors.black,
          buttonColor: Colors.black,
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    padding: const EdgeInsets.only(right: 10),
                    onPressed: () async {
                      bool exit = true;
                      if (_changed) {
                        await showDialog(
                          context: context,
                          builder: (_) => confirmationDialog(
                            onCancel: () {
                              exit = false;
                              Navigator.pop(context);
                            },
                            onDiscard: () {
                              exit = true;
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }
                      if (exit) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    color: Theme.of(context).primaryColor,
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _checkForSave();
                      },
                      decoration: const InputDecoration(
                        hintText: "Enter Bell Title",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _titleController,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    _checkForSave();
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Enter Bell Desciption",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  ),
                  controller: _descController,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.audio);
                      if (result != null) {
                        setState(() {
                          _audioPath = result.files.first.path;
                          _checkForSave();
                        });
                      }
                    },
                    icon: const Icon(Icons.audiotrack_rounded),
                    label: const Text("Pick a new audio"),
                  ),
                  Flexible(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.audio_file_outlined),
                      label: Text(_audioPath ?? "No audio selected"),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SelectDays(
                      onChange: () {
                        _checkForSave();
                      },
                      days: _days,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tooltip(
                        message: 'Pick a new time',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            TimeOfDay? _newTime = await showTimePicker(
                                context: context,
                                initialTime: _time ??
                                    const TimeOfDay(hour: 0, minute: 0));
                            setState(() {
                              _time = _newTime ?? _time;
                            });
                            _checkForSave();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: _time != null
                                ? Text(
                                    MaterialLocalizations.of(context)
                                        .formatTimeOfDay(_time!),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.more_time_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 30,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AlertDialog confirmationDialog({Function()? onDiscard, Function()? onCancel}) {
  return AlertDialog(
    backgroundColor: Colors.black,
    title: const Text("Discard changes?"),
    content: const Text("Are you sure you want to discard your changes?"),
    actions: <Widget>[
      TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
          overlayColor:
              MaterialStateProperty.all<Color>(Colors.red.withOpacity(0.1)),
        ),
        child: const Text("Discard"),
        onPressed: onDiscard ?? () {},
      ),
      TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
          overlayColor:
              MaterialStateProperty.all<Color>(Colors.green.withOpacity(0.1)),
        ),
        child: const Text("Cancel"),
        onPressed: onCancel ?? () {},
      ),
    ],
  );
}
