package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"

import rl "vendor:raylib"

UNIT_SPRITE_SIZE :: 64
UNIT_ANIMATION_SPEED :: 10
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

unload_assets :: proc(assets: ^Assets) {
	rl.UnloadTexture(assets.floor_texture)
	rl.UnloadTexture(assets.crate_texture)
	rl.UnloadTexture(assets.player_texture)
	rl.UnloadTexture(assets.player_up_texture)
	rl.UnloadTexture(assets.player_down_texture)
	rl.UnloadTexture(assets.player_left_texture)
	rl.UnloadTexture(assets.player_right_texture)
	rl.UnloadTexture(assets.red_marker)
	rl.UnloadTexture(assets.red_cross)
	rl.UnloadTexture(assets.green_marker)
	rl.UnloadTexture(assets.green_checkmark)
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "MiniBoks")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	assets := load_assets()
    defer unload_assets(&assets)

	floor := new_sprite((WINDOW_WIDTH - 1024) / 2, 0, assets.floor_texture)
	resize_sprite(&floor, 1024, 1024)

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    main_music := rl.LoadMusicStream("assets/mainmenu.ogg")
    defer rl.UnloadMusicStream(main_music)

    rl.PlayMusicStream(main_music)

    level_crate_count: u32 = 1
    next_level_timer: f32 = 3.0

    level := new_level(level_crate_count, &assets)

	for !rl.WindowShouldClose() {
        update_level(&level)

        if level.game_over {
            next_level_timer -= rl.GetFrameTime()

            if next_level_timer <= 0.0 {
                if level.has_won {
                    level_crate_count += 1
                }

                level = new_level(level_crate_count, &assets)
                next_level_timer = 3.0
            }
        }

        rl.UpdateMusicStream(main_music)

		rl.BeginDrawing()
		rl.ClearBackground({165, 126, 85, 255})

        render_sprite(&floor)
        render_level(&level, &assets)

		rl.EndDrawing()
	}
}
