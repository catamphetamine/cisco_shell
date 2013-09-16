module.exports = (parameters, end) ->
	# you can execute a single command like this (supplying a callback)
	$ 'show ip interface ' + parameters.interface, (interfaces) ->
		
		console.log ''
		
		if interfaces.has(parameters.interface)
			console.log parameters.interface + ' interface found. Proceeding.'
			
			if interfaces.has('is administratively down')
				console.log parameters.interface + ' interface is switched off.'
				console.log 'Here we could easily execute a command to bring it up if we wanted.'
		else
			console.log parameters.interface + ' interface is not present. Terminating.'
			# return 'end()' to disconnect
			return end()
			
		# you can execute a set of commands like this (you can supply a callback here too)
		# (no callback specified = auto disconnect in the end)
		$$ [
			'show inventory',
			
			'configure terminal',
			
			'voice service voip',
			'allow-connections h323 to h323',
			'allow-connections h323 to sip',
			'allow-connections sip to h323',
			'supplementary-service h450.12',
			'redirect ip2ip',
			
			'do write'
		]