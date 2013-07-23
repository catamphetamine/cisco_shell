require './language'

ssh2 = require 'ssh2'

class Secure_shell
	constructor: (@options) ->
		shell = @
		
		@ssh = new ssh2()
		
		@ssh.on 'connect', ->
			console.log('Connection :: connect')
		
		@ssh.on 'ready', ->
			console.log('Connection :: ready')
		
			shell.connected = yes
			shell.shell()
			
		@ssh.on 'error', (error) ->
			shell.result(() -> shell.options.failed(error))

		@ssh.on 'end', ->
			console.log('Connection :: end')

		@ssh.on 'close', (had_error) ->
			if had_error
				shell.result(() -> shell.options.failed(had_error))
			else if not shell.connected?
				shell.result(() -> shell.options.failed())
					
			console.log('Connection :: close')
			
			if options.end?
				options.end()
			
		@ssh.connect(@options)
	
	result: (callback) ->
		if @returned?
			return
			
		callback()
		@returned = yes
	
	end: ->
		if @options.finish?
			@options.finish()
			
		@ssh.end()
	
	execute: (command, output) ->
		shell = @
		
		command = command.trim()
		
		@command = command
		@command_output = ''
		
		if command.starts_with('hostname ')
			hostname = command.substring('hostname '.length)
			@hostname = hostname
		
		@output = (data) ->
			if shell.options.output?
				shell.options.output(data, command)
			if output(data) == no
				shell.end()
			
		@stream.write(command + '\n')
		
	shell: () ->
		shell = @
		
		@ssh.shell (error, stream) ->
			if error?
				throw error
				
			shell.stream = stream
			
			stream.on 'data', (data, extended) ->
				#console.log('Stream :: data')
				
				data = (data + '')
				
				shell.command_output += data
				
				if shell.command?
					if shell.command.starts_with(shell.command_output)
						return
				
				if not shell.hostname?
					hostname = data.trim()
					
					if not hostname.ends_with('#')
						return
					
					shell.hostname = hostname.substring(0, hostname.length - 1)
					#console.log('--->' + shell.hostname + '<---')
					return
				
				output = shell.options.ends_with_command_prompt.bind(shell)(shell.command_output)
				
				if not output?
					return
					
				output = output.substring(shell.command.length).trim()
				
				shell.output(output)
				
			stream.on 'readable', ->
				console.log('Stream :: readable')
			
			stream.on 'end', ->
				console.log('Stream :: EOF')
			
			stream.on 'close', ->
				console.log('Stream :: close')
				
			stream.on 'drain', ->
				#console.log('Stream :: drain')
				
			stream.on 'finish', ->
				console.log('Stream :: finish')
				
			stream.on 'pipe', ->
				console.log('Stream :: pipe')
				
			stream.on 'unpipe', ->
				console.log('Stream :: unpipe')
			
			stream.on 'exit', (code, signal) ->
				console.log('Stream :: exit :: code: ' + code + ', signal: ' + signal)
				
			shell.options.connected()
	
module.exports = Secure_shell