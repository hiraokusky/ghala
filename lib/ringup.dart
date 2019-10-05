import 'package:flutter/material.dart';
import 'package:ghala/home.dart';
import 'package:ghala/otclist.dart';
import 'package:flutter/services.dart';

class RingupScreen extends StatefulWidget {
  RingupScreen({this.customer});

  CustomerData customer;

  @override
  _RingupState createState() => new _RingupState(customer: this.customer);
}

class _RingupState extends State<RingupScreen>
    with SingleTickerProviderStateMixin {
  CustomerData customer;
  List<OtcData> _otcList;

  _RingupState({this.customer});

  @override
  void initState() {
    super.initState();
    setState(() {
      _otcList = customer.otcList;
    });
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
    );
  }

  Widget appBar() {
    return new AppBar(
      title: new GestureDetector(
        onTap: () {
          // reload();
        },
        child: Text(customer.name),
      ),
      elevation: 0.7,
    );
  }

  Widget body() {
    return new Column(children: <Widget>[
      new Flexible(
        child: new ListView.builder(
          physics: BouncingScrollPhysics(),
          reverse: false,
          itemCount: _otcList.length,
          itemBuilder: (context, i) => _buildCustomerItem(i),
        ),
      ),
      new Divider(height: 1.0),
      _result(),
      _buildBottomButton2()
    ]);
  }

  Widget _buildCustomerItem(int i) {
    var otc = _otcList[i];
    // return newResultItem(otc);
    // OTC薬のリンクを表示する
    return Padding(
      padding: new EdgeInsets.all(4.0),
      child: OutlineButton(
        // borderSide: BorderSide(width: 1.0, color: Colors.black),
        // shape: new RoundedRectangleBorder(
        //     borderRadius: new BorderRadius.circular(0.0)),
        padding: EdgeInsets.only(top: 4.0, right: 4.0, bottom: 0.0, left: 4.0),
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
                    otc.name,
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  new Text(
                    otc.price.toString(),
                    style: new TextStyle(color: Colors.pink, fontSize: 16.0),
                  ),
                  new Text(
                    'use: ' + (otc.base - otc.count).toString() + (otc.count == 0 ? ' (count 0)' : ''),
                    style: new TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        onPressed: () {
        },
      ),
    );
  }

  Widget _result() {
    return new Column(children: <Widget>[
      _buildBottomNavigationBar(),
    ]);
  }

  Widget label(String label) {
    return Text(label, style: TextStyle(color: Colors.black, fontSize: 20.0));
  }

  Widget labelColor(String label, Color color) {
    return Text(label, style: TextStyle(color: color, fontSize: 20.0));
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

  // 利用額
  int use = 0;

  // 集金額
  int collection = 0;

  // 価格
  _buildBottomNavigationBar() {
    // 利用額
    use = 0;
    int sum = 0;
    for (var otc in _otcList) {
      sum += otc.count;
      var n = otc.base - otc.count;
      if (n > 0) {
        use += n * otc.price;
      }
    }
    // 未入力なら
    if (sum == 0) {
      use = 0;
    }

    // 負債額
    int debt = customer.debt;

    // 請求額
    int claim = use + debt;

    // 次回請求額
    int next = claim - collection;

    return Container(
        width: MediaQuery.of(context).size.width,
        // height: 85.0,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                label('利用額'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                labelColor(use > 0 ? use.toString() : "         ", Colors.red[300]),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                label('未払い金'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                labelColor(debt.toString(), Colors.red[300]),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                label('請求額'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                labelColor(claim.toString(), Colors.red[300]),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                label('集金額'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                _buildTextComposer(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                label('残未払い金'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                labelColor(next.toString(), Colors.red[300]),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
              ],
            ),
          ],
        ));
  }

  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  // 自由入力フィールド
  Widget _buildTextComposer() {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: OutlineButton(
          borderSide: BorderSide(width: 1.0, color: Colors.grey),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          padding: new EdgeInsets.all(10.0),
          child: new TextField(
            keyboardType: TextInputType.number,
            controller: _textController,
            onChanged: (String text) {
              setState(() {
                _isComposing = text.length > 0;
              });
            },
            onSubmitted: _isComposing ? _handleSubmitted : null,
            decoration: new InputDecoration.collapsed(hintText: "集金額を入力してください"),
          ),
          onPressed: () async {},
        ),
      ),
    );
  }

  // 送信したテキストでシナリオを実行する
  void _handleSubmitted(String text) {
    // _textController.clear();
    collection = int.parse(text);
  }

  _buildBottomButton2() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: RaisedButton(
              onPressed: () async {
                Navigator.pop(context, false);
              },
              color: Colors.grey,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "Back",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: RaisedButton(
              onPressed: () async {
                _handleDone();
              },
              color: Colors.blue,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "Ring up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDone() {
    // baseがあるのにcountが0ならcaution
    var caution = false;
    var count = false;
    for (var otc in _otcList) {
      if (otc.count > 0 || otc.add > 0) {
        count = true;
      } else if (otc.base > 0) {
        caution = true;
      }
    }

    if (count) {
      if (caution) {
        final snackBar = SnackBar(content: Text('数えていない商品があります'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }

      // 在庫数
      for (var i = 0; i < _otcList.length; i++) {
        _otcList[i].preuse = _otcList[i].base - _otcList[i].count;
        _otcList[i].preadd = _otcList[i].add;
        _otcList[i].useall += _otcList[i].preuse;
        _otcList[i].addall += _otcList[i].preadd;
        _otcList[i].base = _otcList[i].count + _otcList[i].add;
        _otcList[i].count = 0;
        _otcList[i].add = 0;
      }
      customer.otcList = _otcList;
    }

    // 請求額
    int claim = use + customer.debt;

    // 売上
    customer.sale += collection;

    // 次回請求額
    customer.debt = claim - collection;

    collection = 0;

    // 更新日時
    customer.updated = DateTime.now().toUtc();

    Navigator.pop(context, false);
  }
}