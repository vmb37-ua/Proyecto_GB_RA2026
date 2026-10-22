INCLUDE "engine/hardware.inc"
INCLUDE "game.inc"
SECTION "Scene: menu and results", ROM0
scene_menu::
    db SCENE_MENU
    dw scene_menu_init, scene_wait_start
scene_win::
    db SCENE_WIN
    dw scene_win_init, scene_result_update
scene_gameover::
    db SCENE_GAMEOVER
    dw scene_gameover_init, scene_result_update
scene_menu_init::
    call bg_clear
    ld de, .title
    ld hl, bg_buffer + 3 * 32 + 4
    call text_draw
    ld de, .instructions
    ld hl, bg_buffer + 6 * 32 + 1
    call text_draw
    ld de, .buy
    ld hl, bg_buffer + 8 * 32 + 1
    call text_draw
    ld de, .cancel
    ld hl, bg_buffer + 10 * 32 + 1
    call text_draw
    ld de, .pause
    ld hl, bg_buffer + 12 * 32 + 1
    call text_draw
    jp scene_prompt
.title db "MOI GRUPPA TD", 0
.instructions db "DPAD MOVE", 0
.buy db "A CHOOSE AND BUY", 0
.cancel db "B CANCEL", 0
.pause db "START PAUSE", 0
scene_prompt:
    ld de, .text
    ld hl, bg_buffer + 15 * 32 + 4
    jp text_draw
.text db "PRESS START", 0
scene_wait_start::
    ld a, [input_pressed]
    bit BTN_START, a
    ret z
    ld hl, scene_game
    jp scene_change
scene_win_init::
    call bg_clear
    ld de, .text
    ld hl, bg_buffer + 6 * 32 + 5
    call text_draw
    jp scene_result_prompt
.text db "YOU WIN", 0
scene_gameover_init::
    call bg_clear
    ld de, .text
    ld hl, bg_buffer + 6 * 32 + 5
    call text_draw
    jp scene_result_prompt
.text db "GAME OVER", 0
scene_result_prompt:
    call scene_prompt
    ld de, .text
    ld hl, bg_buffer + 12 * 32 + 3
    jp text_draw
.text db "B BACK TO MENU", 0
scene_result_update::
    ld a, [input_pressed]
    bit BTN_B, a
    jp z, scene_wait_start
    ld hl, scene_menu
    jp scene_change
