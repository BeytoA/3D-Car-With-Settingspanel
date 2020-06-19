extends MarginContainer

var CarNode : VehicleBody

onready var PresetList = get_node("ScrollContainer/MarginContainer/List/Car/PresetList")
onready var DeleteButton = get_node("ScrollContainer/MarginContainer/List/Car/PresetButtons/DeletePreset")
onready var LoadButton = get_node("ScrollContainer/MarginContainer/List/Car/PresetButtons/LoadPreset")

func _ready():
	# If there is no CarNode attached, Settingspanel quits the tree
	if(CarNode == null):
		free()
		return
	
	#Getting the values from the VehicleBody
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/EngineForce/MaxEngineForce").value = CarNode.MAX_ENGINE_FORCE
	_on_MaxEngineForce_value_changed(CarNode.MAX_ENGINE_FORCE)
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Brake/MaxBrake").value = CarNode.MAX_BRAKE
	_on_MaxBrake_value_changed(CarNode.MAX_BRAKE)
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Steering/MaxSteering").value = CarNode.MAX_STEERING
	_on_MaxSteering_value_changed(CarNode.MAX_STEERING)
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/SteeringSpeed/SteeringSpeed").value = CarNode.STEERING_SPEED
	_on_SteeringSpeed_value_changed(CarNode.STEERING_SPEED)
	get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/Weight").value = CarNode.weight
	_on_Weight_value_changed(CarNode.weight)
	# We do not need to get the Mass from the VehicleBody because Weight automatically updates the Mass
	#get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/Mass").value = CarNode.mass
	#_on_Mass_value_changed(CarNode.mass)
	
	# Each wheel contributes the Wheels dictionary that will later be used twice
	var Wheels = {}
	for Wheel in CarNode.get_children():
		if(Wheel is VehicleWheel):
			Wheels[Wheel.name] = Wheel
	
	# All wheels are instanced in the Settingspanel
	# with their properties from the CarNode
	for Items in Wheels:
		var Wheel = Wheels[Items]
		var ToInstance = preload("../scenes/wheelsettings.tscn").instance()
		ToInstance.get_child(0).text = Wheel.name
		ToInstance.name = Wheel.name
		ToInstance.get_node("Binding/BindedTo").add_item("none")
		for items in Wheels: if(Wheels[items].name != Wheel.name):
			ToInstance.get_node("Binding/BindedTo").add_item(Wheels[items].name)
		ToInstance.set("WheelNode", { Wheel.name : Wheel } )
		ToInstance.get_node("General/UseAsTraction").pressed = Wheel.use_as_traction
		ToInstance.get_node("General/UseAsSteering").pressed = Wheel.use_as_steering
		ToInstance.get_node("Wheel/RollInfluence/WheelRollInfluence").value = Wheel.wheel_roll_influence
		ToInstance.get_node("Wheel/WheelRadius/WheelRadius").value = Wheel.wheel_radius
		ToInstance.get_node("Wheel/RestLength/WheelRestLength").value = Wheel.wheel_rest_length
		ToInstance.get_node("Wheel/FrictionSlip/WheelFrictionSlip").value = Wheel.wheel_friction_slip
		ToInstance.get_node("Suspension/Travel/SuspensionTravel").value = Wheel.suspension_travel
		ToInstance.get_node("Suspension/Stiffness/SuspensionStiffness").value = Wheel.suspension_stiffness
		ToInstance.get_node("Suspension/MaxForce/SuspensionMaxForce").value = Wheel.suspension_max_force
		ToInstance.get_node("Damping/Compression/DampingCompression").value = Wheel.damping_compression
		ToInstance.get_node("Damping/Relaxation/DampingRelaxation").value = Wheel.damping_relaxation
		get_node("ScrollContainer/MarginContainer/List").add_child(ToInstance)
	
	# Get presets in user data
	GetPresets()
	# ..and assign the first preset if it exists
	if(PresetList.get_item_count() > 0):
		if(PresetList.get_item_text(PresetList.get_item_count() - 1) != "No Presets"):
			PresetList.select(0)
			_on_PresetList_item_selected(0)
			LoadPreset()

func SavePreset():
	var presetName = $ScrollContainer/MarginContainer/List/Car/SavePreset/PresetName
	if (presetName.text.length() < 1):
		presetName.text = "Can't be Empty"
		return
	print("Generating Preset File")
	var preset_file = File.new()
	var dir = Directory.new()
	print("Checking the presets directory")
	if (dir.open("user://3d_car_customizable/") != OK):
		print("Preset directory doesn't exist")
		dir.make_dir("user://3d_car_customizable/")
		print("..created a preset directory")
	preset_file.open("user://3d_car_customizable/" + presetName.text + ".json", File.WRITE)
	print("Writing car settings")
	var CarPreset = {
		"MAX_ENGINE_FORCE" : CarNode.get("MAX_ENGINE_FORCE"),
		"MAX_BRAKE" : CarNode.get("MAX_BRAKE"),
		"MAX_STEERING" : CarNode.get("MAX_STEERING"),
		"STEERING_SPEED" : CarNode.get("STEERING_SPEED"),
		"mass" : CarNode.mass,
		"weight" : CarNode.weight,
		"wheel_names" : ""
	}
	for Wheel in CarNode.get_children():
		if(Wheel is VehicleWheel):
			CarPreset["wheel_names"] += Wheel.name + "."
			CarPreset[Wheel.name] = get_node("ScrollContainer/MarginContainer/List").get_node(Wheel.name).save()
	preset_file.store_line(to_json(CarPreset))
	print("Writing file")
	preset_file.close()
	print("Closing file manager")
	GetPresets()

func GetPresets():
	PresetList.clear()
	print("Checking the preset directory")
	var dir = Directory.new()
	if (dir.open("user://3d_car_customizable/")) == OK:
		print("Generating Preset List")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir():
				#If it's not a directory
				print("Found preset: " + file_name)
				PresetList.add_item(file_name.split(".json")[0])
				PresetList.set_item_tooltip_enabled(PresetList.get_item_count() - 1, false)
#			else:
#				print("Found directory: " + file_name)
			file_name = dir.get_next()
		if(PresetList.get_item_count() < 1):
			print("No presets found")
			PresetList.add_item("No Presets")
			PresetList.set_item_tooltip_enabled(PresetList.get_item_count() - 1, false)
	else:
		print("Preset directory doesn't exist")
		PresetList.add_item("No Presets")
		PresetList.set_item_tooltip_enabled(PresetList.get_item_count() - 1, false)

func DeletePreset():
	print("Checking the preset directory")
	var dir = Directory.new()
	if (dir.open("user://3d_car_customizable/")) == OK:
		print("Generating Preset List")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if (file_name == PresetList.get_item_text(PresetList.get_selected_items()[0]) + ".json"):
				#If it's not a directory
				print("Found preset and deleted")
				dir.remove("user://3d_car_customizable/" + PresetList.get_item_text(PresetList.get_selected_items()[0]) + ".json")
				$ScrollContainer/MarginContainer/List/Car/PresetButtons.visible = false
				DeleteButton.disabled = true
				DeleteButton.text = "Delete Preset"
				LoadButton.disabled = true
				LoadButton.text = "Load Preset"
				GetPresets()
				return
			file_name = dir.get_next()
		if(PresetList.get_item_count() < 1):
			print("No presets found > could not delete")
	else:
		print("Preset directory doesn't exist")
	GetPresets()

func LoadPreset():
	var preset_file = File.new()
	print("Checking the preset file")
	if (preset_file.open("user://3d_car_customizable/" + PresetList.get_item_text(PresetList.get_selected_items()[0]) + ".json", File.READ) != OK):
		print("Preset doesn't exist")
		return
	preset_file.open("user://3d_car_customizable/" + PresetList.get_item_text(PresetList.get_selected_items()[0]) + ".json", File.READ)
	print("Read car settings")
	var CarPreset = parse_json(preset_file.get_line())
	_on_MaxEngineForce_value_changed(CarPreset["MAX_ENGINE_FORCE"])
	_on_MaxBrake_value_changed(CarPreset["MAX_BRAKE"])
	_on_MaxSteering_value_changed(CarPreset["MAX_STEERING"])
	_on_SteeringSpeed_value_changed(CarPreset["STEERING_SPEED"])
	_on_Mass_value_changed(CarPreset["mass"])
	_on_Weight_value_changed(CarPreset["weight"])
	print("Applied the preset for: Car Body")
	for WheelName in CarPreset["wheel_names"].split(".", false):
		#Assign to CarNode wheels
		get_node("ScrollContainer/MarginContainer/List").get_node(WheelName).LoadPreset(CarPreset[WheelName])
		print("Applied the preset for: " + WheelName)
	preset_file.close()
	print("Closing file manager")

func _on_MaxEngineForce_value_changed(value):
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/EngineForceText").text = "Max Engine Force = (" + str(value) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/EngineForce/MaxEngineForce").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/EngineForce/MaxEngineForce").value = value
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/EngineForce/MaxEngineForceBox").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/EngineForce/MaxEngineForceBox").value = value
	CarNode.set("MAX_ENGINE_FORCE", value)

func _on_MaxBrake_value_changed(value):
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/BrakeText").text = "Max Brake Force = (" + str(value) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Brake/MaxBrake").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Brake/MaxBrake").value = value
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Brake/MaxBrakeBox").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Brake/MaxBrakeBox").value = value
	CarNode.set("MAX_BRAKE", value)

func _on_MaxSteering_value_changed(value):
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/SteeringText").text = "Max Steering Angle = (" + str(value) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Steering/MaxSteering").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Steering/MaxSteering").value = value
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Steering/MaxSteeringBox").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/Steering/MaxSteeringBox").value = value
	CarNode.set("MAX_STEERING", value)

func _on_SteeringSpeed_value_changed(value):
	get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/SteeringSpeedText").text = "Steering Speed = (" + str(value) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/SteeringSpeed/SteeringSpeed").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/SteeringSpeed/SteeringSpeed").value = value
	if(get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/SteeringSpeed/SteeringSpeedBox").value != value): get_node("ScrollContainer/MarginContainer/List/Car/ScriptVariables/SteeringSpeed/SteeringSpeedBox").value = value
	CarNode.set("STEERING_SPEED", value)

func _on_Mass_value_changed(value):
	get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/MassText").text = "Mass = (" + str(value) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/Mass").value != value): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/Mass").value = value
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/MassBox").value != value): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/MassBox").value = value
	CarNode.mass = value
	get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/WeightText").text = "Weight = (" + str(CarNode.weight) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/Weight").value != CarNode.weight): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/Weight").value = CarNode.weight
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/WeightBox").value != CarNode.weight): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/WeightBox").value = CarNode.weight

func _on_Weight_value_changed(value):
	get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/WeightText").text = "Weight = (" + str(value) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/Weight").value != value): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/Weight").value = value
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/WeightBox").value != value): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Weight/WeightBox").value = value
	CarNode.weight = value
	get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/MassText").text = "Mass = (" + str(CarNode.mass) + ")"
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/Mass").value != CarNode.mass): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/Mass").value = CarNode.mass
	if(get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/MassBox").value != CarNode.mass): get_node("ScrollContainer/MarginContainer/List/Car/VehicleBody/Mass/MassBox").value = CarNode.mass

func _on_PresetList_item_selected(index):
	if(PresetList.get_item_text(index) == "No Presets"): return
	$ScrollContainer/MarginContainer/List/Car/PresetButtons.visible = true
	DeleteButton.disabled = false
	DeleteButton.text = "Delete Preset: " + PresetList.get_item_text(index)
	LoadButton.disabled = false
	LoadButton.text = "Load Preset: " + PresetList.get_item_text(index)
	$ScrollContainer/MarginContainer/List/Car/SavePreset/PresetName.text = PresetList.get_item_text(index)