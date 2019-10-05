import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:ghala/home.dart';
import 'package:ghala/ringup.dart';
import 'package:flutter/services.dart';

class OtcListScreen extends StatefulWidget {
  OtcListScreen({this.customer});

  CustomerData customer;

  @override
  _OtcListState createState() => new _OtcListState(customer: this.customer);
}

class OtcData {
  OtcData(
      {this.key,
      this.name,
      this.code,
      this.price,
      this.base,
      this.preuse,
      this.preadd,
      this.useall,
      this.addall});

  // 薬名
  String key;
  // 薬名
  String name;
  // コード
  String code = '';
  // 単価
  int price = 0;
  // 前回記録した個数
  int base = 0;
  // 前回使用した個数
  int preuse = 0;
  // 前回追加した個数
  int preadd = 0;
  // 使用した個数
  int useall = 0;
  // 追加した個数
  int addall = 0;
  // 今回チェックした個数
  int count = 0;
  // 今回追加した個数
  int add = 0;
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
    // if (customer.otcList == null) {
    //   customer.otcList = await OtcDb.getOtcAll();
    // }

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
      // resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: appBar(),
      body: body(),
      // floatingActionButton: new FloatingActionButton(
      //   backgroundColor: Theme.of(context).accentColor,
      //   child: new Icon(
      //     Icons.note_add,
      //     color: Colors.white,
      //   ),
      //   onPressed: barcodeScanning,
      // ),
    );
  }

  String barcode = "";

// Method for scanning barcode....
  Future barcodeScanning() async {
    try {
      String barcode = await BarcodeScanner.scan();
      _setBarcode(barcode);
      // _handleItem();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'No camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode = 'Nothing captured.');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
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
    if (barcode != "") {
      for (int i = 0; i < _otcList.length; i++) {
        var otc = _otcList[i];
        if (otc.code == barcode) {
          return _otc(otc);
        }
      }
    }

    if (_otcList == null) {
      _otcList = List<OtcData>();
    }
    return new Column(children: <Widget>[
      Text(barcode),
      new Flexible(
        child: new ListView.builder(
          physics: BouncingScrollPhysics(),
          reverse: false,
          itemCount: _otcList.length,
          itemBuilder: (context, i) => _buildCustomerItem(i),
        ),
      ),
      new Divider(height: 1.0),
      _buildBottomButton(),
      _buildBottomButton2('Back', true)
    ]);
  }

  _setBarcode(barcode) {
    for (int i = 0; i < _otcList.length; i++) {
      var otc = _otcList[i];
      if (otc.code == barcode) {
        _textController1.text = otc.count.toString();
        _textController2.text = otc.add.toString();
        setState(() => this.barcode = barcode);
        break;
      }
    }
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
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  new Text(
                    'count: ' + otc.count.toString(),
                    style: new TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                  new Text(
                    'add: ' + otc.add.toString(),
                    style: new TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        onPressed: () {
          _setBarcode(otc.code);
          // _handleItem();
        },
      ),
    );
  }

  _buildBottomButton() {
    return Padding(
      padding: new EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: RaisedButton(
                onPressed: barcodeScanning,
                color: Colors.blue,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.camera,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        "Scan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OTC薬のリンクを表示する
  Widget newResultItem(OtcData otc) {
    return Padding(
        padding: new EdgeInsets.all(4.0),
        child: OutlineButton(
          // borderSide: BorderSide(width: 1.0, color: Colors.black),
          // shape: new RoundedRectangleBorder(
          //     borderRadius: new BorderRadius.circular(0.0)),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        otc.name,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20.0),
                      ),
                      Text(
                        otc.price.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0),
                      ),
                    ],
                  ),
                ),
              ),
              // _buildButton1(otc),
              // _buildButton2(otc),
            ],
          ),
          onPressed: () async {
            // _openDetail(context, otc);
          },
        ));
  }

  // 画像ファイルを取得する
  Widget _loadImage(String name) {
    return Image.asset("assets/mdb/noimage.png", height:100);
  }

  Widget _label(String label) {
    return Text(label, style: TextStyle(color: Colors.black, fontSize: 20.0));
  }

  Widget _labelColor(String label, Color color) {
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

  _buildBottomButton2(back, root) {
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
                if (root) {
                  Navigator.pop(context, false);
                } else {
                  setState(() => this.barcode = '');
                }
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
                      back,
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
              color: Colors.pink,
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
                      "集金",
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new RingupScreen(customer: customer)));
  }

  ////////////////////////////////////////////////////////

  // OTC確認画面
  Widget _otc(otc) {
    var list = List<Widget>();
    list.add(Padding(
      padding: EdgeInsets.all(10.0),
      child: _loadImage(''),
    ));
    list.add(Padding(
      padding: EdgeInsets.all(20.0),
      child: new Text(
        otc.name,
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
    ));
    list.add(_show('残り', otc, _textController1, _handleSubmitted1));
    list.add(_show('追加', otc, _textController2, _handleSubmitted2));
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        _label('合計'),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        _labelColor((otc.count + otc.add).toString(), Colors.red[300]),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
      ],
    ));
    return
        new Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      new Flexible(
        child: new ListView.builder(
          physics: BouncingScrollPhysics(),
          reverse: false,
          itemCount: list.length,
          itemBuilder: (context, i) => list[i],
        ),
      ),
      // Padding(
      //   padding: EdgeInsets.all(10.0),
      //   child: _loadImage(''),
      // ),
      // Padding(
      //   padding: EdgeInsets.all(20.0),
      //   child: new Text(
      //     otc.name,
      //     style:
      //         new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      //   ),
      // ),
      // _show('残り', otc, _textController1, _handleSubmitted1),
      // _show('追加', otc, _textController2, _handleSubmitted2),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: <Widget>[
      //     Padding(
      //       padding: EdgeInsets.all(8.0),
      //     ),
      //     _label('合計'),
      //     Padding(
      //       padding: EdgeInsets.all(8.0),
      //     ),
      //     _labelColor((otc.count + otc.add).toString(), Colors.red[300]),
      //     Padding(
      //       padding: EdgeInsets.all(8.0),
      //     ),
      //   ],
      // ),
      _buildBottomButton(),
      _buildBottomButton2('List', false),
    ]);
  }

  final TextEditingController _textController1 = new TextEditingController();

  // 送信したテキストでシナリオを実行する
  void _handleSubmitted1(otc, String text) {
    otc.count = int.parse(text);
  }

  final TextEditingController _textController2 = new TextEditingController();

  // 送信したテキストでシナリオを実行する
  void _handleSubmitted2(otc, String text) {
    otc.add = int.parse(text);
  }

  Widget _show(label, otc, textController, handleSubmitted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        _label(label),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        _buildTextComposer("", otc, textController, handleSubmitted),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
      ],
    );
  }

  // 自由入力フィールド
  Widget _buildTextComposer(label, otc, textController, handleSubmitted) {
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
            controller: textController,
            // onChanged: (String text) {
            //   _isComposing = text.length > 0;
            // },
            // onSubmitted: _isComposing ? handleSubmitted : null,
            onSubmitted: (t) => handleSubmitted(otc, t),
            decoration: new InputDecoration.collapsed(hintText: label),
          ),
          onPressed: () async {},
        ),
      ),
    );
  }
}
