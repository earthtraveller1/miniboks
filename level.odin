package main

Level :: struct {
    sprites: [dynamic]Sprite,
    player: Player
}

render_level :: proc(level: ^Level) {
    render_player(&level.player)

    for &sprite in level.sprites {
        render_sprite(&sprite)
    }
}

destroy_level :: proc(level: ^Level) {
    for &sprite in level.sprites {
        destroy_sprite(&sprite)
    }

    delete(level.sprites)
    destroy_player(&level.player)
}

