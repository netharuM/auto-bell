import 'package:auto_bell/models/bell.dart';
import 'package:auto_bell/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// shows errors of a [Bell]
/// - [bellErrors] errors of the [Bell]
class BellErrorsPage extends StatelessWidget {
  /// errors of the [Bell]
  final BellErrors bellErrors;
  const BellErrorsPage({Key? key, required this.bellErrors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleBar(
        title: 'bell Errors',
        backgroundColor: Color(0xfff14c4c),
        closeButtonColor: Colors.black,
        buttonColor: Colors.black,
      ),
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Errors on bell "${bellErrors.parent.title}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('cancel'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xfff14c4c).withOpacity(0.1),
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      const Color(0xfff14c4c),
                    ),
                    overlayColor: MaterialStateProperty.all(
                      const Color(0xfff14c4c).withOpacity(0.2),
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  for (var bellError in bellErrors.getErrorsList)
                    BellErrorWidget(
                      bellError: bellError,
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'try clicking on errors and looking at help\nif none of them works and you keep getting the same issue\nplease report to the developer',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    if (!await launch(
                        'https://github.com/netharuM/auto-bell/issues/new')) {
                      throw 'Could not launch Report New Issue';
                    }
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('report a bug on github'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BellErrorWidget extends StatefulWidget {
  final BellErrorExtended bellError;
  const BellErrorWidget({Key? key, required this.bellError}) : super(key: key);

  @override
  State<BellErrorWidget> createState() => _BellErrorWidgetState();
}

class _BellErrorWidgetState extends State<BellErrorWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        hoverColor: Colors.red.withOpacity(0.1),
        splashColor: Colors.red.withOpacity(0.3),
        highlightColor: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bellError.title ?? 'Error',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        widget.bellError.description ??
                            'Error description is unknown',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _expanded
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: Colors.red,
                    size: 35,
                  )
                ],
              ),
              Visibility(
                visible: _expanded && widget.bellError.help != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      color: Colors.red,
                    ),
                    Text(
                      widget.bellError.help ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
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
