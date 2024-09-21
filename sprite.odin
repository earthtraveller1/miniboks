package main

import rl "vendor:raylib"

Sprite :: struct {
	position: rl.Vector2,
	texture:  rl.Texture,
}

new_sprite :: proc(x: f32, y: f32, texture: rl.Texture) -> Sprite {
	return Sprite{position = {x, y}, texture = texture}
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

resize_sprite :: proc(sprite: ^Sprite, newWidth: i32, newHeight: i32) {
	sprite.texture.width = newWidth
	sprite.texture.height = newHeight
}
