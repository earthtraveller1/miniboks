package main

import rl "vendor:raylib"

Direction :: enum {
	NEUTRAL,
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

Player :: struct {
	sprite:            Sprite,
	old_position:      rl.Vector2,
	position_progress: f32,
	textures:          struct {
		neutral: rl.Texture,
		up:      rl.Texture,
		down:    rl.Texture,
		right:   rl.Texture,
		left:    rl.Texture,
	},
	has_moved:         bool,
}

new_player :: proc(start_x: f32, start_y: f32, assets: ^Assets) -> Player {
	sprite := Sprite {
		position = {start_x, start_y},
		texture  = assets.player_texture,
	}
	resize_sprite(&sprite, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)

	player := Player {
		sprite = sprite,
        old_position = sprite.position,
        position_progress = 1.0,
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

apply_pushes :: proc(player: ^Player, pushables: []Sprite) {
	position_delta := player.old_position - player.sprite.position

	for &pushable in pushables {
		if pushable.position == player.sprite.position {
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

	old_position = position
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
		apply_pushes(player, moveable_sprites[:])
	}

	player.has_moved = true
    player.position_progress = 0.0
}

interpolate_quad :: proc(a: f32, b: f32, m: f32) -> f32 {
	return a + (b - a) * m * m
}

render_player :: proc(player: ^Player) {
	progress_sprite := player.sprite

	progress_sprite.position.x = interpolate_quad(
		player.old_position.x,
		progress_sprite.position.x,
		player.position_progress,
	)

	progress_sprite.position.y = interpolate_quad(
		player.old_position.y,
		progress_sprite.position.y,
		player.position_progress,
	)

    if player.position_progress < 1.0 {
        player.position_progress += rl.GetFrameTime()*10.0
    }

	render_sprite(&progress_sprite)
}
