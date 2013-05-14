require './language'
Secure_shell = require './secure shell'

module.exports = (options) ->
	decorator = '==================================================================='

	secure_shell = null
	
	options.connected = ->
		global.$ = (command, output) ->
			output = output || (() -> secure_shell.end())
			secure_shell.execute(command, output) # .bind_await(secure_shell)
	
		global.$$ = (commands, callback) ->
			finish = ->
				if not callback?
					return secure_shell.end()
			
				result = callback()
				if result == no
					secure_shell.end()
		
			next = ->
				if commands.is_empty()
					return finish()
			
				secure_shell.execute(commands.shift(), next)
				
			next()
					
		global.$ 'terminal length 0', ->
			require './script'
	
	options.output = (output, command) ->
		if command != 'terminal length 0'
			console.log(decorator)
			console.log('> ' + command)
			if output
				console.log(decorator)
				console.log(output)
		return yes
		
	options.finish = ->
		console.log(decorator)
		
	options.failed = (error) ->
		console.log(decorator)
		
		if error?
			switch error.code
				when 'ECONNREFUSED'
					console.log('Connection refused. Check your user/password and device ip address')
				else
					console.log('Failed')
					
					if error? && error != yes && error != no
						console.log(error)
		else
			console.log('Failed')
			console.log('Couldn\'t connect. It happens from time to time.')
					
		console.log(decorator)
		
	options.ends_with_command_prompt = (text) ->
		expression = new RegExp(RegExp.escape(@hostname) + '(\((.+)\))?' + '#', 'g')
		found = text.match(expression)
		
		if not found?
			return
			
		marker = found.pop()
		
		if not text.ends_with(marker)
			return
			
		return text.substring(0, text.length - marker.length)
	
	secure_shell = new Secure_shell(options)