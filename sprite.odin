package main

import "core:fmt"
import rl "vendor:raylib"

Sprite :: struct {
	position:           rl.Vector2,
	old_position:       rl.Vector2,
	animation_progress: f32,
	animation_phase:    u32,
	texture:            rl.Texture,
}

new_sprite :: proc(x: f32, y: f32, texture: rl.Texture) -> Sprite {
	return Sprite{position = {x, y}, old_position = {x, y}, texture = texture}
}

new_sprite_v :: proc(position: rl.Vector2, texture: rl.Texture) -> Sprite {
	return new_sprite(position.x, position.y, texture)
}

new_gridded_sprite :: proc(gridded_x: f32, gridded_y: f32, texture: rl.Texture) -> Sprite {
	sprite := new_sprite(gridded_x * UNIT_SPRITE_SIZE, gridded_y * UNIT_SPRITE_SIZE, texture)
	resize_sprite(&sprite, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)
	return sprite
}

new_gridded_sprite_v :: proc(gridded_position: rl.Vector2, texture: rl.Texture) -> Sprite {
	return new_gridded_sprite(gridded_position.x, gridded_position.y, texture)
}

render_sprite :: proc(sprite: ^Sprite) {
	rl.DrawTextureV(sprite.texture, sprite.position, rl.WHITE)
}

render_sprite_at_offset :: proc(sprite: ^Sprite, x_offset: f32, y_offset: f32) {
	rl.DrawTextureV(sprite.texture, sprite.position + {x_offset, y_offset}, rl.WHITE)
}

render_sprite_at_offset_v :: proc(sprite: ^Sprite, offset: rl.Vector2) {
	rl.DrawTextureV(sprite.texture, sprite.position + offset, rl.WHITE)
}

render_sprite_animated_position :: proc(sprite: ^Sprite, speed: f32) {
	animated_position := rl.Vector2 {
		interpolate_quad(sprite.old_position.x, sprite.position.x, sprite.animation_progress),
		interpolate_quad(sprite.old_position.y, sprite.position.y, sprite.animation_progress),
	}

	if sprite.animation_progress < 1.0 {
		sprite.animation_progress += rl.GetFrameTime() * speed
	}

	rl.DrawTextureV(sprite.texture, animated_position, rl.WHITE)
}

render_sprite_animated_opacity :: proc(sprite: ^Sprite, speed: f32) {
    LOWER_OPACITY :: 64
    UPPER_OPACITY :: 255

    animated_opacity: f32
    if sprite.animation_phase == 0 {
        animated_opacity = interpolate_quad(LOWER_OPACITY, UPPER_OPACITY, sprite.animation_progress)
    } else if sprite.animation_phase == 1 {
        animated_opacity = interpolate_quad(UPPER_OPACITY, LOWER_OPACITY, sprite.animation_progress)
    }

	if sprite.animation_progress < 1.0 {
		sprite.animation_progress += rl.GetFrameTime() * speed
	}

	tint := rl.Color{255, 255, 255, u8(animated_opacity)}
	rl.DrawTextureV(sprite.texture, sprite.position, tint)
}

resize_sprite :: proc(sprite: ^Sprite, newWidth: i32, newHeight: i32) {
	sprite.texture.width = newWidth
	sprite.texture.height = newHeight
}

