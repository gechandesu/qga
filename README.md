# QEMU Guest Agent Protocol client for V

`qga` is full featured QGA client for interacting with guest operating systems
in QEMU-powered virtual machine from virtualisation host.

See also:

- Guest Agent in QEMU Wiki: https://wiki.qemu.org/Features/GuestAgent
- QEMU Guest Agent Protocol Reference: https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html

## Usage

Run the virtual machine. In this example `disk.qcow2` contains Debian 12 Bookworm
with `qemu-guest-agent` package installed.

```
/usr/bin/qemu-system-x86_64 \
    -name testvm \
    -accel kvm \
    -cpu host \
    -smp 1 \
    -m 1024M \
    -drive file=disk.qcow2,media=disk,if=virtio \
    -chardev socket,path=/tmp/qga.sock,server=on,wait=off,id=qga0 \
    -device virtio-serial \
    -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0
```

Then connect to a guest agent server socket `/tmp/gqa.sock`:

```v
import qga

fn main() {
  ga := qga.Client.new('/tmp/qga.sock')!
  agent_version := ga.info()!.version
  println('everything is fine! guest agent version is ${agent_version}')
}
```

## Error handling

`GuestAgentError` contains extended error information. See the description of
the structure fields.

The error can be returned either directly by the guest agent or when trying to
communicating it. `GuestAgentError` has an explicit flag to distinguish such
errors. If for some reason the guest agent could not be reached, `is_unreachable`
will be true. The error information will be in the underlying error stored in the
`err` field and in the error text itself.

```v
module main

import qga

fn main() {
	mut ga := qga.Client.new('/tmp/qga.sock')!
	ga.get_devices() or {
		if err is qga.GuestAgentError {
			if err.is_unreachable {
				println('agent is unreachable')
				return
			} else {
				println('error info from guest agent: class=${err.class} desc=${err.desc}')
				return
			}
		}
	}
}
```

Prints this (so `guest-get-devices` is disabled on Debian):

```
error info from guest agent: class=CommandNotFound desc=Command guest-get-devices has been disabled
```

In addition, `qga` module provides a small set of specific error codes.
They can be checked in this way without `err` smartcasting:

```v ignore
ga.ping() or {
  match err.code() {
    qga.err_no_connect { panic('socket connection error') }
    qga.err_timed_out { panic('timeout reached') }
    qga.err_from_agent { panic('error ocurred in guest agent') }
    else { panic(err) }
  }
}
```

## License

`LGPL-3.0-or-later`

See [COPYING](COPYING) and [COPYING.LESSER](COPYING.LESSER) for information.
