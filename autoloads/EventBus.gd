extends Node


signal on_especial_shake


func emit_especial_shake():
	print("especial")
	on_especial_shake.emit()
