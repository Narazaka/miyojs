### (C) 2014 Narazaka : Licensed under The MIT License - http://narazaka.net/license/MIT?2014 ###

if require?
	ShioriJK = require 'shiorijk'

class Miyo
	constructor : (@dictionary) ->
		@filters =
			miyo_require_filters : (argument, request) ->
				if require?
					path = require 'path'
					for file in argument.miyo_require_filters
						if file.match /^\.*\//
							filters = require path.join process.cwd(), file
						else
							filters = require 'miyojs-filter-' + file
						for name, filter of filters
							@filters[name] = filter
				else if MiyoFilters?
					for name of MiyoFilters
						@filters[name] = MiyoFilters[name]
				else
					throw 'miyo_require_filters: filter source not found.'
				argument
		@default_response_headers = {}
		@value_filters = []
	load : (directory) ->
		@shiori_dll_directory = directory
		@call_id '_load', null
	unload : ->
		@call_id '_unload', null
		if process?
			process.exit()
	request : (request) ->
		if request.request_line.version == '3.0'
			try
				response = @call_id request.headers.get('ID'), request
				unless response instanceof ShioriJK.Message.Response
					response = @make_value response, request
				"#{response}" # catch response error in miyo
			catch error
				@make_internal_server_error error, request
		else
			@make_bad_request request
	call_id : (id, request, stash) ->
		entry = @dictionary[id]
		if request == null # not request
			if entry?
				@call_entry entry, request, id, stash
		else
			@call_entry entry, request, id, stash
	call_entry : (entry, request, id, stash) ->
		if entry?
			if entry instanceof Array
				@call_list entry, request, id, stash
			else if entry instanceof Object
				@call_filters entry, request, id, stash
			else
				@call_value entry, request, id, stash
		else
			@call_not_found entry, request, id, stash
	call_value : (entry, request, id, stash) ->
		value = entry
		for filter_name in @value_filters
			filter = @filters[filter_name]
			if filter?
				value = filter.call @, value, request, id, stash
			else
				throw "value filter [#{filter_name}] not found"
		value
	call_list : (entry, request, id, stash) ->
		@call_entry entry[Math.floor (Math.random() * entry.length)], request, id, stash
	call_filters : (entry, request, id, stash) ->
		argument = entry.argument
		if entry.filters instanceof Array
			filters = entry.filters
		else
			filters = [entry.filters]
		for filter_name in filters
			filter = @filters[filter_name]
			if filter?
				argument = filter.call @, argument, request, id, stash
			else
				throw "filter [#{filter_name}] not found"
		argument
	call_not_found : (entry, request, id, stash) ->
		@make_bad_request request
	build_response : ->
		new ShioriJK.Message.Response()
	make_value : (value, request) ->
		response = @build_response()
		response.status_line.protocol = 'SHIORI'
		response.status_line.version = '3.0'
		response.status_line.code = if value?.length then 200 else 204
		for name, content of @default_response_headers
			response.headers.set name, content
		response.headers.set 'Value', value.replace /[\r\n]/g, '' if value?.length
		response
	make_bad_request : (request) ->
		response = @build_response()
		response.status_line.protocol = 'SHIORI'
		response.status_line.version = '3.0'
		response.status_line.code = 400
		for name, content of @default_response_headers
			response.headers.set name, content
		response
	make_internal_server_error : (error, request) ->
		response = @build_response()
		response.status_line.protocol = 'SHIORI'
		response.status_line.version = '3.0'
		response.status_line.code = 500
		for name, content of @default_response_headers
			response.headers.set name, content
		response.headers.set 'X-Miyo-Error', "#{error}".replace(/\r/g, '\\r').replace(/\n/g, '\\n') if error
		response

if module? and module.exports?
	module.exports = Miyo
