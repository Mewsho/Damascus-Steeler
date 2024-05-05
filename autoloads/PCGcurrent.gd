class_name PCGCode
extends Node

# Se precargan los objetos que se usaran para reemplazar
const ENEMY_ROGUE = preload("res://Enemies/NormalEnemies/enemy_rogue.tscn")
const ENEMY_MAGE = preload("res://Enemies/NormalEnemies/enemy_mage.tscn")
const ENEMY_MINION = preload("res://Enemies/NormalEnemies/enemy_minion.tscn")
const ENEMY_WARRIOR = preload("res://Enemies/NormalEnemies/enemy_warrior.tscn")
 
#const tamanoPoblacion = 50
#const rateElitism = 0.05
#const rateMutation = 0.005 #0.0005
#const tamanoElite = int(max(1,round(tamanoPoblacion*rateElitism)))
#const tamanoDescendencia = tamanoPoblacion-tamanoElite
#const GCporChunk = 16
#const FilasporGC = 8
#const maxGen = 75

@export var tamanoPoblacion : int = 50
@export var rateElitism : float = 0.05
@export var tamanoElite = int(max(1,round(tamanoPoblacion*rateElitism)))
@export var tamanoDescendencia : int = tamanoPoblacion-tamanoElite
@export var rateMutation = 0.005
@export var GCporChunk : int = 16
@export var FilasporGC :int = 8
@export var maxGen : int = 75

var iGen = 0
var enemySpawn = 1.0
var objectSpawn = 1.0
var alturaSalto = 1
var alturaRestar = 5
var chunkCargado = 0
var altura_anterior = 2
var n_chunks_to_generate = 5
var Chunks_Elegidos : Array = []
var thread : Thread
var mutex : Mutex

class Chunk extends Node:
	var leftP = 0
	var rightP = 0
	var id = 0
	var gen = 0
	var gcs = []
	var fitness = 0 
	
	func get_altura_inicial() -> int:
		return gcs[0].alturaTile
	func get_altura_final() -> int:
		return gcs[len(gcs)-1].alturaTile

class GeneColumn extends Node:
	var id = 0
	var alturaTile = 0
	var hasEnemy = false
	var enemyLevel = "low"
	var enemyNumber = 0
	var posX = 0

signal PCG_generation_finished


func _ready():
	PCG_generation_finished.connect(_finish_pcg)

func _finish_pcg():
	pass

func PCG_General(): 
	#seed(1941)
	var chunk_elegido
	var poblacion = []
	Chunks_Elegidos = []
	while (chunkCargado < n_chunks_to_generate):
		poblacion = []
		poblacion = iniPoblacion()
		poblacion = generacion_procedural(poblacion)
		chunk_elegido = poblacion[tamanoPoblacion-1]
		altura_anterior = chunk_elegido.get_altura_final()
		Chunks_Elegidos.append(chunk_elegido)
		#chunkElegido.gcs[0].alturaTile = alturaAnterior #Asegurando que se conecten
		print("Current Fitness: ", chunk_elegido.fitness)
		print("Altura Anterior:", altura_anterior)
		print("Chunk cargado = ", chunkCargado)
		chunkCargado +=1
	emit_signal("PCG_generation_finished")

func get_chunk_elegidos():
	return Chunks_Elegidos

func chunks_creation(chunks_selected ,grid : GridMap):
	var altura_inicial = chunks_selected[0].get_altura_inicial()
	for i in range(0,4):
		var altura = altura_inicial
		while altura != 0:
			grid.set_cell_item(Vector3i(i,altura,0),0)
			altura-=1
	for i in range(0,GCporChunk*chunkCargado):
		grid.set_cell_item(Vector3i(i,0,0),0)
	for chunk in range(len(chunks_selected)):
		cellCreation(chunks_selected[chunk], chunk, grid)
	
	var enemy1 = grid.get_used_cells_by_id(1)
	var enemy2 = grid.get_used_cells_by_id(2)
	var enemy3 = grid.get_used_cells_by_id(3)
	var enemy4 = grid.get_used_cells_by_id(4)
	grid.basicTileReplace(enemy1, ENEMY_MAGE)
	grid.basicTileReplace(enemy2, ENEMY_MINION)
	grid.basicTileReplace(enemy3, ENEMY_ROGUE)
	grid.basicTileReplace(enemy4, ENEMY_WARRIOR)

func cellCreation(c : Chunk, cNumber: int, grid : GridMap):
	for i in range(0,GCporChunk):
		var altura = c.gcs[i].alturaTile
		if c.gcs[i].hasEnemy:
			var enemy_id = randi_range(1,4)
			grid.set_cell_item(Vector3i(3+i+(cNumber*GCporChunk), altura+1,0),enemy_id)
		while altura != 0:
			grid.set_cell_item(Vector3i(3+i+(cNumber*GCporChunk),altura,0),0)
			altura -= 1
		if i == GCporChunk-1:
			grid.set_cell_item(Vector3i(3+i+(cNumber*GCporChunk),3,1),0)
	

func generacion_procedural(poblacion : Array):
	var desc = 0
	var elt = 0
	iGen = 0
	#for i in range(tamanoPoblacion):
		#datos(poblacion[i])
	#print()
	while (iGen < maxGen):
		elt = seleccionMejores(poblacion)
		desc = seleccionParientesCrossover(poblacion)
		poblacion = union(desc, elt)
		mutacion(poblacion)
		#print("\nPoblacion")
		#for i in range(tamanoPoblacion):
			#datos(poblacion[i])	
		iGen+=1
	fitnessFx(poblacion)
	poblacion.sort_custom(sortChunks)
	#for i in range(tamanoPoblacion): #WARNING Testeo
		#mostrar_datos(poblacion[i])
	return poblacion

func mostrar_datos(c : Chunk):
	print("id:", c.id, " leftP: ", c.leftP," rightP: ", c.rightP, " fit: ", c.fitness, " gen: ", c.gen)
	for i in range(0,GCporChunk):
		print("fila: " ,i, " h: ", c.gcs[i].alturaTile, " enemy: ", c.gcs[i].hasEnemy)
	print()

func iniPoblacion():
	var chunks = []
	for i in range(0,tamanoPoblacion):
		chunks.append(Chunk.new())
		chunks[i].id = i
		
		for j in range(0, GCporChunk):
			chunks[i].gcs.append(GeneColumn.new())
			chunks[i].gcs[j].id = j
			chunks[i].gcs[j].posX = j
			
			#if (j == 0):
				#chunks[i].gcs[j].alturaTile = alturaIni
			var h = randi_range(0,FilasporGC-alturaRestar)
			chunks[i].gcs[j].alturaTile = h
			if (randi_range(0,1) == 1):
				chunks[i].gcs[j].hasEnemy = true
				var x = randi_range(0,2)
				if (x == 0):#Low
					chunks[i].gcs[j].enemyLevel = "low"
					chunks[i].gcs[j].enemyNumber = 2
				elif (x == 1):
					chunks[i].gcs[j].enemyLevel = "medium"
					chunks[i].gcs[j].enemyNumber = 2
				else:
					chunks[i].gcs[j].enemyLevel = "heavy"
					chunks[i].gcs[j].enemyNumber = 1
							
			#TASK Inicialicacion de powerup y otros elementos
	var Poblacion = chunks
	return Poblacion


func sortChunks(a, b):# La funcion para poder usar sort custom
	if a.fitness < b.fitness: # Ordenar de menor a mayor
		return true
	return false
	
func seleccionMejores(p : Array):
	var elite = []
	for i in range(0,tamanoPoblacion):
		fitnessFx(p)
	p.sort_custom(sortChunks) #Ordenando las cosas
	#print("seleccionMejores")
	#for i in range(tamanoPoblacion):
		#print("pos: ",i)
		#datos(elite[i])
	for i in range(0,tamanoElite):
		elite.append(p[tamanoPoblacion-1-i])
	return elite

func rndWeighted(p : Array):#WARNING explota si suma pesos es negativo
	#Ahora viene el random weighted, gracias stack overflow
	var sumaPesos = 0
	for i in range(p.size()):
		sumaPesos += p[i].fitness 
	if sumaPesos <= 0:
		return randi_range(0,p.size()-1)
	var rnd = randi_range(0,sumaPesos-1)
	print("Suma Pesos: ", sumaPesos, " rnd: ", rnd)
	for i in range(p.size()):
		if rnd < p[i].fitness:
			print("elegido: ",i)
			return int(i) - tamanoElite #Posicion del elegido
		rnd -= p[i].fitness
		
 ## Punto medio
#func crossover(chunkL : Chunk, chunkR : Chunk): #Junta los dos lados del chunk en uno llamado Cross
	#randomize()
	#var Cross = []
	#Cross = chunkR
	#Cross.gcs.shuffle()
	#var l = chunkL
	#randomize()
	#l.gcs.shuffle()
	## for i in range(GCporChunk/2): #Division entera
	#for i in range(randi_range(0,GCporChunk-1)):
		#Cross.gcs[i] = l.gcs[i]
	#return Cross
	
func crossover(chunkL : Chunk, chunkR : Chunk): #2 puntos
	#print("left p: ", chunkL.id, " right p: ", chunkR.id)
	#print("chunkL")
	#datos(chunkL)
	#print("chunkR")
	#datos(chunkR)
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

	var cross = base
	var p1 = 0
	var p2= 0
	var r = 0
	var pmedio = GCporChunk/2
	p1 = randi_range(0, pmedio)
	if (p1==0):
		p1 = 1
	p2 = randi_range(pmedio+1,GCporChunk-1)
	r = randi_range(0,3)
	#print("p1: ",p1, " p2: ", p2,"\n")
	if (r == 0): #Estandar
		for i in range(0,p1):
			cross.gcs[i] = chunkL.gcs[i]
		for i in range(p1,p2):
			cross.gcs[i] = chunkR.gcs[i]
		for i in range(p2,GCporChunk):
			cross.gcs[i] = chunkL.gcs[i]
	elif (r == 1): #Girar el chunkR
		for i in range(0,p1):
			cross.gcs[i] = chunkL.gcs[i]
		for i in range(p1,p2):
			cross.gcs[i] = chunkR.gcs[GCporChunk-2-i]
		for i in range(p2,GCporChunk):
			cross.gcs[i] = chunkL.gcs[i]
	elif (r == 2): #Girar ChunkL
		for i in range(0,p1+1):
			cross.gcs[i] = chunkL.gcs[GCporChunk-i-1]
		for i in range(p1,p2):
			cross.gcs[i] = chunkR.gcs[i]
		for i in range(p2,GCporChunk-1):
			cross.gcs[i] = chunkL.gcs[GCporChunk-2-i]
	else: #Estandar pero shuffle
		for i in range(0,p1):
			cross.gcs[i] = chunkL.gcs[i]
		for i in range(p1,p2):
			cross.gcs[i] = chunkR.gcs[i]
		for i in range(p2,GCporChunk):
			cross.gcs[i] = chunkL.gcs[i]
		cross.gcs.shuffle()
	cross.id = chunkL.id + chunkR.id + 100
	cross.leftP = chunkL.id
	cross.rightP = chunkR.id
	cross.gen = iGen
	base.queue_free()
	#print("Cross")
	#datos(cross)
	return cross 

func seleccionParientesCrossover(p : Array):
	var descendencia = [] 

	var i = 0
	#print("PreCrossover")
	while (i<tamanoDescendencia):
		#print("Poblacion: ")
		#for j in range(tamanoPoblacion):
			#datos(p[j])
		var l = 0
		var r = 0
		var r1 = randi_range(0,tamanoDescendencia-1-tamanoElite) # TEST Testear cual entre rnd o rndWeighted da mejores resultados
		var r2 = randi_range(0,tamanoDescendencia-1-tamanoElite) # TEST Testear si excluir o no a los elites con -tamanoElite
		#var r1 = rndWeighted(p) #TEST Testear si variar entre los dos metodos al azar
		#var r2 = rndWeighted(p)
		#if r1 == tamanoPoblacion:
			#r1-=1
		#if r2 == tamanoPoblacion:
			#r2-=1
		if (r1==r2): #Evitar padres iguales
			if (r1 == tamanoDescendencia-1):
				r1 -=1
			else:
				r1+=1
		l = p[r1]
		r = p[r2]
		descendencia.append(crossover(l,r)) #TEST intento de ignorar a los elites	
		#datos(descendencia[i])
		i+=1
	return descendencia
	
func union(d : Array, e : Array):
	return d + e
	
func mutaChunk(c : Chunk): #TEST si subir rateMutation o hacer mas extrema la mutacion
	for i in range(randi_range(3,GCporChunk)):
		var r = randi_range(0,GCporChunk-1) #Elige un gc aleatorio
		var r2 = randi_range(0,2)
		if (r2 == 0): #Muta altura
			c.gcs[r].alturaTile  = randi_range(0,FilasporGC-alturaRestar) 
		elif (r2 == 1): #Muta enemigo
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
		else:
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
	
func mutacion(p: Array):
	var PoblacionM = p
	for i in range(tamanoPoblacion):
		var rnd = randf_range(0,1)
		if (rnd < rateMutation): #Si rnd da menor a 0.005, muta chunk i
			mutaChunk(PoblacionM[i])
	p = PoblacionM
		
func fitnessFx(p : Array):
	var enemyChunk = enemySpawn * 20 #El numero es definido por nosotros,enemigos por chunks
	var objectChunk = objectSpawn * 4 #Numero de mana por pantalla
	var initialFit = GCporChunk*200 #Tienen 3200 default creo, varia con gcpor chunk
	var puntajeEnemigos = 0
	var puntajePowerup = 0
	for i in range(tamanoPoblacion):#Viaja a traves de los chunks posibles
		var enemyCount = 0
		var objectCount = 0
		var castigoInacc= 0
		for j in range(GCporChunk):
			if (p[i].gcs[j].enemyLevel == "low"):
				enemyCount = enemyCount + 1*p[i].gcs[j].enemyNumber
			if (p[i].gcs[j].enemyLevel == "medium"):
				enemyCount = enemyCount + 2*p[i].gcs[j].enemyNumber
			if (p[i].gcs[j].enemyLevel == "heavy"):
				enemyCount = enemyCount + 4*p[i].gcs[j].enemyNumber
		#TASK Parte de los objetos powerup
		#TASK Esta es el castigo de salto, pero hay que evaluar el caso del inicio del chunk con el chunk anterior
			if (j!=0): 
				var altura = p[i].gcs[j].alturaTile - p[i].gcs[j-1].alturaTile
				if (altura > alturaSalto):
					castigoInacc -= 3000
			else: #WARNING Recordar
				var altura = altura_anterior - p[i].gcs[j].alturaTile
				if altura > alturaSalto:
					castigoInacc -= 3000
		#Calculos
		if(enemyCount > enemyChunk * 1.1):
			puntajeEnemigos = (enemyCount - enemyChunk)*5
		if(enemyCount <= enemyChunk * 1.1 && enemyCount > enemyCount * 0.9):
			puntajeEnemigos = 500
		if(enemyCount <= enemyChunk * 0.9):
			puntajeEnemigos = (enemyChunk - enemyCount)
		# Calculo powerUp
		#if(objectCount > objectChunk * 1.1):
			#puntajePowerup = (objectCount- objectChunk)*5
		#if(objectCount <= objectChunk * 1.1 && objectCount > objectChunk * 0.9):
			#puntajePowerup = 600
		#if(objectCount <= objectChunk* 0.9):
			#puntajePowerup = (objectChunk - objectCount)
		p[i].fitness = initialFit + puntajeEnemigos + puntajePowerup + castigoInacc
		if (p[i].fitness < 0):
			p[i].fitness = 0

