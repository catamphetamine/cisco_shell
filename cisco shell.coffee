require './language'
Secure_shell = require './secure shell'

preliminary_commands = ['terminal length 0', 'terminal width 0']

module.exports = (options) ->
	decorator = '==================================================================='

	options.script_path = options.script_path || './script'
	
	secure_shell = null
	end = () -> secure_shell.end()	
	
	execute = (command, callback) ->
		if !preliminary_commands.has(command)
			console.log(decorator)
			console.log('> ' + command)
				
		secure_shell.execute(command, callback)
	
	options.connected = ->
		global.$ = (command, callback) ->
			execute(command, callback || end)
	
		global.$$ = (commands, callback) ->
			finish = callback || end
		
			next = ->
				if commands.is_empty()
					return finish()
			
				execute(commands.shift(), next)
				
			next()
		
		commands = preliminary_commands.clone()
		
		prepare = ->
			if commands.is_empty()
				return require(options.script_path)(options.parameters, end)
			
			global.$(commands.shift(), prepare)
		
		prepare()
	
	options.output = (output, command) ->
		if !preliminary_commands.has(command)
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
		
		if options.error?
			options.error()
		
	options.ends_with_command_prompt = (text) ->
		if text.ends_with(' [yes/no]: ')
			return text
	 
		max_hostname_length = @hostname.length
		found = null
		
		while max_hostname_length > 0
			expression = new RegExp(RegExp.escape(@hostname.substring(0, max_hostname_length)) + '(\((.+)\))?' + '#', 'g')
			
			found = text.match(expression)
			
			if found?
				break
				
			max_hostname_length--
		
		if not found?
			return
			
		marker = found.pop()
		
		if not text.ends_with(marker)
			return
		
		return text.substring(0, text.length - marker.length)
	
	secure_shell = new Secure_shell(options)