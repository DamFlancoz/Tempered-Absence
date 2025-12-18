# DashComponent.gd
extends Node

## --- Constants & Exports ---

@export var dash_speed: float = 1200.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.3

## --- Private State Variables ---

var _is_dashing: bool = false # Internal state flag
var _can_dash: bool = true   # Internal cooldown flag
var _dash_velocity: Vector2 = Vector2.ZERO # Internal stored velocity for the dash

## --- Signals ---

signal dash_started # Signal emitted when the dash begins
signal dash_finished # Signal emitted when the dash ends

## --- Node References ---

@onready var duration_timer: Timer = $DashDurationTimer
@onready var cooldown_timer: Timer = $DashCooldownTimer

func _ready() -> void:
	# Set timer wait times based on exported values
	duration_timer.wait_time = dash_duration
	cooldown_timer.wait_time = dash_cooldown
	
	# Connect signals from the timers
	duration_timer.timeout.connect(_on_duration_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

## --- Public API (Getters) ---

func is_dashing() -> bool:
	return _is_dashing

func get_dash_velocity() -> Vector2:
	return _dash_velocity

## --- Public API (Initiator) ---

# The Player calls this function to initiate the dash.
func try_dash(direction: Vector2) -> bool:
	if not _can_dash or _is_dashing:
		return false # Cannot dash right now

	if direction == Vector2.ZERO:
		return false
		
	# 1. Update internal state
	_is_dashing = true
	_can_dash = false
	
	# 2. Calculate and store the dash velocity internally
	_dash_velocity = direction.normalized() * dash_speed
	
	# 3. Start the duration timer
	duration_timer.start()
	
	# 4. Notify the parent Player to check the getters and apply movement
	dash_started.emit() 
	
	return true

## --- Timer Callbacks ---

func _on_duration_timer_timeout() -> void:
	_is_dashing = false
	_dash_velocity = Vector2.ZERO # Reset internal velocity
	
	# Notify the parent Player that the dash is over
	dash_finished.emit()
	
	# Start the cooldown period
	cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	_can_dash = true
