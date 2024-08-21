package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

UNIT_SPRITE_SIZE :: 64

Sprite :: struct {
    position: rl.Vector2,
    texture: rl.Texture
}

new_sprite :: proc(x: f32, y: f32, texture_path: cstring) -> Sprite {
    return Sprite {
        position = { x, y },
        texture = rl.LoadTexture(texture_path)
    }
}

render_sprite :: proc(sprite: ^Sprite) {
    rl.DrawTextureV(sprite.texture, sprite.position, rl.WHITE)
}

resize_sprite :: proc(sprite: ^Sprite, newWidth: i32, newHeight: i32) {
    sprite.texture.width = newWidth
    sprite.texture.height = newHeight
}

main :: proc() {
    rl.InitWindow(1280, 1024, "Game")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    floor := new_sprite((1280 - 1024) / 2, 0, "assets/floor.png")
    resize_sprite(&floor, 1024, 1024)

    player := new_sprite(512, 512, "assets/player.png")
    resize_sprite(&player, UNIT_SPRITE_SIZE, UNIT_SPRITE_SIZE)

    for !rl.WindowShouldClose() {
        if rl.IsKeyPressed(.UP) {
            player.position.y -= UNIT_SPRITE_SIZE
        }

        if rl.IsKeyPressed(.DOWN) {
            player.position.y += UNIT_SPRITE_SIZE
        }

        if rl.IsKeyPressed(.RIGHT) {
            player.position.x += UNIT_SPRITE_SIZE
        }

        if rl.IsKeyPressed(.LEFT) {
            player.position.x -= UNIT_SPRITE_SIZE
        }

        rl.BeginDrawing()
        rl.ClearBackground({ 165, 126, 85, 255 })

        render_sprite(&floor)
        render_sprite(&player)

        rl.EndDrawing()
    }
}
