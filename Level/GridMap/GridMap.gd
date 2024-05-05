extends GridMap

const Enemigo = preload("res://Enemies/NormalEnemies/skeleton_minion.tscn") # Se precargan los objetos que se usaran para reemplazar
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_used_cells_by_id(id: int): # Viaja a traves de las celdas usadas buscando las que tengan id igual a la entrada
	var arr = []
	var cells = get_used_cells()
	for i in cells:
		if(get_cell_item(Vector3i(i.x,i.y,i.z)) == id):#Si es el objeto que se busca
			arr.append(i)
	return arr #Retorna los tile placeholder

func basicTileReplace(cellArr : Array, inst):#Viaja en los placeholder, e invoca newObject en cada uno
	var cellPos = Vector3()
	for i in cellArr:
		var newObject = newObject(i, cellPos, inst)
	#Genera la instancia del objeto
	
func newObject(cell: Vector3, cellPos: Vector3, inst):
	var newInst = inst.instantiate()#Genera una instancia
	cellPos = map_to_local(Vector3i(cell.x, cell.y, cell.z))#Toma la posicion del placeholder
	newInst.position = cellPos #Pone la instancia en el placeholder
	newInst.rotation.y = -1.25
	set_cell_item(Vector3i(cell.x, cell.y,cell.z),-1) #Borra el tile placeholder
	add_child(newInst)#Agrega el nodo como hijo
	return newInst
