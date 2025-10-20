@tool
extends EditorScript

func _run():
	print("🔍 Scanning project for broken .tscn UID references...\n")
	var broken = []
	_scan_dir("res://", broken)
	
	if broken.is_empty():
		print("✅ No broken UID or missing resource paths found.")
	else:
		print("⚠️ Broken resource references found in:\n")
		for path in broken:
			print("  - " + path)
		print("\n🧹 Tip: Reopen these scenes and reassign their missing references manually.")

func _scan_dir(dir_path: String, broken: Array):
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_scan_dir(dir_path.path_join(file_name), broken)
		elif file_name.ends_with(".tscn"):
			var file_path = dir_path.path_join(file_name)
			var content = FileAccess.get_file_as_string(file_path)
			if content.find("uid://") != -1:
				for line in content.split("\n"):
					if line.begins_with("[ext_resource") and line.find("path=") != -1:
						var path_start = line.find("path=\"") + 6
						var path_end = line.find("\"", path_start)
						if path_start == -1 or path_end == -1:
							continue
						var resource_path = line.substr(path_start, path_end - path_start)
						if not FileAccess.file_exists(resource_path):
							broken.append(file_path)
							break
