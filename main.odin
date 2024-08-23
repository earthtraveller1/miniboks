package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

UNIT_SPRITE_SIZE :: 64

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
	sprite:    Sprite,
	textures:  struct {
		neutral: rl.Texture,
		up:      rl.Texture,
		down:    rl.Texture,
		right:   rl.Texture,
		left:    rl.Texture,
	},
}

new_player :: proc(start_x: f32, start_y: f32, assets: ^Assets) -> Player {
    sprite := Sprite{position = {start_x, start_y}, texture = assets.player_texture}
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

move_player :: proc(player: ^Player, direction: Direction) {
	using player.sprite
    using player

	switch direction {
	case .UP:
		position.y -= f32(texture.height)
        texture = textures.up
	case .DOWN:
		position.y += f32(texture.height)
        texture = textures.down
	case .LEFT:
		position.x -= f32(texture.width)
        texture = textures.left
	case .RIGHT:
		position.x += f32(texture.width)
        texture = textures.right
	case .NEUTRAL:
        texture = textures.neutral
	}
}

render_player :: proc(player: ^Player) {
    render_sprite(&player.sprite)
}

main :: proc() {
	rl.InitWindow(1280, 1024, "Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	assets := load_assets()

	floor := new_sprite((1280 - 1024) / 2, 0, assets.floor_texture)
	resize_sprite(&floor, 1024, 1024)

    player := new_player(512, 512, &assets)

    crates: [5]Sprite = {
        new_sprite(UNIT_SPRITE_SIZE * 2, UNIT_SPRITE_SIZE * 4, assets.crate_texture),
        new_sprite(UNIT_SPRITE_SIZE * 3, UNIT_SPRITE_SIZE * 6, assets.crate_texture),
        new_sprite(UNIT_SPRITE_SIZE * 5, UNIT_SPRITE_SIZE * 4, assets.crate_texture),
        new_sprite(UNIT_SPRITE_SIZE * 1, UNIT_SPRITE_SIZE * 8, assets.crate_texture),
        new_sprite(UNIT_SPRITE_SIZE * 4, UNIT_SPRITE_SIZE * 4, assets.crate_texture),
    }

    for &crate in crates {
        resize_sprite(&crate, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)
    }


	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.UP) {
            move_player(&player, .UP)
		}

		if rl.IsKeyPressed(.DOWN) {
            move_player(&player, .DOWN)
		}

		if rl.IsKeyPressed(.RIGHT) {
            move_player(&player, .RIGHT)
		}

		if rl.IsKeyPressed(.LEFT) {
            move_player(&player, .LEFT)
		}

		rl.BeginDrawing()
		rl.ClearBackground({165, 126, 85, 255})

		render_sprite(&floor)
		render_player(&player)

        for &crate in crates {
            render_sprite(&crate)
        }

		rl.EndDrawing()
	}
}
