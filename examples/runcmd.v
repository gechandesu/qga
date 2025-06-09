module main

import time
import qga

fn main() {
	args := arguments()[1..]
	eprintln('Run this example as: `v -d trace_guest_agent run runcmd.v SOCKET_PATH COMMAND`')
	eprintln('')
	mut ga := qga.Client.new(args[0] or { panic('socket path is not provided') })!
	eprintln('Ping guest agent...')
	ga.ping() or { panic('ping failed...') }
	eprintln('Ping successfull!')
	eprintln('Run command!')
	pid := ga.exec('/bin/sh',
		args:           ['-c', args[1] or { panic('COMMAND is not provided') }]
		capture_output: true
	)!
	for {
		status := ga.exec_status(pid)!
		time.sleep(500 * time.millisecond)
		if status.exited {
			println(status)
			break
		}
	}
}
