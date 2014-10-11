chai = require 'chai'
chai.should()
expect = chai.expect
sinon = require 'sinon'
ShioriJK = require 'shiorijk'
Miyo = require '../lib/miyo.js'

describe 'build_response', ->
	ms = null
	beforeEach ->
		ms = new Miyo()
	it 'should build response', ->
		res = ms.build_response()
		res.should.be.deep.equal new ShioriJK.Message.Response()

describe 'make_value', ->
	ms = null
	beforeEach ->
		ms = new Miyo()
		ms.default_response_headers.Charset = 'UTF-8'
	it 'should make 204 on empty value', ->
		res = ms.make_value('')
		res.status_line.code.should.be.equal 204
		expect(res.headers.get('Value')).be.undefined
		expect(res.headers.get('Charset')).be.equal 'UTF-8'
	it 'should make 204 on null value', ->
		res = ms.make_value(null)
		res.status_line.code.should.be.equal 204
		expect(res.headers.get('Value')).be.undefined
		expect(res.headers.get('Charset')).be.equal 'UTF-8'
	it 'should make 204 on undefined value', ->
		res = ms.make_value()
		res.status_line.code.should.be.equal 204
		expect(res.headers.get('Value')).be.undefined
		expect(res.headers.get('Charset')).be.equal 'UTF-8'
	it 'should make 200 on normal value', ->
		value = '\\h\\s[0]\\e'
		value_res = value.replace /[\r\n]/g, ''
		res = ms.make_value(value)
		res.status_line.code.should.be.equal 200
		expect(res.headers.get('Value')).be.equal value_res
		expect(res.headers.get('Charset')).be.equal 'UTF-8'
	it 'should make 200 and remove line feeds on normal value', ->
		value = '\\h\\s[0]\n\r\\e\r\n'
		value_res = value.replace /[\r\n]/g, ''
		res = ms.make_value(value)
		res.status_line.code.should.be.equal 200
		expect(res.headers.get('Value')).be.equal value_res
		expect(res.headers.get('Charset')).be.equal 'UTF-8'

describe 'make_bad_request', ->
	ms = null
	beforeEach ->
		ms = new Miyo()
		ms.default_response_headers.Charset = 'UTF-8'
	it 'should make 400', ->
		res = ms.make_bad_request()
		res.status_line.code.should.be.equal 400
		expect(res.headers.get('Value')).be.undefined
		expect(res.headers.get('Charset')).be.equal 'UTF-8'

describe 'make_internal_server_error', ->
	ms = null
	beforeEach ->
		ms = new Miyo()
		ms.default_response_headers.Charset = 'UTF-8'
	it 'should make 500', ->
		error = null
		res = ms.make_internal_server_error(error)
		res.status_line.code.should.be.equal 500
		expect(res.headers.get('Value')).be.undefined
		expect(res.headers.get('X-Miyo-Error')).be.undefined
		expect(res.headers.get('Charset')).be.equal 'UTF-8'
	it 'should make 500 with error header', ->
		error = 'this is the error\0'
		error_res = "#{error}".replace(/\r/g, '\\r').replace(/\n/g, '\\n')
		res = ms.make_internal_server_error(error)
		res.status_line.code.should.be.equal 500
		expect(res.headers.get('Value')).be.undefined
		expect(res.headers.get('X-Miyo-Error')).be.equal error_res
		expect(res.headers.get('Charset')).be.equal 'UTF-8'
	it 'should make 500 with error header that has no raw line feeds', ->
		error = 'error\nerror\r\n'
		error_res = "#{error}".replace(/\r/g, '\\r').replace(/\n/g, '\\n')
		res = ms.make_internal_server_error(error)
		res.status_line.code.should.be.equal 500
		expect(res.headers.get('Value')).be.undefined
		expect(res.headers.get('X-Miyo-Error')).be.equal error_res
		expect(res.headers.get('Charset')).be.equal 'UTF-8'

describe 'call_not_found', ->
	ms = null
	beforeEach ->
		ms = new Miyo()
		ms.default_response_headers.Charset = 'UTF-8'
	it 'should return 400', ->
		res = ms.call_not_found()
		res.status_line.code.should.be.equal 400

describe 'call_value', ->
	ms = null
	request = null
	id = null
	value = null
	stash = null
	beforeEach ->
		ms = new Miyo()
		request = new ShioriJK.Message.Request()
		id = 'OnTest'
		value = '\\h\\s[0]'
		stash = 'stash'
	it 'should pass value to value_filters', ->
		ms.filters.test_value_filter = (value, request, id, stash) -> value + '\\e'
		ms.value_filters.push 'test_value_filter'
		res = ms.call_value(value, request, id, stash)
		res.should.be.equal value + '\\e'
	it 'should pass exact arguments to filters', ->
		ms.filters.test_value_filter = (value, request, id, stash) -> request + id + value + stash + '\\e'
		ms.value_filters.push 'test_value_filter'
		res = ms.call_value(value, request, id, stash)
		res.should.be.equal request + id + value + stash + '\\e'
	it 'should throw on filter not found', ->
		ms.value_filters.push 'test_value_filter'
		(-> ms.call_value(value, request, id, stash)).should.throw /not found/

describe 'call_filters', ->
	ms = null
	test = null
	request = null
	id = null
	stash = null
	beforeEach ->
		ms = new Miyo()
		test = null
		ms.filters.test_filter = (argument, request, id, stash) ->
			test = id
			argument.test_filter
		ms.filters.test_filter2 = (argument, request, id, stash) ->
			test = test + argument.test_filter2 + id + stash
			argument
		ms.filters.test_filter_check = (argument, request, id, stash) ->
			JSON.stringify(argument) + request + id + stash
		request = new ShioriJK.Message.Request()
		id = 'OnTest'
		stash = 'stash'
	it 'should pass argument and filter-return-value to filters sequentially', ->
		entry =
			filters: ['test_filter', 'test_filter2']
			argument:
				test_filter:
					test_filter2: 'test2'
		res = ms.call_filters(entry, request, id, stash)
		res.should.be.deep.equal entry.argument.test_filter
		test.should.be.equal id + entry.argument.test_filter.test_filter2 + id + stash
	it 'should treat non-array filters property', ->
		entry =
			filters: 'test_filter'
			argument:
				test_filter: 'test'
		res = ms.call_filters(entry, request, id, stash)
		res.should.be.deep.equal entry.argument.test_filter
		test.should.be.equal id
	it 'should pass exact arguments to filters', ->
		entry =
			filters: ['test_filter_check']
			argument:
				test_filter: 'test'
		res = ms.call_filters(entry, request, id, stash)
		res.should.be.equal JSON.stringify(entry.argument) + request + id + stash
	it 'should throw on filter not found', ->
		entry =
			filters: ['test_filter_not_exists']
			argument:
				test_filter: 'test'
		(-> ms.call_filters(entry, request, id, stash)).should.throw /not found/

describe 'call_list', ->
	ms = null
	request = null
	id = null
	stash = null
	random_stub = null
	call_entry_spy = null
	beforeEach ->
		ms = new Miyo()
		random_stub = sinon.stub Math, 'random'
		call_entry_spy = sinon.spy ms, 'call_entry'
		request = new ShioriJK.Message.Request()
		id = 'OnTest'
		stash = 'stash'
	afterEach ->
		random_stub.restore()
	it 'should call call_entry on simple entry', ->
		random_stub.returns 0
		entry = [
			'\\h\\s[0]\\e'
			'\\h\\s[1]\\e'
		]
		res = ms.call_list(entry, request, id, stash)
		res.should.be.equal entry[0]
		call_entry_spy.callCount.should.be.equal 1
		call_entry_spy.firstCall.calledWithExactly(entry[0], request, id, stash).should.be.true
	it 'should call call_entry recursively on nested entry', ->
		random_stub.returns 0
		entry = [
			[
				'\\h\\s[0]\\e'
				'\\h\\s[1]\\e'
			]
			'\\h\\s[2]\\e'
			'\\h\\s[3]\\e'
		]
		res = ms.call_list(entry, request, id, stash)
		res.should.be.equal entry[0][0]
		call_entry_spy.callCount.should.be.equal 2
		call_entry_spy.firstCall.calledWithExactly(entry[0], request, id, stash).should.be.true
		call_entry_spy.lastCall.calledWithExactly(entry[0][0], request, id, stash).should.be.true

describe 'call_entry', ->
	ms = null
	request = null
	id = null
	stash = null
	beforeEach ->
		ms = new Miyo()
		request = new ShioriJK.Message.Request()
		id = 'OnTest'
		stash = 'stash'
	it 'should pass value entry to call_value', ->
		entry = '\\h\\s[0]\\e'
		s = sinon.spy ms, 'call_value'
		res = ms.call_entry(entry, request, id, stash)
		s.calledOnce.should.be.true
		s.firstCall.calledWithExactly(entry, request, id, stash).should.be.true
	it 'should pass filter entry to call_filters', ->
		ms.filters.test_filter = (argument, request, id, stash) -> argument
		entry =
			filters: ['test_filter']
			argument:
				test_filter: 'test'
		s = sinon.spy ms, 'call_filters'
		res = ms.call_entry(entry, request, id, stash)
		s.calledOnce.should.be.true
		s.firstCall.calledWithExactly(entry, request, id, stash).should.be.true
	it 'should pass list entry to call_list', ->
		random_stub = sinon.stub Math, 'random'
		random_stub.returns 0.9
		entry = [
			[
				'\\h\\s[0]\\e'
				'\\h\\s[1]\\e'
			]
			'\\h\\s[2]\\e'
			'\\h\\s[3]\\e'
		]
		s = sinon.spy ms, 'call_list'
		res = ms.call_entry(entry, request, id, stash)
		s.calledOnce.should.be.true
		s.firstCall.calledWithExactly(entry, request, id, stash).should.be.true
		random_stub.restore()
	it 'should pass invalid entry to call_not_found', ->
		entry = `undefined`
		s = sinon.spy ms, 'call_not_found'
		res = ms.call_entry(entry, request, id, stash)
		s.calledOnce.should.be.true
		s.firstCall.calledWithExactly(entry, request, id, stash).should.be.true

describe 'call_id', ->
	ms = null
	stash = null
	call_entry_spy = null
	dictionary =
		_load: 'load'
		OnTest: '\\h\\s[0]\\e'
	beforeEach ->
		ms = new Miyo(dictionary)
		call_entry_spy = sinon.spy ms, 'call_entry'
	it 'should not call_id on undefined entry with null request (load, unload)', ->
		id = '_unload'
		request = null
		res = ms.call_id(id, request, stash)
		call_entry_spy.callCount.should.be.equal 0
		expect(res).be.undefined
	it 'should call_id on defined entry with null request (load, unload)', ->
		id = '_load'
		request = null
		res = ms.call_id(id, request, stash)
		call_entry_spy.calledOnce.should.be.true
		call_entry_spy.firstCall.calledWithExactly(dictionary._load, request, id, stash).should.be.true
	it 'should call_id on undefined entry with normal request (request)', ->
		id = 'onTestTest'
		request = new ShioriJK.Message.Request()
		res = ms.call_id(id, request, stash)
		call_entry_spy.calledOnce.should.be.true
		call_entry_spy.firstCall.calledWithExactly(`undefined`, request, id, stash).should.be.true
	it 'should call_id on defined entry with normal request (request)', ->
		id = 'OnTest'
		request = new ShioriJK.Message.Request()
		res = ms.call_id(id, request, stash)
		call_entry_spy.calledOnce.should.be.true
		call_entry_spy.firstCall.calledWithExactly(dictionary.OnTest, request, id, stash).should.be.true

describe 'load', ->
	ms = null
	call_id_spy = null
	beforeEach ->
		ms = new Miyo({})
		call_id_spy = sinon.spy ms, 'call_id'
	it 'should call_id("_load", null) and store shiori_dll_directory', ->
		directory = '/'
		res = ms.load(directory)
		call_id_spy.calledOnce.should.be.true
		call_id_spy.firstCall.calledWithExactly('_load', null).should.be.true
		ms.shiori_dll_directory.should.be.equal directory

describe 'unload', ->
	ms = null
	exit_stub = null
	call_id_spy = null
	beforeEach ->
		ms = new Miyo({})
		exit_stub = sinon.stub process, 'exit'
		call_id_spy = sinon.spy ms, 'call_id'
	afterEach ->
		exit_stub.restore()
	it 'should call_id("_unload", null) and process.exit()', ->
		res = ms.unload()
		call_id_spy.calledOnce.should.be.true
		call_id_spy.firstCall.calledWithExactly('_unload', null).should.be.true
		exit_stub.calledOnce.should.be.true

describe 'request', ->
	ms = null
	call_id_stub = null
	request_2 = null
	request_3 = null
	response = null
	beforeEach ->
		ms = new Miyo()
		request_3 = new ShioriJK.Message.Request()
		request_3.request_line.method = 'GET'
		request_3.request_line.protocol = 'SHIORI'
		request_3.request_line.version = '3.0'
		request_3.headers.set('Charset', 'UTF-8')
		request_3.headers.set('Sender', 'SSP')
		request_2 = new ShioriJK.Message.Request()
		request_2.request_line.method = 'GET Version'
		request_2.request_line.protocol = 'SHIORI'
		request_2.request_line.version = '2.6'
		request_2.headers.set('Charset', 'UTF-8')
		request_2.headers.set('Sender', 'SSP')
		response = new ShioriJK.Message.Response()
		response.status_line.code = 200
		response.status_line.protocol = 'SHIORI'
		response.status_line.version = '3.0'
		response.headers.set('Charset', 'UTF-8')
		response.headers.set('Sender', 'SSP')
		response.headers.set('Value', 'test response')
		call_id_stub = sinon.stub ms, 'call_id'
		call_id_stub.returns()
		call_id_stub.withArgs('OnTest').returns('test')
		call_id_stub.withArgs('OnTestResponse').returns(response)
		call_id_stub.withArgs('OnTestThrow').throws('test throw')
	it 'should make bad request on SHIORI/2.x', ->
		res = ms.request(request_2)
		"#{res}".should.be.equal ms.make_bad_request().toString()
	it 'should make response on entry that returns value', ->
		request_3.headers.set('ID', 'OnTest')
		res = ms.request(request_3)
		"#{res}".should.be.equal ms.make_value('test').toString()
	it 'should return response on entry that returns response object', ->
		request_3.headers.set('ID', 'OnTestResponse')
		res = ms.request(request_3)
		"#{res}".should.be.equal response.toString()
	it 'should make internal server error on entry that throws', ->
		request_3.headers.set('ID', 'OnTestThrow')
		res = ms.request(request_3)
		"#{res}".should.be.equal ms.make_internal_server_error('test throw').toString()