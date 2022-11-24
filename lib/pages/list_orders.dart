import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/main.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:wfm/pages/show_order.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/work_order_tiles.dart';

class WorkOrders extends StatefulWidget {
  final String user, email;
  const WorkOrders({Key? key, required this.user, required this.email}) : super(key: key);

  @override
  State<WorkOrders> createState() => _WorkOrdersState();
}

class _WorkOrdersState extends State<WorkOrders> {
  var ctime, user, email;
  String? filter;
  late SharedPreferences prefs;

  Map logoDict = {
    'MXS' : 'maxis',
    'CEL' : 'celcom',
    'DGI' : 'digi',
    'else' : 'cts',
  };

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async{
    user = widget.user;
    email = widget.email;
    filter = 'Pending';
    prefs = await SharedPreferences.getInstance();
    user = prefs.getString('user') ?? 'Unauthorized';
    email = prefs.getString('email')  ?? 'Unauthorized';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${filter ?? 'All'} Orders'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
                    'assets/img/avatar_default.png',
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/img/bg-prof.jpg'),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Pending'),
              selectedColor: Colors.blue,
              selected: filter == 'Pending' ? true : false,
              onTap: () async {
                filter = 'Pending';
                Navigator.pop(context);
                setState((){});
              },
            ),
            ListTile(
              leading: const Icon(Icons.incomplete_circle),
              title: const Text('In Progress'),
              selectedColor: Colors.blue,
              selected: filter == 'In Progress' ? true : false,
              onTap: () async {
                filter = 'In Progress';
                Navigator.pop(context);
                setState((){});
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Completed'),
              selectedColor: Colors.blue,
              selected: filter == 'Completed' ? true : false,
              onTap: () async {
                filter = 'Completed';
                Navigator.pop(context);
                setState((){});
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle),
              title: const Text('All'),
              selectedColor: Colors.blue,
              selected: filter == null ? true : false,
              onTap: () async {
                filter = null;
                Navigator.pop(context);
                setState((){});
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Speed Test'),
              leading: const Icon(Icons.speed),
              onTap: () async {
                SpeedTestUtils.runSpeedTest();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const SpeedTest()),
                // );
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('user');
                prefs.remove('email');
                prefs.remove('token');
                if(mounted){
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
      body: WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          if (ctime == null ||
              now.difference(ctime) > const Duration(seconds: 2)) {
            //add duration of press gap
            ctime = now;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Press Back Button Again to Exit'))); //scaffold message, you can show Toast message too.
            return Future.value(false);
          }
          SystemNavigator.pop();
          return Future.value(true);
        },
        child: Center(
            child: FutureBuilder<List<WorkOrder>>(
                future: WorkOrderApi.getWorkOrderList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<WorkOrder> list = snapshot.data!;

                    if(filter != null){
                      list = list.where((workOrder) => workOrder.status == filter).toList();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        WorkOrder wo = list[list.length - index - 1];
                        var logo = 'else';

                        try{
                          var temp = wo.woName.substring(0,3);
                          if(logoDict.containsKey(temp)){
                            logo = temp;
                          }
                        }catch(e){
                          print(e);
                        }
                        logo = logoDict[logo];

                        return InkWell(
                            onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: const RouteSettings(
                                          name: "/show",
                                        ),
                                        builder: (context) => ShowOrder(
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
                            author: wo.woType ?? 'Undefined',
                            publishDate: wo.date ?? 'Unassigned',
                            readDuration: wo.time ?? 'Unassigned',
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
      ),
    );
  }
}
