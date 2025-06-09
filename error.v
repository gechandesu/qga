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

// Connection to socket failed.
pub const err_no_connect = 1000

// Cannot read data from socket.
pub const err_cannot_read = 1001

// Cannot write to socket.
pub const err_cannot_write = 1002

// Read or write timeout reached. This may cause if guest agent daemon is shut off in guest.
pub const err_timed_out = 1003

// Guest agent returned an error. See details in `class` and `desc` fields of `GuestAgentError`.
pub const err_from_agent = 1004

pub struct GuestAgentError {
pub:
	msg            string  // human-readable error message
	code           int     // error code (see err_* constants in this module)
	class          string  // error class provided by QEMU Guest Agent Protocol
	desc           string  // error desc provided by QEMU Guest Agent Protocol
	is_unreachable bool    // true if the error means the guest agent could not be reached
	err            ?IError // the underlying error if available
}

pub fn (e GuestAgentError) msg() string {
	return if e.is_unreachable { e.msg } else { '${e.msg}: class=${e.class} desc=${e.desc}' }
}

pub fn (e GuestAgentError) code() int {
	return e.code
}
