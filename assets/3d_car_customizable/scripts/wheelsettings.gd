extends VBoxContainer

# The dictionary that contains binded Wheel nodes
var WheelNode : Dictionary setget _set_wheel

var BindedTarget

func _ready():
	# Apply all values passed from the Settingspanel when being instanced
	_on_UseAsTraction_pressed()
	_on_UseAsSteering_pressed()
	_on_WheelRollInfluence_value_changed(get_node("Wheel/RollInfluence/WheelRollInfluence").value)
	_on_WheelRadius_value_changed(get_node("Wheel/WheelRadius/WheelRadius").value)
	_on_WheelRestLength_value_changed(get_node("Wheel/RestLength/WheelRestLength").value)
	_on_WheelFrictionSlip_value_changed(get_node("Wheel/FrictionSlip/WheelFrictionSlip").value)
	_on_SuspensionTravel_value_changed(get_node("Suspension/Travel/SuspensionTravel").value)
	_on_SuspensionStiffness_value_changed(get_node("Suspension/Stiffness/SuspensionStiffness").value)
	_on_SuspensionMaxForce_value_changed(get_node("Suspension/MaxForce/SuspensionMaxForce").value)
	_on_DampingCompression_value_changed(get_node("Damping/Compression/DampingCompression").value)
	_on_DampingRelaxation_value_changed(get_node("Damping/Relaxation/DampingRelaxation").value)

func _set_wheel(value):
	WheelNode = value

func _on_UseAsTraction_pressed():
	for Wheel in WheelNode:	WheelNode[Wheel].use_as_traction = get_node("General/UseAsTraction").is_pressed()

func _on_UseAsSteering_pressed():
	for Wheel in WheelNode:	WheelNode[Wheel].use_as_steering = get_node("General/UseAsSteering").is_pressed()

func _on_WheelRollInfluence_value_changed(value):
	get_node("Wheel/RollInfluenceText").text = "Roll Influence = (" + str(value) + ")"
	for Wheel in WheelNode:	WheelNode[Wheel].wheel_roll_influence = value

func _on_WheelRadius_value_changed(value):
	get_node("Wheel/WheelRadiusText").text = "Radius = (" + str(value) + ")"
	for Wheel in WheelNode:	WheelNode[Wheel].wheel_radius = value

func _on_WheelRestLength_value_changed(value):
	get_node("Wheel/RestLengthText").text = "Rest Length = (" + str(value) + ")"
	for Wheel in WheelNode:	WheelNode[Wheel].wheel_rest_length = value

func _on_WheelFrictionSlip_value_changed(value):
	get_node("Wheel/FrictionSlipText").text = "Friction Slip = (" + str(value) + ")"
	for Wheel in WheelNode:	WheelNode[Wheel].wheel_friction_slip = value

func _on_SuspensionTravel_value_changed(value):
	get_node("Suspension/TravelText").text = "Travel = (" + str(value) + ")"
	for Wheel in WheelNode:	WheelNode[Wheel].suspension_travel = value

func _on_SuspensionStiffness_value_changed(value):
	get_node("Suspension/StiffnessText").text = "Stiffness = (" + str(value) + ")"
	if(get_node("Suspension/Stiffness/SuspensionStiffness").value != value): get_node("Suspension/Stiffness/SuspensionStiffness").value = value
	if(get_node("Suspension/Stiffness/SuspensionStiffnessBox").value != value): get_node("Suspension/Stiffness/SuspensionStiffnessBox").value = value
	for Wheel in WheelNode:	WheelNode[Wheel].suspension_stiffness = value

func _on_SuspensionMaxForce_value_changed(value):
	get_node("Suspension/MaxForceText").text = "Max Force = (" + str(value) + ")"
	if(get_node("Suspension/MaxForce/SuspensionMaxForce").value != value): get_node("Suspension/MaxForce/SuspensionMaxForce").value = value
	if(get_node("Suspension/MaxForce/SuspensionMaxForceBox").value != value): get_node("Suspension/MaxForce/SuspensionMaxForceBox").value = value
	for Wheel in WheelNode:	WheelNode[Wheel].suspension_max_force = value

func _on_DampingCompression_value_changed(value):
	get_node("Damping/CompressionText").text = "Compression = (" + str(value) + ")"
	for Wheel in WheelNode:	WheelNode[Wheel].damping_compression = value

func _on_DampingRelaxation_value_changed(value):
	get_node("Damping/RelaxationText").text = "Relaxation = (" + str(value) + ")"
	for Wheel in WheelNode:	WheelNode[Wheel].damping_relaxation = value

func DisableAllNodes(ParentNode):
	for ChildNode in ParentNode.get_children():
		if ChildNode.get_child_count() > 0:
			DisableAllNodes(ChildNode)
		if(ChildNode is HSlider): ChildNode.editable = !ChildNode.editable
		if(ChildNode is SpinBox): ChildNode.editable = !ChildNode.editable
		if(ChildNode is CheckBox): ChildNode.disabled = !ChildNode.disabled

func _on_BindedTo_item_selected(ID):
	if(ID != 0):
		#If the wheel is binded to another one
		
		#Unhide all items
		DisableAllNodes(self)
		for child in get_children():
			child.visible = false
			if(child.name == "Binding" || child.name == "SettingsTitle"): child.visible = true
		
		#Add this wheel to the target node
		if(BindedTarget != null):
			var get_WheelNode = get_parent().get_node(get_node("Binding/BindedTo").get_item_text(BindedTarget)).get("WheelNode")
			get_WheelNode.erase(get_node("SettingsTitle").text)
		var get_WheelNode = get_parent().get_node(get_node("Binding/BindedTo").get_item_text(ID)).get("WheelNode")
		get_WheelNode[get_node("SettingsTitle").text] = WheelNode[get_node("SettingsTitle").text]
		BindedTarget = ID
		
		get_parent().get_node(get_node("Binding/BindedTo").get_item_text(BindedTarget)).set("WheelNode", get_WheelNode)
		get_parent().get_node(get_node("Binding/BindedTo").get_item_text(BindedTarget))._ready()
	else:
		#If none is selected
		#and there is a BindedTarget
		
		if(BindedTarget != null):
			#Hide all items
			DisableAllNodes(self)
			for child in get_children():
				child.visible = true
			
			#Remove this wheel from the target node
			var get_WheelNode = get_parent().get_node(get_node("Binding/BindedTo").get_item_text(BindedTarget)).get("WheelNode")
			get_WheelNode.erase(get_node("SettingsTitle").text)
			BindedTarget = null
			#Load function: Load values from wheels, fill nodes
			FillNodesFromWheelInfo()

func FillNodesFromWheelInfo():
	for Wheel in WheelNode:
		get_node("General/UseAsTraction").pressed = WheelNode[Wheel].use_as_traction
		get_node("General/UseAsSteering").pressed = WheelNode[Wheel].use_as_steering
		get_node("Wheel/RollInfluence/WheelRollInfluence").value = WheelNode[Wheel].wheel_roll_influence
		get_node("Wheel/WheelRadius/WheelRadius").value = WheelNode[Wheel].wheel_radius
		get_node("Wheel/RestLength/WheelRestLength").value = WheelNode[Wheel].wheel_rest_length
		get_node("Wheel/FrictionSlip/WheelFrictionSlip").value = WheelNode[Wheel].wheel_friction_slip
		get_node("Suspension/Travel/SuspensionTravel").value = WheelNode[Wheel].suspension_travel
		get_node("Suspension/Stiffness/SuspensionStiffness").value = WheelNode[Wheel].suspension_stiffness
		get_node("Suspension/MaxForce/SuspensionMaxForce").value = WheelNode[Wheel].suspension_max_force
		get_node("Damping/Compression/DampingCompression").value = WheelNode[Wheel].damping_compression
		get_node("Damping/Relaxation/DampingRelaxation").value = WheelNode[Wheel].damping_relaxation

func save():
	var save_dict : Dictionary
	for Wheel in WheelNode:
		save_dict = {
			"name" : WheelNode[Wheel].name,
			"use_as_traction" : WheelNode[Wheel].use_as_traction,
			"use_as_steering" : WheelNode[Wheel].use_as_steering,
			"wheel_roll_influence" : WheelNode[Wheel].wheel_roll_influence,
			"wheel_radius" : WheelNode[Wheel].wheel_radius,
			"wheel_rest_length" : WheelNode[Wheel].wheel_rest_length,
			"wheel_friction_slip" : WheelNode[Wheel].wheel_friction_slip,
			"suspension_travel" : WheelNode[Wheel].suspension_travel,
			"suspension_stiffness" : WheelNode[Wheel].suspension_stiffness,
			"suspension_max_force" : WheelNode[Wheel].suspension_max_force,
			"damping_compression" : WheelNode[Wheel].damping_compression,
			"damping_relaxation" : WheelNode[Wheel].damping_relaxation,
			"bindedto" : BindedTarget
		}
	return save_dict

func LoadPreset(value):
	$General/UseAsTraction.pressed = value["use_as_traction"]
	$General/UseAsSteering.pressed = value["use_as_steering"]
	$Wheel/RollInfluence/WheelRollInfluence.value = value["wheel_roll_influence"]
	$Wheel/WheelRadius/WheelRadius.value = value["wheel_radius"]
	$Wheel/RestLength/WheelRestLength.value = value["wheel_rest_length"]
	$Wheel/FrictionSlip/WheelFrictionSlip.value = value["wheel_friction_slip"]
	$Suspension/Travel/SuspensionTravel.value = value["suspension_travel"]
	$Suspension/Stiffness/SuspensionStiffness.value = value["suspension_stiffness"]
	$Suspension/MaxForce/SuspensionMaxForce.value = value["suspension_max_force"]
	$Damping/Compression/DampingCompression.value = value["damping_compression"]
	$Damping/Relaxation/DampingRelaxation.value = value["damping_relaxation"]
	if(value["bindedto"] != null):
		$Binding/BindedTo.select(value["bindedto"])
		_on_BindedTo_item_selected(value["bindedto"])
