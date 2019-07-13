extends Reference


func write(double):
	var source: String = ""

	## Basic
	if double.inner != "":
		source = 'extends "%s".%s\n' % [double.base_script, double.inner]
		source += "\nconst BASE = preload('%s').%s\n\n" % [double.base_script, double.inner]
	else:
		source = 'extends "%s"\n' % double.base_script
		source += "\nconst BASE = preload('%s')\n\n" % double.base_script
	var constructor_params =  "a,b,c,d,e,f,g,h,i,j,".substr(0, double.dependecies.size() * 2 - 1)
	source += "\nfunc _init(%s).(%s):\n\tpass\n" % [constructor_params, constructor_params]

	### Methods
	for name in double.methods:
		var m = double.methods[name]
		source += _method_to_string(double.resource_path, m.keyword, m.name, m.args, m.spying, m.stubbed)

	source += _inner_classes(double)
	return source

#	add_method_source_code()
func _method_to_string(doubler, keyword, name, args, spying, stubbed):
	var text: String
	text += "%sfunc %s(%s):" % [keyword, name, args]
	text += "\n\tvar args = [%s]" % args
	if spying:
		text += "\n\tload('%s').add_call('%s', args)" % [doubler, name]
	if stubbed:
		text += "\n\tvar retval = load('%s').get_stub('%s', args)" % [doubler, name]
		text += "\n\treturn retval if not retval is load('%s').CallSuper else .%s(%s)\n" % [doubler, name, args]
	return text

func _inner_classes(doubler):
	var source: String = ""
	for klass in doubler.klasses:
		print("%s index is %s" % [klass.name, klass.doubler.index])
		source += "\nclass %s extends 'S%s.gd':\n\tconst PLACEHOLDER = 0" % [klass.name, klass.doubler.index]
	return source