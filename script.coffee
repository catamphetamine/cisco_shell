# you can execute a single command like this (supplying a callback)
$ 'show ip interface GigabitEthernet 0/0', (interfaces) ->
	
	console.log ''
	
	if interfaces.has('GigabitEthernet0/0')
		console.log 'Gigabit Ethernet 0/0 interface found. Proceeding.'
		
		if interfaces.has('is administratively down')
			console.log 'Gigabit Ethernet 0/0 interface is switched off.'
			console.log 'Here we could easily execute a command to bring it up if we wanted.'
	else
		console.log 'Gigabit Ethernet 0/0 interface is not present. Terminating.'
		# return 'no' to disconnect
		return no
		
	# you can execute a set of commands like this (you can supply a callback here too)
	$$ [
		'show inventory',
		
		'configure terminal',
		
		'voice service voip',
		'allow-connections h323 to h323',
		'allow-connections h323 to sip',
		'allow-connections sip to h323',
		'supplementary-service h450.12',
		'redirect ip2ip'
	]