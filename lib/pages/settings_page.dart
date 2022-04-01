import 'package:auto_bell/settings.dart';
import 'package:auto_bell/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TitleBar(
          title: "settings page",
          bottom: Row(
            children: [
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_rounded),
                color: Theme.of(context).primaryColor,
              ),
              const Expanded(
                child: TabBar(tabs: [
                  Tab(text: "Audio"),
                  Tab(text: "Application"),
                  Tab(text: "Info"),
                ]),
              ),
            ],
          ),
          customPrefferedSize: const Size.fromHeight(75),
        ),
        body: const TabBarView(children: [
          // TODO: setup the other pages
          Center(child: Text("Audio havent developed yet")),
          ApplicationSettingsPage(),
          InfoPage(),
        ]),
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.info,
          size: 120,
          color: Colors.white,
        ),
        const Text(
          'ICMU-autoBell',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        Text(
          'Author : Netharu Methmitha',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Links : ",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () async {
                if (!await launch('https://github.com/netharuM')) {
                  throw 'Could not launch github';
                }
              },
              child: const Text('Github'),
            ),
            TextButton(
              onPressed: () async {
                if (!await launch('https://instagram.com/netharuM')) {
                  throw 'Could not launch instagram';
                }
              },
              child: const Text('Instagram'),
            ),
            TextButton(
              onPressed: () async {
                if (!await launch('https://github.com/netharuM/auto-bell')) {
                  throw 'Could not launch Source Code';
                }
              },
              child: const Text('Source Code'),
            )
          ],
        )
      ],
    );
  }
}

class ApplicationSettingsPage extends StatefulWidget {
  const ApplicationSettingsPage({Key? key}) : super(key: key);

  @override
  State<ApplicationSettingsPage> createState() =>
      _ApplicationSettingsPageState();
}

class _ApplicationSettingsPageState extends State<ApplicationSettingsPage> {
  final Settings _settings = Settings.instance;
  late bool _launchOnStartup;
  late bool _preventClose;

  @override
  void initState() {
    super.initState();
    _launchOnStartup = false;
    _preventClose = false;
    _init();
  }

  Future<void> _init() async {
    bool? launchOnStartup = await _settings.getLaunchOnStartup;
    bool? preventClose = await _settings.getPreventClose;
    if (launchOnStartup == null) {
      await _settings.setLaunchOnStartup(false);
      launchOnStartup = false;
    }
    setState(() {
      _launchOnStartup = launchOnStartup!;
      _preventClose = preventClose!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TickOption(
          value: _launchOnStartup,
          text: "Launch on startup",
          onChanged: (bool value) {
            setState(() {
              _launchOnStartup = value;
            });
            _settings.setLaunchOnStartup(value);
          },
        ),
        TickOption(
          value: _preventClose,
          text: "prevent close",
          onChanged: (bool value) {
            setState(() {
              _preventClose = value;
            });
            _settings.setPreventClose(value);
          },
        ),
      ],
    );
  }
}

class TickOption extends StatelessWidget {
  final bool value;
  final String text;
  final void Function(bool) onChanged;
  const TickOption(
      {Key? key,
      required this.value,
      required this.onChanged,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(text),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}