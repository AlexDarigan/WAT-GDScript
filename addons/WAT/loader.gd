extends Reference

var _tests: Array = []

func deposit(tests: Array) -> void:
	_tests = tests
#	ResourceSaver.save(resource_path, self)
	
func withdraw() -> Array:
	var tests: Array = []
	for path in _tests:
		# Can't load WAT.Test here for whatever reason
		var test = load(path) if path is String else path
		if test.get("TEST") != null:
			tests.append(test)
		elif test.get("IS_WAT_SUITE") and Engine.get_version_info().minor == 2:
			tests += _suite_of_suites_3p2(test)
		elif test.get("IS_WAT_SUITE") and Engine.get_version_info().minor == 1:
			tests += _suite_of_suites_3p1(test)
	_tests = []
	return tests

func _suite_of_suites_3p2(suite_of_suites) -> Array:
	var subtests: Array = []
	for constant in suite_of_suites.get_script_constant_map():
		var expression: Expression = Expression.new()
		expression.parse(constant)
		var subtest = expression.execute([], suite_of_suites)
		if subtest.get("TEST") != null:
			subtest.set_meta("path", "%s.%s" % [suite_of_suites.get_path(), constant])
			subtests.append(subtest)
	return subtests
	
func _suite_of_suites_3p1(suite_of_suites) -> Array:
	var subtests: Array = []
	var source = suite_of_suites.source_code
	for l in source.split("\n"):
		if l.begins_with("class"):
			var classname = l.split(" ")[1]
			var expr = Expression.new()
			expr.parse(classname)
			var subtest = expr.execute([], suite_of_suites)
			if subtest.get("TEST") != null:
				subtest.set_meta("path", "%s.%s" % [suite_of_suites.get_path(), classname])
				subtests.append(subtest)
	return subtests