extends "res://Level/GridMap/GridMap.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func newObject(cell: Vector3, cellPos: Vector3, inst):
	var newInst = inst.instantiate()#Genera una instancia
	cellPos = map_to_local(Vector3i(cell.x, cell.y, cell.z)) #Toma la posicion del placeholder
	newInst.position = cellPos #Pone la instancia en el placeholder
	#newInst.rotation.y = -1.25
	set_cell_item(Vector3i(cell.x, cell.y,cell.z),-1) #Borra el tile placeholder
	add_child(newInst) # Agrega el nodo como hijo
	return newInst
