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

import encoding.base64

// Empty is used for guest-ping and other commands with no arguments or no return.
struct Empty {}

struct GuestExec {
	pid int
}

struct GuestExecRequest {
mut:
	path           string
	arg            ?[]string
	env            ?[]string
	input_data     ?string @[json: 'input-data']
	capture_output ?bool   @[json: 'capture-output']
}

@[params]
pub struct GuestExecParams {
pub:
	args           ?[]string
	env            ?[]string
	input_data     ?string
	capture_output ?bool
}

// exec executes [guest-exec](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-exec) command.
pub fn (mut c Client) exec(path string, params GuestExecParams) !int {
	req := GuestExecRequest{
		path:           path
		arg:            params.args
		env:            params.env
		input_data:     params.input_data
		capture_output: params.capture_output
	}
	res := c.execute[GuestExecRequest, GuestExec]('guest-exec', req)!
	return res.return.pid
}

pub struct GuestExecStatus {
pub:
	exited        bool
	exitcode      ?int
	signal        ?int
	out_data      ?string @[json: 'out-data']
	err_data      ?string @[json: 'err-data']
	out_truncated ?bool   @[json: 'out-truncated']
	err_truncated ?bool   @[json: 'err-truncated']
}

struct GuestExecStatusRequest {
	pid int
}

// exec_status executes [guest-exec-status](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-exec-status) command.
pub fn (mut c Client) exec_status(pid int) !GuestExecStatus {
	req := GuestExecStatusRequest{pid}
	return c.execute[GuestExecStatusRequest, GuestExecStatus]('guest-exec-status', req)!.return
}

struct GuestFileCloseRequest {
	handle int
}

// file_close executes [guest-file-close](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-file-close) command.
pub fn (mut c Client) file_close(handle int) ! {
	req := GuestFileCloseRequest{handle}
	c.execute[GuestFileCloseRequest, Empty]('guest-file-close', req)!
}

struct GuestFileFlushRequest {
	handle int
}

// file_flush executes [guest-file-flush](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-file-flush) command.
pub fn (mut c Client) file_flush(handle int) ! {
	req := GuestFileFlushRequest{handle}
	c.execute[GuestFileFlushRequest, Empty]('guest-file-flush', req)!
}

struct GuestFileOpenRequest {
	path string
	mode string
}

// file_open executes [guest-file-open](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-file-open) command.
pub fn (mut c Client) file_open(path string, mode string) !int {
	req := GuestFileOpenRequest{path, mode}
	return c.execute[GuestFileOpenRequest, int]('guest-file-open', req)!.return
}

struct GuestFileReadRequest {
	handle int
	count  int
}

pub struct GuestFileRead {
pub:
	count   int
	buf_b64 string @[json: 'buf-b64']
	eof     bool
}

// file_read executes [guest-file-read](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-file-read) command.
pub fn (mut c Client) file_read(handle int, count int) !GuestFileRead {
	req := GuestFileReadRequest{handle, count}
	return c.execute[GuestFileReadRequest, GuestFileRead]('guest-file-read', req)!.return
}

struct GuestFileSeekRequest {
	handle int
	offset int
	whence GuestAgentWhence
}

pub struct GuestFileSeek {
pub:
	position int
	eof      bool
}

pub struct GuestAgentWhence {
pub:
	value int
	name  QGASeek
}

pub enum QGASeek {
	set
	cur
	end
}

// file_seek executes [guest-file-seek](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-file-seek) command.
pub fn (mut c Client) file_seek(handle int, offset int, whence GuestAgentWhence) !GuestFileSeek {
	req := GuestFileSeekRequest{handle, offset, whence}
	return c.execute[GuestFileSeekRequest, GuestFileSeek]('guest-file-seek', req)!.return
}

struct GuestFileWriteRequest {
mut:
	handle  int
	buf_b64 string
	count   int
}

pub struct GuestFileWrite {
pub:
	count int
	eof   bool
}

@[params]
pub struct GuestFileWriteParams {
pub:
	is_encoded bool
	count      ?int
}

// file_write executes [guest-file-write](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-file-write) command.
pub fn (mut c Client) file_write(handle int, buf string, params GuestFileWriteParams) !GuestFileWrite {
	mut req := GuestFileWriteRequest{
		handle: handle
	}
	if params.is_encoded {
		req.buf_b64 = buf
	} else {
		req.buf_b64 = base64.encode_str(buf)
	}
	if params.count == none {
		req.count = req.buf_b64.len
	} else {
		req.count = params.count
	}
	return c.execute[GuestFileWriteRequest, GuestFileWrite]('guest-file-write', req)!.return
}

// fsfreeze_freeze executes [guest-fsfreeze-freeze](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-fsfreeze-freeze) command.
pub fn (mut c Client) fsfreeze_freeze() !int {
	return c.execute[Empty, int]('guest-fsfreeze-freeze', none)!.return
}

struct GuestFsfreezeFsfreezeList {
mut:
	mountpoints ?[]string
}

// fsfreeze_freeze_list executes [guest-fsfreeze-freeze-list](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-fsfreeze-freeze-list) command.
// An empty `mountpoints` array will freeze all filesystems.
pub fn (mut c Client) fsfreeze_freeze_list(mountpoints []string) !int {
	mut req := GuestFsfreezeFsfreezeList{}
	if mountpoints.len > 0 {
		req.mountpoints = mountpoints
	}
	return c.execute[GuestFsfreezeFsfreezeList, int]('guest-fsfreeze-freeze-list', req)!.return
}

pub enum GuestFsfreezeStatus {
	thawed
	frozen
}

// fsfreeze_status executes [guest-fsfreeze-status](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-fsfreeze-status) command.
pub fn (mut c Client) fsfreeze_status() !GuestFsfreezeStatus {
	return c.execute[Empty, GuestFsfreezeStatus]('guest-fsfreeze-status', none)!.return
}

// fsfreeze_thaw executes [guest-fsfreeze-thaw](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-fsfreeze-thaw) command.
pub fn (mut c Client) fsfreeze_thaw() !int {
	return c.execute[Empty, int]('guest-fsfreeze-thaw', none)!.return
}

struct GuestFilesystemTrimRequest {
	minimun u64
}

pub struct GuestFilesystemTrimResponse {
pub:
	paths []GuestFilesystemTrimResult
}

pub struct GuestFilesystemTrimResult {
	path    string
	error   ?string
	trimmed ?u64
	minimum ?u64
}

// fstrim executes [guest-fstrim](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-fstrim) command.
// Set `minimum` to zero to discard every free block.
pub fn (mut c Client) fstrim(minimum u64) !GuestFilesystemTrimResponse {
	req := GuestFilesystemTrimRequest{minimum}
	return c.execute[GuestFilesystemTrimRequest, GuestFilesystemTrimResponse]('guest-fstrim',
		req)!.return
}

pub struct GuestCpuStats {
	GuestLinuxCpuStats
pub:
	type GuestCpuStatsType
}

pub enum GuestCpuStatsType {
	linux
}

pub struct GuestLinuxCpuStats {
pub:
	cpu       int
	user      int
	nice      int
	system    int
	idle      int
	iowait    ?int
	irq       ?int
	sofirq    ?int
	steal     ?int
	guest     ?int
	guestnice ?int
}

// get_cpustats executes [guest-get-cpustats](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-cpustats) command.
pub fn (mut c Client) get_cpustats() ![]GuestCpuStats {
	return c.execute[Empty, []GuestCpuStats]('guest-get-cpustats', none)!.return
}

pub struct GuestDeviceInfo {
	driver_name    string  @[json: 'driver-name']
	driver_data    ?string @[json: 'driver-data']
	driver_version ?string @[json: 'driver-version']
	id             ?GuestDeviceId
}

pub struct GuestDeviceId {
pub:
	type      GuestDeviceType
	vendor_id int @[json: 'vendor-id']
	device_id int @[json: 'device-id']
}

pub enum GuestDeviceType {
	pci
}

// get_devices executes [guest-get-devices](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-devices) command.
pub fn (mut c Client) get_devices() ![]GuestDeviceInfo {
	return c.execute[Empty, []GuestDeviceInfo]('guest-get-devices', none)!.return
}

pub struct GuestDiskInfo {
pub:
	name         string
	partition    bool
	dependencies ?[]string
	address      ?GuestDiskAddress
	alias        ?string
	smart        ?GuestDiskSmart
}

pub struct GuestDiskAddress {
pub:
	pci_controller GuestPCIAddress  @[json: 'pci-controller']
	bus_type       GuestDiskBusType @[json: 'bus-type']
	bus            int
	target         int
	unit           int
	serial         ?string
	dev            ?string
	ccw_address    ?GuestCCWAddress @[json: 'ccw-address']
}

pub struct GuestPCIAddress {
pub:
	domain   int
	bus      int
	slot     int
	function int
}

pub enum GuestDiskBusType {
	ide
	fdc
	scsi
	virtio
	xen
	usb
	uml
	sata
	sd
	unknown
	ieee1394
	ssa
	fibre
	raid
	iscsi
	sas
	mmc
	virtual
	file_backed_virtual  @[json: 'file-backed-virtual']
	nvme
}

pub struct GuestCCWAddress {
pub:
	cssid   int
	ssid    int
	subchno int
	devno   int
}

pub struct GuestDiskSmart {
pub:
	critical_warning               int @[json: 'critical-warning']
	temperature                    int @[json: 'temperature']
	available_spare                int @[json: 'available-spare']
	available_spare_threshold      int @[json: 'available-spare-threshold']
	percentage_used                int @[json: 'percentage-used']
	data_units_read_lo             int @[json: 'data-units-read-lo']
	data_units_read_hi             int @[json: 'data-units-read-hi']
	data_units_written_lo          int @[json: 'data-units-written-lo']
	data_units_written_hi          int @[json: 'data-units-written-hi']
	host_read_commands_lo          int @[json: 'host-read-commands-lo']
	host_read_commands_hi          int @[json: 'host-read-commands-hi']
	host_write_commands_lo         int @[json: 'host-write-commands-lo']
	host_write_commands_hi         int @[json: 'host-write-commands-hi']
	controller_busy_time_lo        int @[json: 'controller-busy-time-lo']
	controller_busy_time_hi        int @[json: 'controller-busy-time-hi']
	power_cycles_lo                int @[json: 'power-cycles-lo']
	power_cycles_hi                int @[json: 'power-cycles-hi']
	power_on_hours_lo              int @[json: 'power-on-hours-lo']
	power_on_hours_hi              int @[json: 'power-on-hours-hi']
	unsafe_shutdowns_lo            int @[json: 'unsafe-shutdowns-lo']
	unsafe_shutdowns_hi            int @[json: 'unsafe-shutdowns-hi']
	media_errors_lo                int @[json: 'media-errors-lo']
	media_errors_hi                int @[json: 'media-errors-hi']
	number_of_error_log_entries_lo int @[json: 'number-of-error-log-entries-lo']
	number_of_error_log_entries_hi int @[json: 'number-of-error-log-entries-hi']
}

// get_disks executes [guest-get-disks](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-disks) command.
pub fn (mut c Client) get_disks() ![]GuestDiskInfo {
	return c.execute[Empty, []GuestDiskInfo]('guest-get-disks', none)!.return
}

pub struct GuestDiskStatsInfo {
pub:
	name  string
	major int
	minor int
	stats GuestDiskStats
}

pub struct GuestDiskStats {
	read_sectors    ?int @[json: 'read-sectors']
	read_ios        ?int @[json: 'read-ios']
	read_merges     ?int @[json: 'read-merges']
	write_sectors   ?int @[json: 'write-sectors']
	write_ios       ?int @[json: 'write-ios']
	write_merges    ?int @[json: 'write-merges']
	discard_sectors ?int @[json: 'discard-sectors']
	discard_ios     ?int @[json: 'discard-ios']
	discard_merges  ?int @[json: 'discard-merges']
	flush_ios       ?int @[json: 'flush-ios']
	read_ticks      ?int @[json: 'read-ticks']
	write_ticks     ?int @[json: 'write-ticks']
	discard_ticks   ?int @[json: 'discard-ticks']
	flush_ticks     ?int @[json: 'flush-ticks']
	ios_pgr         ?int @[json: 'ios-pgr']
	total_ticks     ?int @[json: 'total-ticks']
	weight_ticks    ?int @[json: 'weight-ticks']
}

// get_diskstats executes [guest-get-diskstats](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-diskstats) command.
pub fn (mut c Client) get_diskstats() ![]GuestDiskStatsInfo {
	return c.execute[Empty, []GuestDiskStatsInfo]('guest-get-diskstats', none)!.return
}

pub struct GuestFilesystemInfo {
pub:
	name                   string
	mountpoint             string
	type                   string
	used_bytes             ?u64 @[json: 'used-bytes']
	total_bytes            ?u64 @[json: 'total-bytes']
	total_bytes_privileged ?u64 @[json: 'total-bytes-privileged']
	disk                   []GuestDiskAddress
}

// get_fsinfo executes [guest-get-fsinfo](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-fsinfo) command.
pub fn (mut c Client) get_fsinfo() ![]GuestFilesystemInfo {
	return c.execute[Empty, []GuestFilesystemInfo]('guest-get-fsinfo', none)!.return
}

struct GuestHostName {
	host_name string @[json: 'host-name']
}

// get_host_name executes [guest-get-host-name](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-host-name) command.
pub fn (mut c Client) get_host_name() !string {
	return c.execute[Empty, GuestHostName]('guest-get-host-name', none)!.return.host_name
}

pub struct GuestLoadAverage {
	load1m  f64
	load5m  f64
	load15m f64
}

// get_load executes [guest-get-load](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-load) command.
pub fn (mut c Client) get_load() !GuestLoadAverage {
	return c.execute[Empty, GuestLoadAverage]('guest-get-load', none)!.return
}

pub struct GuestMemoryBlockInfo {
	size int
}

// get_memory_block_info executes [guest-get-memory-block-info](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-memory-block-info) command.
pub fn (mut c Client) get_memory_block_info() !GuestMemoryBlockInfo {
	return c.execute[Empty, GuestMemoryBlockInfo]('guest-get-memory-block-info', none)!.return
}

pub struct GuestMemoryBlock {
pub:
	phys_index  int @[json: 'phys-index']
	online      bool
	can_offline ?bool @[json: 'can-offline']
}

// get_memory_blocks executes [guest-get-memory-blocks](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-memory-blocks) command.
pub fn (mut c Client) get_memory_blocks() ![]GuestMemoryBlock {
	return c.execute[Empty, []GuestMemoryBlock]('guest-get-memory-blocks', none)!.return
}

pub struct GuestOSInfo {
pub:
	kernel_release ?string @[json: 'kernel-release']
	kernel_version ?string @[json: 'kernel-version']
	machine        ?string
	id             ?string
	name           ?string
	pretty_name    ?string @[json: 'pretty-name']
	version        ?string
	version_id     ?string @[json: 'version-id']
	variant        ?string
	variant_id     ?string @[json: 'variant-id']
}

// get_osinfo executes [guest-get-osinfo](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-osinfo) command.
pub fn (mut c Client) get_osinfo() !GuestOSInfo {
	return c.execute[Empty, GuestOSInfo]('guest-get-osinfo', none)!.return
}

// get_time executes [guest-get-time](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-time) command.
pub fn (mut c Client) get_time() !i64 {
	return c.execute[Empty, i64]('guest-get-time', none)!.return
}

pub struct GuestTimezone {
	zone   ?string
	offset int
}

// get_timezone executes [guest-get-timezone](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-timezone) command.
pub fn (mut c Client) get_timezone() !GuestTimezone {
	return c.execute[Empty, GuestTimezone]('guest-get-timezone', none)!.return
}

pub struct GuestUser {
pub:
	user       string
	domain     string
	login_time f64 @[json: 'login-time']
}

// get_users executes [guest-get-users](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-users) command.
pub fn (mut c Client) get_users() ![]GuestUser {
	return c.execute[Empty, []GuestUser]('guest-get-users', none)!.return
}

pub struct GuestLogicalProcessor {
pub:
	logical_id  int @[json: 'logical-id']
	online      bool
	can_offline ?bool @[json: 'can-offline']
}

// get_vcpus executes [guest-get-vcpus](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-get-vcpus) command.
pub fn (mut c Client) get_vcpus() ![]GuestLogicalProcessor {
	return c.execute[Empty, []GuestLogicalProcessor]('guest-get-vcpus', none)!.return
}

pub struct GuestAgentInfo {
pub:
	version            string
	supported_commands []GuestAgentCommandInfo
}

pub struct GuestAgentCommandInfo {
pub:
	name             string
	enabled          bool
	success_response bool @[json: 'success-response']
}

// info executes [guest-info](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-info) command.
pub fn (mut c Client) info() !GuestAgentInfo {
	return c.execute[Empty, GuestAgentInfo]('guest-info', none)!.return
}

pub struct GuestNetworkInterface {
pub:
	name             string
	hardware_address ?string           @[json: 'hardware-address']
	ip_addresses     ?[]GuestIpAddress @[json: 'ip-addresses']
	statistics       ?GuestNetworkInterfaceStat
}

pub struct GuestIpAddress {
pub:
	ip_address      string             @[json: 'ip-address']
	ip_address_type GuestIpAddressType @[json: 'ip-address-type']
	prefix          int
}

pub enum GuestIpAddressType {
	ipv4
	ipv6
}

pub struct GuestNetworkInterfaceStat {
pub:
	rx_bytes   int @[json: 'rx-bytes']
	rx_packets int @[json: 'rx-packets']
	rx_errs    int @[json: 'rx-errs']
	rx_dropped int @[json: 'rx-dropped']
	tx_bytes   int @[json: 'tx-bytes']
	tx_packets int @[json: 'tx-packets']
	tx_errs    int @[json: 'tx-errs']
	tx_dropped int @[json: 'tx-dropped']
}

// network_get_interfaces executes [guest-network-get-interfaces](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-network-get-interfaces) command.
pub fn (mut c Client) network_get_interfaces() ![]GuestNetworkInterface {
	return c.execute[Empty, []GuestNetworkInterface]('guest-network-get-interfaces', none)!.return
}

pub struct GuestNetworkRoute {
pub:
	iface        string
	destination  string
	metric       int
	gateway      ?string
	mask         ?string
	irtt         ?int
	flags        ?int
	refcnt       ?int
	use          ?int
	window       ?int
	mtu          ?int
	desprefixlen ?string
	source       ?string
	srcprefixlen ?string
	nexthop      ?string
	version      int
}

// network_get_route executes [guest-network-get-route](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-network-get-route) command.
pub fn (mut c Client) network_get_route() ![]GuestNetworkRoute {
	return c.execute[Empty, []GuestNetworkRoute]('guest-network-get-route', none)!.return
}

// ping executes [guest-ping](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-ping) command, a non-error return implies success.
pub fn (mut c Client) ping() ! {
	c.execute[Empty, Empty]('guest-ping', none)!
}

struct GuestSetMemoryBlocksRequest {
	mem_blks []GuestMemoryBlock @[json: 'mem-blks']
}

pub struct GuestMemoryBlockResponse {
pub:
	phys_index int @[json: 'phys-index']
	response   GuestMemoryBlockResponseType
	error_code ?int @[json: 'error-code']
}

pub enum GuestMemoryBlockResponseType {
	success
	not_found                @[json: 'not-found']
	operation_not_supported  @[json: 'operation-not-supported']
	operation_failed         @[json: 'operation-failed']
}

// set_memory_blocks executes [guest-set-memory-blocks](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-set-memory-blocks) command.
pub fn (mut c Client) set_memory_blocks(blocks []GuestMemoryBlock) ![]GuestMemoryBlockResponse {
	req := GuestSetMemoryBlocksRequest{blocks}
	return c.execute[GuestSetMemoryBlocksRequest, []GuestMemoryBlockResponse]('guest-set-memory-blocks',
		req)!.return
}

struct GuestSetTimeRequest {
	time i64
}

// set_time executes [guest-set-time](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-set-time) command.
pub fn (mut c Client) set_time(epoch i64) ! {
	req := GuestSetTimeRequest{epoch}
	c.execute[GuestSetTimeRequest, Empty]('guest-set-time', req)!
}

struct GuestSetUserPasswordRequest {
	username string
	password string
	crypted  bool
}

// set_user_password executes [guest-set-user-password](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-set-user-password) command.
pub fn (mut c Client) set_user_password(username string, password string, crypted bool) ! {
	req := GuestSetUserPasswordRequest{username, password, crypted}
	c.execute[GuestSetUserPasswordRequest, Empty]('guest-set-user-password', req)!
}

struct GuestSetVcpusRequest {
	vcpus []GuestLogicalProcessor
}

// set_vcpus executes [guest-set-vcpus](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-set-vcpus) command.
pub fn (mut c Client) set_vcpus(vcpus []GuestLogicalProcessor) !int {
	req := GuestSetVcpusRequest{vcpus}
	return c.execute[GuestSetVcpusRequest, int]('guest-set-vcpus', req)!.return
}

pub enum GuestShutdownMode {
	halt
	powerdown
	reboot
}

struct GuestShutdownRequest {
	mode GuestShutdownMode
}

// shutdown executes [guest-shutdown](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-shutdown) command.
pub fn (mut c Client) shutdown(mode GuestShutdownMode) ! {
	req := GuestShutdownRequest{mode}
	c.execute[GuestShutdownRequest, Empty]('guest-shutdown', req, no_return: true)!
}

struct GuestSSHAddAuthorizedKeysRequest {
	username string
	keys     []string
	reset    ?bool
}

// ssh_add_authorized_keys executes [guest-ssh-add-authorized-keys](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-ssh-add-authorized-keys) command.
pub fn (mut c Client) ssh_add_authorized_keys(username string, keys []string, reset bool) ! {
	req := GuestSSHAddAuthorizedKeysRequest{username, keys, reset}
	c.execute[GuestSSHAddAuthorizedKeysRequest, Empty]('guest-ssh-add-authorized-keys',
		req)!
}

struct GuestAuthorizedKeys {
	keys []string
}

// ssh_get_authorized_keys executes [guest-ssh-get-authorized-keys](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-ssh-get-authorized-keys) command.
pub fn (mut c Client) ssh_get_authorized_keys() ![]string {
	return c.execute[Empty, GuestAuthorizedKeys]('guest-ssh-get-authorized-keys', none)!.return.keys
}

// ssh_remove_authorized_keys executes [guest-ssh-remove-authorized-keys](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-ssh-remove-authorized-keys) command.
pub fn (mut c Client) ssh_remove_authorized_keys(username string, keys []string) ! {
	req := GuestSSHAddAuthorizedKeysRequest{
		username: username
		keys:     keys
	}
	c.execute[GuestSSHAddAuthorizedKeysRequest, Empty]('guest-ssh-remove-authorized-keys',
		req)!
}

// suspend_disk executes [guest-suspend-disk](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-suspend-disk) command.
pub fn (mut c Client) suspend_disk() ! {
	c.execute[Empty, Empty]('guest-suspend-disk', none, no_return: true)!
}

// suspend_hybrid executes [guest-suspend-hybrid](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-suspend-hybrid) command.
pub fn (mut c Client) suspend_hybrid() ! {
	c.execute[Empty, Empty]('guest-suspend-hybrid', none, no_return: true)!
}

// suspend_ram executes [guest-suspend-ram](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-suspend-ram) command.
pub fn (mut c Client) suspend_ram() ! {
	c.execute[Empty, Empty]('guest-suspend-ram', none, no_return: true)!
}

struct GuestSyncRequest {
	id u64
}

// sync executes the [guest-sync](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-sync) command.
pub fn (mut c Client) sync(id u64) !u64 {
	req := GuestSyncRequest{id}
	res := c.execute[GuestSyncRequest, u64]('guest-sync', req)!
	return res.return
}

// sync_delimited executes [guest-sync-delimited](https://qemu-project.gitlab.io/qemu/interop/qemu-ga-ref.html#command-QGA-qapi-schema.guest-sync-delimited) command.
pub fn (mut c Client) sync_delimited(id u64) !u64 {
	req := GuestSyncRequest{id}
	res := c.execute[GuestSyncRequest, u64]('guest-sync-delimited', req)!
	return res.return
}
