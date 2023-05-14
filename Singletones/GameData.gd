extends Node

var SELL_COEF = 0.8

var towers = {
	"General": {
		"image": "res://Assets/Towers/red-shroom-single.png",
		"path": "res://Scenes/Towers/General.tscn",
		"price": 50,
		"size": [64, 64],
		"levels": [
			{
				"range": 350.0,
				"damage": 20.0,
				"rof": 1.0,
			},
			{
				"range": 400.0,
				"damage": 30.0,
				"rof": 1.0,
			},
			{
				"range": 400.0,
				"damage": 30.0,
				"rof": 0.5,
			},
			{
				"range": 1000.0,
				"damage": 300.0,
				"rof": 0.1,
			},
		],
		"attack": {
			"type": "projectile",
			"path": "res://Scenes/Projectile/Boulder.tscn",
		},
	},
	"Frost": {
		"image": "res://Assets/Towers/frost-shroom-single.png",
		"path": "res://Scenes/Towers/Frost.tscn",
		"price": 100,
		"size": [64, 64],
		"levels": [
			{
				"range": 150.0,
				"damage": 100.0,
				"rof": 1.0,
				"effects": [
					{
						"name": "Frozen",
						"duration": 5.0,
						"slow_coef": 0.5,
					},
				],
			},
			{
				"range": 200.0,
				"damage": 200.0,
				"effects": [
					{
						"name": "Frozen",
						"duration": 5.0,
						"slow_coef": 0.4,
					},
				],
			},
			{
				"range": 200.0,
				"damage": 300.0,
				"rof": 0.5,
				"effects": [
					{
						"name": "Frozen",
						"duration": 10.0,
						"slow_coef": 0.3,
					},
				],
			},
			{
				"range": 500.0,
				"damage": 600.0,
				"rof": 0.1,
				"effects": [
					{
						"name": "Frozen",
						"duration": 20.0,
						"slow_coef": 0.1,
					},
				],
			},
		],
		"attack": {
			"type": "projectile",
			"path": "res://Scenes/Projectile/Frostball.tscn",
		},
	},
	"Chanterelle": {
		"image": "res://Assets/Towers/frost-shroom-single.png",
		"path": "res://Scenes/Towers/Сhanterelle.tscn",
		"price": 150,
		"size": [64, 64],
		"levels": [
			{
				"range": 350.0,
				"damage": 10.0,
				"rof": 1.0,
				"effects": [
					{
						"name": "Burning",
						"duration": 5.0,
						"damage": 50.0,
						"wait_time": 1.0,
					},
				],
			},
			{
				"range": 400.0,
				"damage": 20.0,
				"effects": [
					{
						"name": "Burning",
						"damage": 100.0,
						"duration": 5.0,
						"wait_time": 2 / 3,
					},
				],
			},
			{
				"range": 500.0,
				"damage": 30.0,
				"rof": 0.5,
				"effects": [
					{
						"name": "Burning",
						"damage": 250.0,
						"duration": 10.0,
						"wait_time": 2 / 3,
					},
				],
			},
			{
				"range": 750.0,
				"damage": 60.0,
				"rof": 0.1,
				"effects": [
					{
						"name": "Burning",
						"damage": 250.0,
						"duration": 20.0,
						"wait_time": 1 / 3,
					},
				],
			},
		],
		"attack": {
			"type": "projectile",
			"path": "res://Scenes/Projectile/Fireball.tscn",
		},
	}
}

var enemies = {
	"PigT1": {
		"path": "res://Scenes/Enemies/PigT1.tscn",
		"speed": 150,
		"hp": 500,
		"damage": 10,
		"bounty_min": 25,
		"bounty_max": 50,
	},
	"BurningPig": {
		"path": "res://Scenes/Enemies/PigT1.tscn",
		"speed": 500,
		"hp": 100,
		"damage": 100,
		"bounty_min": 0,
		"bounty_max": 500,
		"effects": [
			{
				"name": "Burning",
				"damage": 100.0,
				"duration": 5.0,
				"wait_time": 2 / 3,
			},
		],
	},
}

var effects = {
	"Burning": "res://Scenes/Effects/Burning.gd",
	"Frozen": "res://Scenes/Effects/Frozen.gd"
}

var maps = [
	{
		"name": "Map0",
		"path": "res://Scenes/Maps/Map1.tscn",
		"waves_delay": 5.0,
		"waves": [
			{
				"enemy_delay_min": 0.0,
				"enemy_delay_max": 0.1,
				"receipe": [
					{
						"type": "PigT1",
						"count": 100,
					},
				]
			},
		],
		"base_hp": 100,
		"towers": [
			"General",
			"Frost",
			"Chanterelle",
		],
		"wallet_start": 500,
	},
	{
		"name": "Map1",
		"path": "res://Scenes/Maps/Map1.tscn",
		"waves_delay": 5.0,
		"waves": [
			{
				"enemy_delay_min": 1.0,
				"enemy_delay_max": 5.0,
				"receipe": [
					{
						"type": "PigT1",
						"count": 4,
					},
				]
			},
			{
				"enemy_delay_min": 0.1,
				"enemy_delay_max": 2.0,
				"receipe": [
					{
						"type": "PigT1",
						"count": 12,
					},
				]
			},
			{
				"enemy_delay_min": 0.0,
				"enemy_delay_max": 0.5,
				"receipe": [
					{
						"type": "PigT1",
						"count": 32,
					},
				]
			},
		],
		"base_hp": 150,
		"towers": [
			"General",
			"Frost",
			"Chanterelle",
		],
		"wallet_start": 150,
	}
]
