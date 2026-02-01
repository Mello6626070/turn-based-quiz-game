@abstract class_name ClassVisual extends Node2D
signal animation_finished(animation: String)
signal hurt_enemy()
@export var animated_sprite: AnimatedSprite2D
@abstract func start_animation(animtation_name: String)
