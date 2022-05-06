import 'package:auto_bell/models/bell.dart';
import 'package:auto_bell/widgets/title_bar.dart';
import 'package:flutter/material.dart';

class AddNewBellPage extends StatefulWidget {
  const AddNewBellPage({Key? key}) : super(key: key);

  @override
  State<AddNewBellPage> createState() => _AddNewBellPageState();
}

class _AddNewBellPageState extends State<AddNewBellPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _filled = false;
  TimeOfDay? _time;

  /// returns [true] if every parameter is filled
  bool _checkFilled() {
    if (_titleController.text == "") return false;
    if (_time == null) return false;
    return true;
  }

  /// looking for ability to save
  void _checkForSave() {
    setState(() {
      _filled = _checkFilled();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: Visibility(
        visible: _filled,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pop(
              context,
              Bell(
                title: _titleController.text,
                description:
                    _descController.text == "" ? null : _descController.text,
                time: _time,
              ),
            );
          },
          child: const Icon(Icons.check),
          backgroundColor: Theme.of(context).primaryColor,
        ),
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  color: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (_) {
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
                onChanged: (_) {
                  _checkForSave();
                },
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: 'Pick a new time',
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    TimeOfDay? _newTime = await showTimePicker(
                        context: context,
                        initialTime:
                            _time ?? const TimeOfDay(hour: 0, minute: 0));
                    setState(() {
                      _time = _newTime;
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
    );
  }
}
