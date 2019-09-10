import 'package:flutter/material.dart';
import 'package:ghala/otclist.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _WhatsAppHomeState createState() => new _WhatsAppHomeState();
}

class CustomerData {
  CustomerData({this.name});
  String name;
  List<OtcData> otcList;
  int debt = 0;
  DateTime updated = DateTime.now().toUtc();
}

/// ユーザーリストを保持する
/// このリストを選択して、ユーザーごとに配置している薬リストを表示する。
class CustomerDb {
  static Future<List<CustomerData>> getUserAll() async {
    List<CustomerData> result = List<CustomerData>();
    result.add(CustomerData(name: 'abc1'));
    result.add(CustomerData(name: 'def2'));
    result.add(CustomerData(name: 'abc3'));
    result.add(CustomerData(name: 'def4'));
    result.add(CustomerData(name: 'abc5'));
    result.add(CustomerData(name: 'def6'));
    result.add(CustomerData(name: 'abc7'));
    result.add(CustomerData(name: 'def8'));
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

  void reload() async {
    var list = await CustomerDb.getUserAll();
    setState(() {
      _customerList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return screen();
  }

  Widget screen() {
    return new Scaffold(
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
        onTap: () {
          reload();
          // MemoDb.delete();
        },
        child: Center(
          child: Text("顧客リスト"),
        ),
      ),
      elevation: 0.7,
    );
  }

  void _onSwitch(index) async {}

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
      onLongPress: () {
        deleteDialog(i);
      },
      child: new Column(
        children: <Widget>[
          new ListTile(
            // leading: new CircleAvatar(
            //   foregroundColor: Theme.of(context).primaryColor,
            //   backgroundColor: Colors.grey,
            //   backgroundImage: new NetworkImage(dummyData[i].avatarUrl),
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
            // subtitle: new Container(
            //   padding: const EdgeInsets.only(top: 5.0),
            //   child: new Text(
            //     memo.body,
            //     style: new TextStyle(color: Colors.grey, fontSize: 10.0),
            //   ),
            // ),
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

  void deleteDialog(int index) async {
    var result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('削除してもよろしいですか？'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(0),
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(1),
            ),
          ],
        );
      },
    );
    print('dialog result: $result');
    if (result == 1) {
      // MemoSubjectTable.deleteById(dummyData[index].id);
      // setState(() {
      //   dummyData.removeAt(index);
      // });
    }
  }
}
