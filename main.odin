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
	defer destroy_sprite(&floor)
	resize_sprite(&floor, 1024, 1024)

	player := new_player(
		(((WINDOW_WIDTH / UNIT_SPRITE_SIZE) - 1) / 2) * UNIT_SPRITE_SIZE,
		(((WINDOW_HEIGHT / UNIT_SPRITE_SIZE) - 1) / 2) * UNIT_SPRITE_SIZE,
		&assets,
	)
	defer destroy_player(&player)

	crates: [2]Sprite
	for &crate in crates {
		crate = new_gridded_sprite(
			math.floor(rand.float32_range(2, 14)),
			math.floor(rand.float32_range(2, 14)),
			assets.crate_texture,
		)
	}

	defer for &crate in crates {
		destroy_sprite(&crate)
	}

	targets: [2]Sprite
	for &target in targets {
		target = new_gridded_sprite(
			math.floor(rand.float32_range(2, 14)),
			math.floor(rand.float32_range(2, 14)),
			assets.red_marker,
		)
	}

	defer for &target in targets {
		destroy_sprite(&target)
	}

	final_target := new_gridded_sprite(10, 2, assets.green_marker)
	defer destroy_sprite(&final_target)

	camera := rl.Camera2D {
		target   = {0, 0},
		offset   = {0, 0},
		rotation = 0.0,
		zoom     = 1.0,
	}

	game_over := false

	for !rl.WindowShouldClose() {
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

		rl.EndMode2D()
		rl.EndDrawing()
	}
}
