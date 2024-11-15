#El algoritmo principal de generacion procedural, tiene class_name para que actue como un nodo que se puede agregar a esceneas
class_name PCGCode
extends Node

## Algoritmo de generacion procedural del escenario

## Especificamente, el algoritmo crea objetos chunks y gccolumns que evalua y combina por multiples generaciones,
## para generar una poblacion donde se elije el mejor para crear en el mundo

# Se precargan las escenas de los enemigos que se usaran para poner enemigos
const ENEMY_ROGUE = preload("res://Enemies/NormalEnemies/enemy_rogue.tscn")
const ENEMY_MAGE = preload("res://Enemies/NormalEnemies/enemy_mage.tscn")
const ENEMY_MINION = preload("res://Enemies/NormalEnemies/enemy_minion.tscn")
const ENEMY_WARRIOR = preload("res://Enemies/NormalEnemies/enemy_warrior.tscn")
const MANA = preload("res://Level/GridMap/mana.tscn")
const LAND_AREA_REPLACE = preload("res://Level/GridMap/land_area_replace.tscn")
## Constantes usadas anteriormente
## Region de datos y valores iniciales, algunos son export para facilitar el cambio
#region Datos
@export var tamanoPoblacion : int = 35
@export var rateElitism : float = 0.05
var tamanoElite = int(max(1,round(tamanoPoblacion*rateElitism)))
var tamanoDescendencia : int = tamanoPoblacion-tamanoElite
@export var rateMutation = 0.005
@export var GCporChunk : int = 16
@export var FilasporGC :int = 8
@export var maxGen : int = 50
#Los principales factores de rendimiento son maxgen y tamanopoblacion
var iGen = 0
var enemySpawn = 1.0
var objectSpawn = 1.0
var alturaSalto = 1 #Usado para la evaluacion
var alturaRestar = 5 #Usado para hacer mas bajos los niveles
var chunkCargado = 0 #Contador de chunk cargado, para que cada uno vaya despues de otro
var altura_anterior = 2 #Altura del final de un chunk
var n_chunks_to_generate = 8 #Chunks a generar
var Chunks_Elegidos : Array = []

signal PCG_generation_finished
#endregion

## Region de los objetos personalizados Chunk y GeneColumn
#region Objetos para generación
class Chunk : #Cada chunk representa un pedazo de escenario a generar, multiples compiten entre ellos
	var leftP = 0 # Variables de trazabilidad de cada chunk
	var rightP = 0
	var id = 0 
	var gen = 0
	var gcs = [] #Columnas que lo componen
	var altura_anterior = 0
	var is_punished_prev_chunk : bool = false
	var fitness = 0 #Puntaje
	#Funciones para facilitar la lectura del codigo
	func get_altura_inicial() -> int:
		return gcs[0].alturaTile
	func get_altura_final() -> int:
		return gcs[len(gcs)-1].alturaTile
		
class GeneColumn: #Cada genecolumn representa un columna en el mundo
	var id = 0 
	var alturaTile = 0 #Altura de la columna
	var hasEnemy = false
	var enemyLevel = "low" 
	var enemyNumber = 0
	var posX = 0
	var hasMana = false
#endregion

func _ready():
	PCG_generation_finished.connect(_finish_pcg)

func _finish_pcg():
	pass

func get_chunk_elegidos():
	return Chunks_Elegidos

## Funcion de utilidad para mostrar la info de un chunk
func mostrar_datos(c : Chunk):
	print("id:", c.id, " leftP: ", c.leftP," rightP: ", c.rightP, " fit: ", c.fitness, " gen: ", c.gen, " H anterior: ", c.altura_anterior, " castigado por prev?: ", c.is_punished_prev_chunk)
	for i in range(0,GCporChunk):
		print("fila: " ,i, " h: ", c.gcs[i].alturaTile, " enemy: ", c.gcs[i].hasEnemy)
	print()

func PCG_General(): 
	#seed(1941)
	var poblacion = []
	Chunks_Elegidos = []
	while (chunkCargado < n_chunks_to_generate):
		poblacion = []
		poblacion = iniPoblacion()
		var fitness_pob = 0
		fitnessFx(poblacion)
		for chunk in range(tamanoPoblacion):
			fitness_pob += poblacion[chunk].fitness
		print("Initial fitness of pob: ", fitness_pob)
		poblacion = generacion_procedural(poblacion)
		var chunk_elegido = poblacion[tamanoPoblacion-1]
		if chunk_elegido.fitness > 1000:
			chunk_elegido.altura_anterior = altura_anterior
			altura_anterior = chunk_elegido.get_altura_final()
			Chunks_Elegidos.append(chunk_elegido)
			print("Current Fitness: ", chunk_elegido.fitness)
			print("Altura inicial elegido: ", chunk_elegido.get_altura_inicial())
			print("Altura Anterior:", altura_anterior)
			print("Chunk cargado = ", chunkCargado)
			chunkCargado +=1
		else:
			print()
			print("Failed Poblation, fitness: ", chunk_elegido.fitness)
			print()
		
	call_deferred("emit_signal","PCG_generation_finished")
	#emit_signal("PCG_generation_finished")

## Creacion de los bloques en el escenario y posicionamiento de los enemigos
#region Funcion chunks_creation y cellCreation
## Funcion encargada de tomar los chunks elegidos y llevarlos al mundo,
## recibe una lista de los chunks elegidos y un gridmap donde generar los bloques
func chunks_creation(chunks_selected ,grid : GridMap, aux_grid : GridMap, scenery_grid : GridMap):
	#Genera un plataforma previa a la generación en si
	var altura_inicial = chunks_selected[0].get_altura_inicial()
	var altura_negativa = -5
	# Mini platadorma antes del pcg 
	for i in range(-5,4):
		var altura = altura_inicial
		aux_grid.set_cell_item(Vector3i(i,altura+1,0),0) #Linea de area landing
		grid.set_cell_item(Vector3i(i,altura,0),6) # Linea de bloque piso PRE pcg
		while altura != altura_negativa:
			#grid.set_cell_item(Vector3i(i,altura,0),6)
			scenery_grid.set_cell_item(Vector3i(i,altura,1),0) # Tiles de pared voxel
			altura-=1
	# Recta de bloques para dar el piso y despues le agrega bloques hacia abajo para cubrir la pantalla
	for i in range(0,GCporChunk*chunkCargado*2):
		grid.set_cell_item(Vector3i(i,0,0),6) # Linea de bloques piso hasta el final
		for y in range(altura_negativa,0+1):
			scenery_grid.set_cell_item(Vector3i(i,y,1),0) # Tiles de pared voxel hasta el final
			#grid.set_cell_item(Vector3i(i,y,0),6)
	
	#Genera las celdas procedurales, pasando por cada chunk elegido
	var prev_height
	for chunk in range(len(chunks_selected)):
		print(mostrar_datos(chunks_selected[chunk]))
		
		if chunk == 0:
			prev_height = altura_inicial
		else:
			prev_height = chunks_selected[chunk].get_altura_final()
		cellCreation(chunks_selected[chunk], chunk, grid, aux_grid, scenery_grid,prev_height)
	
	#Obtiene los bloques que representan a los enemigos y los reemplaza con las escenas precargadas
	var enemy1 = grid.get_used_cells_by_id(1)
	var enemy2 = grid.get_used_cells_by_id(2)
	var enemy3 = grid.get_used_cells_by_id(3)
	var enemy4 = grid.get_used_cells_by_id(4)
	var mana = grid.get_used_cells_by_id(5)
	var area = aux_grid.get_used_cells_by_item(0)
	grid.basicTileReplace(enemy1, ENEMY_MAGE)
	grid.basicTileReplace(enemy2, ENEMY_MINION)
	grid.basicTileReplace(enemy3, ENEMY_ROGUE)
	grid.basicTileReplace(enemy4, ENEMY_WARRIOR)
	grid.basicTileReplace(mana,MANA)
	aux_grid.basicTileReplace(area,LAND_AREA_REPLACE)

##Funcion que crea cada elemento del chunk que recibe
func cellCreation(c : Chunk, cNumber: int, grid : GridMap, aux_grid : GridMap, scenery_grid : GridMap, prev_height):
	## 2 columnas reales por columna generada
	var i = 0
	var column = 0
	while i < GCporChunk*2:
		var is_first_block : bool = true
		for j in range(0,2):
			var altura = c.gcs[column].alturaTile #Obtiene la altura de la columna en cuestion
			if c.gcs[column].hasEnemy and !c.gcs[column].hasMana: #Si tiene enemigo lo pone encima del bloque de altura maxima
				var enemy_id = randi_range(1,4) #Elige enemigo aleatorio
				grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2), altura+1,0),enemy_id)
			if c.gcs[column].hasMana and !c.gcs[column].hasEnemy:
				var mana_id = 5
				grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2), altura+1,0),mana_id)
			if c.gcs[column].hasMana and c.gcs[column].hasEnemy:
				var enemy_id = randi_range(1,4) #Elige enemigo aleatorio
				var mana_id = 5
				grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2), altura+2,0),enemy_id) #Spawnea el enemigo 1 mas arriba, ya que deberia tener gravedad
				grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2), altura+1,0),mana_id)
			aux_grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2),altura+1,0),0)
			
			var current_prev_height
			if column == 0:
				current_prev_height = prev_height
			else:
				current_prev_height = c.gcs[column-1].alturaTile
			while altura != 0: #Pone bloques de la altura maxima hacia abajo
				if current_prev_height < altura && is_first_block: #El anterior es menor -> escalera
					grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2),altura,0),7)
					scenery_grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2),altura,1),1)
					is_first_block = false
				else: #El anterior es mayor -> caida
					scenery_grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2),altura,1),0)
					grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk*2),altura,0),6)
				altura -= 1
		i +=2
		column = i/2
	## Versiones anteriores, solo una columna del mundo por columna
		#if i == GCporChunk-1: #TEST Genera un bloque a la derecha para ver cuando termina un chunk 
			#grid.set_cell_item(Vector3i(3+i+(cNumber*GCporChunk),3,1),0)
	#var j = 0
	#for i in range(0,GCporChunk):
		#var altura = c.gcs[i].alturaTile #Obtiene la altura de la columna en cuestion
		#if c.gcs[i].hasEnemy and !c.gcs[i].hasMana: #Si tiene enemigo lo pone encima del bloque de altura maxima
			#var enemy_id = randi_range(1,4) #Elige enemigo aleatorio
			#grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk), altura+1,0),enemy_id)
		#if c.gcs[i].hasMana and !c.gcs[i].hasEnemy:
			#var mana_id = 5
			#grid.set_cell_item(Vector3i(3+i+j+(cNumber*GCporChunk), altura+1,0),mana_id)
		#if c.gcs[i].hasMana and c.gcs[i].hasEnemy:
			#var enemy_id = randi_range(1,4) #Elige enemigo aleatorio
			#var mana_id = 5
			#grid.set_cell_item(Vector3i(3+i+(cNumber*GCporChunk), altura+2,0),enemy_id) #Spawnea el enemigo 1 mas arriba, ya que deberia tener gravedad
			#grid.set_cell_item(Vector3i(3+i+(cNumber*GCporChunk), altura+1,0),mana_id)
		#while altura != 0: #Pone bloques de la altura maxima hacia abajo
			#grid.set_cell_item(Vector3i(3+i+(cNumber*GCporChunk),altura,0),0)
			#altura -= 1
#endregion

## Funcion principal de la generacion, llama al resto de funciones importantes,
## la funcion al inicio determina a la elite, luego genera la descendencia para unir ambos grupos,
## despues los muta y sigue el bucle. Finalmente evalua la poblacion generada, la ordena y la retorna
func generacion_procedural(poblacion : Array):
	var desc = 0 #Descendencia
	var elt = 0 #Elite
	iGen = 0
	#for i in range(tamanoPoblacion): #INFO Usado para obtener la informacion de la poblacion inicial
		#datos(poblacion[i])
	while (iGen < maxGen):
		fitnessFx(poblacion)
		elt = seleccionMejores(poblacion)
		desc = seleccionParientesCrossover(poblacion)
		poblacion = union(desc, elt)
		mutacion(poblacion)
		#for i in range(tamanoPoblacion): #INFO Usado para obtener la informacion de cada generacion
			#datos(poblacion[i])	
		iGen+=1
	fitnessFx(poblacion)
	poblacion.sort_custom(sortChunks)
	#for i in range(tamanoPoblacion): #INFO Usado para obtener la informacion de la poblacion final
		#mostrar_datos(poblacion[i])
	return poblacion

## Inicializa la poblacion, generandola aleatoriamente y retornandola
func iniPoblacion():
	var chunks = []
	for chunk in range(0,tamanoPoblacion):
		chunks.append(Chunk.new())
		chunks[chunk].id = chunk
		for columna in range(0, GCporChunk):
			chunks[chunk].gcs.append(GeneColumn.new())
			chunks[chunk].gcs[columna].id = columna
			chunks[chunk].gcs[columna].posX = columna
			var h = randi_range(0,FilasporGC-alturaRestar) #Altura
			chunks[chunk].gcs[columna].alturaTile = h
			if (randi_range(0,1) == 1): #Si tiene enemigo
				chunks[chunk].gcs[columna].hasEnemy = true
				var x = randi_range(0,2)
				if (x == 0):# Que tipo de enemigo
					chunks[chunk].gcs[columna].enemyLevel = "low"
					chunks[chunk].gcs[columna].enemyNumber = 2
				elif (x == 1):
					chunks[chunk].gcs[columna].enemyLevel = "medium"
					chunks[chunk].gcs[columna].enemyNumber = 2
				else:
					chunks[chunk].gcs[columna].enemyLevel = "heavy"
					chunks[chunk].gcs[columna].enemyNumber = 1
			if (randi_range(0,3) == 3):
					chunks[chunk].gcs[columna].hasMana = true
	var Poblacion = chunks
	return Poblacion

## Funcion auxiliar para el uso del metodo sort_custom nativo de godot,
## que permite ordenar en base a parametros personalizados
func sortChunks(a, b): # La funcion para poder usar sort custom
	if a.fitness < b.fitness: # Ordenar de menor a mayor en base a fitness
		return true
	return false

## Funcion que recibe una poblacion y determina a la elite para retornarla, 
## ademas aprovecha de evaluar toda la poblacion y ordenarla en base al fitness
func seleccionMejores(p : Array):
	var elite = []
	p.sort_custom(sortChunks) #Ordenando los chunks de la poblacion
	for i in range(0,tamanoElite): # Guarda los mejores en la lista elite
		elite.append(p[tamanoPoblacion-1-i])
	return elite #Retorna la elite

## TEST Funcion para determinar un chunk aleatorio, pero que tenga preferencia los chunks con mayor puntaje,
## Actualmente se usa una azar estandar, porque resultaba en que elegia siempre los ultimos chunks, acabando con la variabilidad genetica
## En el futuro podemos testar el uso de esto, modificandole para darle mas posibilidades a chunks inferiores
## Una manera seria siempre restarle un valor, a pesar que tenga fitness 0
func rndWeighted(p : Array):#WARNING explota si suma pesos es negativo
	#Ahora viene el random weighted, gracias stack overflow
	var sumaPesos = 0
	for i in range(p.size()):
		sumaPesos += p[i].fitness 
	if sumaPesos <= 0:
		return randi_range(0,p.size()-1)
	var rnd = randi_range(0,sumaPesos-1)
	#print("Suma Pesos: ", sumaPesos, " rnd: ", rnd) #INFO Test
	for i in range(p.size()):
		if rnd < p[i].fitness:
			#print("elegido: ",i) #INFO Test
			return int(i) - tamanoElite #Posicion del elegido
		rnd -= p[i].fitness


## DEPRECATED Previa funcion de crossover de los chunks, combinaba solo en el punto medio,
## tomando la parte izquierda de uno y la derecha de otro, se paro de usar ya que hacia que los
## chunks se volvieran identicos muy rapidamente
#func crossover(chunkL : Chunk, chunkR : Chunk): #Junta los dos lados del chunk en uno llamado Cross
	#var Cross = []
	#Cross = chunkR
	#var l = chunkL
	#randomize()
	#l.gcs.shuffle()
	# for i in range(GCporChunk/2): #Division entera
	#for i in range(randi_range(0,GCporChunk-1)):
		#Cross.gcs[i] = l.gcs[i]
	#return Cross
	
## Funcion de crossover actual usando dos puntos, toma dos chunks y los combina en base a dos puntos 
## aleatorios, generando tres zonas, que llamara izquierda, medio y derecha, tomando la izquierda y 
## derecha del primer chunk y el medio del segundo
## Al combinarlos puede girar el orden de alguno de los padres aleatoriamente
## WARNING Cuidado al modificar, ya que anteriormente tenia bugs en que tomaba al hijo
## como un padre, lo que forzo la creacion de un chunk base
func crossover(chunkL : Chunk, chunkR : Chunk): #2
	#print("left p: ", chunkL.id, " right p: ", chunkR.id) #INFO Testeo para trazabilidad de los parientes
	#print("chunkL")
	#datos(chunkL)
	#print("chunkR")
	#datos(chunkR)
	## Esto crea un chunk base placeholder nuevo
	var base = 0
	base = Chunk.new()
	for j in range(0, GCporChunk):
			base.gcs.append(GeneColumn.new())
			base.gcs[j].id = "test"
			base.gcs[j].posX = "test"
			var h = randi_range(0,FilasporGC-alturaRestar)
			base.gcs[j].alturaTile = h
			if (randi_range(0,1) == 1):
				base.gcs[j].hasEnemy = true
				var x = randi_range(0,2)
				if (x == 0):#Low
					base.gcs[j].enemyLevel = "low"
					base.gcs[j].enemyNumber = 2
				elif (x == 1):
					base.gcs[j].enemyLevel = "medium"
					base.gcs[j].enemyNumber = 2
				else:
					base.gcs[j].enemyLevel = "heavy"
					base.gcs[j].enemyNumber = 1
	var cross = base #Igual a cross, el hijo, con el base aleatorio
	var p1 = 0 #Punto de crossover 1
	var p2= 0 #Punto de crossover 2
	var r_cross = 0 #Random que determina que combinacion usar
	var pmedio = GCporChunk/2 #Punto medio para guiar la aleatoriedad
	p1 = randi_range(0, pmedio) #Primer punto aleatorio, se evita el caso 0 para si o si tener algo en la izq
	if (p1==0):
		p1 = 1
	p2 = randi_range(pmedio+1,GCporChunk-1)
	r_cross = randi_range(0,2)
	if (r_cross == 0): # Estandar
		for i in range(0,p1):
			cross.gcs[i] = chunkL.gcs[i]
		for i in range(p1,p2):
			cross.gcs[i] = chunkR.gcs[i]
		for i in range(p2,GCporChunk):
			cross.gcs[i] = chunkL.gcs[i]
	elif (r_cross == 1): # Girar el chunkR
		for i in range(0,p1):
			cross.gcs[i] = chunkL.gcs[i]
		for i in range(p1,p2):
			cross.gcs[i] = chunkR.gcs[GCporChunk-2-i]
		for i in range(p2,GCporChunk):
			cross.gcs[i] = chunkL.gcs[i]
	elif (r_cross == 2): #Girar ChunkL
		for i in range(0,p1+1):
			cross.gcs[i] = chunkL.gcs[GCporChunk-i-1]
		for i in range(p1,p2):
			cross.gcs[i] = chunkR.gcs[i]
		for i in range(p2,GCporChunk-1):
			cross.gcs[i] = chunkL.gcs[GCporChunk-2-i]
	#else: #Estandar pero shuffle #TEST Podemos intentar eliminarlo, y testear si mejora o empeora
		#for i in range(0,p1):
			#cross.gcs[i] = chunkL.gcs[i]
		#for i in range(p1,p2):
			#cross.gcs[i] = chunkR.gcs[i]
		#for i in range(p2,GCporChunk):
			#cross.gcs[i] = chunkL.gcs[i]
		#cross.gcs.shuffle()
	cross.id = chunkL.id + chunkR.id + 100
	cross.leftP = chunkL.id
	cross.rightP = chunkR.id
	cross.gen = iGen
	return cross #Retorna el hijo

## Funcion encargada de elegir a los parieneste al azar y hacer el crossover, haciendo esto la 
## la cantidad de veces necesaria segun el tamanoDescendencia, retornando una lista de 
## descendientes
func seleccionParientesCrossover(p : Array):
	var descendencia = [] 
	var i = 0
	while (i<tamanoDescendencia):
		var l = 0
		var r = 0
		# Eleccion aleatoria, en el futuro valdria la pena testear cual es mejor
		var r1 = randi_range(0,tamanoDescendencia-1-tamanoElite) # TEST Testear cual entre rnd o rndWeighted da mejores resultados
		var r2 = randi_range(0,tamanoDescendencia-1-tamanoElite) # TEST Testear si excluir o no a los elites con -tamanoElite
		#var r1 = rndWeighted(p) #TEST Testear si variar entre los dos metodos al azar
		#var r2 = rndWeighted(p)
		if (r1==r2): # Evitar padres iguales
			if (r1 == tamanoDescendencia-1): #Que no elija algo fuera del indice
				r1 -=1
			else:
				r1+=1
		l = p[r1]  
		r = p[r2]
		descendencia.append(crossover(l,r)) # Llama a crossover y agrega lo resultante a una lista
		i+=1
	return descendencia

## Funcion simple que une las dos listas, los elites y los descendientes
func union(d : Array, e : Array): 
	return d + e

## Funcion que muta un chunk que recibe, puede mutar los enemigos, la altura o ambos al mismo
## tiempo. La manera en que muta es similar a la inicializacion de poblacion
## TEST Si hacer mas extremas las mutaciones o no
func mutaChunk(c : Chunk): #TEST si subir rateMutation o hacer mas extrema la mutacion
	for i in range(randi_range(3,GCporChunk)):
		var r = randi_range(0,GCporChunk-1) # Elige un gc aleatorio
		var r2 = randi_range(0,2)
		if (r2 == 0): # Muta altura
			c.gcs[r].alturaTile  = randi_range(0,FilasporGC-alturaRestar) 
		elif (r2 == 1): # Muta enemigo
			if (randi_range(0,1)== 0):
				c.gcs[r].hasEnemy = false
			else:
				c.gcs[r].hasEnemy = true
				var x = randi_range(0,2)
				if (x == 0):
					c.gcs[r].enemyLevel = "low"
					c.gcs[r].enemyNumber = 3
				elif (x == 1):
					c.gcs[r].enemyLevel = "medium"
					c.gcs[r].enemyNumber = 2
				else:
					c.gcs[r].enemyLevel = "heavy"
					c.gcs[r].enemyNumber = 1
		else: # Muta ambos
			c.gcs[r].alturaTile  = randi_range(0,FilasporGC-alturaRestar) 	
			if (randi_range(0,1)== 0):
				c.gcs[r].hasEnemy = false
			else:
				c.gcs[r].hasEnemy = true
				var x = randi_range(0,2)
				if (x == 0):
					c.gcs[r].enemyLevel = "low"
					c.gcs[r].enemyNumber = 3
				elif (x == 1):
					c.gcs[r].enemyLevel = "medium"
					c.gcs[r].enemyNumber = 2
				else:
					c.gcs[r].enemyLevel = "heavy"
					c.gcs[r].enemyNumber = 1
	#TASK Mutar powerup o otros

## Funcion que pasa por la poblacion y determina si algun chunk va a mutar
func mutacion(p: Array):
	var PoblacionM = p
	for i in range(tamanoPoblacion):
		var rnd = randf_range(0,1)
		if (rnd < rateMutation): #Si rnd da menor a a rateMutation, muta chunk i
			mutaChunk(PoblacionM[i])
	p = PoblacionM

## Funcion evaluadora de los chunks de una poblacion, utiliza multiples variables para evaluar,
## hasta ahora solo evalua enemigos y altura, ya que no hemos agregado mas cosas aun
## TASK Agregar mana
## TASK Mejorar la evaluacion de altura
## TEST Variar los puntajes de castigo y bonificaciones
## TEST Variar los parametros de evalucion
func fitnessFx(p : Array):
	#Variables de evaluacion
	var enemyChunk = enemySpawn * 20 #El numero es definido por nosotros,enemigos por chunks
	var objectChunk = objectSpawn * 4 #Numero de mana por pantalla
	#Puntaje Base
	var initialFit = GCporChunk*200 #Tienen 3200 default creo, varia con gcpor chunk
	var puntajeEnemigos = 0
	var puntajePowerup = 0
	for i in range(tamanoPoblacion):#Viaja a traves de los chunks posibles
		var enemyCount = 0
		var objectCount = 0
		var castigoInacc= 0
		for j in range(GCporChunk):
			# Obtiene los datos del chunk
			if (p[i].gcs[j].enemyLevel == "low"):
				enemyCount = enemyCount + 1*p[i].gcs[j].enemyNumber
			if (p[i].gcs[j].enemyLevel == "medium"):
				enemyCount = enemyCount + 2*p[i].gcs[j].enemyNumber
			if (p[i].gcs[j].enemyLevel == "heavy"):
				enemyCount = enemyCount + 4*p[i].gcs[j].enemyNumber
		#TASK Parte de los objetos powerup
			if (j!=0): #Si no es la primera columna
				var altura = p[i].gcs[j].alturaTile - p[i].gcs[j-1].alturaTile
				if (altura > alturaSalto):
					castigoInacc -= 3000
			else:
				var altura = p[i].gcs[j].alturaTile - altura_anterior
				if altura > alturaSalto:
					p[i].is_punished_prev_chunk = true
					castigoInacc -= 4000
		
		# Evaluacion de los enemigos
		if(enemyCount > enemyChunk * 1.1):
			puntajeEnemigos = (enemyCount - enemyChunk)*5
		if(enemyCount <= enemyChunk * 1.1 && enemyCount > enemyCount * 0.9):
			puntajeEnemigos = 500
		if(enemyCount <= enemyChunk * 0.9):
			puntajeEnemigos = (enemyChunk - enemyCount)
		# TASK Calculo powerUp
		#if(objectCount > objectChunk * 1.1):
			#puntajePowerup = (objectCount- objectChunk)*5
		#if(objectCount <= objectChunk * 1.1 && objectCount > objectChunk * 0.9):
			#puntajePowerup = 600
		#if(objectCount <= objectChunk* 0.9):
			#puntajePowerup = (objectChunk - objectCount)
		#Sumatoria final de los puntajes
		p[i].fitness = initialFit + puntajeEnemigos + puntajePowerup + castigoInacc
		if (p[i].fitness < 0): # Para evitar puntajes negativos
			p[i].fitness = 0
