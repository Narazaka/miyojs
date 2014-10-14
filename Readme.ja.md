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

以下で「Miyo」と記述してあるところはMiyo一般のことであり、JavaScript版であるMiyoJS特有のことではないということを示しています。
MiyoはMiyoJSに読み替えることが可能です。

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

ライブラリとしての使用方法は後述の__MiyoJSリファレンス__を参照してください。

依存関係
-----------------------

SHIORIプロトコルの処理に[ShioriJK](https://github.com/Narazaka/shiorijk.git)、SHIOLINKインターフェースに[ShiolinkJS](https://github.com/Narazaka/shiolinkjs.git)を利用しています。

関連リソース
-----------------------

公開されたフィルタの一覧は[miyojs-filters](https://github.com/Narazaka/miyojs-filters/wiki)にまとまっています。

MiyoJSの標準的な動作
-----------------------

伺かの栞として利用される場合の動作を説明します。

### 起動

MiyoJSはゴースト起動時にSSPに読み込まれたSHIOLINK.dllからシェルを通じて起動されます。

起動時に辞書ファイルが配置されるディレクトリを渡されるので、それを読み込んでオブジェクトとしてメモリに保持します。
もし失敗したときは、起動に失敗しSSPが固まります。

この辞書はmiyoをMiyoのインスタンスとして、miyo.dictionaryで参照できます。

### 初期化

起動後はShiolinkJSを利用してSSP←→SHIOLINK.dll←→MiyoJSとSHIORI/3.0の通信が受け渡されます。

まずSHIORI load()に対応する呼び出しにより、辞書から特別な名前である_loadエントリを呼び出し、実行します。

このloadの動作をゴースト作者は完全に制御できるので、通常ここで初期化処理を行います。

### 栞としての動作

この後は終了する直前まで、SHIORI request()に対応する呼び出しと返答で栞は動作します。

SHIORI request()に対応する呼び出しと返答は以下のように行われます。

MiyoJSはrequest()呼び出しにより渡されたSHIORI/3.0 Requestメッセージを受け取ると、ShioriJKのパーサーによりShioriJK.Message.Requestオブジェクトにして扱います。

辞書からそのリクエストがもつID名(IDヘッダの文字列)のエントリを呼び出し、実行した返り値からShioriJK.Message.Responseオブジェクトを生成します。

これは文字列化され、SHIORI/3.0 Responseメッセージとして返答とされます。

### 終了

終了時は、SHIORI unload()に対応する呼び出しにより、辞書から特別な名前である_unloadエントリを呼び出し、実行します。

このunloadの動作もゴースト作者は完全に制御できるので、通常ここで終了処理を行います。

その処理が終わると栞のプロセスを終了します。

エントリの呼び出しと実行
-----------------------

Miyoの最も主要な動作である「エントリ呼び出しと実行」について詳細に説明します。

起動時の「辞書読み込み」と、終了時の「プロセス終了」という例外的な動作を除いて、Miyoは全ての動作が「エントリの呼び出しと実行」です。

load()、unload()時は与えられる情報が少なく、返り値が使われないという違いはありますが、それも「エントリの呼び出しと実行」に変わりありません。

request()時の「エントリ呼び出しと実行」が標準的なので、それを基準に説明します。

### 渡されたSHIORI/3.0 Requestをオブジェクトにする

まずrequest()呼び出しによってSHIOLINK.dllから渡されたSHIORI/3.0 Request文字列が、パーサにかけられ[ShioriJK.Message.Request](http://narazaka.github.io/shiorijk/doc/class/ShioriJK/Message.Request.html)オブジェクトとなります。

これは[ShioriJK.RequestLine](http://narazaka.github.io/shiorijk/doc/class/ShioriJK/RequestLine.html)と[ShioriJK.Headers.Request](http://narazaka.github.io/shiorijk/doc/class/ShioriJK/Headers.Request.html)を持ち、各種データの参照を容易とするものです。

    var method = request.request_line.method; // GET or NOTIFY
    var id = request.headers.get('ID'); // OnBoot etc.
    var reference0 = request.headers.get('Reference0');

このリクエストオブジェクトShioriJK.Message.Requestをmiyo.request()に渡します。

### リクエストが有効なら辞書処理を呼ぶ(request)

まずリクエストオブジェクトがSHIORI/3.0であることを確認し、そうでないなら400 BadRequestを生成してSHIORIのrequest()に返答します。

次にこのオブジェクトからIDヘッダを取得し、そのIDとShioriJK.Message.Requestを引数にとってmiyo.call_id()が呼ばれます。

### IDに対応する辞書エントリを選択する(call_id)

「辞書」(miyo.dictionaryに保持された連想配列)からID名のキー(たとえばmiyo.dictionary['OnBoot'])を捜します。

キーが存在しない場合は400 BadRequestを生成してSHIORIのrequest()に返答します。

キーが存在する場合はキーに対応する内容を「エントリ」とします。

    var entry = miyo.dictionary[id];

そしてID、ShioriJK.Message.Requestとこのエントリを引数にとってmiyo.call_entry()が呼ばれます。

### エントリの種別に対してそれぞれの処理を行い、単一値を得る(call_entry)

エントリに対して以下の試行をします。

1. エントリがスカラ(単一値)なら、その値をmiyo.call_value()に渡す。
2. エントリが配列なら、ランダム選択によりそのうち1要素を得る(call_list)。その値をエントリとして、再びmiyo.call_entry()を呼ぶ。
3. エントリが連想配列なら、エントリ内容をmiyo.call_filters()に渡す。

エントリが配列だった場合は、それが配列でなくなるまで再帰的にランダム選択されます。

つまりこのcall_entryでは最終的に、単一値がmiyo.call_value()に渡されるか、連想配列値がmiyo.call_filters()に渡されるかの2パターンになります。

miyo.call_value()に渡される単一値はたいていの場合単なるさくらスクリプト文字列か、またはリソース文字列です。

miyo.call_filters()に渡される連想配列値は、「フィルタ」の名前を列挙したfiltersキーと、最初のフィルタに渡す引数であるargumentキー(ない場合もある)をもつデータです。

miyo.call_value()は「Valueフィルタ処理」、miyo.call_filters()は「フィルタ処理」をそれぞれ渡された値に施して、Valueヘッダ文字列か、ShioriJK.Message.Responseオブジェクトを返します。

どちらにもエントリのほかにID、ShioriJK.Message.Requestも引数として渡されます。

この「Valueフィルタ処理」、「フィルタ処理」はゴースト制作者が完全に制御できる、Miyoの特徴の根幹です。

これらの詳細については後で説明します。

とりあえず、エントリの値に何らかの変換を施して、最終値を得るということです。

この最終値、Valueヘッダ文字列か、ShioriJK.Message.Responseオブジェクトをmiyo.request()に返します。

### SHIORI/3.0 Responseを生成する(request)

Valueヘッダ文字列か、ShioriJK.Message.Responseオブジェクトを受け取って、前者の場合はその値を基にしてShioriJK.Message.Responseオブジェクトを生成します。

これを文字列化してSHIORI/3.0 ResponseとしてSHIORIのrequest()に返答します。

もしここまでの過程のうちでエラーが生じていた場合、500 Internal Server ErrorをSHIORIのrequest()に返答します。

以上で「エントリの呼び出しと実行」の一連の流れが終了します。

エントリの呼び出しと実行(load()、unload()時)
-----------------------

load()、unload()時も中心的な流れは同一ですが、開始と終了に違いがあります。

### load()呼び出しの場合 渡されるディレクトリを格納する(load)

load()はゴーストのカレントディレクトリを表す1つの引数を伴っています。

これをmiyo.shiori_dll_directoryに保存します。

### 辞書処理を呼ぶ(load/unload)

loadの場合、IDを「_load」としてmiyo.call_id()が呼ばれます。

unloadの場合、IDを「_unload」としてmiyo.call_id()が呼ばれます。

リクエストオブジェクトは当然存在しないので、nullが渡されます。

### request()と同一の処理

この後はrequestと同一の処理が行われますが、返値は無視されます。

なので前述の説明のcall_entryの箇所までとなります。

### unload()呼び出しの場合 終了する(unload)

すべての処理が終わったら、process.exit()を呼び、プロセスを終了します。

フィルタ処理(call_filters)
-----------------------

### call_filters

miyo.call_filters()は、「フィルタ」の名前を列挙したfiltersキーと最初のフィルタに渡す引数であるargumentキー(ない場合もある)をもつ連想配列entry、リクエストオブジェクト、ID等を引数にとり、「フィルタ処理」を実行し、Valueヘッダ文字列かShioriJK.Message.Responseオブジェクトを返します。

    var value_or_response = miyo.call_filters(
    	{filters: ['filter_name_1', 'filter_name_2'], argument: argument},
    	request,
    	id
    );

これはmiyo.call_entry()でエントリが連想配列であった場合にまず呼ばれます。

### フィルタ処理

「フィルタ処理」は、filtersで指定された「フィルタ群」にargumentの値を渡し、返値としてValueヘッダ文字列か、ShioriJK.Message.Responseオブジェクトを受け取る処理です。

「フィルタ処理」は以下の手順で行われます。

最初に後述するフィルタの種類チェックをして、適合しない場合エラーとなります。

また列挙された名前のフィルタが存在しない場合もエラーとなります。

これらをクリアした後、まずfiltersに指定された最初の名前の「フィルタ」にargumentの値を引数として渡して返値を得ます。

次に2番目の「フィルタ」があればこの返値を引数として渡して再び返値を得ます。

3番目以降も前の「フィルタ」の返値を次の「フィルタ関数」の引数にして、全ての「フィルタ」を実行し、最後の返値を最終的な「フィルタ処理」の返値とします。

なお各「フィルタ」には利便のため上記の主引数と同時にリクエストオブジェクト、ID等も一緒に渡されています。

以下に例を挙げます。

    OnTest:
    	filters: [filter_1, filter_2]
    	argument:
    		filter_1: 111

上記の場合miyo.filters.filter_1、miyo.filters.filter_2が実行されます。

filter_1の引数はargumentの内容である{filter_1: 111}です。

filter_2の引数はfilter_1の返値です。

そしてOnTestエントリの返値はfilter_2の返値です。

### フィルタの実態

このように、Miyoにおいて「フィルタ」と呼ばれるものは、辞書から名前を指定して呼び出しできる単なる関数で、連想配列miyo.filtersに名前をキーとして登録されています。

フィルタの具体的な作成方法は以降にある「フィルタの利用と作成」の項をご覧ください。

フィルタは形式的には単なる関数ですが、しかし名前の通り、ある規約内の入力値と出力値を持つことを要求されます。

### フィルタの入出力チェック

MiyoJSのフィルタ処理は、argumentを最初の入力データとして、最終的にValueヘッダ文字列かShioriJK.Message.Responseオブジェクトを生成する体系です。

なのでフィルタには次の種類のものが考えられます。

- 任意引数を受け取り、そのままを返値とするもの [throughフィルタ]
- データを引数として受け取り、データを返値とするもの [data-dataフィルタ]
- データを引数として受け取り、ValueヘッダかShioriJK.Message.Responseを返値とするもの [data-valueフィルタ]
- ValueヘッダかShioriJK.Message.Responseを受け取り、ValueヘッダかShioriJK.Message.Responseを返値とするもの [value-valueフィルタ]
- データまたはValueヘッダかShioriJK.Message.Responseを引数として受け取り、ValueヘッダかShioriJK.Message.Responseを返値とするもの [any-valueフィルタ]

このフィルタの種類により、簡易的な型システムのように、フィルタの組み合わせがチェックされます。

連鎖するフィルタは前のフィルタの返値と次のフィルタの引数の種類が同じでなければなりません。

例えば、data-dataからdata-valueにつなげることはできますが、data-dataからvalue-valueにつなげることはできません。

また最初のフィルタはdataを渡されるので、value-value以外が許可されます。
そして最後のフィルタはvalueを返す必要があるので、data-data以外が許可されます。

ただしthroughはどんな引数でもとれて、引数の種類を変換しないので、throughはないものとして考えた場合の連鎖が要求通りになっている必要があります。

またany-valueは前の引数の種類はdataでもvalueでもかまいません。

### フィルタの用途

これら色々な種類のフィルタが想定されますが、それぞれに想定される適した用途を述べておきます。

#### throughフィルタ

これは完全な「副作用」を目的とするフィルタです。

Miyoインスタンスの設定を変えたり、機能を追加したりする、あるいは外部のコマンドを呼び出す等の用途が考えられます。

また設定を必要とするフィルタのために変数等を初期化する用途に使われることもあるでしょう。

### data-dataフィルタ・data-valueフィルタ・any-valueフィルタ

条件によって引数や内容を加工する用途等が想定されます。

辞書内で条件分岐を記述したりするのが主な用途でしょう。

### value-valueフィルタ

後述のValueフィルタが最も主要な使い道でしょう。

Valueヘッダを変換する用途は、いわばOnTranslateのようなものです。

Valueフィルタ処理(call_value)
-----------------------

### call_value

miyo.call_value()は、Valueヘッダ文字列かShioriJK.Message.Responseオブジェクトであるvalue、リクエストオブジェクト、ID等を引数にとり、「Valueフィルタ処理」を実行し、Valueヘッダ文字列かShioriJK.Message.Responseオブジェクトを返します。

    var value_or_response = miyo.call_value(
    	'\\h\\s[0]\\e',
    	request,
    	id
    );

これはmiyo.call_entry()でエントリが単一値であった場合にまず呼ばれます。

### Valueフィルタ処理

「フィルタ処理」は、miyo.value_filtersで指定された「フィルタ群」にvalueの値を渡し、返値としてValueヘッダ文字列かShioriJK.Message.Responseオブジェクトを受け取る処理です。

これは「フィルタ処理」(call_filters)でエントリのfiltersキーをmiyo.value_filters、argumentキーをvalueとしたものと同一です。

なお同様に各「フィルタ」には利便のため上記の主引数と同時にリクエストオブジェクト、ID等も一緒に渡されています。

以下に例を挙げます。

    # miyo.value_filters = ['filter_1', 'filter_2']
    OnTest: \h\s[0]\e

上記の場合、OnTestはフィルタ呼び出しを明示的に含んでいないにもかかわらず、miyo.filters.filter_1、miyo.filters.filter_2が実行され、OnTestエントリの返値はfilter_2の返値となります。

### Valueフィルタの用途

グローバルにテンプレート等を導入したい場合はValueフィルタに指定するのが手っ取り早いでしょう。

また特定の語尾を付けるなどグローバルな変換機能等も想定されます。

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

OnBootとOnFirstBootは__単一値__エントリ(トップレベルの連想配列キーに対応する内容)です。

OnFirstBootはYAMLのブロック記述を使っています。

OnCloseは__配列値__エントリです。

3番目の値が同様にYAMLのブロック記述を使っています。

OnGhostChangingは__連想配列値__エントリです。

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

フィルタの利用と作成
-----------------------

### フィルタの形式

MiyoJSのフィルタはMiyoJSインスタンスmiyo上ではmiyo.filtersに名前で登録されている関数として存在します。

またMiyoJSフィルタはファイルシステム上には通常node.jsのモジュールとして存在します。

### 公開されているフィルタのインストール

node.jsのモジュールはnode.jsのパッケージ管理ツールnpmで管理することができます。

npmに登録されているMiyoJSのフィルタモジュールを探すには、[npm](http://npmjs.org/)で「miyojs-filter-」が先頭につくものを探すことで可能です。

インストールはゴーストのルートディレクトリをカレントディレクトリとして

    npm install miyojs-filter-foo

等を実行することで可能です。

npmに登録されていなくとも、Github等から直接インストールすることもできます。

詳しくはnpmのヘルプ等を参照してください。

### フィルタのロード

#### node.js上

MiyoJSは基本的にnode.jsの`require`を利用して、node.jsのフィルタモジュールをロードします。

フィルタのロードは自動では行われません。
Miyoで最初から利用可能な特別なフィルタ`miyo_require_filters`を利用して、辞書で明示的に指定して行います。

    _load:
    	filters: [miyo_require_filters]
    	argument:
    		miyo_require_filters:
    			- filter1
    			- ./filter2
    			- ./filter3.js

miyo_require_filtersはargument.miyo_require_filtersに指定されたフィルタ名のリストを使ってフィルタをロードするフィルタです。

このロードには次の規則があります。

フィルタ名の先頭にパスを示す「/」,「./」,「../」がつく場合、カレントディレクトリのパスと指定されたフィルタ名を連結したパスをrequireに渡します。

例えばカレントディレクトリが`Z:\path\to\ghost\master`だった場合は、`./filter2`は`Z:\path\to\ghost\master\filter2としてrequireされます。

カレントディレクトリは栞として動いている場合通常ゴーストのルートディレクトリです。

フィルタ名の先頭にそれらがつかない場合、「miyojs-filter-」と指定されたフィルタ名を連結した名前をrequireに渡します。

例えば`filter1`は`miyojs-filter-filter1`としてrequireされます。

基本的にこの読み込み時にフィルタ名の先頭にパスを示す文字列がつかない、パッケージとして整備された(した)フィルタを使うことを推奨します。

なぜなら、パッケージとして整備されることで再利用性が高まるのはもちろん、MiyoJSだけでない将来の他言語版Miyoと相互運用性がとれる可能性が高まるからです。

requireの動作に関しては[node.jsのドキュメント](http://nodejs.jp/nodejs.org_ja/api/modules.html)を参照することをお勧めしますが、標準的な使用法にあたるものを簡単に説明します。

`./filter3.js`から呼ばれるrequire('Z:\path\to\ghost\master\filter3.js')は絶対パスを含むので、そのパスにあるfilter3.jsファイルを読み込みます。

`./filter2`から呼ばれるrequire('Z:\path\to\ghost\master\filter2')は絶対パスを含むので、そのパスにあるfilter2が処理されます。

filter2がディレクトリだった場合、ディレクトリ形式のモジュール読み出しを試行します。
filter2/package.jsonがあればその記述に従い、なければfolder2/index.jsを読み込みます。

filter2がファイルであるか、filter2.jsファイルが存在する場合、そのファイルを読み込みます。

`filter1`から呼ばれるrequire('miyojs-filter-filter1')はパスを含まないので、node_modulesディレクトリからの読み込みプロセスとなります。

MiyoJSのライブラリがあるディレクトリから、順に親ディレクトリをたぐってゆきそれぞれに/node_modulesを付加したパスにmiyojs-filter-filter1がないか探します。

例えばMiyoJSのライブラリが`Z:\path\to\ghost\master\node_modules\miyojs`にある場合(標準的)、`Z:\path\to\ghost\master\node_modules\miyojs\node_modules\miyojs-filter-filter1`がないか探し、なければ`Z:\path\to\ghost\master\node_modules\node_modules\miyojs-filter-filter1`、`Z:\path\to\ghost\master\node_modules\miyojs-filter-filter1`、と順に探してゆきます。

見つかった段階で`./filter2`の場合と同じようにディレクトリ形式のモジュール読み出しかファイル形式のモジュール読み出しを行います。

npmからインストールしたモジュールは基本的にこの場合のディレクトリ形式のモジュール読み出しが使われます。

なぜなら前述の方法でnpmでインストールしたモジュールmiyojs-filter-filter1は`Z:\path\to\ghost\master\node_modules\miyojs-filter-filter1`に配置されるからです。

#### ブラウザ上

MiyoJSのフィルタは通常node.jsのモジュールとして読み込まれますが、MiyoJSはブラウザでも簡単に動作するように作られています。

なのでMiyoJSのフィルタもブラウザでも実行できるように用意すべきです。

ブラウザ上でのフィルタ読み込みは、requireが使えず、フィルタ名とファイル名の対応もつかないゆえに、以下のような挙動となります。
miyo_require_filtersはargument.miyo_require_filtersを無視し、連想配列変数MiyoFiltersに実行時に存在するフィルタ全てをフィルタとして読み込みます。

あらかじめ<script>等でフィルタのファイルを選択して読み込んでおき、そのあとでmiyo_require_filtersを実行すべきです。

### フィルタの作成

この項では、MiyoJSインスタンスに適切に登録できるMiyoJSフィルタの作成方法を説明します。

#### 雛形

MiyoJSのフィルタは前述のようにnode.jsのモジュールとしても動き、ブラウザ上でも動くべきです。

もしnode.jsに固有の機能を使う必要がある場合はnode.jsのモジュールとしてのみ、ブラウザ固有の機能を使う必要がある場合はブラウザ上のみを考えれば良いですが、一般的にはどちらでも動くよう以下の対応をとります。

node.jsとして動く場合、miyo_require_filtersはmodule.exportsでエクスポートされた連想配列に含まれる名前とフィルタ内容のペアをフィルタリストにコピーします。

またブラウザ上で動く場合、miyo_require_filtersは連想配列MiyoFiltersに含まれる名前とフィルタ内容のペアを同様にフィルタリストにコピーします。

よってフィルタのテンプレートとしては以下が推奨されます。

    var MiyoFilters;
    if (! MiyoFilters) MiyoFilters = {};
    
    MiyoFilters.foo_filter = {
    	type: '...',
    	filter: function(argument, request, id, stash){...}
    };
    
    if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    	module.exports = MiyoFilters;
    }

coffee-scriptで生成する場合は以下のようにして、--bare(-b)オプションをつけてください。

    unless MiyoFilters?
    	MiyoFilters = {}
    
    MiyoFilters.foo_filter = type: '...', filter: (argument, request, id, stash) ->
    	...
    
    if module?.exports?
    	module.exports = MiyoFilters

foo_filterがフィルタ名で、これが辞書内のfiltersに記述される名前となります。

foo-filter等JavaScriptで変数として扱われない名前を使いたい場合は

    MiyoFilters['foo-filter'] = ...

のようにしてください。

複数のフィルタを指定したい場合は単純にMiyoFiltersに複数のキーで指定してください。

#### フィルタの指定

さて、MiyoFilters.foo_filterは連想配列で、typeキーとfilterキーがあります。

typeキーにはフィルタの入出力タイプを指定します。

これは「フィルタ処理」中「フィルタの入出力チェック」の項にある

- through
- data-data
- data-value
- value-value
- any-value

のうちどれかを文字列で指定します。

dataは任意引数ですが、通常はフィルタ呼び出しエントリのargumentで指定される引数等を指します。

valueはValueヘッダ文字列かShioriJK.Message.Responseオブジェクトを指します。

anyはどちらもあり得ます。

詳細は「フィルタの入出力チェック」の項を参照してください。

valueは形式的にはdataの指す集合に含まれますが、フィルタ処理の出力値がvalueである必要があるため特別扱いされています。

これはあくまでフィルタの人手での組み合せをスムーズにするための完全な自己申告であり、入出力がvalueであるところに他の値を渡したり返したりしてもチェックされません。

filterキーにはフィルタの本体の関数を指定します。

#### フィルタ関数の引数

フィルタ関数は(argument, request, id, stash)を引数に持ちます。

- argumentはdataあるいはvalueである主引数です。
- requestは現在のセッションのリクエストオブジェクトです。
- idは現在のセッションのリクエストIDです(リクエストオブジェクトからも取得できます)。
- stashはstashです。

argumentと返値の扱いについて以下のポリシーを定めます。

フィルタは「フィルタ処理」の項にあるように、前のフィルタの返値を引数として実行されます。

なので、dataを入力値にするフィルタは、「辞書」の項にあるように、argumentを連想配列として扱い、その中のフィルタ名と同名のキーをオプションとして扱うことを強く推奨します。

また、valueを入力値にするフィルタは、argumentがValueヘッダ文字列かShioriJK.Message.Responseオブジェクトどちらであった場合も、そのうちのValueヘッダのみを変更する処理をすることを強く推奨します。

加えてvalue-valueフィルタは出力値を入力値の形式(Valueヘッダ文字列かShioriJK.Message.Responseオブジェクト)と同一にすることを強く推奨します。

4番目のstashとは、現在のセッションで保持されるデータです。
これはフィルタのみが使うデータで、任意のデータを保存できます。

stashが何のためにあるかというと、主にフィルタ関数内部からcall_id()、call_entry()等を呼ぶ場合、argumentが呼ばれる新しいエントリのものとなるために、stashなしでは変数の受け渡しができないからです。

このstashを実現するため、

- call_id(id, request, stash)
- call_entry(entry, request, id, stash)
- call_list(entry, request, id, stash)

は全て最終引数に渡されたstashを保持し、次の処理に渡します。

また

- call_value(entry, request, id, stash)
- call_filters(entry, request, id, stash)

は、使用する各フィルタに引数としてstashを渡します。

このようにstashは1回の一連のフィルタ処理で同一のものが使われます。

なのでstashを使うフィルタが一連のフィルタの中に複数あった場合を想定し、辞書のargument指定と同じように、stashを連想配列として定義し、フィルタ名をキーとした変数の受け渡しを行うことを強く推奨します。

stashはフィルタ関数内部からこれらcall_*()を呼ぶときに指定されるもので、連鎖の必要はないので、stashを使わない関数では無視してかまいません。

stashはload(), unload(), request()から直接呼ばれたcall_value(), call_filters()では常に未定義です。

#### フィルタモジュールの作成

フィルタの内容を記述できたら、それをmiyo_require_filtersから読めるよう配置する必要があります。

特にmiyo_require_filtersからパスを示す「/」,「./」,「../」がつかない名前指定の形式で参照できることを強く推奨します。

つまり、ゴーストのルートディレクトリ下のnode_modulesディレクトリに、「miyojs-filter-foobar」の名前を使って配置します。

この名前は含まれる主なフィルタの名前と一致させることを推奨します。

あるいは例えばfoo_create, foo_get, foo_update, foo_deleteのようなフィルタを提供する場合に、fooという名前にすることも推奨します。

またその規則に従わずともかまいません。

ただし、少なくともnpmやGithub等を参照して、重複しない名前を付けるべきです。

「miyojs-filter-foobar」の名前で参照できる形式としては

- miyojs-filter-foobar.jsという単体のファイル
- miyojs-filter-foobarディレクトリ下のディレクトリ形式のモジュール

があります。

他のnode.jsモジュールとの混乱を避けるためディレクトリ形式のモジュールを推奨します。

またディレクトリ形式のモジュールではmiyojs-filter-foobarディレクトリ下にindex.jsを置けば一応動きますが、npmモジュール形式にすることを視野に入れてpackage.jsonを適切に記述することを推奨します。

モジュールはnpmモジュール形式にして他の人も使えるよう公開することも視野に入れてください。

公開して多くの人にフィードバックをもらうことで、ソフトウェアの品質は向上します。

最低限のnpmモジュールはfoo.jsとpackage.jsonを必要とします。

package.jsonはnpmに登録する情報を記述するJSONファイルです。
次のような内容になります。

    {
      "name": "miyojs-filter-foo",
      "version": "0.0.1",
      "main": "foo.js",
      "description": "foo - MiyoJS filter for foo",
      "keywords": ["miyojs", "miyojs-filter"],
      "license": "MIT",
      "dependencies": {
        "js-yaml": ">= 3.0.2"
      },
      "readmeFilename": "Readme.md",
      "homepage": "http://www.example.com/foo/",
      "author": {
        "name": "bar",
        "url": "http://www.example.com/bar/"
      },
      "repository": {
        "type": "git",
        "url": "https://github.com/bar/miyojs-filter-foo.git"
      }
    }

- nameはnpmモジュール名で、miyojs-filter-*の形式にします。
- versionはバージョンで、x.x.xの形式に限定されます。
- mainはモジュールのメインのJavaScriptファイルです。
- (任意)descriptionは説明です。
- (任意)keywordsはキーワードの配列です。検索時に使われます。最低限"miyojs", "miyojs-filter"を指定しておくとよいでしょう。
- licenseはライセンスです。よく知られたオープンソースライセンスを使う場合は定められた略称で記述できます。
- dependenciesは依存するモジュールです。依存モジュールがない場合は省略できます。
- (任意)readmeFilenameはReadmeファイルの名前です。
- (任意)homepageはWebサイトです。
- (任意)authorは作者情報です。
- (任意)repositoryは開発時のリポジトリ情報です。

詳細は[package.jsonの説明](http://liberty-technology.biz/PublicItems/npm/package.json.html)等を参照ください。

他にソフトウェアテストを書くtestや、Readme.mdファイル等があるとよりよく標準的です。

MiyoJSのフィルタモジュールをnpmモジュール形式にする場合に注意してほしい点があります。

それは自作のフィルタが他のMiyoJSのフィルタモジュールの機能に依存する場合、それをpackage.jsonのdependenciesに書いてはいけない(意味がない)ということです。

npmはモジュールが依存するモジュールを、そのモジュールのディレクトリの中のnode_modulesに配置します。

しかしmiyo_require_filtersが使うrequireの仕様により、Miyoのインスタンスはその「モジュールが依存するモジュール」が配置されている、深い階層のnode_modulesを参照しません。

なのでMiyoJSのフィルタモジュールは個別にインストールしてもらう必要があります。

Readme等にその旨を書いてください。

### フィルタ作成のTips

#### フィルタ中でのrequire

node.jsのrequireは常にそれが記述されているファイルの位置を基準として実行されます。

なのでmiyo_require_filtersのrequireと同じ走査をするためにはmiyo_require_filtersと同様に

-フィルタ名の先頭にパスを示す「/」,「./」,「../」がつく場合、カレントディレクトリのパスと指定されたフィルタ名を連結したパスをrequireに渡す。
-フィルタ名の先頭にそれらがつかない場合、「miyojs-filter-」と指定されたフィルタ名を連結した名前をrequireに渡す。

の少なくとも前者のプロセスを踏む必要があります。

MiyoJSリファレンス
-----------------------

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

__辞書__のデータ

イベント名とエントリ内容のペアである連想配列としてのオブジェクトです。

#### filters

__フィルタ__のデータ

フィルタ名とフィルタ関数のペアである連想配列としてのオブジェクトです。

#### value_filters

__Valueフィルタ__の名前リスト

Valueフィルタとして使用するフィルタを渡す順に列挙します。

#### default_response_headers

`make_value()`等のSHIORIレスポンスメッセージ自動生成で利用されるデフォルトのヘッダ

ヘッダ名とヘッダ内容のペアである連想配列としてのオブジェクトです。

`Charset: UTF-8`やSender等を登録しておくと便利です。

### メソッド

#### load(directory)

    miyo.load('C:/path/to/shiori/dll')

directoryはベースウェアからload時に渡されるSHIORI.dllのbasedirです。

辞書中の`_load`エントリを呼びます。

#### request(request)

    var response = miyo.request(request)

requestはShioriJK.Message.Requestです。

responseとしてSHIORI/3.0 Responseを返します。

requestとresponseを対応付ける処理は__辞書__にゆだねられます。

#### unload()

    miyo.unload()

可能なら`process.exit()`します。

#### call_id(id, request, stash)

    var response = miyo.call_id('OnBoot', request)

渡されたIDに対応するエントリを適切に処理し、結果を返します。

miyo.dictionaryからidに対応するエントリを探し、

    var response = miyo.call_entry(entry, request, id, stash)

を実行し、その返値を返します。

もしrequestがnullの場合(load()またはunload()を表す)、entryが空なら何も呼ばずに終了します。

#### call_entry(entry, request, id, stash)

    var response = miyo.call_entry('http://www.example.com/', request, 'homeurl', stash)

渡されたエントリを種類によって適切に処理し、結果を返します。

- entryが配列ならmiyo.call_list(entry, request, id, stash)
- entryが連想配列ならmiyo.call_filters(entry, request, id, stash)
- entryがスカラならmiyo.call_value(entry, request, id, stash)
- entryが空ならmiyo.call_not_found()

それぞれを呼んで、その返値を返します。

#### call_value(entry, request, id, stash)

    var response = miyo.call_value('http://www.example.com/', request, 'homeurl', stash)

渡された値を「Valueフィルタ処理」にかけ、結果を返します。

#### call_list(entry, request, id, stash)

    var response = miyo.call_list(['\\h\\s[0]おはよう\\e', '\\h\\s[0]おはこんばんちは\\e'], request, 'OnBoot', stash)

複数あるエントリ候補をランダムに選び、そのエントリを適切に処理し、結果を返します。

渡された配列要素のうち1つをランダムに選び、それをmiyo.call_entry()に渡し、結果を返します。

#### call_filters(entry, request, id, stash)

    var response = miyo.call_filters({
    	filters: ['filter_1', 'filter_2'],
    	argument: {
    		filter_1: {option: 1},
    		filter_2: 128
    	},
    }, request, 'OnTest', stash)

渡された値を「フィルタ処理」にかけ、結果を返します。

#### call_not_found(entry, request, id, stash)

    var response = miyo.call_not_found()

エントリがなかった場合に呼ばれる用途です。

miyo.make_bad_request()を呼び、返します。

#### build_response()

    var response = miyo.build_response()

空のShioriJK.Message.Responseオブジェクトを生成します。

#### make_value(value, request)

    var response = miyo.make_value('miyo', request)

200 OKまたは204 No Content(valueが空の場合)を生成します。

Valueヘッダにvalueを記述します。改行文字が含まれていた場合は「\r」、「\n」の文字列に変換されます。

requestは現在使われていませんが、SHIORI/3.0以外を扱うことが可能になった場合、リクエストのSHIORIバージョンと同じレスポンスを返すために使うことを想定して、引数としてあります。

#### make_bad_request(request)

    var response = miyo.make_bad_request(request)

400 Bad Requestを生成します。

#### make_internal_server_error(error, request)

    var response = miyo.make_internal_server_error('undefined value called', request)

500 Internal Server Errorを生成します。

X-Miyo-Errorヘッダにerrorを記述します。改行文字が含まれていた場合は「\r」、「\n」の文字列に変換されます。

### 静的属性

#### filter_types

    var filter_io_types = Miyo.filter_types.through

フィルタの種類名と入出力の種類の対応表です。

### 静的関数

#### DictionaryLoader.load_recursive(directory)

    var dictionary = Miyo.DictionaryLoader.load_recursive('./dictionaries')

指定されたディレクトリ下のすべてのファイルをMiyoDictionary形式の辞書として読み込み、オブジェクトとして返します。

ディレクトリは再帰的に辿られるので、深いディレクトリに辞書を置くことも可能です。

読み込み時の挙動は「辞書」の中「辞書の読み込み」の項をご覧ください。

#### DictionaryLoader.load(file)

    var dictionary = Miyo.DictionaryLoader.load('./dictionaries/default.yaml')

指定されたファイルをMiyoDictionary形式の辞書として読み込み、オブジェクトとして返します。

#### DictionaryLoader.merge_dictionary(source, destination)

複数のファイルから読み込まれた辞書をマージします。

内部的に使われます。

ライセンス
--------------------------

[MITライセンス](http://narazaka.net/license/MIT?2014)の元で配布いたします。
