; Game.inc : ゲーム
;


; マクロの定義
;

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_TITLE                =   0x10
GAME_STATE_START                =   0x20
GAME_STATE_PLAY                 =   0x30
GAME_STATE_OVER                 =   0x40
GAME_STATE_CLEAR                =   0x50

; スプライト
GAME_SPRITE_PLAYER              =   0x00
GAME_SPRITE_BLOCK               =   0x10

; レベル
GAME_LEVEL_MAX                  =   0x63
GAME_LEVEL_HIGH                 =   0x00
GAME_LEVEL_PLAY                 =   0x01
GAME_LEVEL_SIZE                 =   0x02

; フィールド
GAME_FIELD_SIZE                 =   0x20

; プレイヤ
GAME_PLAYER_POSITION_X          =   0x00
GAME_PLAYER_POSITION_Y          =   0x01
GAME_PLAYER_MOVE                =   0x02
GAME_PLAYER_ANIMATION           =   0x03
GAME_PLAYER_SIZE                =   0x04
GAME_PLAYER_MOVE_NULL           =   (+0x00)
GAME_PLAYER_MOVE_RIGHT          =   (+0x02)
GAME_PLAYER_MOVE_LEFT           =   (-0x02)

; ブロック
GAME_BLOCK_POSITION_X           =   0x00
GAME_BLOCK_POSITION_Y           =   0x01
GAME_BLOCK_MOVE                 =   0x02
GAME_BLOCK_SIZE                 =   0x03

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

