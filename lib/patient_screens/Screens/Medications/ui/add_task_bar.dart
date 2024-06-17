import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:patient/patient_screens/Screens/Medications/controllers/task.controller.dart';
import 'package:patient/patient_screens/Screens/Medications/models/task.dart';
import 'package:patient/patient_screens/Screens/Medications/theme/theme.dart';
import 'package:patient/patient_screens/Screens/Medications/ui/widgets/button.dart';
import 'package:patient/patient_screens/Screens/Medications/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;
  final String selectedRepeat;

  const AddTaskPage({Key? key, this.task, this.selectedRepeat = 'Daily'})
      : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat("hh:mm a")
      .format(DateTime.now().add(const Duration(minutes: 2)))
      .toString();
  String _endTime = DateFormat("hh:mm a")
      .format(DateTime.now().add(const Duration(minutes: 10)))
      .toString();

  int _selectedRemind = 0;
  List<int> remindList = [0, 5, 10, 15, 20, 25, 30];

  late String selectedRepeat = widget.selectedRepeat;
  List<String> repeatList = ["Daily", "Weekly", "Monthly", "One time"];

  int _selectedColor = 0;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _noteController.text = widget.task!.note;
      _selectedDate = DateFormat.yMd().parse(widget.task!.date!);
      _startTime = widget.task!.startTime!;
      _endTime = widget.task!.endTime!;
      _selectedRemind = widget.task!.remind!;
      selectedRepeat = widget.task!.repeat!;
      _selectedColor = widget.task!.color!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleBar(),
              _inputField(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: Get.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      backgroundColor: context.theme.colorScheme.background,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [],
    );
  }

  _titleBar() {
    return Text(widget.task == null ? "Add Medication" : "Update Medication",
        style: headingStyle);
  }

  _getDateFromUser() async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 4)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 8)),
    );

    if (pickerDate != null) {
      setState(() {
        _selectedDate = pickerDate;
      });
    } else {
      Get.snackbar(
        "Error Occured!",
        "Date is not selected",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickTime = await _showTimePicker();

    if (pickTime != null) {
      // ignore: use_build_context_synchronously
      String formatedTime = pickTime.format(context);

      setState(() {
        if (isStartTime) {
          _startTime = formatedTime;
        } else {
          _endTime = formatedTime;
        }
      });
    } else {
      Get.snackbar(
        "Error Occured!",
        "Time is not selected",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(":")[0]),
        minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
      ),
    );
  }

  _inputField() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          MyInputField(
            title: "Medicine",
            hint: "Enter your medicine",
            controller: _titleController,
          ),
          MyInputField(
            title: "Medical Note",
            hint: "Enter your Medical note",
            controller: _noteController,
          ),
          MyInputField(
            title: "Date",
            hint: DateFormat.yMd().format(_selectedDate),
            widget: IconButton(
              onPressed: () => {
                _getDateFromUser(),
              },
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.grey,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: MyInputField(
                  title: "Start Time",
                  hint: _startTime,
                  widget: IconButton(
                    onPressed: () => {
                      _getTimeFromUser(isStartTime: true),
                    },
                    icon: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: MyInputField(
                  title: "End Time",
                  hint: _endTime,
                  widget: IconButton(
                    onPressed: () => {
                      _getTimeFromUser(isStartTime: false),
                    },
                    icon: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          MyInputField(
            title: "Remind",
            hint: "$_selectedRemind minutes early",
            widget: DropdownButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
              iconSize: 32,
              elevation: 4,
              padding: const EdgeInsets.only(right: 5),
              style: subTitleStyle,
              underline: Container(
                height: 0,
                color: Colors.transparent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRemind = int.parse(newValue!);
                });
              },
              items: remindList.map<DropdownMenuItem<String>>((int value) {
                return DropdownMenuItem<String>(
                  value: value.toString(),
                  child: Text(
                    "$value minutes early",
                    style: subTitleStyle,
                  ),
                );
              }).toList(),
            ),
          ),
          MyInputField(
            title: "Repeat",
            hint: selectedRepeat,
            widget: DropdownButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
              iconSize: 32,
              elevation: 4,
              padding: const EdgeInsets.only(right: 5),
              style: subTitleStyle,
              underline: Container(
                height: 0,
                color: Colors.transparent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRepeat = newValue!;
                });
              },
              items: repeatList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: subTitleStyle,
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _colorPallet(),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          MyButton(
            label:
                widget.task == null ? "Create Medication" : "Update Medication",
            onTap: () => _validateData(),
          ),
        ],
      ),
    );
  }

  _validateData() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      // Add to database
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "All field is required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.white : Colors.grey,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 35,
        ),
        colorText: Colors.red,
      );
    }
  }

  _colorPallet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Medicine type",
          style: titleStyle,
        ),
        Wrap(
          children: List<Widget>.generate(4, (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: index == 0
                          ? primaryColor
                          : index == 1
                              ? pinkColor
                              : index == 2
                                  ? yellowishColor
                                  : greenColor,
                      child: Icon(
                        _selectedColor == index ? Icons.done : null,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(
                        height:
                            4), // Add spacing between the CircleAvatar and the image
                    Image.asset(
                      index == 0
                          ? 'assets/icons/medicine.png'
                          : index == 1
                              ? 'assets/icons/eye-drops.png'
                              : index == 2
                                  ? 'assets/icons/syringe-outline.png'
                                  : 'assets/icons/syrup.png',
                      width: 91,
                      height: 91,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _addTaskToDb() async {
    Task task = Task(
      id: widget.task?.id,
      title: _titleController.text,
      note: _noteController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: selectedRepeat,
      color: _selectedColor,
      isCompleted: widget.task?.isCompleted ?? 0,
      createdAt:
          widget.task?.createdAt ?? DateFormat.yMd().format(DateTime.now()),
      updatedAt: DateFormat.yMd().format(DateTime.now()),
    );

    if (widget.task == null) {
      // Add a new task to the database
      await _taskController.addTask(task: task);
    } else {
      // Update the existing task in the database
      await _taskController.updateTaskInfo(task);
    }
    // Navigate back to the task list
    Get.back();
  }
}
