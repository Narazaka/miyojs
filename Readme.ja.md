MiyoJS - JavaScript用SHIORIサブシステム「美代」
===============================================

Miyo(美代)とは
-----------------------

Miyo(美代)は伺か用のSHIORI(栞)サブシステムです。

標準でYAMLによる簡潔で記述し易い辞書形式MiyoDictionaryを用いつつ、フィルタによりあらゆるプログラムコードの実行をサポートします。

MiyoJSとは
-----------------------

Miyoの仕様を満たしたJavaScriptによる栞の実装です。

今のところ唯一の実装ですが、今後他言語版も作るかどうかは未定です。

コンセプト
-----------------------

新しい栞には新しいコンセプトが必要です。

Miyoは汎用言語の採用および簡潔かつ一貫した機能と徹底した役割分離により、プログラミング的に保守性の高いゴースト作成ができるSHIORIを目指しています。

Miyoが本質的にサポートするのは素のSHIORIプロトコルとの変換と辞書の制御程度の非常に限定的な部分です。

SHIORIサブシステムのrequestをSHIORI/3.0 ID別に分けて呼び出すことを基本としますが、普通干渉しないload、unloadをも制御できます。
一貫した動作を目指すことにより、多くのSHIORIサブシステムが内部で勝手に返すID: version等も全て辞書にゆだねられています。

さらに辞書から任意引数を渡せるフィルタ関数をサポートし、処理とデータを分離しつつ自由な処理ができる構造になっています。
これによってMiyoが辞書の枠組みに特化した基本的な機能のみを提供しつつ、その他の様々な機能は個別のフィルタとして随時選んで追加することが可能となり、透明性とメンテナンス性の高いゴースト制作が可能となります。

名前について
-----------------------

伺かのSHIORIサブシステムには伝統的に女性名をあてるので、拙作の漫画のキャラクターから名前を取り美代(みよ)と名づけました。

使用方法
-----------------------

### 栞として

ここではゴーストに組み込んで使用する方法を示します。

`/ghost/master`ディレクトリをカレントとして

    npm install miyojs

を実行します。

次にSHIOLINK.iniを

この部分はアーカイブ済みサンプルゴーストを使うことでスキップできます。

### ライブラリとしてのインストール

    npm install miyoshiori

ライブラリとしての使用方法は後述の**Miyoリファレンス**を参照してください。

依存関係
-----------------------

SHIORIプロトコルの処理に[ShioriJK](https://github.com/Narazaka/shiorijk.git)、SHIOLINKインターフェースに[ShiolinkJS](https://github.com/Narazaka/shiolinkjs.git)を利用しています。

辞書
-----------------------

(ドキュメント未作成)

フィルタ
-----------------------

フィルタの一覧は[miyo-filters](https://github.com/Narazaka/miyojs-filters/wiki)にまとまっています。

(ドキュメント未作成)

Miyoリファレンス
-----------------------

### require

以下の記述は次を前提とします。

    var Miyo = require('miyojs');

### コンストラクタ

    var miyo = new Miyo(dictionary)

dictionaryはdictionary属性に代入されます。

### 属性

#### shiori_dll_directory

ベースウェアからload時に渡されるSHIORI.dllのbasedir

これは`load()`が呼ばれた以降に存在します。

#### dictionary

**辞書**のデータ

イベント名とエントリ内容のペアである連想配列としてのオブジェクトです。

#### filters

**フィルタ**のデータ

フィルタ名とフィルタ関数のペアである連想配列としてのオブジェクトです。

#### value_filters

**valueフィルタ**の名前リスト

valueフィルタとして使用するフィルタを渡す順に列挙します。

#### default_response_headers

`make_value()`等のSHIORIレスポンスメッセージ自動生成で利用されるデフォルトのヘッダ

ヘッダ名とヘッダ内容のペアである連想配列としてのオブジェクトです。

`Charset: UTF-8`やSender等を登録しておくと便利です。

### load(directory)

    miyo.load('C:/path/to/shiori/dll')

directoryはベースウェアからload時に渡されるSHIORI.dllのbasedirです。

辞書中の`_load`エントリを呼びます。

### request(request)

    var response = miyo.request(request)

requestはShioriJK.Message.Requestです。

responseとしてSHIORI/3.0 Responseを返します。

requestとresponseを対応付ける処理は**辞書**にゆだねられます。

### unload()

    miyo.unload()

可能なら`process.exit()`します。

(ドキュメント作成中)

ライセンス
--------------------------

[MITライセンス](http://narazaka.net/license/MIT?2014)の元で配布いたします。
