// This file is part of qga.
//
// qga is free software: you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// qga is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with qga. If not, see <https://www.gnu.org/licenses/>.

module qga

import json
import net.unix
import time

// Client holds a connection to the QEMU Guest Agent socket.
struct Client {
mut:
	stream           unix.StreamConn
	read_buffer_size int
}

// Client.new creates new Client instance connected to provided UNIX domain socket address.
// Example:
// ```
// mut ga := qga.Client.new('/tmp/qga0.sock')!
// ga.ping()!
// ```
pub fn Client.new(addr string, params ClientParams) !Client {
	mut stream := unix.connect_stream(addr) or {
		return GuestAgentError{
			msg:            'unable to connect to socket at ${addr}: ${err}'
			code:           err_no_connect
			err:            err
			is_unreachable: true
		}
	}
	stream.set_write_timeout(params.timeout)
	stream.set_read_timeout(params.timeout)
	return Client{stream, params.read_buffer_size}
}

// Client.from_handle creates new Client instance connected to socket handle.
pub fn Client.from_handle(handle int, params ClientParams) !Client {
	mut sock := unix.stream_socket_from_handle(handle) or {
		return GuestAgentError{
			msg:            'unable to connect to socket at ${handle}: ${err}'
			code:           err_no_connect
			err:            err
			is_unreachable: true
		}
	}
	mut stream := unix.StreamConn{
		sock: sock
	}
	stream.set_write_timeout(params.timeout)
	stream.set_read_timeout(params.timeout)
	return Client{stream, params.read_buffer_size}
}

@[params]
pub struct ClientParams {
	timeout          time.Duration = 5 * time.second // socket write and read timeout
	read_buffer_size int           = 4096            // read buffer size in bytes
}

// Request represents a common QEMU Guest Agent Protocol request schema.
struct Request[T] {
	execute   string
	arguments ?T
}

// Response represents a common QEMU Guest Agent Protocol response schema.
struct Response[T] {
	return T
	error  ?struct {
		class string
		desc  string
	}
}

// execute is generic function to run arbitrary QGA commands.
fn (mut c Client) execute[T, R](name string, args ?T, params ExecuteParams) !Response[R] {
	request := Request[T]{
		execute:   name
		arguments: args
	}
	encoded := json.encode(request)
	c.stream.wait_for_write() or {
		return GuestAgentError{
			msg:            'socket write timeout reached'
			code:           err_timed_out
			err:            err
			is_unreachable: true
		}
	}
	c.stream.write(encoded.bytes()) or {
		return GuestAgentError{
			msg:            'cannot write data to socket at ${c.stream.sock.handle}: ${err}'
			code:           err_cannot_write
			err:            err
			is_unreachable: true
		}
	}
	$if trace_guest_agent ? {
		eprintln('>>> ${@MOD}.${@METHOD} Sent: ${encoded}')
	}
	if params.no_return {
		$if trace_guest_agent ? {
			eprintln('<<< ${@MOD}.${@METHOD} command ${name} is no return, skip reading response')
		}
		return Response[R]{}
	}
	mut buf := []u8{len: c.read_buffer_size}
	c.stream.wait_for_read() or {
		return GuestAgentError{
			msg:            'socket read timeout reached'
			code:           err_timed_out
			err:            err
			is_unreachable: true
		}
	}
	c.stream.read(mut buf) or {
		return GuestAgentError{
			msg:            'cannot read from socket at ${c.stream.sock.handle}: ${err}'
			code:           err_cannot_read
			err:            err
			is_unreachable: true
		}
	}
	// trim trailing null bytes
	mut idx := buf.len - 1
	for idx >= 0 && buf[idx] == 0 {
		idx--
	}
	str := buf[..idx + 1].bytestr().trim_space()
	$if trace_guest_agent ? {
		eprintln('<<< ${@MOD}.${@METHOD} Recv: ${str}')
	}
	decoded := json.decode(Response[R], str)!
	if decoded.error != none {
		return GuestAgentError{
			msg:   'guest agent command failed'
			code:  err_from_agent
			class: decoded.error.class
			desc:  decoded.error.desc
		}
	}
	return decoded
}

@[params]
struct ExecuteParams {
pub:
	no_return bool
}
