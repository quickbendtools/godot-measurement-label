@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("MeasurementLabel", "HboxContainer", preload("measurement_label.gd"), preload("ic_measurement-label.png"))

func _exit_tree():
	remove_custom_type("MeasurementLabel");
