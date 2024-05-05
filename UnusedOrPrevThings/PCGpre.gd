extends Node



const tamanoPoblacion = 10
const rateElitism = 0.05
const rateMutation = 0.0005
const tamanoElite = round(tamanoPoblacion*rateElitism)
const tamanoDescendencia = tamanoPoblacion-tamanoElite
const GCporChunk = 6
const FilasporGC = 8
const randomColumna = ["tile", "enemigo", "null"]
const maxGen = 1
var chunks =[]

var enemySpawn = 1
var objectSpawn = 1
var alturaSalto = 1
var alturaRestar = 5


class Chunk:
	var leftP = 0
	var rightP = 0
	var id = 0
	var gcs = []
	var fitness = 0
 
class GeneColumn:
	var id = 0
	"""
	var fila0 = null
	var fila1 = null
	var fila2 = null
	var fila3 = null
	var fila4 = null
	var fila5 = null
	var fila6 = null
	var fila7 = null
	"""
	#var filas = []
	var alturaTile = 0
	var hasEnemy = false
	var enemyLevel = "low"
	var enemyNumber = 0
	var posX = 0

# Called when the node enters the scene tree for the first time.
func _ready(): 
	seed(911)
	var poblacion = iniPoblacion()
	var iGen = 0
	
	for i in range(tamanoPoblacion):
		print("id origen: ",poblacion[i].id," fit: ",poblacion[i].fitness," ")
		for j in range(GCporChunk):
			print("h: ",poblacion[i].gcs[j].alturaTile, " enemy: ", poblacion[i].gcs[j].hasEnemy)
					
	print()
	print()
	print()
	
	for igen in range(0,maxGen):
		var elite = seleccionMejores(poblacion)
		for i in range(tamanoPoblacion):
			print("l parent: ",poblacion[i].leftP, " r parent: ",poblacion[i].rightP," fit: ",poblacion[i].fitness," ")
			for j in range(GCporChunk):
				print("h: ",poblacion[i].gcs[j].alturaTile, " enemy: ", poblacion[i].gcs[j].hasEnemy)
		print()
		print()
	
		var desc = seleccionParientesCrossover(poblacion)
		poblacion = union(elite,desc)
		#poblacion = mutacion(poblacion)
		for i in range(tamanoPoblacion):
			print("l parent: ",poblacion[i].leftP, " r parent: ",poblacion[i].rightP," fit: ",poblacion[i].fitness," ")
			for j in range(GCporChunk):
				print("h: ",poblacion[i].gcs[j].alturaTile, " enemy: ", poblacion[i].gcs[j].hasEnemy)
		print()
		print()
	
	#Aqui poblacion esta lista
	fitnessFx(poblacion)
	poblacion.sort_custom(sortChunks)
	for i in range(tamanoPoblacion):
		for j in range(0,GCporChunk):
			var altura = poblacion[i].gcs[j].alturaTile
			if poblacion[i].gcs[j].hasEnemy:
				$GridMap.set_cell_item(Vector3i(3+j, altura+1,i),1)
			while altura != 0:
				$GridMap.set_cell_item(Vector3i(3+j,altura,i),0)
				altura -= 1
	

	var enemies = $GridMap.get_used_cells_by_id(1)
	#$GridMap.basicTileReplace(enemies, Enemigo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func iniPoblacion():
	
	for i in range(0,tamanoPoblacion):
		chunks.append(Chunk.new())
		chunks[i].id = i
		
		for j in range(0, GCporChunk):
			chunks[i].gcs.append(GeneColumn.new())
			chunks[i].gcs[j].id = j
			chunks[i].gcs[j].posX = j
			
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
	var Elite = []
	for i in range(0,tamanoPoblacion):
		fitnessFx(p)
	p.sort_custom(sortChunks) #Ordenando las cosas
	for i in range (tamanoElite):
		Elite.append(p[tamanoPoblacion-1-i])
	return Elite

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
			return int(i) #Posicion del elegido
		rnd -= p[i].fitness
		
""" # Punto medio
func crossover(chunkL : Chunk, chunkR : Chunk): #Junta los dos lados del chunk en uno llamado Cross
	randomize()
	var Cross = []
	Cross = chunkR
	Cross.gcs.shuffle()
	var l = chunkL
	randomize()
	l.gcs.shuffle()
	# for i in range(GCporChunk/2): #Division entera
	for i in range(randi_range(0,GCporChunk-1)):
		Cross.gcs[i] = l.gcs[i]
	return Cross
"""

func crossover(chunkL : Chunk, chunkR : Chunk): #2 puntos
	var Cross = chunkL
	var pmedio = GCporChunk/2
	var p1 = randi_range(0, pmedio)
	var p2 = randi_range(pmedio+1,GCporChunk)
	print("p1: ",p1, " p2: ", p2,"\n")
	for i in range(p1,p2):
		Cross.gcs[i] = chunkR.gcs[i]
	return Cross 
		


func seleccionParientesCrossover(p : Array):
	var Descendencia = p #Sacamos a los elites 	
	for i in range(0,tamanoDescendencia-tamanoElite):
		var r1 = randi_range(0,tamanoDescendencia-1-tamanoElite) # WARNING Modificar por rnd weighted
		var r2 = randi_range(0,tamanoDescendencia-1-tamanoElite)
		Descendencia[i].leftP = p[r1].id
		Descendencia[i].rightP = p[r2].id
		print("left p: ", p[r1].id, " right p: ", p[r2].id)
		Descendencia[i] = (crossover(p[r1],p[r2])) #TEST intento de ignorar a los elites
	return Descendencia
	
func union(e : Array, d : Array):
	var cont = 0
	return d
	
func mutaChunk(c : Chunk):
	var r = randi_range(0,GCporChunk-1) #Elige un gc aleatorio
	var r2 = randi_range(0,1)
	if (r2 == 0): #Muta altura
		c.gcs[r].alturaTile  = randi_range(0,FilasporGC-alturaRestar) 
	else: #Muta enemigo
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
		if (rnd < rateMutation): #Si rnd da menor a 0.0005, muta chunk i
			mutaChunk(PoblacionM[i])
	return PoblacionM
		
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
			#else: #WARNING Recordar
				#var altura = p[i].gcs[j].alturaTile
				#if altura > alturaSalto:
					#castigoInacc -= 3000
		#Calculos
		if(enemyCount > enemyChunk * 1.1):
			puntajeEnemigos = (enemyCount - enemyChunk)*5
		if(enemyCount <= enemyChunk * 1.1 && enemyCount > enemyCount * 0.9):
			puntajeEnemigos = 1200
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
	
