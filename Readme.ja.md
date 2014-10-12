MiyoJS - SHIORIサブシステム「美代」 for JavaScript
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

次に、[node.js](http://nodejs.org/)実行環境のnode.exeを適当な場所に配置します。

さらに[SHIOLINK](https://code.google.com/p/shiori-basic/downloads/)を入手し、SHIOLINK.dllとSHIOLINK.iniを`/ghost/master`ディレクトリに配置します。

そしてSHIOLINK.iniを編集し、

    commandline = path\to\node.exe .\node_modules\miyojs\bin\miyo-shiolink.js path\to\dictionaries

と設定します。

`path\to\dictionaries`はMiyoDictionary辞書ファイルを配置するディレクトリです。

この部分はアーカイブ済みサンプルゴーストを使うことでスキップできます。

### ライブラリとしてのインストール

    npm install miyojs

ライブラリとしての使用方法は後述の__Miyoリファレンス__を参照してください。

依存関係
-----------------------

SHIORIプロトコルの処理に[ShioriJK](https://github.com/Narazaka/shiorijk.git)、SHIOLINKインターフェースに[ShiolinkJS](https://github.com/Narazaka/shiolinkjs.git)を利用しています。

辞書
-----------------------

Miyoは辞書形式MiyoDictionaryを使用します。

MiyoDictionaryは形式的には、インデントにタブ文字を許した(混在は未定義です)YAMLです。

Miyo仕様の栞内部で扱う分には、配列と連想配列が階層的に使用でき、文字列を保存できるというだけの条件をもったいかなる形式でもかまいません。
ですが、形式的な仕様を制限することで、相互運用性が高まります。

### 構成

    OnBoot: \h\s[0]起動。\e
    OnFirstBoot: |
    	\h\s[0]初回起動。\w9\w9
    	\n
    	\n[half]
    	\s[8]かな？
    	\e
    
    OnClose:
    	- \h\s[0]終了。\e
    	- \h\s[0]終了かな？かな？\e
    	- |
    		\h\s[0]終わる世界と……\w9\w9
    		\s[2]なんだろう？
    		\e
    
    OnGhostChanging:
    	filters: [conditions]
    	argument:
    		conditions:
    			-
    				when.jse: |
    					request.headers.get('Reference0') == 'さくら'
    				do: |
    					\h\s[0]さくらだもん。\w9\w9
    					\n
    					\n[half]
    					\s[6]……ごめん。
    					\e
    			-
    				do:
    					- \h\s[0]変わるよ。\e
    					- \h\s[0]カワルミライ。\e

繰り返しますが、MiyoDictionaryはインデントにタブ文字を許したYAMLです。

さくらスクリプトは普通はエスケープをすることなく完全にYAMLのリテラルとして有効です。

一方で辞書内に少量の制御用プログラムコードを書く場合に出てくる「:」などが1行記述だとリテラルとして認識されない場合があります。

そのような場合はYAMLのブロック記述を利用すると、それらの値もリテラルとして扱われます。

長いさくらスクリプトやプログラムコードは、YAMLのブロック記述を利用して複数行記述をすると良いでしょう。

### エントリの種類(単一値・配列値・連想配列値)

上記の例を見てみましょう。

基本的に辞書にはSHIORI/3.0 Event名をトップレベルにした連想配列を記述します。

OnBootとOnFirstBootは__単一値__を持つエントリ(トップレベルの連想配列キー)です。

OnFirstBootはYAMLのブロック記述を使っています。

OnCloseは__配列値__を持つエントリです。

3番目の値が同様にYAMLのブロック記述を使っています。

OnGhostChangingは__連想配列値__をもつエントリです。

MiyoDictionaryで有効な連想配列値の中のキーは、filtersキー(必須)とargument(なくても良い)のみです。
filtersキーには配列または単一値、argumentには任意の値が許可されます。

このように、MiyoDictionaryでは3種類の値を扱います。

### 単一値・配列値のエントリ

単一値のエントリは、そこに記述されている値がSHIORI/3.0 ResponseのValue値の生成元としてそのまま使われます。

配列値のエントリは、配列中からランダムに1つ選ばれた値が単一値として同じように使われます。

ここでSHIORI/3.0 ResponseのValue値の生成元として選ばれた値は、MiyoのValueフィルタ機能で加工されます(Valueフィルタがなければ何もされない)。

YAMLの仕様ではブロック記述内での改行は保持されます。ですが、MiyoDictionaryでフィルタの処理を受けない値は通常この素の改行を無視して使われます。

ただし、Valueフィルタが素の改行を無視しない扱いをして結果を加工することもありえます。
ですが、デバッグ等の特別な理由がない限り、Valueフィルタもこの素の改行を無視するポリシーに従うべきです。

### 連想配列値のエントリ

連想配列値のエントリは、filtersキーに指定されたフィルタ関数をargumentキーの内容を引数として呼び出し、その返り値をSHIORI/3.0 Responseの生成元として使います。

返り値が単なる文字列等ならValue値として、SHIORI/3.0 Responseを表すオブジェクトならそのまま使われます。

    OnGhostChanging:
    	filters: conditions
    	argument:
    		conditions:
    			-
    				when.jse: |
    					request.headers.get('Reference0') == 'さくら'
    				do: |
    					\h\s[0]さくらだもん。\w9\w9
    					\n
    					\n[half]
    					\s[6]……ごめん。
    					\e
    			-
    				do:
    					- \h\s[0]変わるよ。\e
    					- \h\s[0]カワルミライ。\e

この場合、conditionsフィルタにargumentの値を引数として渡して、返り値をValue値として使います。

ここでargumentの中、doキーがMiyoDictionaryのトップレベルに似ています。
MiyoがMiyoDictionaryのトップレベルを処理する関数を公開しているので、しばしばフィルタに渡す値がMiyoDictionaryのトップレベルと同じように扱われる場合があり、これはその実例です。

この場合はdoの値がいずれも連想配列値ではないのでフィルタ処理は1回で終わりですが、ここに連想配列値を指定すれば2階層目のフィルタ呼び出しが行われることになります。

    OnGhostChanging:
    	filters: conditions
    	argument:
    		conditions:
    			-
    				when.jse: |
    					request.headers.get('Reference0') == 'さくら'
    				do: |
    					\h\s[0]さくらだもん。\w9\w9
    					\n
    					\n[half]
    					\s[6]……ごめん。
    					\e
    			-
    				do:
    					filters: conditions
    					argument:
    						conditions:
    							-
    								when.jse: |
    									request.headers.get('Reference0') == 'まゆら'
    								do: |
    									\h\s[0]シテオク。\w9\w9
    									\u\s[10]とりあえずそれいえばええと思ってへんか？
    									\e
    							-
    								do: \h\s[0]変わるよ。\e

フィルタが適切に作られていれば、複雑な処理も単純な組み合わせで記述できます。

filtersキーには複数値を指定することも出来ます。

この場合、filtersのフィルタは前から順に実行され、前のフィルタの実行結果が後ろのフィルタの引数となります。

適切に連鎖させることで、ひとつのエントリで様々な処理が可能となります。

    OnGhostChanging:
    	filters: [my_filter, conditions]
    	argument:
    		my_filter:
    			option1: aaa
    			option2: bbb
    		conditions:
    			-
    				when.jse: |
    					request.headers.get('Reference0') == 'さくら'
    				do: |
    					\h\s[0]さくらだもん。\w9\w9
    					\n
    					\n[half]
    					\s[6]……ごめん。
    					\e
    			-
    				do:
    					- \h\s[0]変わるよ。\e
    					- \h\s[0]カワルミライ。\e

上の例では、まずmy_filterにargumentが引数として渡され、my_filterの返り値がconditionsに引数として渡され、その結果の値が最終的にOnGhostChangingの結果となります。

このような仕様の元で、いくつかのフィルタのポリシーが定められます。

例ではargumentの中にフィルタ名と同じ、my_filterキー、conditionsキーがあります。

こうしてフィルタそれぞれのオプション記述領域を分けることで、フィルタの連鎖が簡単になります。

なのでフィルタが引数を必要とするときは、argument下のフィルタと同名のキーにオプションを記述することを強く推奨します。

また基本的に最終的なValue値やSHIORI/3.0 Response値を返すフィルタでない限り、渡された引数をそのまま返すことを強く推奨します。

後続のフィルタが受け取る引数が辞書の記述から加工されていると、予期しない動作を起こしがちです。

例でmy_filterがargumentそのままを返さず、conditionsを加工したとすれば、デバッグは煩雑になります。

### 辞書の読み込み

辞書は起動時に全てを読み込み、階層的なデータに変換して保持されます。

ディレクトリの中のファイルを一括で読み込む場合に、別ファイルに同一名エントリがあった場合は以下のようになります。

同一名エントリ全てが配列値なら読み込み順に要素が連結されます(ランダム選択なので順番は本質的に関係ありません)。

同一名エントリ全てが連想配列値なら、直下のキーは名前が重複しない場合マージされます。

それ以外の場合は読み込みエラーとなります。

### エントリの呼び出し

SHIORIのload、request、unload関数呼び出しに応じて呼び出されます。

load時は特別な名前のエントリ、「_load」が呼び出されます。

request時はSHIORI/3.0 RequestのIDヘッダ名と同名のエントリが呼び出されます。

unload時は特別な名前のエントリ、「_unload」が呼び出されます。

いずれのエントリ呼び出しも基本的に処理は同じですが、load、unload時は特にフィルタで使用する変数のうちIDとRequestを表す変数が空になります。

フィルタ
-----------------------

公開されたフィルタの一覧は[miyo-filters](https://github.com/Narazaka/miyojs-filters/wiki)にまとまっています。

(ドキュメント未作成)

Miyoの標準的な動作
-----------------------

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
