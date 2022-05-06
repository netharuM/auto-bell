import 'dart:math';
import 'package:auto_bell/inheited_widgets.dart';
import 'package:auto_bell/models/bell.dart';
import 'package:auto_bell/pages/bell_errors_page.dart';
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
  final bool disableActions;
  final bool? shake;
  const BellCard({
    Key? key,
    this.onTap,
    this.onDelete,
    this.onDisabled,
    this.onEnabled,
    this.onPlay,
    this.onStop,
    this.disableActions = false,
    required this.bell,
    this.shake,
  }) : super(key: key);

  @override
  State<BellCard> createState() => _BellCardState();
}

class _BellCardState extends State<BellCard> {
  bool _playing = false;
  bool _activatedOnInit = false;
  bool _timerActivated = false;
  bool _activateable = false;
  BellErrors? _bellErrorsList;

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
    checkForErrors();
  }

  Future<void> checkForErrors() async {
    bool activateable = await widget.bell.activateable;
    if (activateable == false) {
      BellErrors bellErrors = await widget.bell.getErrors;
      if (_bellErrorsList != bellErrors) {
        debugPrint('updating the errorsList');
        setState(() {
          _bellErrorsList = bellErrors;
        });
      }
    }
    if (_activateable != activateable) {
      setState(() {
        _activateable = activateable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _activatedOnInit = widget.bell.activateOnInit;
    _timerActivated = widget.bell.timerActive;
    checkForErrors();
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
    return ShakeWidget(
      shake: widget.shake ?? BellCardData.of(context).shake,
      child: Container(
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
        child: IgnorePointer(
          ignoring: widget.disableActions,
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
                    TimerActiveIndicator(
                      timerActivated: _timerActivated,
                      activateable: _activateable,
                      dateTime: widget.bell.dateTime,
                      bellErrors: _bellErrorsList,
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
                                color:
                                    _activateable ? Colors.white : Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.bell.description ?? 'unknown description',
                              style: TextStyle(
                                color:
                                    _activateable ? Colors.white : Colors.grey,
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
                          tooltip: _activatedOnInit && _activateable
                              ? (_playing ? 'stop' : 'play')
                              : 'disabled',
                          onPressed: _activatedOnInit && _activateable
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
                          icon: _activatedOnInit && _activateable
                              ? Icon(_playing
                                  ? Icons.stop_rounded
                                  : Icons.play_arrow_rounded)
                              : const Icon(Icons.play_disabled_outlined),
                          color: _activatedOnInit && _activateable
                              ? (_playing
                                  ? const Color(0xfff1a522)
                                  : const Color(0xff53a679))
                              : Colors.grey,
                        ),
                        IconButton(
                          tooltip: _activateable
                              ? (_activatedOnInit ? 'deactivate' : 'activate')
                              : 'unable to activate',
                          onPressed: _activateable
                              ? (_activatedOnInit
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
                          icon: Icon(_activatedOnInit
                              ? Icons.alarm_off_rounded
                              : Icons.alarm_on_rounded),
                          color: _activateable
                              ? (_activatedOnInit
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
        ),
      ),
    );
  }
}

/// a widget that animates the border of the timer to blink in order to indicate that the bell timer has been activated
class TimerActiveIndicator extends StatefulWidget {
  final bool timerActivated;
  final bool activateable;
  final DateTime dateTime;
  final BellErrors? bellErrors;
  const TimerActiveIndicator({
    Key? key,
    required this.timerActivated,
    required this.activateable,
    required this.dateTime,
    this.bellErrors,
  }) : super(key: key);
  @override
  State<TimerActiveIndicator> createState() => _TimerActiveIndicatorState();
}

class _TimerActiveIndicatorState extends State<TimerActiveIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.activateable && widget.timerActivated) ||
        (widget.activateable == false &&
            widget.bellErrors != null &&
            widget.bellErrors!.isThereErrors)) {
      _controller.repeat(reverse: true);
    } else {
      _controller.reset();
    }

    if (widget.activateable ||
        (widget.bellErrors == null || !widget.bellErrors!.isThereErrors)) {
      return Tooltip(
        message:
            widget.timerActivated ? 'timer activated' : 'timer is not active',
        child: SizedBox(
          width: 130,
          height: 50,
          child: DecoratedBoxTransition(
            decoration: DecorationTween(
              begin: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              end: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(
                    0xff53a679,
                  ),
                ),
              ),
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.ease,
              ),
            ),
            child: Center(
              child: Text(
                DateFormat("HH:mm").format(widget.dateTime),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: widget.timerActivated
                      ? FontStyle.italic
                      : FontStyle.normal,
                  decoration: widget.timerActivated
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                  color: widget.activateable ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Tooltip(
        message: 'there are errors click to see them',
        child: InkWell(
          splashColor: const Color(0xfff14c4c).withOpacity(0.5),
          highlightColor: const Color(0xfff14c4c).withOpacity(0.2),
          hoverColor: const Color(0xfff14c4c).withOpacity(0.1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BellErrorsPage(
                  bellErrors: widget.bellErrors!,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            width: 130,
            height: 50,
            child: DecoratedBoxTransition(
              decoration: DecorationTween(
                begin: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                ),
                end: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: const Color(0xfff14c4c),
                  ),
                ),
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.ease,
                ),
              ),
              child: Center(
                child: Text(
                  DateFormat("HH:mm").format(widget.dateTime),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: widget.timerActivated
                        ? FontStyle.italic
                        : FontStyle.normal,
                    decoration: widget.timerActivated
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                    color: widget.activateable ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

/// this will shake the child component
/// designed to indicate that the child widget is draggable
/// like in the IOS apps start to shake when dragging
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  final Offset end;
  const ShakeWidget({
    Key? key,
    required this.child,
    required this.shake,
    this.end = const Offset(0.005, 0.0),
  }) : super(key: key);

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
          begin: Offset.zero, end: widget.end)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int random(min, max) {
      return min + Random().nextInt(max - min);
    }

    if (widget.shake) {
      Future.delayed(Duration(milliseconds: random(0, 500)), () {
        _controller.repeat(reverse: true);
      });
    } else {
      _controller.stop();
    }
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
