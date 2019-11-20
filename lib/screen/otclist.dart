import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:ghala/repository/otc.dart';
import 'package:ghala/screen/components/parts.dart';
import 'package:ghala/screen/home.dart';
import 'package:ghala/screen/otc.dart';
import 'package:ghala/screen/ringup.dart';
import 'package:flutter/services.dart';

/// Show Otc list which customer has.
class OtcListScreen extends StatefulWidget {
  OtcListScreen({this.customer});

  CustomerData customer;

  @override
  OtcListState createState() => new OtcListState(customer: this.customer);
}

class OtcListState extends State<OtcListScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<OtcData> _otcList;
  CustomerData customer;

  OtcListState({this.customer});

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 2);

    reload();
  }

  void reload() async {
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
      floatingActionButton: buildBottomNavigationBar(context, barcodeScanning),
    );
  }

  Widget buildBottomNavigationBar(context, run) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'scan',
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              run();
            },
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 50.0,
      ),
    ]);
  }

  // Scanned barcode data.
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
          return OtcScreen(state: this, otc: otc);
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
      // Parts().buildBottomButton(context, barcodeScanning),
      Parts().buildBottomButton3(context, _handleDone)
    ]);
  }

  _handleDone() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new RingupScreen(customer: customer)));
  }

  _onBack() {
    Navigator.pop(context, false);
  }

  _setBarcode(barcode) {
    for (int i = 0; i < _otcList.length; i++) {
      var otc = _otcList[i];
      if (otc.code == barcode) {
        Parts().textController1.text = otc.count.toString();
        Parts().textController2.text = otc.add.toString();
        setState(() => this.barcode = barcode);
        return;
      }
    }
    setState(() => this.barcode = '');
  }

  Widget _buildCustomerItem(int i) {
    var otc = _otcList[i];
    return Padding(
      padding: new EdgeInsets.all(4.0),
      child: new Container(
        decoration: new BoxDecoration(color: (otc.count == 0 ? Colors.greenAccent : Colors.white)),
        child: OutlineButton(
          padding:
              EdgeInsets.only(top: 4.0, right: 4.0, bottom: 0.0, left: 4.0),
          child: new Column(
            children: <Widget>[
              new ListTile(
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
                subtitle: Text(otc.base.toString()),
              ),
            ],
          ),
          onPressed: () {
            _setBarcode(otc.code);
          },
        ),
      ),
    );
  }
}
