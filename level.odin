package main

import "core:math/rand"
import "core:math"

Level :: struct {
	crates:  [dynamic]Sprite,
	targets: [dynamic]Sprite,
	player:  Player,
}

new_level :: proc(crate_count: u32, assets: ^Assets) -> Level {
	level := Level{}
	reserve_dynamic_array(&level.crates, crate_count)
	reserve_dynamic_array(&level.targets, crate_count)

	for i in 0 ..< crate_count {
		append(
			&level.targets,
			new_gridded_sprite(
				math.floor(rand.float32_range(2, 14)),
				math.floor(rand.float32_range(2, 14)),
				assets.red_marker,
			),
		)

		append(
			&level.crates,
			new_gridded_sprite(
				math.floor(rand.float32_range(2, 14)),
				math.floor(rand.float32_range(2, 14)),
				assets.crate_texture,
			),
		)
	}

	return level
}

render_level :: proc(level: ^Level) {
	render_player(&level.player)

	for &crate in level.crates {
		render_sprite(&crate)
	}
}

destroy_level :: proc(level: ^Level) {
	delete(level.crates)
	delete(level.targets)
}
