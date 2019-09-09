import 'package:flutter/material.dart';
import 'package:ghala/home.dart';

class OtcListScreen extends StatefulWidget {
  OtcListScreen({this.customer});

  CustomerData customer;

  @override
  _OtcListState createState() => new _OtcListState(customer: this.customer);
}

class OtcData {
  OtcData({this.name, this.priceLabel});
  String name;
  int count = 0;
  String priceLabel;
}

/// OTCリストを保持する
class OtcDb {
  static Future<List<OtcData>> getOtcAll() async {
    List<OtcData> result = List<OtcData>();
    result.add(OtcData(name: 'abc', priceLabel: '100'));
    result.add(OtcData(name: 'def', priceLabel: '100'));
    return result;
  }
}

class _OtcListState extends State<OtcListScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<OtcData> _otcList;
  CustomerData customer;

  _OtcListState({this.customer});

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 2);

    reload();
  }

  void reload() async {
    if (customer.otcList == null) {
      customer.otcList = await OtcDb.getOtcAll();
    }
    
    setState(() {
      _otcList = customer.otcList;
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (int index) {
          if (index == 3) {
            _onTap(0);
          } else {
            _onSwitch(index);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.shop),
            title: new Text('在庫'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.money_off),
            title: new Text('集金'),
          )
        ],
      ),
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
          child: Text(customer.name),
        ),
      ),
      elevation: 0.7,
    );
  }

  void _onSwitch(index) async {}

  Widget body() {
    return new Column(children: <Widget>[
      new Flexible(
        child: new ListView.builder(
          reverse: false,
          itemCount: _otcList.length,
          itemBuilder: (context, i) => _buildCustomerItem(i),
        ),
      ),
    ]);
  }

  Widget _buildCustomerItem(int i) {
    var otc = _otcList[i];
    return newResultItem(otc);
  }

  void _onTap(int index) async {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => new MemoScreen(_root, dummyData, index)));
  }

  // OTC薬のリンクを表示する
  Widget newResultItem(OtcData otc) {
    return Padding(
        padding: new EdgeInsets.all(4.0),
        child: OutlineButton(
          borderSide: BorderSide(width: 1.0, color: Colors.black),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(0.0)),
          padding:
              EdgeInsets.only(top: 4.0, right: 4.0, bottom: 0.0, left: 4.0),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  child: _loadImage(''),
                ),
                title: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        otc.name,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18.0),
                      ),
                      Text(
                        otc.priceLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  getChip(otc.count.toString(), Colors.black),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: RaisedButton(
                      onPressed: () async {
                        _count(otc, -1);
                      },
                      color: Colors.grey,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Icon(
                            //   Icons.min,
                            //   color: Colors.white,
                            // ),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text(
                              "-",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Flexible(
                    flex: 1,
                    child: RaisedButton(
                      onPressed: () async {
                        _count(otc, 1);
                      },
                      color: Colors.grey,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Icon(
                            //   Icons.arrow_back,
                            //   color: Colors.white,
                            // ),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text(
                              "+",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onPressed: () async {
            // _openDetail(context, otc);
          },
        ));
  }

  void _count(OtcData otc, int i) {
    if (i < 0 && otc.count == 0) {
      i = 0;
    }
    setState(() {
      otc.count += i;
    });
  }

  Widget getChip(String label, Color color) {
    return Chip(
        label: Text(label, style: TextStyle(color: color, fontSize: 20.0)),
        backgroundColor: Colors.white,
        shape: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0, color: Colors.grey),
          borderRadius: new BorderRadius.circular(25.0),
        ));
  }

  // 画像ファイルを取得する
  Widget _loadImage(String name) {
    return Image.asset("assets/mdb/noimage.png");
  }
}
