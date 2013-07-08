cisco_shell = require './cisco shell'

# coffee
process.argv.shift()
# run.coffee
process.argv.shift()

options = null

try
	options = JSON.parse(process.argv.shift())
catch error
	console.log('Error while parsing options:')
	console.log(error)
	console.log('')
	console.log('Usage: coffee run.coffee "{ \\"user\\": \\"Username\\", \\"password\\": \\"P@$$w0rD\\", \\"device\\": \\"4.4.4.4\\" }"')
	console.log('')
	console.log('The executed commands are read from the "commands.txt" file')
	return
		
ssh_options = 
	port: 22
	username: options.user
	password: options.password
	host: options.device
	parameters: { interface: 'GigabitEthernet0/0' }

cisco_shell(ssh_options)
