extends Node

var towers = {
	"GunT1": {
		"range": 350.0,
		"damage": 20.0,
		"rof": 1.0,
		"category": "Projectile",
	},
	"GunT2": {
		"range": 450.0,
		"damage": 30.0,
		"rof": 0.75,
		"category": "Projectile",
	},
	"MissileT1": {
		"range": 550.0,
		"damage": 100.0,
		"rof": 3.0,
		"category": "Missile",
	},
}

var enemies = {
	"TankT1": {},
}

var maps = [
	{
		"waves_delay": 5.0,
		"waves": [
			{
				"enemy_delay_min": 0.5,
				"enemy_delay_mean": 1.0,
				"enemy_delay_deviation": 5.0,
				"receipe": {
					"TankT1": 4,
				}
			},
		],
	}
]
