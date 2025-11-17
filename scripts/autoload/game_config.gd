extends Node

# Global game configuration singleton
var config: GameConfigResource
var signature_formulas: SignatureFormulas

func _ready():
	# Load default config or create new one
	if ResourceLoader.exists("res://resources/configs/default_config.tres"):
		config = load("res://resources/configs/default_config.tres")
	else:
		config = GameConfigResource.new()
		print("Created new default config")

	# Load signature formulas
	if ResourceLoader.exists("res://resources/formulas/signature_formulas.tres"):
		signature_formulas = load("res://resources/formulas/signature_formulas.tres")
	else:
		signature_formulas = SignatureFormulas.new()
		print("Created new signature formulas")

func get_config() -> GameConfigResource:
	return config

func get_signature_formulas() -> SignatureFormulas:
	return signature_formulas
