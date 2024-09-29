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
	sprite := new_sprite(start_x, start_y, assets.player_texture)
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

apply_pushes :: proc(player: ^Player, pushables: []Sprite) {
	position_delta := player.sprite.old_position - player.sprite.position

	for &pushable in pushables {
		if pushable.position == player.sprite.position {
            pushable.old_position = pushable.position
			pushable.position -= position_delta
            pushable.animation_progress = 0
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
    player.sprite.animation_progress = 0
}

interpolate_quad :: proc(a: f32, b: f32, m: f32) -> f32 {
	return a + (b - a) * m * m
}

render_player :: proc(player: ^Player) {
	render_sprite_animated(&player.sprite, UNIT_ANIMATION_SPEED)
}
