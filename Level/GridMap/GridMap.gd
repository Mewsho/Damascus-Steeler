extends GridMap

## Script asociado al gridmap, donde se dibujan los bloques del escenario del algoritmo de
## generacion procedural

## Funcion que recibe una id, y busca todos los bloques del gridmap con esa id,
## Entregando un arreglo de esos objetos
func get_used_cells_by_id(id: int): # Viaja a traves de las celdas usadas buscando las que tengan id igual a la entrada
	var arr = [] 
	var cells = get_used_cells() #Todas las celdas usadas
	for i in cells:
		if(get_cell_item(Vector3i(i.x,i.y,i.z)) == id): # Si es el objeto que se busca
			arr.append(i)
	return arr #Retorna los tile placeholder con el id que se pide

## Funcion que recibe el arreglo de objetos a reemplazar y una instancia que los reemplazara.
## avanza en ese arreglo y en cada uno de ellos llama a la funcion newObject
func basicTileReplace(cellArr : Array, inst):#Viaja en los placeholder, e invoca newObject en cada uno
	var cellPos = Vector3()
	for i in cellArr:
		var newObject = newObject(i, cellPos, inst)
	#Genera la instancia del objeto

## Funcion que recibe posiciones y una instancia, para crear el objeto en la posicion deseada
func newObject(cell: Vector3, cellPos: Vector3, inst):
	var newInst = inst.instantiate()#Genera una instancia
	cellPos = map_to_local(Vector3i(cell.x, cell.y, cell.z)) #Toma la posicion del placeholder
	newInst.position = cellPos #Pone la instancia en el placeholder
	set_cell_item(Vector3i(cell.x, cell.y,cell.z),-1) #Borra el tile placeholder
	add_child(newInst) # Agrega el nodo como hijo
	return newInst
