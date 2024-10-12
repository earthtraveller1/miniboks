package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"

import rl "vendor:raylib"

Level :: struct {
	crates:       [dynamic]Sprite,
	targets:      [dynamic]Sprite,
	game_over:    bool,
	final_target: Sprite,
	player:       Player,
	has_won:      bool,
	timer:        f32,
}

new_level :: proc(crate_count: u32, assets: ^Assets) -> Level {
	level := Level{}
	reserve_dynamic_array(&level.crates, crate_count)
	reserve_dynamic_array(&level.targets, crate_count)

	level.final_target = new_gridded_sprite(7, 7, assets.green_marker)

	level.player = new_player(
		(((WINDOW_WIDTH / UNIT_SPRITE_SIZE) - 1) / 2) * UNIT_SPRITE_SIZE,
		(((WINDOW_HEIGHT / UNIT_SPRITE_SIZE) - 1) / 2) * UNIT_SPRITE_SIZE,
		assets,
	)

	level.game_over = false
    level.timer = 0

	for i in 0 ..< crate_count {
		target_x := math.floor(rand.float32_range(2, 14))
		target_y := math.floor(rand.float32_range(2, 14))

		for {
			already_exists := false

			for target in level.targets {
				if target.position.x == target_x && target.position.y == target_y {
					already_exists = true
				}
			}

			if already_exists {
				target_x = math.floor(rand.float32_range(2, 14))
				target_y = math.floor(rand.float32_range(2, 14))
			} else {
				break
			}
		}

		crate_x := math.floor(rand.float32_range(2, 14))
		crate_y := math.floor(rand.float32_range(2, 14))

		for {
			already_exists := false

			for crate in level.crates {
				if crate.position.x == crate_x && crate.position.y == crate_y {
					already_exists = true
				}
			}

			if already_exists {
				crate_x = math.floor(rand.float32_range(2, 14))
				crate_y = math.floor(rand.float32_range(2, 14))
			} else {
				break
			}
		}

		append(&level.targets, new_gridded_sprite(target_x, target_y, assets.red_marker))
		append(&level.crates, new_gridded_sprite(crate_x, crate_y, assets.crate_texture))
	}

	return level
}

update_level :: proc(level: ^Level) {
	if !level.game_over {
		if rl.IsKeyPressed(.UP) {
			move_player(&level.player, .UP, level.crates[:])
		}

		if rl.IsKeyPressed(.DOWN) {
			move_player(&level.player, .DOWN, level.crates[:])
		}

		if rl.IsKeyPressed(.RIGHT) {
			move_player(&level.player, .RIGHT, level.crates[:])
		}

		if rl.IsKeyPressed(.LEFT) {
			move_player(&level.player, .LEFT, level.crates[:])
		}

		if level.player.sprite.position == level.final_target.position {
			level.game_over = true
		}

        level.timer += rl.GetFrameTime()
	}
}

render_level :: proc(level: ^Level, assets: ^Assets) {
	render_player(&level.player)

	if !level.player.has_moved {
		for &target in level.targets {
			render_sprite(&target)
		}

		render_sprite(&level.final_target)
	}

	for &crate in level.crates {
		render_sprite_animated(&crate, UNIT_ANIMATION_SPEED)
	}

	if level.game_over {
		level.has_won = true

		for crate in level.crates {
			at_right_spot := false
			for target in level.targets {
				if crate.position == target.position {
					at_right_spot = true
					break
				}
			}

			if at_right_spot {
				checkmark := new_sprite_v(crate.position, assets.green_checkmark)
				resize_sprite(&checkmark, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)
				render_sprite(&checkmark)
			} else {
				cross := new_sprite_v(crate.position, assets.red_cross)
				resize_sprite(&cross, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)
				render_sprite(&cross)

				level.has_won = false
			}
		}
	}

	time := level.timer
	minutes := math.floor(time / 60)
	seconds := i32(time) % 60

	builder := strings.Builder{}
	defer strings.builder_destroy(&builder)
	fmt.sbprintf(&builder, "%d:%2d", i32(minutes), i32(seconds))

	text_width := rl.MeasureText(strings.to_cstring(&builder), 64)
	rl.DrawText(strings.to_cstring(&builder), (WINDOW_WIDTH - text_width) / 2, 8, 64, rl.WHITE)
}

destroy_level :: proc(level: ^Level) {
	delete(level.crates)
	delete(level.targets)
}
