# ghala

配置薬管理用アプリ

## Getting Started

1. lib/secret_tmpl.dartをlib/secret.dartにリネーム。
2. secret.dartのsheetIdに、編集対象のGoogle SheetsのIdを設定
3. secret.dartのserviceAccountKeyに、Goolge Cloud Platformで取得したサービスアカウントキーを設定

## スペック

ユーザーごとのデータをロードする。
同期ボタンでユーザーごとにデータを書き込む。

バーコードを読み取ると、薬が出る。
薬にアクションすると、記録される。

清算ボタンを押すと、清算画面が出て清算できる。
そのときに、使った薬一覧が出る。
薬に対して、さらに

清算完了を押すと、使った薬情報がリセットされ、未払い金がカウントされる。
利用代金が記録される。

未払い金は別途集金できる。

## Google Sheetsのデータ

シート名は、スタッフ名。
シート名がitemのシートは、薬の定義。

itemシートの仕様
key: スタッフシートと結びつけるキー
name: 薬名
code: バーコード/QRコードの値
price: 値段

スタッフシートの仕様
staff: スタッフ名(シート名と同じ)
customer: 顧客名
key: データ項目名
value: データの値

