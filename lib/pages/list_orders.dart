import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/auth_api.dart';
import 'package:wfm/api/base_api.dart';
import 'package:wfm/landing.dart';
import 'package:wfm/main.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:wfm/pages/admin_show_new_installation.dart';
import 'package:wfm/pages/admin_show_troubleshoot_order.dart';
import 'package:wfm/pages/user_screens.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/show_troubleshoot_order.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';
import 'package:wfm/pages/widgets/work_order_tiles.dart';

class WorkOrders extends StatefulWidget {
  final String user, email;
  const WorkOrders({super.key, required this.user, required this.email});

  @override
  State<WorkOrders> createState() => _WorkOrdersState();
}

class _WorkOrdersState extends State<WorkOrders> {
  var ctime;
  DateTimeRange? _dtrFilter;
  late String user = "-",
      email = "-",
      token = "-",
      role = "-",
      organization = "-"; //user info

  final ValueNotifier<Map<String, String?>> filterNotifier = ValueNotifier({
    'type': 'All Orders',
    'status': 'All Status',
    'search': null,
  });

  final ValueNotifier<Map<String, DateTime?>> dateFilterNotifier =
      ValueNotifier({'singleDate': null, 'startDate': null, 'endDate': null});

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences prefs;
  late Future<List<WorkOrder>> _workOrderList;

  Future<void> initMessageHandling() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage); //background message handling

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      num id = num.parse(message.data['id']);
      showOrderSnackbar(context, message.data['type'], id, message.data['name']);
    });
  }

  void _handleMessage(RemoteMessage message) {
    String type = message.data['type'];
    num id = num.parse(message.data['id']);

    if (type == 'SO') {
      Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(
              name: "/showServiceOrder",
            ),
            builder: (context) => ShowServiceOrder(
              orderID: id,
            )),
      );
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(
              name: "/showTroubleshootOrder",
            ),
            builder: (context) =>
                ShowTroubleshootOrder(
                  orderID: id,
                )),
      );
    }
  }

  @override
  void initState() {
    getPrefs();
    _workOrderList = _fetchWorkOrders();
    initMessageHandling();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  setFilter(String value, String filterType, Icon icon) {
    return ListTile(
      leading: icon,
      title: Text(value),
      selectedColor: Colors.indigo,
      selected: filterNotifier.value[filterType] == value ? true : false,
      onTap: () async {
        filterNotifier.value[filterType] = value;
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    user = prefs.getString('user') ?? 'Unauthorized';
    email = prefs.getString('email') ?? 'Unauthorized';
    token = prefs.getString('token') ?? '';
    role = prefs.getString('role') ?? '';
    organization = prefs.getString('organization') ?? '';
    setState(() {});
  }

  Future<List<WorkOrder>> _fetchWorkOrders() async {
    return await WorkOrderApi.getWorkOrderList();
  }

  List<WorkOrder> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          showCursor: false,
          autofocus: false,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.search),
            suffixIconColor: Colors.white,
            label: Text(
              filterNotifier.value['type'] ?? "e",
              style: const TextStyle(color: Colors.white),
            ),
            hintText: "Search order",
            hintStyle: const TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          onEditingComplete: () {
            filterNotifier.value['search'] =
                _searchController.text.toUpperCase();
            setState(() {});
          },
        ),
        actions: [
          Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Icon(Icons.filter_list_outlined, color: dateFilterNotifier.value['singleDate'] != null || dateFilterNotifier.value['startDate'] != null || dateFilterNotifier.value['endDate'] != null ? Colors.deepOrange : null));
          })
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: filterNotifier,
              builder: (context, value, child) => ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 66),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(100),
                                bottomLeft: Radius.circular(100)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(
                                    0.3), // Shadow color with opacity
                                spreadRadius: 2, // Spread radius of the shadow
                                blurRadius: 3, // Blur radius of the shadow
                                offset: const Offset(1.5,
                                    2.5), // Offset of the shadow (horizontal, vertical)
                              )
                            ]),
                        height: 40,
                        width: 284,
                        child: const Center(
                          child: Text(
                            'Filters',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const ListTile(
                    selected: false,
                    tileColor: Colors.indigoAccent,
                    title: Text(
                      'Status',
                      style: TextStyle(fontSize: 16, color: Colors.indigo),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        setFilter(
                            'All Status', 'status', const Icon(Icons.circle)),
                        setFilter('Pending', 'status',
                            const Icon(Icons.circle_notifications)),
                        setFilter('Completed', 'status',
                            const Icon(Icons.check_circle)),
                        setFilter(
                            'Cancelled', 'status', const Icon(Icons.cancel)),
                        setFilter('Returned', 'status',
                            const Icon(Icons.arrow_circle_left_sharp)),
                      ],
                    ),
                  ),
                  const ListTile(
                    title: Text(
                      'Date',
                      style: TextStyle(fontSize: 16, color: Colors.indigo),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 17,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                var today = DateTime.now();
                                dateFilterNotifier.value['singleDate'] =
                                    await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2023),
                                        lastDate: DateTime(
                                            today.year, today.month + 6));
                                setState(() {});
                              },
                              style: dateFilterNotifier.value['singleDate'] != null ? ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.deepOrange)) : null,
                              child: const Text('Single Date')),
                          ElevatedButton(
                              onPressed: () async {
                                var today = DateTime.now();
                                _dtrFilter = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2023),
                                    lastDate:
                                        DateTime(today.year, today.month + 6));
                                dateFilterNotifier.value['startDate'] =
                                    _dtrFilter?.start;
                                dateFilterNotifier.value['endDate'] =
                                    _dtrFilter?.end;
                                dateFilterNotifier.value['endDate'] =
                                    dateFilterNotifier.value['endDate']!
                                        .add(const Duration(days: 1));
                                setState(() {});
                              },
                              style: dateFilterNotifier.value['startDate'] != null && dateFilterNotifier.value['endDate'] != null ? ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.deepOrange)) : null,
                              child: const Text('Range Date')),
                        ],
                      ),
                      const SizedBox(
                        height: 17,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              style: const ButtonStyle(),
                              onPressed: () {
                                dateFilterNotifier.value['singleDate'] = null;
                                dateFilterNotifier.value['startDate'] = null;
                                dateFilterNotifier.value['endDate'] = null;
                                setState(() {});
                              },
                              child: const Text('Reset Date Filter')),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 230,
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(120)),
                gradient:
                    LinearGradient(colors: [Colors.indigo, Colors.deepPurple]),
                color: Colors.indigo,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/img/bg4.jpg'),
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  ListTile(
                    title: Text(widget.user),
                    subtitle: Text(widget.email),
                    textColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            setFilter(
                'All Orders', 'type', const Icon(Icons.assignment_outlined)),
            setFilter('New Installation', 'type',
                const Icon(Icons.add_business_outlined)),
            setFilter('Troubleshoot', 'type', const Icon(Icons.build)),
            // ListTile(
            //   title: const Text('Speed Test'),
            //   leading: const Icon(Icons.speed),
            //   onTap: () async {
            //     SpeedTestUtils.runSpeedTest();
            //   },
            // ),
            const Spacer(),
            const Divider(),
            role == 'Admin'
                ? ListTile(
                    title: const Text('User Management'),
                    leading: const Icon(Icons.person),
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(
                              name: "/listUsers",
                            ),
                            builder: (context) => UsersScreen(
                                  token: token,
                                )),
                      ),
                    },
                  )
                : const SizedBox(),
            ListTile(
              title: const Text('Update Password'),
              leading: const Icon(Icons.lock),
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(
                        name: "/listUsers",
                      ),
                      builder: (context) => UpdatePassword(userEmail: email)),
                ),
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                loadingScreen(context);
                await Future.delayed(const Duration(seconds: 1), () {});
                await logOut();
              },
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            return Future.value(false);
          }
          if (_scaffoldKey.currentState!.isDrawerOpen) {
            _scaffoldKey.currentState!.closeDrawer();
            return Future.value(false);
          }
          if (_scaffoldKey.currentState!.isEndDrawerOpen) {
            _scaffoldKey.currentState!.closeEndDrawer();
            return Future.value(false);
          }
          DateTime now = DateTime.now();
          if (ctime == null ||
              now.difference(ctime) > const Duration(seconds: 2)) {
            //add duration of press gap
            ctime = now;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Press Back Button Again to Exit'),
              backgroundColor: Colors.indigoAccent,
            )); //scaffold message, you can show Toast message too.
            return Future.value(false);
          }
          SystemNavigator.pop();
          return Future.value(true);
        },
        child: Center(
            child: FutureBuilder<List<WorkOrder>>(
                future: _workOrderList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    list = snapshot.data!;

                    if (filterNotifier.value['search'] != null ||
                        filterNotifier.value['search'] != '') {
                      list = list
                          .where((workOrder) => workOrder.woName
                              .contains(filterNotifier.value['search'] ?? ''))
                          .toList();
                    }
                    if (filterNotifier.value['status'] != 'All Status') {
                      list = list
                          .where((workOrder) =>
                              workOrder.status ==
                              filterNotifier.value['status'])
                          .toList();
                    }
                    if (filterNotifier.value['type'] != 'All Orders') {
                      list = list
                          .where((workOrder) =>
                              workOrder.type == filterNotifier.value['type'])
                          .toList();
                    }
                    if (dateFilterNotifier.value['singleDate'] != null) {
                      list = list
                          .where((workOrder) => DateUtils.isSameDay(
                              DateTime.parse(workOrder.startDate ?? ''),
                              dateFilterNotifier.value['singleDate'] ??
                                  DateTime.now()))
                          .toList();
                    }
                    if (dateFilterNotifier.value['startDate'] != null) {
                      list = list
                          .where((workOrder) =>
                              DateTime.parse(workOrder.startDate ?? '').isAfter(
                                  dateFilterNotifier.value['startDate'] ??
                                      DateTime.now()))
                          .toList();
                    }
                    if (dateFilterNotifier.value['endDate'] != null) {
                      list = list
                          .where((workOrder) =>
                              DateTime.parse(workOrder.startDate ?? '')
                                  .isBefore(
                                      dateFilterNotifier.value['endDate'] ??
                                          DateTime.now()))
                          .toList();
                    }
                    return RefreshIndicator(
                      onRefresh: _pullRefresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          WorkOrder wo = list[list.length - index - 1];
                          var logo = 'cts';

                          if (!wo.requestedBy.contains('CTS')) {
                            logo = wo.requestedBy.toLowerCase();
                          }

                          if (wo.type != 'Troubleshoot') {
                            if (role == 'Admin') {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: const RouteSettings(
                                          name: "/adminShowServiceOrder",
                                        ),
                                        builder: (context) =>
                                            AdminShowServiceOrder(
                                              orderID: wo.woId,
                                            )),
                                  );
                                },
                                onLongPress: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: wo.woName));
                                },
                                child: OrderItem(
                                  thumbnail: Image.asset(
                                    'assets/img/logo/$logo.png',
                                    fit: BoxFit.fitWidth,
                                  ),
                                  title: wo.woName,
                                  subtitle: wo.address,
                                  group: '${wo.type} (${wo.status})',
                                  date: wo.date ?? 'Unassigned',
                                  time: wo.time ?? 'Unassigned',
                                  ticketStatus: wo.closedAt == null ? 'Open' : 'Closed',
                                ),
                              );
                            } else {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: const RouteSettings(
                                          name: "/showServiceOrder",
                                        ),
                                        builder: (context) => ShowServiceOrder(
                                              orderID: wo.woId,
                                            )),
                                  );
                                },
                                child: OrderItem(
                                  thumbnail: Image.asset(
                                    'assets/img/logo/$logo.png',
                                    fit: BoxFit.fitWidth,
                                  ),
                                  title: wo.woName,
                                  subtitle: wo.address,
                                  group: '${wo.type} (${wo.status})',
                                  date: wo.date ?? 'Unassigned',
                                  time: wo.time ?? 'Unassigned',
                                  ticketStatus: wo.closedAt == null ? 'Open' : 'Closed',
                                ),
                              );
                            }
                          } else {
                            if (role == 'Admin') {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: const RouteSettings(
                                          name: "/adminShowTroubleshootOrder",
                                        ),
                                        builder: (context) =>
                                            AdminShowTroubleshootOrder(
                                              orderID: wo.woId,
                                            )),
                                  );
                                },
                                onLongPress: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: wo.woName));
                                },
                                child: OrderItem(
                                  thumbnail: Image.asset(
                                    'assets/img/logo/$logo.png',
                                    fit: BoxFit.fitWidth,
                                  ),
                                  title: wo.woName,
                                  subtitle: wo.address,
                                  group: '${wo.type} (${wo.status})',
                                  date: wo.date ?? 'Unassigned',
                                  time: wo.time ?? 'Unassigned',
                                  ticketStatus: wo.closedAt == null ? 'Open' : 'Closed',
                                ),
                              );
                            } else {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: const RouteSettings(
                                          name: "/showTroubleshootOrder",
                                        ),
                                        builder: (context) =>
                                            ShowTroubleshootOrder(
                                              orderID: wo.woId,
                                            )),
                                  );
                                },
                                child: OrderItem(
                                  thumbnail: Image.asset(
                                    'assets/img/logo/$logo.png',
                                    fit: BoxFit.fitWidth,
                                  ),
                                  title: wo.woName,
                                  subtitle: wo.address,
                                  group: '${wo.type} (${wo.status})',
                                  date: wo.date ?? 'Unassigned',
                                  time: wo.time ?? 'Unassigned',
                                  ticketStatus: wo.closedAt == null ? 'Open' : 'Closed',
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return RefreshIndicator(
                        onRefresh: _pullRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height - 100,
                              child: const Text('Error loading order',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ));
                  } else {
                    return RefreshIndicator(
                        onRefresh: _pullRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height - 100,
                                child: const Center(child: Text('Empty order'))
                            ),
                          ],
                        ));
                  }
                })),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    if(prefs.getString('user') == null){
      colorSnackbarMessage(context, 'Forced log out!', Colors.red);
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const Landing(),
        ),
      );
    }
    if(await AuthApi.checkVersion() != BaseApi.appVersion){
      if(mounted){
        colorSnackbarMessage(context, 'Invalid app version.', Colors.red);
        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const Landing(),
          ),
        );
      }
    }
    setState(() {
      _workOrderList = _fetchWorkOrders();
    });
  }

  Future<void> logOut() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool logoutSuccess = await AuthApi.logOut(email, prefs.getString('fcm_token'));
    String logoutMessage;
    Color logoutColor;
    await prefs.clear();

    if(logoutSuccess){
      logoutMessage = "Account logged out";
      logoutColor = Colors.green;
    }else{
      logoutMessage = "Log out failed. Redirecting to login page.";
      logoutColor = Colors.red;
    }

    if (mounted) {
      colorSnackbarMessage(context, logoutMessage, logoutColor);
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const Landing(),
        ),
      );
    }
  }
}
