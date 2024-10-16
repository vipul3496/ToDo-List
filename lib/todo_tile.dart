import 'package:flutter/material.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;

  const ToDoTile({
    Key? key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Container(
        height: 60.0,
        color: Colors.cyan[50],
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
              activeColor: Colors.purple[800],
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        decoration: taskCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Set the maximum number of lines
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
