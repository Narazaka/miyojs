### (C) 2014 Narazaka : Licensed under The MIT License - http://narazaka.net/license/MIT?2014 ###

if require?
	ShiolinkJS = require 'shiolinkjs'
	Miyo = require 'miyojs'

shiolink = new ShiolinkJS new Miyo Miyo.DictionaryLoader.load_recursive if process.argv[2]? then process.argv[2] else '.'

process.stdin.resume()
process.stdin.setEncoding 'utf8'
process.stdin.on 'data', (chunk) ->
	process.stdout.write shiolink.add_chunk chunk
