import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/model/course/course_main_extra_json.dart';
import 'package:flutter_app/src/model/course_table/course_table_json.dart';
import 'package:flutter_app/src/task/course/course_extra_info_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';

class CourseInfoPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  CourseInfoPage(this.studentId, this.courseInfo);

  @override
  _CourseInfoPageState createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage>
    with AutomaticKeepAliveClientMixin {
  CourseMainInfoJson courseMainInfo;
  CourseExtraInfoJson courseExtraInfo;
  bool isLoading = true;
  final List<Widget> courseData = [];
  final List<Widget> listItem = [];
  bool canPop = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    BackButtonInterceptor.add(myInterceptor);
    Future.delayed(Duration.zero, () {
      _addTask();
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (!canPop) {
      Get.back();
    }
    return !canPop;
  }

  void _addTask() async {
    courseMainInfo = widget.courseInfo.main;
    String courseId = courseMainInfo.course.id;
    TaskFlow taskFlow = TaskFlow();
    var task = CourseExtraInfoTask(courseId);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      courseExtraInfo = task.result;
    }

    listItem
        .add(_buildCourseInfo(R.current.semester, courseExtraInfo.semester));
    listItem
        .add(_buildCourseInfo(R.current.courseId, courseExtraInfo.courseNo));
    listItem.add(
        _buildCourseInfo(R.current.courseName, courseExtraInfo.courseName));
    listItem.add(
        _buildCourseInfo(R.current.instructor, courseExtraInfo.courseTeacher));
    listItem.add(_buildCourseInfo(
        "${R.current.courseTimes}/${R.current.practicalTimes}",
        sprintf("%s/%s",
            [courseExtraInfo.courseTimes, courseExtraInfo.practicalTimes])));
    listItem.add(_buildCourseInfo(
        R.current.requireOption,
        sprintf("%s/%s",
            [courseExtraInfo.requireOption, courseExtraInfo.allYear])));

    listItem.add(_buildCourseInfo(
        R.current.choosePeople,
        sprintf("%s ( %s / %s )", [
          courseExtraInfo.allStudent,
          courseExtraInfo.chooseStudent,
          courseExtraInfo.threeStudent
        ])));
    try {
      listItem.add(_buildCourseInfo(
          R.current.chooseUpBoundary,
          sprintf(R.current.choosePeopleString, [
            courseExtraInfo.restrict1,
            courseExtraInfo.restrict2,
            int.parse(courseExtraInfo.nTNURestrict) +
                int.parse(courseExtraInfo.nTURestrict)
          ])));
    } catch (e) {}

    listItem.add(
        _buildCourseInfo(R.current.classRoomNo, courseExtraInfo.classRoomNo));
    listItem.add(
        _buildCourseInfo(R.current.coreAbility, courseExtraInfo.coreAbility));
    listItem
        .add(_buildCourseInfo(R.current.courseURL, courseExtraInfo.courseURL));
    listItem.add(
        _buildCourseInfo(R.current.courseObject, courseExtraInfo.courseObject));
    listItem.add(_buildCourseInfo(
        R.current.courseContent, courseExtraInfo.courseContent));
    listItem.add(_buildCourseInfo(
        R.current.courseTextbook, courseExtraInfo.courseTextbook));
    listItem.add(_buildCourseInfo(
        R.current.courseRefbook, courseExtraInfo.courseRefbook));
    listItem.add(
        _buildCourseInfo(R.current.courseNote, courseExtraInfo.courseNote));
    listItem.add(_buildCourseInfo(
        R.current.courseGrading, courseExtraInfo.courseGrading));
    listItem.add(
        _buildCourseInfo(R.current.courseRemark, courseExtraInfo.courseRemark));
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          (isLoading)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: getAnimationList(),
                ),
        ],
      ),
    );
  }

  Widget getAnimationList() {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: listItem.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, //讓透明部分有反應
                  child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: listItem[index]),
                  onTap: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseInfo(String text, String info) {
    if (info == null || info.isEmpty) {
      return null;
    }
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Card(
        child: ListTile(
          title: Text(text),
          subtitle: Text(info),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}