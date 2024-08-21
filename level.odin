package main

Level :: struct {
    sprites: [dynamic]Sprite,
    player: Sprite
}

render_level :: proc(level: ^Level) {
    render_sprite(&level.player)

    for &sprite in level.sprites {
        render_sprite(&sprite)
    }
}

