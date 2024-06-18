import 'dart:developer';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patient/patient_screens/Screens/Medications/controllers/task.controller.dart';
import 'package:patient/patient_screens/Screens/Medications/models/task.dart';
import 'package:patient/patient_screens/Screens/Medications/services/notification_services.dart';
import 'package:patient/patient_screens/Screens/Medications/services/theme_services.dart';
import 'package:patient/patient_screens/Screens/Medications/theme/theme.dart';
import 'package:patient/patient_screens/Screens/Medications/ui/add_task_bar.dart';
import 'package:patient/patient_screens/Screens/Medications/ui/widgets/button.dart';
import 'package:patient/patient_screens/Screens/Medications/ui/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> filterTaskList = [];

  double? width;
  double? height;

  // ignore: prefer_typing_uninitialized_variables
  var notifyHelper;
  String? deviceName;
  bool shorted = false;
  // setting state for selected date
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());

  @override
  void initState() {
    super.initState();

    filterTaskList = _taskController.taskList;

    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    notifyHelper.requestAndroidPermissions();
  }

  // Sorting function
  List<Task> _shortNotesByModifiedDate(List<Task> taskList) {
    taskList.sort((a, b) => a.updatedAt!.compareTo(b.updatedAt!));

    if (shorted) {
      taskList = List.from(taskList.reversed);
    } else {
      taskList = List.from(taskList.reversed);
    }

    shorted = !shorted;

    return taskList;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    // print(filterTaskList[0].updatedAt);
    return GetBuilder<ThemeServices>(
      init: ThemeServices(),
      builder: (themeServices) => Scaffold(
        backgroundColor: Colors.white,
        // appBar: _appBar(themeServices),
        body: Column(
          children: [
            _addTaskBar(),
            _dateBar(),
            const SizedBox(height: 10),
            _showTasks(),
          ],
        ),
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat("EEE, d MMM yyyy").format(_selectedDate),
                style: subHeadingStyle.copyWith(fontSize: width! * .049),
              ),
              Text(
                (_selectedDate.year == DateTime.now().year &&
                        _selectedDate.month == DateTime.now().month &&
                        _selectedDate.day == DateTime.now().day)
                    ? "Today"
                    : DateFormat("d,EEEEEEEEEEE ").format(_selectedDate),
                style: headingStyle.copyWith(fontSize: width! * .06),
              )
            ],
          ),
          MyButton(
            label: "+ Add Medication",
            onTap: () async {
              await Get.to(() => const AddTaskPage());
              _taskController.getTasks();
            },
          )
        ],
      ),
    );
  }

  _dateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10),
      child: DatePicker(
        DateTime.now(),
        height: 125,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryColor,
        selectedTextColor: Colors.white,
        onDateChange: (date) {
          // selected date in the medication home screen
          setState(() {
            _selectedDate = date;
            log(_selectedDate.toString());
          });
        },
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: width! * 0.039,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: width! * 0.037,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: width! * 0.030,
            fontWeight: FontWeight.normal,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: filterTaskList.length,
          itemBuilder: (_, index) {
            Task task = filterTaskList[filterTaskList.length - 1 - index];
            log("test task ${task.toJson()}");
            log("test filterTaskList $filterTaskList");

            DateTime date = _parseDateTime(task.startTime.toString());
            var myTime = DateFormat.Hm().format(date);
            var remind = DateFormat.Hm()
                .format(date.subtract(Duration(minutes: task.remind!)));
            int mainTaskNotificationId = task.id!.toInt();
            int reminderNotificationId = mainTaskNotificationId + 1;

            DateTime selectedDate =
                _selectedDate; // Assuming _selectedDate is of type DateTime

            // Check if the task date is on or before the selected date
            if (DateFormat('MM/dd/yyyy')
                .parse(task.date!)
                .isAfter(selectedDate)) {
              return Container();
            }

            // Determine if the task should be displayed based on repeat frequency
            bool shouldDisplayTask = _shouldDisplayTask(task, selectedDate);
            if (!shouldDisplayTask) {
              return Container();
            }

            // Schedule notifications if applicable
            if (task.remind! > 0) {
              notifyHelper.remindNotification(
                int.parse(remind.split(":")[0]), // hour
                int.parse(remind.split(":")[1]), // minute
                task,
              );
              notifyHelper.cancelNotification(reminderNotificationId);
            }

            notifyHelper.scheduledNotification(
              int.parse(myTime.split(":")[0]), // hour
              int.parse(myTime.split(":")[1]), // minute
              task,
            );
            notifyHelper.cancelNotification(reminderNotificationId);

            // Update if daily task is completed to reset it every 11:59 pm if not completed
            if (task.repeat == "Daily" &&
                DateTime.now().hour == 23 &&
                DateTime.now().minute == 59) {
              _taskController.markTaskAsCompleted(task.id!, false);
            }

            return AnimationConfiguration.staggeredList(
              position: index,
              child: SlideAnimation(
                child: FadeInAnimation(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showBottomSheet(context, task);
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          Get.to(() => AddTaskPage(task: task));
                        },
                        child: TaskTile(task),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  bool _shouldDisplayTask(Task task, DateTime selectedDate) {
    DateTime taskDate = DateFormat('MM/dd/yyyy').parse(task.date!);

    if (task.repeat == "Daily") {
      return true;
    } else if (task.repeat == "Weekly" &&
        DateFormat('EEEE').format(selectedDate) ==
            DateFormat('EEEE').format(taskDate)) {
      return true;
    } else if (task.repeat == "Monthly" &&
        DateFormat('dd').format(selectedDate) ==
            DateFormat('dd').format(taskDate)) {
      return true;
    } else if (task.repeat == "One time" &&
        taskDate.isAtSameMomentAs(selectedDate)) {
      return true;
    } else if (task.date == DateFormat('MM/dd/yyyy').format(selectedDate)) {
      return true;
    }
    return false;
  }

  void _scheduleNotifications(
      String remind, String myTime, int reminderNotificationId, Task task) {
    if (task.remind! > 0) {
      notifyHelper.remindNotification(
        int.parse(remind.split(":")[0]), // hour
        int.parse(remind.split(":")[1]), // minute
        task,
      );
      notifyHelper.cancelNotification(reminderNotificationId);
    }

    notifyHelper.scheduledNotification(
      int.parse(myTime.split(":")[0]), // hour
      int.parse(myTime.split(":")[1]), // minute
      task,
    );
    notifyHelper.cancelNotification(reminderNotificationId);
  }

  DateTime _parseDateTime(String timeString) {
    // Split the timeString into components (hour, minute, period)
    List<String> components = timeString.split(' ');

    // Extract and parse the hour and minute
    List<String> timeComponents = components[0].split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    // If the time string contains a period (AM or PM),
    //adjust the hour for 12-hour format
    if (components.length > 1) {
      String period = components[1];
      if (period.toLowerCase() == 'pm' && hour < 12) {
        hour += 12;
      } else if (period.toLowerCase() == 'am' && hour == 12) {
        hour = 0;
      }
    }

    return DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hour, minute);
  }

  void _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        width: MediaQuery.of(context).size.width,
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.28
            : MediaQuery.of(context).size.height * 0.35,
        color: Colors.white,
        child: Column(children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
          ),
          const Spacer(),
          _bottomSheetButton(
            label: "change medicen",
            color: Colors.green[400]!,
            onTap: () {
              Get.back();
              Get.to(() => AddTaskPage(task: task));
            },
            context: context,
            icon: Icons.update,
          ),
          task.isCompleted == 1
              ? Container()
              : _bottomSheetButton(
                  label: "took my medicen",
                  color: primaryColor,
                  onTap: () {
                    Get.back();
                    _taskController.markTaskAsCompleted(task.id!, true);
                    _taskController.getTasks();
                  },
                  context: context,
                  icon: Icons.check,
                ),
          _bottomSheetButton(
            label: "Delete this medicen",
            color: Colors.red[400]!,
            onTap: () {
              Get.back();
              showDialog(
                  context: context,
                  builder: (_) => _alertDialogBox(context, task));
              // _taskController.deleteTask(task.id!);
            },
            context: context,
            icon: Icons.delete,
          ),
          const SizedBox(height: 15),
          _bottomSheetButton(
            label: "Close",
            color: Colors.red[400]!.withOpacity(0.5),
            isClose: true,
            onTap: () {
              Get.back();
            },
            context: context,
            icon: Icons.close,
          ),
        ]),
      ),
    );
  }

  _alertDialogBox(BuildContext context, Task task) {
    return AlertDialog(
      backgroundColor: context.theme.colorScheme.background,
      icon: const Icon(Icons.warning, color: Colors.red),
      title: const Text("Are you sure you want to delete?"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Get.back();
              _taskController.deleteTask(task.id!);
              // Cancel delete notification
              if (task.remind! > 4) {
                notifyHelper.cancelNotification(task.id! + 1);
              }
              _showTasks();
            },
            child: const SizedBox(
              width: 60,
              child: Text(
                "Yes",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Get.back();
            },
            child: const SizedBox(
              width: 60,
              child: Text(
                "No",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _bottomSheetButton(
      {required String label,
      required BuildContext context,
      required Color color,
      required Function()? onTap,
      IconData? icon,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 7),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,

        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose
                ? Get.isDarkMode
                    ? Colors.grey[700]!
                    : Colors.grey[300]!
                : color,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : color,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: isClose
                        ? Get.isDarkMode
                            ? Colors.white
                            : Colors.black
                        : Colors.white,
                    size: 30,
                  )
                : const SizedBox(),
            Text(
              label,
              style: titleStyle.copyWith(
                fontSize: 18,
                color: isClose
                    ? Get.isDarkMode
                        ? Colors.white
                        : Colors.black
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> getTasksCompletedToday(List<Task> taskList) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    return taskList.where((task) {
      if (task.completedAt == null) {
        return false;
      }

      DateTime completedDate = DateTime.parse(task.completedAt!);
      completedDate = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      return completedDate == today;
    }).toList();
  }
}
