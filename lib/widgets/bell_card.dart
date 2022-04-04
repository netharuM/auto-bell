import 'package:auto_bell/models/bell.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BellCard extends StatefulWidget {
  final Bell bell;
  final Function(Bell bell)? onTap;
  final Function(Bell bell)? onDelete;
  final Function(Bell bell)? onDisabled;
  final Function(Bell bell)? onEnabled;
  final Function(Bell bell)? onPlay;
  final Function(Bell bell)? onStop;
  const BellCard({
    Key? key,
    this.onTap,
    this.onDelete,
    this.onDisabled,
    this.onEnabled,
    this.onPlay,
    this.onStop,
    required this.bell,
  }) : super(key: key);

  @override
  State<BellCard> createState() => _BellCardState();
}

class _BellCardState extends State<BellCard> {
  bool _playing = false;
  bool _activated = false;
  bool _timerActivated = false;

  @override
  void initState() {
    super.initState();
    widget.bell.onPlay = () {
      setState(() {
        _playing = true;
      });
    };
    widget.bell.onStop = () {
      setState(() {
        _playing = false;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    _activated = widget.bell.activateOnInit;
    _timerActivated = widget.bell.timerActive;
    widget.bell.onPlay ??= () {
      setState(() {
        _playing = true;
      });
    };
    widget.bell.onStop ??= () {
      setState(() {
        _playing = false;
      });
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onTap != null) widget.onTap!(widget.bell);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  message: _timerActivated
                      ? 'timer activated'
                      : 'timer is not active',
                  child: Container(
                    width: 130,
                    height: 50,
                    // margin: const EdgeInsets.only(left: 4, right: 22),
                    decoration: BoxDecoration(
                      // color: _timerActivated
                      //     ? const Color(0xff53a679)
                      //     : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: _timerActivated
                            ? const Color(0xff53a679)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat("HH:mm").format(widget.bell.dateTime),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: _timerActivated
                              ? FontStyle.italic
                              : FontStyle.normal,
                          decoration: _timerActivated
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                          color: widget.bell.activateable
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                // title and the description
                Flexible(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.bell.title ?? 'untitled',
                          style: TextStyle(
                            color: widget.bell.activateable
                                ? Colors.white
                                : Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.bell.description ?? 'unknown description',
                          style: TextStyle(
                            color: widget.bell.activateable
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // belll tools
                Row(
                  children: [
                    IconButton(
                      tooltip: _activated
                          ? (_playing ? 'stop' : 'play')
                          : 'disabled',
                      onPressed: _activated
                          ? (_playing
                              ? () {
                                  if (widget.onStop != null) {
                                    widget.onStop!(widget.bell);
                                  }
                                }
                              : () {
                                  if (widget.onPlay != null) {
                                    widget.onPlay!(widget.bell);
                                  }
                                })
                          : () {},
                      icon: Icon(_playing
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded),
                      color: _activated
                          ? (_playing
                              ? const Color(0xfff1a522)
                              : const Color(0xff53a679))
                          : Colors.grey,
                    ),
                    IconButton(
                      tooltip: widget.bell.activateable
                          ? (_activated ? 'deactivate' : 'activate')
                          : 'unable to activate',
                      onPressed: widget.bell.activateable
                          ? (_activated
                              ? () {
                                  if (widget.onDisabled != null) {
                                    widget.onDisabled!(widget.bell);
                                  }
                                }
                              : () {
                                  if (widget.onEnabled != null) {
                                    widget.onEnabled!(widget.bell);
                                  }
                                })
                          : () {},
                      icon: Icon(_activated
                          ? Icons.alarm_off_rounded
                          : Icons.alarm_on_rounded),
                      color: widget.bell.activateable
                          ? (_activated
                              ? const Color(0xffe5c07b)
                              : const Color(0xff98c379))
                          : Colors.grey,
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () {
                        if (widget.onDelete != null) {
                          widget.onDelete!(widget.bell);
                        }
                      },
                      icon: const Icon(Icons.delete),
                      color: const Color(0xffff4473),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
