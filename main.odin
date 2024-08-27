package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

UNIT_SPRITE_SIZE :: 64
WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 1024

Sprite :: struct {
	position: rl.Vector2,
	texture:  rl.Texture,
}

new_sprite :: proc(x: f32, y: f32, texture: rl.Texture) -> Sprite {
	return Sprite{position = {x, y}, texture = texture}
}

render_sprite :: proc(sprite: ^Sprite) {
	rl.DrawTextureV(sprite.texture, sprite.position, rl.WHITE)
}

resize_sprite :: proc(sprite: ^Sprite, newWidth: i32, newHeight: i32) {
	sprite.texture.width = newWidth
	sprite.texture.height = newHeight
}

destroy_sprite :: proc(sprite: ^Sprite) {
    rl.UnloadTexture(sprite.texture)
}

Assets :: struct {
	floor_texture:        rl.Texture,
	crate_texture:        rl.Texture,
	player_texture:       rl.Texture,
	player_up_texture:    rl.Texture,
	player_down_texture:  rl.Texture,
	player_left_texture:  rl.Texture,
	player_right_texture: rl.Texture,
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
	}
}

Direction :: enum {
	NEUTRAL,
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

Player :: struct {
	sprite:   Sprite,
	textures: struct {
		neutral: rl.Texture,
		up:      rl.Texture,
		down:    rl.Texture,
		right:   rl.Texture,
		left:    rl.Texture,
	},
    has_moved: bool
}

new_player :: proc(start_x: f32, start_y: f32, assets: ^Assets) -> Player {
	sprite := Sprite {
		position = {start_x, start_y},
		texture  = assets.player_texture,
	}
	resize_sprite(&sprite, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)

	player := Player {
		sprite = sprite,
		textures = {
			neutral = assets.player_texture,
			up = assets.player_up_texture,
			down = assets.player_down_texture,
			right = assets.player_right_texture,
			left = assets.player_left_texture,
		},
	}

	player.textures.neutral.width = UNIT_SPRITE_SIZE
	player.textures.neutral.height = UNIT_SPRITE_SIZE
	player.textures.up.width = UNIT_SPRITE_SIZE
	player.textures.up.height = UNIT_SPRITE_SIZE
	player.textures.down.width = UNIT_SPRITE_SIZE
	player.textures.down.height = UNIT_SPRITE_SIZE
	player.textures.right.width = UNIT_SPRITE_SIZE
	player.textures.right.height = UNIT_SPRITE_SIZE
	player.textures.left.width = UNIT_SPRITE_SIZE
	player.textures.left.height = UNIT_SPRITE_SIZE

	return player
}

apply_pushes :: proc(sprite: ^Sprite, old_position: rl.Vector2, pushables: []Sprite) {
	position_delta := old_position - sprite.position

	for &pushable in pushables {
		if pushable.position == sprite.position {
			pushable.position -= position_delta
		}
	}
}

is_sprite_present :: proc(position: rl.Vector2, sprites: []Sprite) -> bool {
	for sprite in sprites {
		if sprite.position == position {
			return true
		}
	}

	return false
}

move_player :: proc(player: ^Player, direction: Direction, moveable_sprites: []Sprite) {
	using player.sprite
	using player

	old_position := position
	position_change: rl.Vector2

	switch direction {
	case .UP:
		position_change = {0, -f32(texture.height)}
		texture = textures.up
	case .DOWN:
		position_change = {0, f32(texture.height)}
		texture = textures.down
	case .LEFT:
		position_change = {-f32(texture.width), 0}
		texture = textures.left
	case .RIGHT:
		position_change = {f32(texture.width), 0}
		texture = textures.right
	case .NEUTRAL:
		texture = textures.neutral
	}

	if !is_sprite_present(position + position_change, moveable_sprites) ||
	   !is_sprite_present(position + position_change * 2, moveable_sprites) {
		position += position_change
		apply_pushes(&sprite, old_position, moveable_sprites[:])
	}

    player.has_moved = true
}

render_player :: proc(player: ^Player) {
	render_sprite(&player.sprite)
}

destroy_player :: proc(player: ^Player) {
    destroy_sprite(&player.sprite)

    rl.UnloadTexture(player.textures.up)
    rl.UnloadTexture(player.textures.down)
    rl.UnloadTexture(player.textures.right)
    rl.UnloadTexture(player.textures.left)
    rl.UnloadTexture(player.textures.neutral)
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	assets := load_assets()

	floor := new_sprite((WINDOW_WIDTH - 1024) / 2, 0, assets.floor_texture)
    defer destroy_sprite(&floor)
	resize_sprite(&floor, 1024, 1024)

	player := new_player(512, 512, &assets)
    defer destroy_player(&player)

	crates: [5]Sprite = {
		new_sprite(UNIT_SPRITE_SIZE * 2, UNIT_SPRITE_SIZE * 4, assets.crate_texture),
		new_sprite(UNIT_SPRITE_SIZE * 10, UNIT_SPRITE_SIZE * 6, assets.crate_texture),
		new_sprite(UNIT_SPRITE_SIZE * 5, UNIT_SPRITE_SIZE * 9, assets.crate_texture),
		new_sprite(UNIT_SPRITE_SIZE * 16, UNIT_SPRITE_SIZE * 8, assets.crate_texture),
		new_sprite(UNIT_SPRITE_SIZE * 4, UNIT_SPRITE_SIZE * 15, assets.crate_texture),
	}
    defer for &crate in crates {
        destroy_sprite(&crate)
    }

	for &crate in crates {
		resize_sprite(&crate, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)
	}

	camera := rl.Camera2D {
		target   = {0, 0},
		offset   = {0, 0},
		rotation = 0.0,
		zoom     = 1.0,
	}

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

		for &crate in crates {
			render_sprite(&crate)
		}

        rl.EndMode2D()
		rl.EndDrawing()
	}
}
