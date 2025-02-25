import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/ad/ad_manager.dart';
import 'package:flutter_app/src/file/my_downloader.dart';
import 'package:flutter_app/src/notifications/notifications.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/src/util/language_utils.dart';
import 'package:flutter_app/src/util/remote_config_utils.dart';
import 'package:flutter_app/src/util/route_utils.dart';
import 'package:flutter_app/src/version/app_version.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:flutter_app/ui/pages/calendar/calendar_page.dart';
import 'package:flutter_app/ui/pages/course_table/course_table_page.dart';
import 'package:flutter_app/ui/pages/other/other_page.dart';
import 'package:flutter_app/ui/pages/score/score_page.dart';
import 'package:flutter_app/ui/pages/subsystem/sub_system_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  final _pageController = PageController();
  int _currentIndex = 0;
  int _closeAppCount = 0;
  List<Widget> _pageList = [];

  @override
  void initState() {
    appInit();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    AnalyticsUtils.observer
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    AnalyticsUtils.observer.unsubscribe(this);
    super.dispose();
  }

  void appInit() async {
    R.set(context);
    bool catchError =
        await Model.instance.getInstance(); //一定要先getInstance()不然無法取得資料
    try {
      if (!(await Model.instance.getAgreeContributor())) {
        RouteUtils.toAgreePrivacyPolicyScreen();
        return;
      }
      await RemoteConfigUtils.init();
      await initLanguage();
      APPVersion.initAndCheck().then((needUpdate) {
        if (!needUpdate) {
          RemoteConfigUtils.showAnnouncementDialog();
        }
      });
      AdManager.init();
      Log.init();
      initFlutterDownloader();
      initNotifications();
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
    }
    setState(() {
      _pageList = [];
      _pageList.add(const CourseTablePage());
      _pageList.add(const SubSystemPage());
      _pageList.add(const CalendarPage());
      _pageList.add(const ScoreViewerPage());
      _pageList.add(OtherPage(_pageController));
    });
    if (catchError) {
      await Future.delayed(const Duration(milliseconds: 500));
      ErrorDialogParameter parameter =
          ErrorDialogParameter(desc: R.current.loadDataFail);
      parameter.btnCancelOnPress = null;
      parameter.btnOkText = R.current.sure;
      await ErrorDialog(parameter).show();
    }
  }

  void initFlutterDownloader() async {
    await MyDownloader.init();
  }

  void initNotifications() async {
    await Notifications.instance.init();
  }

  Future<void> initLanguage() async {
    await LanguageUtils.init(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget? child) {
        appProvider.navigatorKey = Get.key;
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: _buildPageView(),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    var canPop = Navigator.of(context).canPop();
    //Log.d(canPop.toString());
    if (canPop) {
      Navigator.of(context).pop();
      _closeAppCount = 0;
    } else {
      _closeAppCount++;
      MyToast.show(R.current.closeOnce);
      Future.delayed(const Duration(seconds: 2)).then((_) {
        _closeAppCount = 0;
      });
    }
    return (_closeAppCount >= 2);
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      physics: const NeverScrollableScrollPhysics(),
      children: _pageList, // 禁止滑動
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(
            EvaIcons.clockOutline,
          ),
          label: R.current.titleCourse,
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            EvaIcons.infoOutline,
          ),
          label: R.current.informationSystem,
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            EvaIcons.calendarOutline,
          ),
          label: R.current.calendar,
        ),
        BottomNavigationBarItem(
            icon: const Icon(
              EvaIcons.bookOpenOutline,
            ),
            label: R.current.titleScore),
        BottomNavigationBarItem(
            icon: const Icon(
              EvaIcons.menu,
            ),
            label: R.current.titleOther),
      ],
    );
  }

  void _onPageChange(int index) {
    String screenName = _pageList[index].toString();
    AnalyticsUtils.setScreenName(screenName);
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _onPageChange(_currentIndex);
    });
  }
}
