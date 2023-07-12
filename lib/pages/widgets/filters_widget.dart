import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  final ValueNotifier<Map<String, String?>> filter;
  const Filters({Key? key, required this.filter}) : super(key: key);

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  Map<String, String> filters = {
    'status': 'Pending Activation',
    'type': 'New Installation',
  };
  Map <String, String?> filter = {'status' : 'Pending Activation', 'type' : 'New Installation'};

  @override
  void initState(){
    filter = widget.filter.value;
    super.initState();
  }

  MaterialColor themeColor = Colors.indigo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 50,
        ),
        const ListTile(
          title: Text(
            'Order Status',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.circle_notifications),
                title: const Text('Pending'),
                selectedColor: themeColor,
                selected: filter['status'] == 'Pending' ? true : false,
                onTap: () async {
                  Navigator.pop(context);
                  filter['status'] = 'Pending';
                  widget.filter.value['status'] = 'Pending';
                  print(widget.filter.value);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_notifications_outlined),
                title: const Text('Pending Attachment'),
                selectedColor: themeColor,
                selected: filter['status'] == 'Pending Attachment' ? true : false,
                onTap: () async {
                  filter['status'] = 'Pending Attachment';
                  widget.filter.value['status'] = 'Pending Attachment';
                  print(widget.filter.value);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Completed'),
                selectedColor: themeColor,
                selected: filter['status'] == 'Completed' ? true : false,
                onTap: () async {
                  filter['status'] = 'Completed';
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_circle_left_sharp),
                title: const Text('Returned'),
                selectedColor: themeColor,
                selected: filter['status'] == 'Returned' ? true : false,
                onTap: () async {
                  filter['status'] = 'Returned';
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelled'),
                selectedColor: themeColor,
                selected: filter['status'] == 'Cancelled' ? true : false,
                onTap: () async {
                  filter['status'] = 'Cancelled';
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_notifications),
                title: const Text('Show All'),
                selectedColor: themeColor,
                selected: filter['status'] == '' ? true : false,
                onTap: () async {
                  filter['status'] = '';
                  setState(() {});
                },
              ),
              // SubmitONT(
              //   ontID: wo.ontActId,
              // ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        const ListTile(
          title: Text(
            'Order Type',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.circle_notifications),
                title: const Text('New Installation'),
                selectedColor: themeColor,
                selected: filter['status'] == 'New Installation' ? true : false,
                onTap: () async {
                  filter['type'] = 'New Installation';
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_notifications),
                title: const Text('Termination'),
                selectedColor: themeColor,
                selected: filter['status'] == 'Termination' ? true : false,
                onTap: () async {
                  filter['type'] = 'Termination';
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_notifications),
                title: const Text('Troubleshoot'),
                selectedColor: themeColor,
                selected: filter['status'] == 'Troubleshoot' ? true : false,
                onTap: () async {
                  filter['type'] = 'Troubleshoot';
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              // SubmitONT(
              //   ontID: wo.ontActId,
              // ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        // DropdownButton<String>(
        //   hint: const Text('Select Type', style: TextStyle(color: Colors.white),),
        //   onChanged: (String? newValue) {
        //     setState(() {
        //       filters['type'] = newValue!;
        //     });
        //   },
        //   items: <String>['New Installation', 'Termination', 'Troubleshoot']
        //       .map<DropdownMenuItem<String>>((String value) {
        //     return DropdownMenuItem<String>(
        //       value: value,
        //       child: Text(value),
        //     );
        //   }).toList(),
        // ),
        // ElevatedButton(
        //   onPressed: () {
        //     // Perform filtering action
        //     print(filters);
        //   },
        //   child: Text('Filter'),
        // ),
      ],
    );
  }
}
