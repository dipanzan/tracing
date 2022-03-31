loadModule("/TraceCompass/Trace")
loadModule("/System/Resources")
loadModule("/System/Scripting")
loadModule("/TraceCompass/TraceUI")


def process_syscall_durations_and_count(trace):
	layout = trace.getKernelEventLayout()
	iter = getEventIterator(trace)

	syscall_durations = {}
	syscall_name_counts = {}

	syscall_name_and_time_hashmap = java.util.HashMap()

	count = 0

	while iter.hasNext():
		if count > 100000:
			break
		event = iter.next()
		event_name = str(event.getName())
		count += 1
		tid = org.eclipse.tracecompass.analysis.os.linux.core.kernel.KernelTidAspect.INSTANCE.resolve(event)

		if (event_name.startswith(layout.eventSyscallEntryPrefix()) or event_name.startswith(
				layout.eventCompatSyscallEntryPrefix())):
			syscall_name = event_name[len(layout.eventSyscallEntryPrefix()):]

			start_time = event.getTimestamp().toNanos()
			syscall_name_and_time = [str(syscall_name), start_time]
			syscall_name_and_time_hashmap.put(tid, syscall_name_and_time)

		elif (event_name.startswith(layout.eventSyscallExitPrefix())):
			end_time = event.getTimestamp().toNanos()
			syscall_name_and_time = syscall_name_and_time_hashmap.remove(tid)

			if not (syscall_name_and_time is None):
				syscall_name = syscall_name_and_time[0]
				start_time = syscall_name_and_time[1]
				syscall_duration = float(end_time - start_time)


				syscall_durations[str(syscall_name)] = syscall_duration
				syscall_name_counts[str(syscall_name)] = 1

	return syscall_name_counts, syscall_durations

def get_trace(trace_name, random=False):
	trace_path = "random" + "/" + trace_name if random else "not-random" + "/" + trace_name
	trace = openTrace("tracing", trace_path, False)

	if trace is None:
		print("There is no active trace. Please open the trace to run this script on")
		exit()
	return trace

for i in range(10):
	trace_name = "time-5s-threads-6-file-10MB-trace-{}-r".format(i)
	print("Processing: " + trace_name)
	trace = get_trace(trace_name, True)
	# syscall_name_counts, syscall_durations = process_syscall_durations_and_count(trace)
