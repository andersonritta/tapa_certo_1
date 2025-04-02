extends Control

# Hora da última apertada do botão, inicializado com o epoch do UNIX time (00:00 UTC 01/01/1970).
var hora_da_última_apertada_de_um_botão_secreto: float = 0.0
var sequência: Array[int] = []
const TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS: float = 2.0

# Variáveis para armazenar os IDs
var id_profissional: int
var id_sujeito_de_teste: int

# Referências aos nós LineEdit
@onready var line_edit_profissional: LineEdit = $ContainerIDs/LineEditProfissional
@onready var line_edit_sujeito_de_teste: LineEdit = $ContainerIDs/LineEditSujeitoDeTeste


var ícone_música_normal = preload("res://assets/icons/music_note/music_note_normal.svg")
var ícone_música_precionado = preload("res://assets/icons/music_note/music_note_pressed.svg")
var ícone_música_desligada_normal = preload("res://assets/icons/music_note/music_note_off_normal.svg")
var ícone_música_desligada_precionado = preload("res://assets/icons/music_note/music_note_off_pressed.svg")

var ícone_sons_normal = preload("res://assets/icons/speaker/speaker_normal.svg")
var ícone_sons_precionado = preload("res://assets/icons/speaker/speaker_pressed.svg")
var ícone_sons_mudo_normal = preload("res://assets/icons/speaker/speaker_mute_normal.svg")
var ícone_sons_mudo_precionado = preload("res://assets/icons/speaker/speaker_mute_pressed.svg")

const TAMANHO_BASE_FONTE_LINE_EDIT: int = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ContainerIDs/LineEditProfissional.add_theme_font_size_override("font_size", GameManager.escala * TAMANHO_BASE_FONTE_LINE_EDIT)
	$ContainerIDs/LineEditSujeitoDeTeste.add_theme_font_size_override("font_size", GameManager.escala * TAMANHO_BASE_FONTE_LINE_EDIT)
	
	GameManager.iniciar_música()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func _on_botão_música_button_down() -> void:
	if GameManager.música_desligada:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_precionado
	else:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_precionado


func _on_botão_música_button_up() -> void:
	if GameManager.música_desligada:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
	else:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
	

func _on_botão_música_pressed() -> void:
	var index_bus_música = AudioServer.get_bus_index("Música")
	
	GameManager.música_desligada = !GameManager.música_desligada
	
	if GameManager.música_desligada:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		AudioServer.set_bus_mute(index_bus_música, true)
	else:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		AudioServer.set_bus_mute(index_bus_música, false)


func _on_botão_sons_button_down() -> void:
	if GameManager.sons_mutados:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_precionado
	else:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_precionado


func _on_botão_sons_button_up() -> void:
	if GameManager.sons_mutados:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal
	else:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_normal


func _on_botão_sons_pressed() -> void:
	var index_bust_sons = AudioServer.get_bus_index("SFX")
	
	GameManager.sons_mutados = !GameManager.sons_mutados
	
	if GameManager.sons_mutados:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal
		AudioServer.set_bus_mute(index_bust_sons, true)
	else:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_normal
		AudioServer.set_bus_mute(index_bust_sons, false)


func _on_botão_secreto_1_pressed() -> void:
	if (Time.get_unix_time_from_system() - hora_da_última_apertada_de_um_botão_secreto <= TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS):
		sequência.append(1)
	else:
		sequência = [1]
	
	hora_da_última_apertada_de_um_botão_secreto = Time.get_unix_time_from_system()


func _on_botão_secreto_2_pressed() -> void:
	if (Time.get_unix_time_from_system() - hora_da_última_apertada_de_um_botão_secreto <= TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS):
		sequência.append(2)
	else:
		sequência = [2]
		
	hora_da_última_apertada_de_um_botão_secreto = Time.get_unix_time_from_system()


func _on_botão_secreto_3_pressed() -> void:
	if (Time.get_unix_time_from_system() - hora_da_última_apertada_de_um_botão_secreto <= TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS):
		sequência.append(3)
		
		# Sequência secreta: 3, 1, 2, 3
		if sequência == [3, 1, 2, 3]:
			sequência = []
			
			print("Sequência secreta realizada.")
	else:
		sequência = [3]
		
	hora_da_última_apertada_de_um_botão_secreto = Time.get_unix_time_from_system()


func _on_botão_jogar_pressed() -> void:
	print("Botão Jogar pressionado!")  # Teste para ver se a função é chamada

	var id_profissional_text = $ContainerIDs/LineEditProfissional.text.strip_edges()
	var id_sujeito_de_teste_text = $ContainerIDs/LineEditSujeitoDeTeste.text.strip_edges()

	print("Profissional: ", id_profissional_text, "Sujeito de teste: ", id_sujeito_de_teste_text)

	var regex = RegEx.new()
	regex.compile("^[0-9]{4}$")

	if not regex.search(id_profissional_text):
		print("Erro: O ID do profissional deve ter exatamente 4 dígitos numéricos.")
		return

	if not regex.search(id_sujeito_de_teste_text):
		print("Erro: O ID do sujeito de teste deve ter exatamente 4 dígitos numéricos.")
		return

	id_profissional = int(id_profissional_text)
	id_sujeito_de_teste = int(id_sujeito_de_teste_text)
	
	var id_profissional_string = str(id_profissional)
	var id_sujeito_de_teste_string = str(id_sujeito_de_teste)


	print("ID do Profissional: ", id_profissional)
	print("ID do Sujeito de Teste: ", id_sujeito_de_teste)
	print("Iniciando jogo...")

	GameManager.iniciar_jogo(10, GameManager.PolíticasDeReposicionamento.TODOS, GameManager.VELOCIDADE_LENTA_PADRÃO, id_profissional_string, id_sujeito_de_teste_string)
