import 'package:flutter/material.dart';

class SelectDays extends StatefulWidget {
  final List<bool> days;
  final Function()? onChange;
  const SelectDays({
    Key? key,
    this.onChange,
    this.days = const [true, true, true, true, true],
  }) : super(key: key);

  @override
  State<SelectDays> createState() => _SelectDaysState();
}

class _SelectDaysState extends State<SelectDays> {
  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < widget.days.length; i++)
          Tooltip(
            message: _dayNames[i],
            child: InkWell(
              onTap: () {
                setState(() {
                  widget.days[i] = !widget.days[i];
                  if (widget.onChange != null) widget.onChange!();
                });
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.days[i]
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    _dayNames[i].substring(0, 2),
                    style: TextStyle(
                      color: widget.days[i]
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
