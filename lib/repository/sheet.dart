import 'package:ghala/repository/otc.dart';
import 'package:ghala/screen/home.dart';
import 'package:ghala/screen/otclist.dart';
import 'package:ghala/secret.dart';
import 'package:ghala/sl/googlesheets.dart';

/// ユーザーリストを保持する
/// このリストを選択して、ユーザーごとに配置している薬リストを表示する。
class CustomerDb {
  static var sheetId = Secret.sheetId;
  static var sheet = Map<String, dynamic>();

  // 購入記録をセーブする
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
      sheet.values.last[++n] = ['', '', 'box', row.box];
      for (var otc in row.otcList) {
        sheet.values.last[++n] = [
          '',
          '',
          otc.key,
          otc.price,
          otc.base,
          otc.preuse,
          otc.preadd,
          otc.useall,
          otc.addall
        ];
      }
    }
    print(sheet);
    await Sheets.save(sheetId, sheet);
  }

  // 購入記録をロードする
  static Future<List<CustomerData>> loadFromSheets(String staffname, Map<String, ItemData> items) async {
    var range = staffname + '!A1:I1000';
    sheet = await Sheets.load(sheetId, range);
    if (sheet == null) {
      return null;
    }
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
        } else if (key == 'box') {
          user.box = value;
        } else {
          var item = items[key];

          var count = row[i++];
          var use = row[i++];
          var add = row[i++];
          var useall = row[i++];
          var addall = row[i++];
          var otc = OtcData(
              key: key,
              name: item.name,
              code: item.code,
              price: item.price,
              base: int.parse(count),
              preuse: int.parse(use),
              preadd: int.parse(add),
              useall: int.parse(useall),
              addall: int.parse(addall));
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

  // アイテムリストをロードする
  static Future<Map<String, ItemData>> loadItemFromSheets() async {
    var range = 'item!A1:I1000';
    sheet = await Sheets.load(sheetId, range);
    print(sheet.values.last);

    Map<String, ItemData> result = Map<String, ItemData>();
    int n = 0;
    for (var row in sheet.values.last) {
      n++;
      if (n == 1) {
        continue;
      }
      var i = 0;
      try {
        var key = row[i++];
        var name = row[i++];
        var code = row[i++];
        var price = row[i++];
        var item = ItemData(
          key: key,
          name: name,
          code: code,
          price: int.parse(price),
        );
        result.putIfAbsent(key, () => item);
      } catch (e) {
        print(e);
        continue;
      }
    }
    return result;
  }
}

class ItemData {
  ItemData({
    this.key,
    this.name,
    this.code,
    this.price,
  });

  // 薬名
  String key;
  // 薬名
  String name;
  // 識別コード
  String code;
  // 単価
  int price = 0;
}
