extends Reference

var name: String = ""
var spying: bool = false
var stubbed: bool = false
var calls_super: bool = false
var args: String = ""
var keyword: String = ""
var calls: Array = []
var stubs: Array = []
var default

func _init(name):
	self.name = name

func dummy():
	stubbed = true
	default = null
	return self

func spy():
	spying = true
	return self

func stub(return_value, arguments: Array = []):
	stubbed = true
	if arguments.empty():
		default = return_value
	else:
		stubs.append({args = arguments, "return_value": return_value})
	return self

func add_call(args) -> void:
	calls.append(args)

func get_stub(args):
	for stub in stubs:
		if _pattern_matched(stub.args, args):
			return stub.return_value
	return default

func found_matching_call(expected_args) -> bool:
	for call in calls:
		if _pattern_matched(expected_args, call):
			return true
	return false

func _pattern_matched(pattern: Array, args: Array) -> bool:
	var indices: Array = []
	for index in pattern.size():
		if pattern[index] is Object and pattern[index].get_class() == "Any":
			continue
		indices.append(index)
	for i in indices:
		# We check based on type first otherwise some errors occur (ie object can't be compared to int)
		if typeof(pattern[i]) != typeof(args[i]) or pattern[i] != args[i]:
			return false
	return true