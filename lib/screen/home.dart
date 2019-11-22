import 'package:flutter/material.dart';
import 'package:ghala/repository/otc.dart';
import 'package:ghala/screen/otclist.dart';
import 'package:ghala/profile/drawer.dart';
import 'package:ghala/profile/signin.dart';
import 'package:ghala/secret.dart';
import 'package:ghala/repository/sheet.dart';
import 'package:intl/intl.dart';

/// Show customers list.
class HomeScreen extends StatefulWidget {
  HomeScreen();

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

class _WhatsAppHomeState extends State<HomeScreen>
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
    print(userEmail);
    var items = await CustomerDb.loadItemFromSheets();
    var list = await CustomerDb.loadFromSheets(userEmail, items);

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
          icon: Icon(Icons.cached),
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
    return Padding(
      padding: new EdgeInsets.all(4.0),
      child: new Container(
        decoration: new BoxDecoration(color: Colors.yellowAccent),
        child: OutlineButton(
          onPressed: () {
            _onTap(i);
          },
          padding:
              EdgeInsets.only(top: 4.0, right: 4.0, bottom: 0.0, left: 4.0),
          child: new Column(
            children: <Widget>[
              new ListTile(
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
            ],
          ),
        ),
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
