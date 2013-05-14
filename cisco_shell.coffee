ssh2 = require 'ssh2'

require './language'
disk_tools = require './disk tools'

class Secure_shell
	commands: []
	
	constructor: (@options) ->
		shell = @
		
		@ssh = new ssh2()
		
		@ssh.on 'connect', ->
			console.log('Connection :: connect')
		
		@ssh.on 'ready', ->
			console.log('Connection :: ready')
		
			shell.shell()
			
		@ssh.on 'error', (error) ->
			if not shell.finished?
				if shell.options.failed?
					shell.options.failed(error)
				shell.finished = yes

		@ssh.on 'end', ->
			console.log('Connection :: end')

		@ssh.on 'close', (had_error) ->
			if not shell.succeeded?
				if not shell.finished?
					if shell.options.failed?
						shell.options.failed(had_error)
					shell.finished = yes
					
			console.log('Connection :: close')
			
		@ssh.connect(@options)
			
	command: (command, output) ->
		@commands.push({ 'command': command, 'output': output })
	
	next: ->
		if @commands.length == 0
			return @end()
			
		@execute_command(@commands.shift())
	
	end: ->
		@ssh.end()
		
	shell: () ->
		shell = @
		
		finished = no
		
		command = null
		command_output = null
		
		ends_with_command_prompt = (text) ->
			expression = new RegExp(RegExp.escape(shell.hostname) + '(\((.+)\))?' + '#', 'g')
			found = text.match(expression)
			
			if not found?
				return
				
			marker = found.pop()
			
			if not text.ends_with(marker)
				return
				
			return text.substring(0, text.length - marker.length)
		
		@ssh.shell (error, stream) ->
			if error?
				throw error
				
			next = ->
				if shell.options.commands.length == 0
					shell.succeeded = yes
					
					if shell.options.finish
						shell.options.finish()
						
					return shell.end()
					
				command = shell.options.commands.shift()
				command_output = ''
				
				if command.starts_with('hostname ')
					hostname = command.substring('hostname '.length)
					shell.hostname = hostname
				
				stream.write(command + '\n')
				
			stream.on 'data', (data, extended) ->
				#console.log('Stream :: data')
				#console.log(data + '')
				
				if extended == 'stderr'
					throw data
					
				data = (data + '')
				
				command_output += data
					
				if command.starts_with(command_output)
					return
				
				if not shell.hostname?
					hostname = data.trim()
					if not hostname.ends_with('#')
						return #throw 'Invalid command prompt marker received: ' + hostname
					
					shell.hostname = hostname.substring(0, hostname.length - 1)
					#console.log('--->' + shell.hostname + '<---')
				else
					output = ends_with_command_prompt(command_output)
					if output?
						finished = yes
						#command_output = command_output.substring(0, command_output.length - shell.command_prompt.length).trim()
						
						abort = ->
							console.log('Abort requested')
							shell.end()
							
						output = output.substring(command.length).trim()
							
						result = shell.options.output.bind(shell)(output, command, next, abort)
						if result == yes
							next()
						else if result == no
							abort()
				
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
			
			shell.stream = stream
			
			next()

module.exports = (options) ->
	decorator = '==================================================================='

	options.output = (output, command) ->
		if command != 'terminal length 0'
			console.log(decorator)
			console.log('Executing command: ' + command)
			if output
				console.log(decorator)
				console.log('Output:')
				console.log(output)
		return yes
		
	options.finish = () ->
		console.log(decorator)
		
	options.failed = (error) ->
		console.log(decorator)
		
		if error?
			switch error.code
				when 'ECONNREFUSED'
					console.log('Connection refused. Check your user/password and device ip address')
				else
					console.log('Failed to connect')
					
					if error
						console.log(error)
					else
						console.log('(sometimes it happens from time to time)')

		console.log(decorator)
		
	commands_list = require('./disk').read('commands.txt').trim()
	
	options.commands = commands_list.split('\n').map((x) -> x.trim()).filter((x) -> x.length > 0)
	#console.log(options.commands)
		
	options.commands.unshift('terminal length 0')

	new Secure_shell(options)