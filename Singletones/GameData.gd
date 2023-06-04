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
				"damage": 40.0,
				"rof": 1.0,
			},
			{
				"range": 500.0,
				"damage": 40.0,
				"rof": 0.5,
			},
			{
				"range": 500.0,
				"damage": 80.0,
				"rof": 0.4,
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
				"range": 200.0,
				"damage": 60.0,
				"rof": 1.0,
				"effects": [
					{
						"name": "Frozen",
						"duration": 5.0,
						"slow_coef": 0.75,
					},
				],
			},
			{
				"range": 200.0,
				"damage": 100.0,
				"rof": 0.8,
				"effects": [
					{
						"name": "Frozen",
						"duration": 5.0,
						"slow_coef": 0.6,
					},
				],
			},
			{
				"range": 250.0,
				"damage": 120.0,
				"rof": 0.8,
				"effects": [
					{
						"name": "Frozen",
						"duration": 6.0,
						"slow_coef": 0.5,
					},
				],
			},
			{
				"range": 350.0,
				"damage": 150.0,
				"rof": 0.4,
				"effects": [
					{
						"name": "Frozen",
						"duration": 8.0,
						"slow_coef": 0.4,
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
	"Pig": {
		"path": "res://Scenes/Enemies/Pig.tscn",
		"speed": 150,
		"hp": 300,
		"damage": 10,
		"bounty_min": 25,
		"bounty_max": 50,
	},
	"BurningPig": {
		"path": "res://Scenes/Enemies/BurningPig.tscn",
		"speed": 300,
		"hp": 500,
		"damage": 15,
		"bounty_min": 0,
		"bounty_max": 500,
	},
	"BigPig": {
		"path": "res://Scenes/Enemies/BigPig.tscn",
		"speed": 75,
		"hp": 1500,
		"damage": 10,
		"size_scale": 1.3,
		"bounty_min": 50,
		"bounty_max": 100,
		"z_index": 1,
	},
}

var effects = {
	"Burning": "res://Scenes/Effects/Burning.gd",
	"Frozen": "res://Scenes/Effects/Frozen.gd"
}

var maps = [
	{
		"name": "#0",
		"path": "res://Scenes/Maps/Map1.tscn",
		"waves_delay": 8.0,
		"waves": [
			{
				"enemy_delay_min": 1.0,
				"enemy_delay_max": 5.0,
				"receipe": [
					{
						"type": "Pig",
						"count": 4,
					},
				]
			},
			{
				"enemy_delay_min": 0.1,
				"enemy_delay_max": 2.0,
				"receipe": [
					{
						"type": "Pig",
						"count": 8,
					},
				]
			},
			{
				"enemy_delay_min": 0.0,
				"enemy_delay_max": 0.5,
				"receipe": [
					{
						"type": "Pig",
						"count": 14,
					},
					{
						"type": "BigPig",
						"count": 1,
					},
				]
			},
		],
		"base_hp": 500,
		"towers": [
			"General",
		],
		"wallet_start": 150,
		"soundtrack": "res://Assets/Sounds/soundtrack-battle.wav",
	},
	{
		"name": "#1",
		"path": "res://Scenes/Maps/Map2.tscn",
		"waves_delay": 5.0,
		"waves": [
			{
				"enemy_delay_min": 1.0,
				"enemy_delay_max": 3.0,
				"receipe": [
					{
						"type": "Pig",
						"count": 8,
					},
				]
			},
			{
				"enemy_delay_min": 0.5,
				"enemy_delay_max": 3.0,
				"receipe": [
					{
						"type": "BurningPig",
						"count": 4,
					},
					{
						"type": "Pig",
						"count": 32,
					},
				]
			},
			{
				"enemy_delay_min": 0.1,
				"enemy_delay_max": 1.0,
				"receipe": [
					{
						"type": "Pig",
						"count": 52,
					},
					{
						"type": "BigPig",
						"count": 4,
					},
					{
						"type": "Pig",
						"count": 4,
					},
				]
			},
		],
		"base_hp": 250,
		"towers": [
			"General",
			"Frost",
		],
		"wallet_start": 200,
		"soundtrack": "res://Assets/Sounds/soundtrack-battle.wav",
	},
	{
		"name": "#2",
		"path": "res://Scenes/Maps/Map2.tscn",
		"waves_delay": 10.0,
		"waves": [
			{
				"enemy_delay_min": 0.0,
				"enemy_delay_max": 2.0,
				"receipe": [
					{
						"type": "Pig",
						"count": 12,
					},
				]
			},
			{
				"enemy_delay_min": 0.1,
				"enemy_delay_max": 1.5,
				"receipe": [
					{
						"type": "BurningPig",
						"count": 4,
					},
					{
						"type": "Pig",
						"count": 28,
					},
					{
						"type": "BurningPig",
						"count": 4,
					},
				]
			},
			{
				"enemy_delay_min": 0.1,
				"enemy_delay_max": 0.5,
				"receipe": [
					{
						"type": "BigPig",
						"count": 2,
					},
					{
						"type": "Pig",
						"count": 8,
					},
					{
						"type": "BigPig",
						"count": 4,
					},
					{
						"type": "Pig",
						"count": 64,
					},
				],
			},
			{
				"enemy_delay_min": 0.0,
				"enemy_delay_max": 0.2,
				"receipe": [
					{
						"type": "BurningPig",
						"count": 8,
					},
					{
						"type": "Pig",
						"count": 12,
					},
					{
						"type": "BigPig",
						"count": 4,
					},
					{
						"type": "Pig",
						"count": 12,
					},
					{
						"type": "BurningPig",
						"count": 4,
					},
					{
						"type": "Pig",
						"count": 16,
					},
					{
						"type": "BigPig",
						"count": 4,
					},
					{
						"type": "Pig",
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
		"wallet_start": 350,
		"soundtrack": "res://Assets/Sounds/soundtrack-boss.wav",
	},
]
