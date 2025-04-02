extends Node2D


@onready var donut = $Donut
@onready var hambúrguer = $"Hambúrguer"
@onready var pizza = $Pizza
@onready var ovo_frito = $OvoFrito
@onready var maçã = $"Maçã"
@onready var uva = $Uva
@onready var sorvete = $Sorvete
@onready var cupcake = $Cupcake
@onready var brócolis = $"Brócolis"
@onready var picolé = $"Picolé"

@onready var rng = RandomNumberGenerator.new()

var velocidade: float
var alvos_no_jogo: Array = []
var vetores_de_movimento_dos_alvos: Array[Vector2] = []
var sprites_dos_alvos: Array[Sprite2D] = []
var sprite_do_alvo_atual: Sprite2D
var tamanho_da_janela: Vector2
var tempo_total: float = 0.0
var tempo_desde_clique_certo = 0.0

const colunas: int = 5
var linhas: int

var tamanho_célula: Vector2
var offset_máximo: Vector2
const BASE_OFFSET_MÁXIMO: int = 50

var distância_mínima_entre_alvos: float = 125.0

var grid_de_alvos: Array[Array] = []

const TAMANHO_BASE_DA_FONTE: int = 48
const TEMPO_ATÉ_AUMENTAR_O_SUPORTE: float = 30.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:   
	tamanho_da_janela = get_viewport_rect().size
	
	distância_mínima_entre_alvos *= GameManager.escala
	velocidade = GameManager.velocidade * GameManager.escala


	# Inicialização do ruído azul
	linhas = round(tamanho_da_janela.y / tamanho_da_janela.x * colunas)
	tamanho_célula.x = tamanho_da_janela.x / colunas
	tamanho_célula.y = tamanho_da_janela.y / linhas
	
	grid_de_alvos.resize(colunas)
	
	var array_temporário: Array[int]
	array_temporário.resize(linhas)
	array_temporário.fill(-1)
	
	for i in grid_de_alvos.size():
		grid_de_alvos[i] = array_temporário.duplicate()
	
	# A primeira célula é reservada para o indicador do alvo atual
	grid_de_alvos[0][0] = 2147483647
	
	var aspect_ratio_célula: float = tamanho_célula.y / tamanho_célula.x
	offset_máximo = Vector2(BASE_OFFSET_MÁXIMO * GameManager.escala, BASE_OFFSET_MÁXIMO * GameManager.escala * aspect_ratio_célula)
	

	# Inicialização dos alvos
	for alvo in GameManager.alvos_no_jogo:
		match alvo:
			GameManager.Alvos.DONUT:
				alvos_no_jogo.append(donut)
			GameManager.Alvos.HAMBÚRGUER:
				alvos_no_jogo.append(hambúrguer)
			GameManager.Alvos.PIZZA:
				alvos_no_jogo.append(pizza)
			GameManager.Alvos.OVO_FRITO:
				alvos_no_jogo.append(ovo_frito)
			GameManager.Alvos.MAÇÃ:
				alvos_no_jogo.append(maçã)
			GameManager.Alvos.UVA:
				alvos_no_jogo.append(uva)
			GameManager.Alvos.SORVETE:
				alvos_no_jogo.append(sorvete)
			GameManager.Alvos.CUPCAKE:
				alvos_no_jogo.append(cupcake)
			GameManager.Alvos.BRÓCOLIS:
				alvos_no_jogo.append(brócolis)
			GameManager.Alvos.PICOLÉ:
				alvos_no_jogo.append(picolé)
			_:
				assert(false, "Alvo inválido")
				
	vetores_de_movimento_dos_alvos.resize(alvos_no_jogo.size())
	sprites_dos_alvos.resize(alvos_no_jogo.size())
		
	for i in alvos_no_jogo.size():
		alvos_no_jogo[i].scale = Vector2(GameManager.escala, GameManager.escala)
		
		for child in alvos_no_jogo[i].get_children():
			if child is Sprite2D:
				sprites_dos_alvos[i] = child.duplicate()
				
				sprites_dos_alvos[i].scale *= GameManager.escala
				sprites_dos_alvos[i].position = Vector2(75 * GameManager.escala, 75 * GameManager.escala)
				
		vetores_de_movimento_dos_alvos[i] = vetor_de_movimento_aleatório()

	spawnar_todos_os_alvos()
	
	# Não mantenha as células ocupadas se os alvos vão se mover
	if velocidade == GameManager.VELOCIDADE_ZERO_PADRÃO:
		remover_todos_os_alvos_do_grid()
	
	
	# Inicialização dos indicadores da interface
	setar_sprite_alvo(GameManager.alvos_no_jogo.find(GameManager.alvo_atual))
	$CanvasLayer/Control/TextureRect.scale = Vector2(GameManager.escala, GameManager.escala)
	
	$CanvasLayer/Label.add_theme_font_size_override("font_size", GameManager.escala * TAMANHO_BASE_DA_FONTE)
	
	$CanvasLayer/AjudaAlvo.scale = Vector2(GameManager.escala, GameManager.escala)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tempo_total += delta
	tempo_desde_clique_certo += delta
	
	var novo_suporte: int = min(10, floor(tempo_desde_clique_certo / TEMPO_ATÉ_AUMENTAR_O_SUPORTE))
	
	if novo_suporte != GameManager.suporte:
		alterar_suporte(novo_suporte)
	
	for i in alvos_no_jogo.size():
		alvos_no_jogo[i].global_position += vetores_de_movimento_dos_alvos[i] * delta
		
		if vetores_de_movimento_dos_alvos[i].x < 0 and alvos_no_jogo[i].global_position.x < 0:
			vetores_de_movimento_dos_alvos[i].x *= -1
		
		if vetores_de_movimento_dos_alvos[i].x > 0 and alvos_no_jogo[i].global_position.x + alvos_no_jogo[i].width * GameManager.escala > tamanho_da_janela.x:
			vetores_de_movimento_dos_alvos[i].x *= -1

		if vetores_de_movimento_dos_alvos[i].y < 0 and alvos_no_jogo[i].global_position.y < 0:
			vetores_de_movimento_dos_alvos[i].y *= -1

		if vetores_de_movimento_dos_alvos[i].y > 0 and alvos_no_jogo[i].global_position.y + alvos_no_jogo[i].height * GameManager.escala > tamanho_da_janela.y:
			vetores_de_movimento_dos_alvos[i].y *= -1

	if (GameManager.suporte > 0):
		var alvo_atual = alvos_no_jogo[GameManager.alvos_no_jogo.find(GameManager.alvo_atual)]
		
		var escala_ajuda_alvo = abs(sin(tempo_total * GameManager.suporte) * (GameManager.suporte - 1) * 0.1)
		$CanvasLayer/AjudaAlvo.scale = Vector2(GameManager.escala + GameManager.escala * escala_ajuda_alvo, GameManager.escala + GameManager.escala * escala_ajuda_alvo)
		
		$CanvasLayer/AjudaAlvo.global_position = Vector2(alvo_atual.global_position.x + (alvo_atual.width / 2 - 75 * (1 + escala_ajuda_alvo)) * GameManager.escala,
														 alvo_atual.global_position.y + (alvo_atual.height / 2 - 75 * (1 + escala_ajuda_alvo)) * GameManager.escala)
	else:
		$CanvasLayer/AjudaAlvo.scale = Vector2(0, 0)
		$CanvasLayer/AjudaAlvo.global_position = Vector2(-10000, -10000)


func alterar_suporte(novo_suporte: int):
	if (novo_suporte != GameManager.suporte):
		GameManager.suporte = novo_suporte
		GameManager.mudança_no_suporte()

func setar_sprite_alvo(index: int) -> void:
	if sprite_do_alvo_atual != null:
		$CanvasLayer/Control.remove_child(sprite_do_alvo_atual)
	
	$CanvasLayer/Control.add_child(sprites_dos_alvos[index])
	sprite_do_alvo_atual = sprites_dos_alvos[index]


func atualizar_placar() -> void:
		$CanvasLayer/Label.text = "Pontos: " + str(GameManager.pontos)


func clique(alvo: int) -> void:    
	var alvo_original = GameManager.alvos_no_jogo.find(GameManager.alvo_atual)
	var certo = GameManager.clique(alvo)
	
	if certo:        
		$TapRight.play()
		
		alterar_suporte(0)
		tempo_desde_clique_certo = 0.0
		
		$CanvasLayer/AjudaAlvo.global_position = Vector2(0, -150 * GameManager.escala)
		
		var index = GameManager.alvos_no_jogo.find(GameManager.alvo_atual)
		setar_sprite_alvo(index)
		
		if GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.ALVO:
			# Reposiciona o alvo imóvel
			if velocidade == GameManager.VELOCIDADE_ZERO_PADRÃO:
				trocar_alvo_de_posição(alvo_original)
			# Reposiciona o alvo móvel
			else:
				vetores_de_movimento_dos_alvos[alvo_original] = vetor_de_movimento_aleatório()
				
				var posição_original: Vector2 = centro_de_alvo(alvo_original)
				
				var tentativas = 0

				while true:                
					alvos_no_jogo[alvo_original].global_position = Vector2(rng.randf_range(0, tamanho_da_janela.x - alvos_no_jogo[alvo_original].width * GameManager.escala),
																		   rng.randf_range(0, tamanho_da_janela.y - alvos_no_jogo[alvo_original].height * GameManager.escala))
					
					var colisão = false
					var colisão_com_o_indicado_do_alvo = false
					
					for i in alvos_no_jogo.size():
						if i == alvo_original:
							continue
						
						if distância_entre_alvos(i, alvo_original) < distância_mínima_entre_alvos:
							colisão = true
							break
					
					# Detecta se o alvo está na área do indicador do alvo
					if distância_entre_alvos(alvo_original, -1, Vector2(0, 0)) < 200 * GameManager.escala:
						colisão = true
						colisão_com_o_indicado_do_alvo = true
						
					# Detecta se o alvo está muito perto da posição inicial
					if distância_entre_alvos(alvo_original, -1, posição_original) < 300 * GameManager.escala:
						colisão = true
							
					if not colisão or (tentativas >= 100 and not colisão_com_o_indicado_do_alvo):
						break
		elif GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.TODOS:
			spawnar_todos_os_alvos()
			
	else:
		$TapWrong.play()
		
	atualizar_placar()
	
	# A ordem de renderização de nós irmão é de cima para baixo com base no que aparece na árvore de
	# nós. A ordem de tratamento de entradas segue a mesma ordem. O efeito disso é que nós
	# renderizados abaixo de outros nós serão tratados antes dos nós a frente, então se a propagação
	# é parada apenas o nó mais de traz é tratado. Para resolver isso a solução é colocar os nós na
	# árvore em ordem reversa a ordem desejada para renderização e setar o índice Z para que sejam
	# renderizados na ordem desejada.
	# A ordem de renderização é bem documentada, porém, aparente mente a ordem de execução de
	# entradas não é. Mais informações sobre a ordem de execução não documentada:
	# https://www.reddit.com/r/godot/comments/112w2zt/notes_on_event_execution_order_with_a_side_dose/
	get_viewport().set_input_as_handled() # Para a propagação da entrada
 

func vetor_de_movimento_aleatório() -> Vector2:
	var vetor_de_movimento: Vector2 = Vector2(rng.randi_range(0, 1), rng.randi_range(0, 1))
		
	if vetor_de_movimento.x == 0:
		vetor_de_movimento.x = -1.0
	
	if vetor_de_movimento.y == 0:
		vetor_de_movimento.y = -1.0
		
	vetor_de_movimento = vetor_de_movimento.normalized() * velocidade
		
	return vetor_de_movimento
   
	
func spawnar_alvo(alvo: int, ocupar: bool) -> void:
	var coluna: int
	var linha: int
	
	# Cria uma lista de células não ocupadas
	var células_vazias: Array = []
	for i in colunas:
		for j in linhas:
			if grid_de_alvos[i][j] < 0:
				células_vazias.append([i, j])
	
	# Escolhe uma célula aleatória da lista
	if células_vazias.size() > 0:
		var célula_escolhida = células_vazias[rng.randi_range(0, células_vazias.size() - 1)]
		coluna = célula_escolhida[0]
		linha = célula_escolhida[1]
	else:
		# Caso não haja células vazias, escolhe uma célula aleatória
		coluna = rng.randi_range(0, colunas - 1)
		linha = rng.randi_range(0, linhas - 1)
	
	if ocupar:
		grid_de_alvos[coluna][linha] = alvo
		
	var pos_x = coluna * tamanho_célula.x + tamanho_célula.x / 2 + rng.randf_range(-offset_máximo.x, offset_máximo.x)
	var pos_y = linha * tamanho_célula.y + tamanho_célula.y / 2 + rng.randf_range(-offset_máximo.y, offset_máximo.y)
	
	alvos_no_jogo[alvo].global_position = Vector2(pos_x - alvos_no_jogo[alvo].width * GameManager.escala / 2,\
												  pos_y - alvos_no_jogo[alvo].height * GameManager.escala / 2)


func spawnar_todos_os_alvos() -> void:
	remover_todos_os_alvos_do_grid()
	
	for i in alvos_no_jogo.size():
		spawnar_alvo(i, true)


func remover_alvo_do_grid(alvo: int) -> bool:
	for i in grid_de_alvos.size():
		for j in grid_de_alvos[i].size():
			if grid_de_alvos[i][j] == alvo:
				grid_de_alvos[i][j] = -1
				return true
	
	return false


func encontrar_posição_de_alvo_no_grid(alvo: int) -> Array[int]:
	for i in grid_de_alvos.size():
		for j in grid_de_alvos[i].size():
			if grid_de_alvos[i][j] == alvo:
				return [i, j]
	
	return [-1, -1]


func trocar_alvo_de_posição(alvo: int) -> void:
	var posição_atual = encontrar_posição_de_alvo_no_grid(alvo)

	assert(posição_atual[0] >= 0 and posição_atual[1] >= 0, "Alvo não encontrado no grid")

	spawnar_alvo(alvo, true)
	grid_de_alvos[posição_atual[0]][posição_atual[1]] = -1
		

func remover_todos_os_alvos_do_grid() -> void:
	for i in grid_de_alvos.size():
		for j in grid_de_alvos[i].size():
			grid_de_alvos[i][j] = -1

	grid_de_alvos[0][0] = 2147483647


func centro_de_alvo(alvo: int) -> Vector2:
	return alvos_no_jogo[alvo].global_position + Vector2(alvos_no_jogo[alvo].width / 2 * GameManager.escala,
														 alvos_no_jogo[alvo].height / 2 * GameManager.escala)


# Calcula a distância entre o centro de dois alvos. Use -1 em um dos alvos para especificar um ponto
# arbitrário no terceiro argumento ou -1 nos dois alvos para especificar dois pontos arbitrários no
# terceiro e quart argumento e calcular a distância entre eles.
func distância_entre_alvos(a: int, b: int, pos_1: Vector2 = Vector2(0, 0), pos_2: Vector2 = Vector2(0, 0)) -> float:
	var centro_a: Vector2
	var centro_b: Vector2
	
	if a == -1 and b == -1:
		centro_a = pos_1
		centro_b = pos_2
	elif a == -1:
		centro_a = pos_1
		centro_b = centro_de_alvo(b)
	elif b == -1:
		centro_a = centro_de_alvo(a)
		centro_b = pos_1
	else:
		centro_a = centro_de_alvo(a)
		centro_b = centro_de_alvo(b)
	
	return sqrt(pow(centro_a.x - centro_b.x, 2) + pow(centro_a.y - centro_b.y, 2))
