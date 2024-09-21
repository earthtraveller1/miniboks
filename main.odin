package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"

import rl "vendor:raylib"

UNIT_SPRITE_SIZE :: 64
WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 1024

Assets :: struct {
	floor_texture:        rl.Texture,
	crate_texture:        rl.Texture,
	player_texture:       rl.Texture,
	player_up_texture:    rl.Texture,
	player_down_texture:  rl.Texture,
	player_left_texture:  rl.Texture,
	player_right_texture: rl.Texture,
	red_marker:           rl.Texture,
	red_cross:            rl.Texture,
	green_marker:         rl.Texture,
	green_checkmark:      rl.Texture,
}

load_assets :: proc() -> Assets {
	return Assets {
		floor_texture = rl.LoadTexture("assets/floor.png"),
		crate_texture = rl.LoadTexture("assets/crate.png"),
		player_texture = rl.LoadTexture("assets/player.png"),
		player_up_texture = rl.LoadTexture("assets/player-up.png"),
		player_down_texture = rl.LoadTexture("assets/player-down.png"),
		player_left_texture = rl.LoadTexture("assets/player-left.png"),
		player_right_texture = rl.LoadTexture("assets/player-right.png"),
		red_marker = rl.LoadTexture("assets/red-marker.png"),
		red_cross = rl.LoadTexture("assets/red-cross.png"),
		green_marker = rl.LoadTexture("assets/green-marker.png"),
		green_checkmark = rl.LoadTexture("assets/green-checkmark.png"),
	}
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	assets := load_assets()

	floor := new_sprite((WINDOW_WIDTH - 1024) / 2, 0, assets.floor_texture)
	resize_sprite(&floor, 1024, 1024)

	player := new_player(
		(((WINDOW_WIDTH / UNIT_SPRITE_SIZE) - 1) / 2) * UNIT_SPRITE_SIZE,
		(((WINDOW_HEIGHT / UNIT_SPRITE_SIZE) - 1) / 2) * UNIT_SPRITE_SIZE,
		&assets,
	)

	crates: [2]Sprite
	for &crate in crates {
		crate = new_gridded_sprite(
			math.floor(rand.float32_range(2, 14)),
			math.floor(rand.float32_range(2, 14)),
			assets.crate_texture,
		)
	}

	targets: [2]Sprite
	for &target in targets {
		target = new_gridded_sprite(
			math.floor(rand.float32_range(2, 14)),
			math.floor(rand.float32_range(2, 14)),
			assets.red_marker,
		)
	}

	final_target := new_gridded_sprite(10, 2, assets.green_marker)

	camera := rl.Camera2D {
		target   = {0, 0},
		offset   = {0, 0},
		rotation = 0.0,
		zoom     = 1.0,
	}

	game_over := false

	for !rl.WindowShouldClose() {
		if !game_over {
			if rl.IsKeyPressed(.UP) {
				move_player(&player, .UP, crates[:])
			}

			if rl.IsKeyPressed(.DOWN) {
				move_player(&player, .DOWN, crates[:])
			}

			if rl.IsKeyPressed(.RIGHT) {
				move_player(&player, .RIGHT, crates[:])
			}

			if rl.IsKeyPressed(.LEFT) {
				move_player(&player, .LEFT, crates[:])
			}

			if player.sprite.position == final_target.position {
				game_over = true
			}
		}

		rl.BeginDrawing()
		rl.ClearBackground({165, 126, 85, 255})

		rl.BeginMode2D(camera)

		render_sprite(&floor)
		render_player(&player)

		if !player.has_moved {
			for &target in targets {
				render_sprite(&target)
			}

			render_sprite(&final_target)
		}

		for &crate in crates {
			render_sprite(&crate)
		}

		if game_over {
			for crate in crates {
				at_right_spot := false
				for target in targets {
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
				}
			}
		}

		rl.EndMode2D()
		rl.EndDrawing()
	}
}
