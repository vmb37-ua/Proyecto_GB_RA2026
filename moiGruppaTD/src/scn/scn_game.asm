INCLUDE "game.inc"
SECTION "Scene: game", ROM0
scene_game::
    db SCENE_GAME
    dw scene_game_init, scene_game_update
scene_game_init::
    call game_init
    jp bg_game_init
;; La escena decide el ORDEN; cada sistema gestiona su propia tarea.
scene_game_update::
    call sys_input_update
    ld a, [wPaused]
    and a
    ret nz
    ld hl, wMessageTimer
    ld a, [hl]
    and a
    jr z, .simulation
    dec [hl]
.simulation
    call sys_income_update
    call sys_spawn_update
    call sys_attack_update
    call sys_physics_update
    call sys_collision_update
    jp game_check_end
