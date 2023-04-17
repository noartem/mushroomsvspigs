extends Node

var towers = {
	"MushroomT1": {
		"image": "res://Assets/Towers/red-shroom-single.png",
		"path": "res://Scenes/Towers/MushroomT1.tscn",
		"range": 350.0,
		"damage": 20.0,
		"rof": 1.0,
		"price": 50,
	},
}

var enemies = {
	"PigT1": {
		"path": "res://Scenes/Enemies/PigT1.tscn",
		"speed": 150,
		"hp": 50,
		"damage": 10,
		"bounty_min": 25,
		"bounty_max": 50,
	},
}

var maps = [
	{
		"name": "Map0",
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
		],
		"base_hp": 100,
		"towers": [
			"MushroomT1",
		],
		"wallet_start": 50,
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
			"MushroomT1",
		],
		"wallet_start": 150,
	}
]
