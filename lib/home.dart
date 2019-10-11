import 'package:flutter/material.dart';
import 'package:ghala/otclist.dart';
import 'package:ghala/profile/drawer.dart';
import 'package:ghala/profile/signin.dart';
import 'package:ghala/secret.dart';
import 'package:ghala/sheet.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _WhatsAppHomeState createState() => new _WhatsAppHomeState();
}

class CustomerData {
  CustomerData({this.name});

  String name;
  List<OtcData> otcList = List<OtcData>();
  int sale;
  int debt;
  DateTime updated;
}

class _WhatsAppHomeState extends State<Home>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<CustomerData> _customerList;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 2);

    reload();
  }

  // Google sheetからデータをロード
  Future reload() async {
    print(userName);
    var items = await CustomerDb.loadItemFromSheets();
    var list = await CustomerDb.loadFromSheets(userName, items);
    setState(() {
      _customerList = list;
    });
  }

  // Google sheetへデータをセーブ
  Future save() async {
    if (_customerList != null) {
      await CustomerDb.saveAsSheets(_customerList);
      await reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return screen();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget screen() {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: appBar(),
      body: body(),
      drawer: AppDrawer.showDrawer(context),
    );
  }

  Widget appBar() {
    return new AppBar(
      title: new GestureDetector(
        onTap: () {},
        child: Center(
          child: Text("Customers"),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.file_upload),
          onPressed: () {
            final snackBar = SnackBar(content: Text('Uploading...'));
            _scaffoldKey.currentState.showSnackBar(snackBar);
            save();
          },
        ),
      ],
      elevation: 0.7,
    );
  }

  Widget body() {
    if (_customerList == null) {
      return Text('No user data: ' + userName);
    }
    int len = _customerList != null ? _customerList.length : 0;
    return new Column(children: <Widget>[
      new Flexible(
        child: new ListView.builder(
          physics: BouncingScrollPhysics(),
          reverse: false,
          itemCount: len,
          itemBuilder: (context, i) => _buildCustomerItem(i),
        ),
      ),
    ]);
  }

  String date(customer) {
    final _formatter = DateFormat("MM/dd HH:mm");
    return _formatter.format(customer.updated.toLocal());
  }

  Widget _buildCustomerItem(int i) {
    var customer = _customerList[i];
    return new GestureDetector(
      onTap: () {
        _onTap(i);
      },
      onLongPress: () {},
      child: new Column(
        children: <Widget>[
          new ListTile(
            // leading: new CircleAvatar(
            //   foregroundColor: Theme.of(context).primaryColor,
            //   backgroundColor: Colors.grey,
            //   backgroundImage: new NetworkImage(''),
            // ),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  customer.name,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                new Text(
                  customer.debt.toString(),
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[300],
                  ),
                ),
                new Text(
                  date(customer),
                  style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                ),
              ],
            ),
          ),
          new Divider(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  void _onTap(int index) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                new OtcListScreen(customer: _customerList[index])));
  }
}
