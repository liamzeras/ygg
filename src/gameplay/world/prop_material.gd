class_name PropMaterial
extends Resource
## Propriedades físicas e elementais de um material.
## Ver design/gdd/physics-magic-system.md (seção Materiais).

@export var display_name := ""
@export var color := Color.WHITE
@export_range(0.0, 1.0) var roughness := 0.8
@export_range(0.0, 1.0) var metallic := 0.0

@export_group("Física")
## Densidade "de jogo" em kg/m³ (massa = volume x densidade).
@export var density := 100.0
@export_range(0.0, 1.0) var friction := 0.8
@export_range(0.0, 1.0) var bounce := 0.05

@export_group("Fogo")
@export var flammable := false
## Calor acumulado necessário para pegar fogo.
@export var ignition_heat := 100.0
## Calor perdido por segundo quando não está queimando.
@export var heat_decay := 20.0
## Quanto tempo queima até virar cinzas (segundos).
@export var burn_time := 8.0
## Raio em que o fogo aquece outros objetos.
@export var fire_spread_radius := 1.6
## Calor por segundo transmitido a objetos no raio (cai com a distância).
@export var fire_spread_heat := 60.0

@export_group("Explosão")
@export var explosive := false
## Segundos queimando antes de explodir.
@export var fuse_time := 1.5
@export var explosion_radius := 5.0
@export var explosion_impulse := 900.0
@export var explosion_heat := 150.0
## Velocidade de impacto (m/s) que detona o objeto na hora.
@export var impact_detonation_speed := 9.0

@export_group("Futuro")
## Reservado para eletricidade (ainda sem efeito).
@export var conductive := false
