extends Node

var towers = {
	"MushroomT1": {
		"path": "res://Scenes/Towers/MushroomT1.tscn",
		"range": 350.0,
		"damage": 20.0,
		"rof": 1.0,
	},
}

var enemies = {
	"PigT1": {
		"path": "res://Scenes/Enemies/PigT1.tscn",
		"speed": 150,
		"hp": 50,
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
				"enemy_delay_mean": 1.0,
				"enemy_delay_deviation": 5.0,
				"receipe": {
					"PigT1": 4,
				}
			},
		],
	},
	{
		"name": "Map1",
		"path": "res://Scenes/Maps/Map1.tscn",
		"waves_delay": 5.0,
		"waves": [
			{
				"enemy_delay_min": 1.0,
				"enemy_delay_mean": 1.0,
				"enemy_delay_deviation": 5.0,
				"receipe": {
					"PigT1": 4,
				}
			},
			{
				"enemy_delay_min": 0.1,
				"enemy_delay_mean": 0.0,
				"enemy_delay_deviation": 2.0,
				"receipe": {
					"PigT1": 12,
				}
			},
			{
				"enemy_delay_min": 0.0,
				"enemy_delay_mean": 0.0,
				"enemy_delay_deviation": 0.5,
				"receipe": {
					"PigT1": 32,
				}
			},
		],
	}
]
