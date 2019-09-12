import 'package:flutter/material.dart';
import 'package:ghala/googlesheets.dart';
import 'package:ghala/otclist.dart';
import 'package:ghala/secret.dart';
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

/// ユーザーリストを保持する
/// このリストを選択して、ユーザーごとに配置している薬リストを表示する。
class CustomerDb {
  static var sheetId = Secret.sheetId;
  static var sheet = Map<String, dynamic>();

  static Future<void> saveAsSheets(List<CustomerData> list) async {
    int n = 0;
    for (var row in list) {
      sheet.values.last[++n] = [
        'A',
        row.name,
        'updated',
        row.updated.toUtc().toIso8601String()
      ];
      sheet.values.last[++n] = ['', '', 'sale', row.sale];
      sheet.values.last[++n] = ['', '', 'debt', row.debt];
      for (var otc in row.otcList) {
        sheet.values.last[++n] = ['', '', otc.name, otc.base, otc.preuse, otc.preadd];
      }
    }
    print(sheet);
    await Sheets.save(sheetId, sheet);
  }

  static Future<List<CustomerData>> loadFromSheets() async {
    var range = 'A1:F100';
    sheet = await Sheets.load(sheetId, range);
    print(sheet.values.last);

    List<CustomerData> result = List<CustomerData>();
    int n = 0;
    var customer = '';
    CustomerData user = null;
    for (var row in sheet.values.last) {
      n++;
      if (n == 1) {
        continue;
      }
      var i = 0;
      try {
        var staff = row[i++];
        String name = row[i++];
        if (name.length > 0) {
          if (user != null) {
            result.add(user);
          }
          customer = name;
          user = CustomerData(name: name);
        }
        var key = row[i++];
        var value = row[i++];

        if (key == 'updated') {
          user.updated = DateTime.parse(value);
        } else if (key == 'sale') {
          user.sale = int.parse(value);
        } else if (key == 'debt') {
          user.debt = int.parse(value);
        } else {
          var use = row[i++];
          var add = row[i++];
          var otc = OtcData(name: key, base: int.parse(value), preuse: int.parse(use), preadd: int.parse(add));
          user.otcList.add(otc);
        }
      } catch (e) {
        print(e);
        continue;
      }
    }
    result.add(user);
    return result;
  }
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

  Future reload() async {
    var list = await CustomerDb.loadFromSheets();
    setState(() {
      _customerList = list;
    });
  }

  Future save() async {
    await CustomerDb.saveAsSheets(_customerList);
    await reload();
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
      // floatingActionButton: new FloatingActionButton(
      //   backgroundColor: Theme.of(context).accentColor,
      //   child: new Icon(
      //     Icons.note_add,
      //     color: Colors.white,
      //   ),
      //   onPressed: () => _onTap(-1),
      // ),
    );
  }

  Widget appBar() {
    return new AppBar(
      title: new GestureDetector(
        onTap: () {},
        child: Center(
          child: Text("顧客リスト"),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.cached),
          onPressed: () {
            final snackBar = SnackBar(content: Text('Syncing...'));
            _scaffoldKey.currentState.showSnackBar(snackBar);
            save();
          },
        ),
      ],
      elevation: 0.7,
    );
  }

  Widget body() {
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
