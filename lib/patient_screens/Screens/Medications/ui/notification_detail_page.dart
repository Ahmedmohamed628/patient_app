import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:patient/dialog_utils.dart';
import 'package:patient/patient_screens/Screens/Medications/controllers/task.controller.dart';
import 'package:patient/patient_screens/Screens/Medications/ui/add_task_bar.dart';
import 'package:patient/theme/theme.dart';

class NotificationDetailPage extends StatefulWidget {
  final String? label;

  const NotificationDetailPage({Key? key, required this.label})
      : super(key: key);

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  final _taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.white,
      appBar: _appBar(context, widget.label),
      body: Center(
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Lottie.asset('assets/images/taking medicen.json')),
            Container(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(78, 90, 232, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        LineAwesomeIcons.capsules,
                        color: MyTheme.white,
                        size: 50,
                      ),
                      Text(
                        "Your medication is: ",
                        style: TextStyle(
                          color: MyTheme.white,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    "${widget.label.toString().split("|")[0]}",
                    style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    children: [
                      Icon(
                        LineAwesomeIcons.medical_file,
                        color: MyTheme.white,
                        size: 50,
                      ),
                      Text(
                        "Your medical note is: ",
                        style: TextStyle(
                          color: MyTheme.white,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    "${widget.label.toString().split("|")[1]}",
                    style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    children: [
                      Icon(
                        LineAwesomeIcons.clock,
                        color: MyTheme.white,
                        size: 50,
                      ),
                      Text(
                        "You should take it at: ",
                        style: TextStyle(
                          color: MyTheme.white,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    "${widget.label.toString().split("|")[2]}",
                    style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Text(
              "Have you taken your medication?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.005,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.09,
              child: Row(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.05,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: SizedBox(
                      child: Image.asset("assets/images/Right.png"),
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                  GestureDetector(
                    onTap: () async {
                      DialogUtils.showMessage(
                        context,
                        title:
                            '${widget.label.toString().split("|")[0]} medicen',
                        'If you don\'t want to take it now, reassign it.',
                        barrierDismissible: false,
                        posActionName: 'Ok',
                        posAction: () async {
                          await Get.to(() => const AddTaskPage(
                                selectedRepeat: "One time",
                              ));
                          _taskController.getTasks();
                        },
                        negActionName: 'Cancel',
                        negAction: () {},
                      );
                    },
                    child: SizedBox(
                      child: Image.asset("assets/images/Wrong.png"),
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context, label) {
    return AppBar(
      backgroundColor: MyTheme.redColor,
      leading: IconButton(
        icon: Icon(LineAwesomeIcons.angle_left, color: MyTheme.redColor),
        onPressed: () {},
      ),
      // elevation: 0,
      title: Text(
        "${label.toString().split("|")[0]} Reminder",
        style: TextStyle(
          color: MyTheme.white,
        ),
      ),
    );
  }
}
