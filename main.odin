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


MAIN_MENU_FONT_SIZE :: 128

MainMenu :: struct {
	play_button_rectangle: rl.Rectangle,
    player_element: Sprite,
    crate_element: Sprite
}

new_main_menu :: proc(assets: ^Assets) -> MainMenu {
	text_width := rl.MeasureText("PLAY", MAIN_MENU_FONT_SIZE)
    player_element := new_sprite(650, 512, assets.player_texture)
    resize_sprite(&player_element, 400, 400)
    crate_element := new_sprite(800, 140, assets.crate_texture)
    resize_sprite(&crate_element, 300, 300)

	return MainMenu {
		play_button_rectangle = rl.Rectangle {
			x = 128,
			y = 512,
			width = f32(text_width),
			height = MAIN_MENU_FONT_SIZE,
		},
        player_element = player_element,
        crate_element = crate_element,
	}
}

render_main_menu :: proc(main_menu: ^MainMenu) {
    rl.BeginDrawing()
    
	color: rl.Color
	if is_cursor_within_rect(main_menu.play_button_rectangle) {
		color = rl.WHITE
	} else {
		color = rl.GetColor(0xAAAAAAAA)
	}

	rl.ClearBackground({165, 126, 85, 255})

	// rl.DrawRectangleRec(rectangle, color)
	rl.DrawText(
		"PLAY",
		i32(main_menu.play_button_rectangle.x),
		i32(main_menu.play_button_rectangle.y),
		MAIN_MENU_FONT_SIZE,
		color,
	)

    rl.DrawText("MiniBoks", 128, 128, 128, rl.LIGHTGRAY)

    mouse_position := rl.GetMousePosition()

    render_sprite_at_offset_v(&main_menu.crate_element, mouse_position * 0.05)
    render_sprite_at_offset_v(&main_menu.player_element, -mouse_position * 0.1)

    rl.EndDrawing()
}

is_cursor_within_rect :: proc(rect: rl.Rectangle) -> bool {
	mouse := rl.GetMousePosition()

	left_bound := rect.x
	right_bound := rect.x + rect.width
	upper_bound := rect.y
	lower_bound := rect.y + rect.height

	within_x_bound := mouse.x >= left_bound && mouse.x <= right_bound
	within_y_bound := mouse.y >= upper_bound && mouse.y <= lower_bound

	return within_x_bound && within_y_bound
}

update_main_menu :: proc(main_menu: ^MainMenu) -> bool {
    if is_cursor_within_rect(main_menu.play_button_rectangle) {
        return rl.IsMouseButtonReleased(.LEFT)
    } else {
        return false
    }
}

GameScene :: struct {
	floor:             Sprite,
	level:             Level,
	level_crate_count: u32,
	next_level_timer:  f32,
}

new_game_scene :: proc(assets: ^Assets) -> GameScene {
	floor := new_sprite((WINDOW_WIDTH - 1024) / 2, 0, assets.floor_texture)
	resize_sprite(&floor, 1024, 1024)

	level_crate_count: u32 = 1
	next_level_timer: f32 = 3.0

	level := new_level(level_crate_count, assets)

	return GameScene {
		floor = floor,
		level = level,
		level_crate_count = level_crate_count,
		next_level_timer = next_level_timer,
	}
}

update_game_scene :: proc(scene: ^GameScene, assets: ^Assets) {
	using scene

	update_level(&level)

	if level.game_over {
		next_level_timer -= rl.GetFrameTime()

		if next_level_timer <= 0.0 {
			if level.has_won {
				level_crate_count += 1
			}

			level = new_level(level_crate_count, assets)
			next_level_timer = 3.0
		}
	}

	rl.BeginDrawing()
	rl.ClearBackground({165, 126, 85, 255})

	render_sprite(&floor)
	render_level(&level, assets)

	rl.EndDrawing()

}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "MiniBoks")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	assets := load_assets()
	defer unload_assets(&assets)

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	main_music := rl.LoadMusicStream("assets/mainmenu.ogg")
	defer rl.UnloadMusicStream(main_music)

	rl.PlayMusicStream(main_music)

	at_main_menu := true
	game_scene := new_game_scene(&assets)
    main_menu := new_main_menu(&assets)

	for !rl.WindowShouldClose() {
		rl.UpdateMusicStream(main_music)

		if !at_main_menu {
			update_game_scene(&game_scene, &assets)
		} else {
			if update_main_menu(&main_menu) {
				at_main_menu = false
			}

			render_main_menu(&main_menu)
		}
	}
}
