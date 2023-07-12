import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/main.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/show_troubleshoot_order.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';
import 'package:wfm/pages/widgets/work_order_tiles.dart';

class WorkOrders extends StatefulWidget {
  final String user, email;
  const WorkOrders({Key? key, required this.user, required this.email})
      : super(key: key);

  @override
  State<WorkOrders> createState() => _WorkOrdersState();
}

class _WorkOrdersState extends State<WorkOrders> {
  var ctime, user, email;
  final ValueNotifier<Map<String, String?>> filterNotifier = ValueNotifier({
    'type': 'All Orders',
    'status': 'All Status',
  });
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  late SharedPreferences prefs;

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  setFilter(String value, String type, Icon icon){
    return ListTile(
      leading: icon,
      title: Text(value),
      selectedColor: Colors.indigo,
      selected: filterNotifier.value[type] == value ? true : false,
      onTap: () async {
        filterNotifier.value[type] = value;
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    user = prefs.getString('user') ?? 'Unauthorized';
    email = prefs.getString('email') ?? 'Unauthorized';
  }

  List<WorkOrder> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
            child: Text('${filterNotifier.value['type']}'),
          onTap: (){},
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: const Icon(Icons.filter_list_outlined));
            }
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => {
      //     showModalBottomSheet<void>(
      //       context: context,
      //       isScrollControlled: true,
      //       builder: (BuildContext context) {
      //         // Returning SizedBox instead of a Container
      //         return Divider();
      //       },
      //     ),
      //   },
      //   label: const Text('Filter'),
      //   icon: const Icon(Icons.filter_list_sharp),
      // ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: filterNotifier,
              builder: (context, value, child) => ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const ListTile(
                    title: Text(
                      'Filter Status',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(),
                  setFilter('Pending', 'status',  const Icon(Icons.circle_notifications)),
                  setFilter('Completed', 'status',  const Icon(Icons.check_circle)),
                  setFilter('Cancelled', 'status',  const Icon(Icons.cancel)),
                  setFilter('Returned', 'status',  const Icon(Icons.arrow_circle_left_sharp)),
                  setFilter('All Status', 'status',  const Icon(Icons.circle)),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ValueListenableBuilder(
          valueListenable: filterNotifier,
          builder: (context, value, child) => ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user ?? "Missing Value"),
                accountEmail: Text(email ?? "Missing Value"),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/img/bg4.jpg'),
                  ),
                ),
              ),
              setFilter('New Installation', 'type',  const Icon(Icons.build)),
              setFilter('Termination', 'type',  const Icon(Icons.dnd_forwardslash)),
              setFilter('Troubleshoot', 'type',  const Icon(Icons.settings)),
              setFilter('All Orders', 'type',  const Icon(Icons.select_all)),
              const Divider(),
              // ListTile(
              //   title: const Text('Speed Test'),
              //   leading: const Icon(Icons.speed),
              //   onTap: () async {
              //     SpeedTestUtils.runSpeedTest();
              //   },
              // ),
              ListTile(
                title: const Text('Log Out'),
                leading: const Icon(Icons.exit_to_app),
                onTap: () async {
                  loadingScreen(context);
                  await Future.delayed(Duration(seconds: 1), () {
                  });
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('user');
                  prefs.remove('email');
                  prefs.remove('token');
                  if (mounted) {
                    colorSnackbarMessage(context, 'Logged out', Colors.green);
                    Navigator.pushReplacement<void, void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const Landing(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          if (ctime == null ||
              now.difference(ctime) > const Duration(seconds: 2)) {
            //add duration of press gap
            ctime = now;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Press Back Button Again to Exit'),
            backgroundColor: Colors.indigoAccent,)); //scaffold message, you can show Toast message too.
            return Future.value(false);
          }
          SystemNavigator.pop();
          return Future.value(true);
        },
        child: Center(
            child: FutureBuilder<List<WorkOrder>>(
                future: WorkOrderApi.getWorkOrderList(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }else if (snapshot.hasData) {
                    list = snapshot.data!;

                    if (filterNotifier.value['status'] != 'All Status') {
                      list = list
                          .where((workOrder) =>
                              workOrder.status == filterNotifier.value['status'])
                          .toList();
                    }
                    if (filterNotifier.value['type'] != 'All Orders') {
                      list = list
                          .where((workOrder) =>
                      workOrder.type == filterNotifier.value['type'])
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

                          if(!wo.requestedBy.contains('CTS')){
                            logo = wo.requestedBy.toLowerCase();
                          }

                          if(wo.type != 'Troubleshoot'){
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
                              child: CustomListItemTwo(
                                thumbnail: Image.asset(
                                  'assets/img/logo/$logo.png',
                                  fit: BoxFit.fitWidth,
                                ),
                                title: wo.woName,
                                subtitle: wo.address,
                                group: '${wo.type} (${wo.status})',
                                date: wo.date ?? 'Unassigned',
                                time: wo.time ?? 'Unassigned',
                              ),
                            );
                          }else{
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                        name: "/show",
                                      ),
                                      builder: (context) => ShowTroubleshootOrder(
                                        orderID: wo.woId,
                                      )),
                                );
                              },
                              child: CustomListItemTwo(
                                thumbnail: Image.asset(
                                  'assets/img/logo/$logo.png',
                                  fit: BoxFit.fitWidth,
                                ),
                                title: wo.woName,
                                subtitle: wo.address,
                                group: '${wo.type} (${wo.status})',
                                date: wo.date ?? 'Unassigned',
                                time: wo.time ?? 'Unassigned',
                              ),
                            );
                          }
                        },
                      ),
                    );
                  } else if(snapshot.hasError){
                    return const Center(
                      child: Text('Error loading order', style: TextStyle(color: Colors.red)),
                    );
                  } else{
                    return const Center(
                      child: Text("Empty order"),
                    );
                  }
                })),
      ),
    );
  }

  // Future<void> refreshList() async {
  //   refreshKey.currentState?.show(
  //       atTop:
  //       true); // change atTop to false to show progress indicator at bottom
  //   await Future.delayed(Duration(seconds: 2)); //wait here for 2 second
  //   setState(() {
  //   });
  // }

  Future<void> _pullRefresh() async {
    List<WorkOrder> refreshList = await WorkOrderApi.getWorkOrderList();
    setState(() {
      list = refreshList;
    });
  }
}
