; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; レベルの初期化
    ld      a, #0x01
    ld      (gameLevel + GAME_LEVEL_HIGH), a
    xor     a
    ld      (gameLevel + GAME_LEVEL_PLAY), a

    ; フィールドの初期化
    ld      a, #0x01
    ld      (gameFieldBefore), a
    ld      (gameFieldAfter), a

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 状態の設定
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 乱数の更新
    call    _SystemGetRandom
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (gameState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; デバッグの表示
;   call    GamePrintDebug

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; タイトル画面で開始を待つ
;
GameTitle:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; レベルの設定
    xor     a
    ld      (gameLevel + GAME_LEVEL_PLAY), a

    ; パターンネームのクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #(0x02ff)
    xor     a
    ld      (hl), a
    ldir

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ロゴの描画
    ld      hl, #(_appPatternName + 0x012a)
    ld      de, #(_appPatternName + 0x014a)
    ld      bc, #0x0c50
    ld      a, #0x60
10$:
    ld      (hl), c
    ld      (de), a
    inc     hl
    inc     c
    inc     de
    inc     a
    djnz    10$

    ; レベルの描画
    ld      hl, #gameStringHigh
    ld      de, #(_appPatternName + 0x02f4)
    ld      a, (gameLevel + GAME_LEVEL_HIGH)
    call    GameDrawString

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; キー入力の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 99$

    ; 状態の更新
    ld      a, #GAME_STATE_START
    ld      (gameState), a
99$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; レベルの更新
    ld      hl, #(gameLevel + GAME_LEVEL_PLAY)
    ld      a, (hl)
    cp      #GAME_LEVEL_MAX
    jr      nc, 00$
    inc     a
    ld      (hl), a
00$:

    ; フィールドの設定
;   ld      a, (gameLevel + GAME_LEVEL_PLAY)
    ld      hl, #gameField
    cp      #0x60
    jr      nc, 01$
    dec     a
    and     #0x0f
    ld      b, a
    ld      a, #0x10
    sub     b
    ld      b, a
    cp      #0x04
    jr      nc, 02$
01$:
    ld      b, #0x04
02$:
    xor     a
    ld      de, #0x0001
03$:
    ld      (hl), e
    inc     hl
    inc     a
    djnz    03$
04$:
    ld      (hl), d
    inc     hl
    inc     a
    cp      #0x1e
    jr      c, 04$
05$:
    ld      (hl), e
    inc     hl
    inc     a
    cp      #GAME_FIELD_SIZE
    jr      c, 05$

    ; プレイヤの設定
    xor     a
    ld      (gamePlayer + GAME_PLAYER_POSITION_X), a
    ld      (gamePlayer + GAME_PLAYER_MOVE), a
    ld      (gamePlayer + GAME_PLAYER_ANIMATION), a
    ld      a, #0xb7
    ld      (gamePlayer + GAME_PLAYER_POSITION_Y), a

    ; ブロックの設定
06$:
    call    _SystemGetRandom
    and     #0x1f
    cp      #0x16
    jr      nc, 06$
    add     a, #0x04
    add     a, a
    add     a, a
    add     a, a
    ld      (gameBlock + GAME_BLOCK_POSITION_X), a
    ld      a, #-0x08
    ld      (gameBlock + GAME_BLOCK_POSITION_Y), a
    ld      a, #0x01
    ld      (gameBlock + GAME_BLOCK_MOVE), a

    ; パターンネームのクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #(0x02ff)
    xor     a
    ld      (hl), a
    ldir

    ; サウンドの再生
    ld      hl, #gameSoundStart
    ld      (_soundRequest + 0x0000), hl

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; フィールドの描画
    call    GameDrawField

    ; プレイヤの描画
    call    GameDrawPlayer

    ; ブロックの描画
    call    GameDrawBlock

    ; アナウンスの描画
    ld      hl, #gameStringStart
    call    GameDrawAnnounce

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0x0000)
    or      h
    or      l
    jr      nz, 99$

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
99$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; プレイヤの更新
    ld      hl, #(gamePlayer + GAME_PLAYER_POSITION_X)
    ld      de, #(gamePlayer + GAME_PLAYER_MOVE)
    ld      c, #GAME_PLAYER_MOVE_NULL
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 10$
    ld      a, (hl)
    cp      #0xfa
    jr      nc, 12$
    ld      c, #GAME_PLAYER_MOVE_RIGHT
    jr      12$
10$:
    ld      a, (hl)
    or      a
    jr      z, 12$
    ld      a, (de)
    cp      #GAME_PLAYER_MOVE_RIGHT
    jr      nz, 11$
    ld      a, (hl)
    cp      #0xe8
    jr      nc, 11$
    push    hl
    push    de
    srl     a
    srl     a
    srl     a
    add     a, #0x03
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameField
    add     hl, de
    ld      a, #0x01
    ld      (hl), a
    ld      hl, #gameSoundPlug
    ld      (_soundRequest + 0x0006), hl
    pop     de
    pop     hl
11$:
    ld      c, #GAME_PLAYER_MOVE_LEFT
12$:
    ld      a, c
    ld      (de), a
    add     a, (hl)
    ld      (hl), a
    ld      hl, #(gamePlayer + GAME_PLAYER_ANIMATION)
    or      a
    jr      z, 13$
    ld      a, (hl)
    inc     a
13$:
    ld      (hl), a

    ; ブロックの更新
    ld      hl, #(gameBlock + GAME_BLOCK_MOVE)
    dec     (hl)
    jr      nz, 22$
    ld      hl, #(gameBlock + GAME_BLOCK_POSITION_Y)
    ld      a, (hl)
    add     a, #0x02
    ld      (hl), a
    cp      #0xb8
    jr      nz, 21$
    ld      a, (gameBlock + GAME_BLOCK_POSITION_X)
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameField
    add     hl, de
    ld      e, #0x01
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), e
;   inc     hl
20$:
    call    _SystemGetRandom
    and     #0x1f
    cp      #0x16
    jr      nc, 20$
    add     a, #0x04
    add     a, a
    add     a, a
    add     a, a
    ld      (gameBlock + GAME_BLOCK_POSITION_X), a
    ld      a, #-0x08
    ld      (gameBlock + GAME_BLOCK_POSITION_Y), a
21$:
    ld      a, (gameLevel + GAME_LEVEL_PLAY)
    dec     a
    srl     a
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameBlockMoves
    add     hl, de
    ld      a, (hl)
    ld      (gameBlock + GAME_BLOCK_MOVE), a
22$:

    ; フィールドの描画
    call    GameDrawField

    ; プレイヤの描画
    call    GameDrawPlayer

    ; ブロックの描画
    call    GameDrawBlock

    ; アナウンスの描画
    ld      hl, #0x0000
    call    GameDrawAnnounce

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; プレイヤのゴールの監視
    ld      a, (gamePlayer + GAME_PLAYER_POSITION_X)
    cp      #0xfa
    jr      c, 90$

    ; 状態の更新
    ld      a, #GAME_STATE_CLEAR
    ld      (gameState), a
    jr      99$
90$:

    ; プレイヤの落下の監視
    ld      a, (gamePlayer + GAME_PLAYER_POSITION_X)
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameField
    add     hl, de
    ld      a, (hl)
    or      a
    jr      nz, 91$
    ld      a, (gamePlayer + GAME_PLAYER_POSITION_X)
    add     a, #0x05
    srl     a
    srl     a
    srl     a
    ld      e, a
    ld      hl, #gameField
    add     hl, de
    ld      a, (hl)
    or      a
    jr      nz, 91$

    ; 状態の更新
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
;   jr      99$
91$:

    ; プレイヤの監視の終了
99$:    

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; サウンドの再生
    ld      hl, #gameSoundOver
    ld      (_soundRequest + 0x0000), hl

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; プレイヤの落下
    ld      hl, #(gamePlayer + GAME_PLAYER_POSITION_Y)
    ld      a, (hl)
    inc     a
    cp      #0xc8
    jr      nc, 10$
    ld      (hl), a
10$:

    ; フィールドの描画
    call    GameDrawField

    ; プレイヤの描画
    call    GameDrawPlayer

    ; ブロックの描画
;   call    GameDrawBlock

    ; アナウンスの描画
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      z, 20$
    ld      hl, #gameStringOver
20$:
    call    GameDrawAnnounce

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0x0000)
    or      h
    or      l
    jr      nz, 99$

    ; レベルの更新
    ld      a, (gameLevel + GAME_LEVEL_PLAY)
    ld      hl, #(gameLevel + GAME_LEVEL_HIGH)
    cp      (hl)
    jr      c, 90$
    ld      (hl), a
90$:

    ; 状態の更新
    ld      a, #GAME_STATE_TITLE
    ld      (gameState), a
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; サウンドの再生
    ld      hl, #gameSoundClear
    ld      (_soundRequest + 0x0000), hl

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; フィールドの描画
    call    GameDrawField

    ; プレイヤの描画
    call    GameDrawPlayer

    ; ブロックの描画
;   call    GameDrawBlock

    ; アナウンスの描画
    ld      hl, #gameStringClear
    ld      a, (gameLevel + GAME_LEVEL_PLAY)
    cp      #GAME_LEVEL_MAX
    jr      c, 20$
    ld      hl, #gameStringClearAll
20$:
    call    GameDrawAnnounce

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      a, h
    or      l
    ld      hl, (_soundPlay + 0x0000)
    or      h
    or      l
    jr      nz, 99$

    ; レベルの監視
    ld      a, (gameLevel + GAME_LEVEL_PLAY)
    cp      #GAME_LEVEL_MAX
    jr      nc, 90$
    ld      a, #GAME_STATE_START
    jr      92$
90$:
    ld      hl, #(gameLevel + GAME_LEVEL_HIGH)
    cp      (hl)
    jr      c, 91$
    ld      (hl), a
91$:
    ld      a, #GAME_STATE_TITLE
92$:
    ld      (gameState), a

    ; 監視の完了
99$:
    
    ; レジスタの復帰

    ; 終了
    ret

; フィールドを描画する
;
GameDrawField:

    ; レジスタの保存

    ; パターンネームの設定
    ld      hl, #gameField
    ld      de, #(_appPatternName + 0x02e0)
    ld      b, #GAME_FIELD_SIZE
10$:
    ld      a, (hl)
    or      a
    jr      z, 13$
    ld      c, #0x40
    dec     hl
    ld      a, (hl)
    inc     hl
    or      a
    jr      z, 11$
    ld      a, #0x01
    or      c
    ld      c, a
11$:
    inc     hl
    ld      a, (hl)
    dec     hl
    or      a
    jr      z, 12$
    ld      a, #0x02
    or      c
    ld      c, a
12$:
    ld      a, c
13$:
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを描画する
;
GameDrawPlayer:

    ; レジスタの保存

    ; スプライトの設定
    ld      hl, #(_sprite + GAME_SPRITE_PLAYER)
    ld      a, (gamePlayer + GAME_PLAYER_POSITION_Y)
    sub     #0x10
    ld      (hl), a
    inc     hl
    ld      a, (gamePlayer + GAME_PLAYER_POSITION_X)
    ld      (hl), a
    inc     hl
    ld      a, (gamePlayer + GAME_PLAYER_ANIMATION)
    and     #0x0c
    add     a, #0x20
    ld      c, a
    ld      a, (gamePlayer + GAME_PLAYER_MOVE)
    cp      #GAME_PLAYER_MOVE_LEFT
    jr      nz, 10$
    ld      a, #0x10
    add     a, c
    ld      c, a
10$:
    ld      (hl), c
    inc     hl
    ld      a, #0x0f
    ld      (hl), a
;   inc     hl

    ; レジスタの復帰

    ; 終了
    ret

; ブロックを描画する
;
GameDrawBlock:

    ; レジスタの保存

    ; スプライトの設定
    ld      hl, #(_sprite + GAME_SPRITE_BLOCK)
    ld      a, (gameBlock + GAME_BLOCK_POSITION_Y)
    dec     a
    ld      (hl), a
    inc     hl
    ld      a, (gameBlock + GAME_BLOCK_POSITION_X)
    ld      (hl), a
    inc     hl
    ld      a, #0x04
    ld      (hl), a
    inc     hl
    ld      a, #0x0f
    ld      (hl), a
    inc     hl
    ld      a, (gameBlock + GAME_BLOCK_POSITION_Y)
    dec     a
    ld      (hl), a
    inc     hl
    ld      a, (gameBlock + GAME_BLOCK_POSITION_X)
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, #0x08
    ld      (hl), a
    inc     hl
    ld      a, #0x0f
    ld      (hl), a
;   inc     hl

    ; レジスタの復帰

    ; 終了
    ret

; アナウンスを描画する
;
GameDrawAnnounce:

    ; レジスタの保存

    ; 表示業のクリア
    ld      de, #(_appPatternName + 0x0140)
    xor     a
    ld      b, #0x20
10$:
    ld      (de), a
    inc     de
    djnz    10$

    ; 文字列の存在
    ld      a, h
    or      l
    jr      z, 90$

    ; 表示位置の取得
    push    hl
    ld      b, #0x00
20$:
    ld      a, (hl)
    or      a
    jr      z, 21$
    inc     b
    inc     hl
    cp      #'%
    jr      nz, 20$
    inc     b
    jr      20$
21$:
    ld      a, #0x20
    sub     b
    srl     a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_appPatternName + 0x0140)
    add     hl, de
    ex      de, hl
    pop     hl

    ; 文字列の描画
    ld      a, (gameLevel + GAME_LEVEL_PLAY)
    call    GameDrawString

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 文字列を描画する
;
GameDrawString:

    ; レジスタの保存

    ; 文字列の描画
    ld      c, a
10$:
    ld      a, (hl)
    or      a
    jr      z, 19$
    sub     #0x20
    cp      #('% - 0x20)
    jr      nz, 13$
    ld      a, c
    ld      b, #0x00
11$:
    inc     b
    sub     #0x0a
    jr      nc, 11$
    dec     b
    add     a, #0x0a
    push    af
    ld      a, b
    or      a
    jr      nz, 12$
    ld      a, #(0x20 - '0)
12$:
    add     a, #('0 - 0x20)
    ld      (de), a
    inc     de
    pop     af
    add     a, #('0 - 0x20)
13$:
    ld      (de), a
    inc     de
    inc     hl
    jr      10$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; デバッグを表示する
;
GamePrintDebug:

    ; レジスタの保存

    ; デバッグの表示
    ld      hl, #gameDebug
    ld      de, #_appPatternName
    ld      b, #0x10
10$:
    ld      a, (hl)
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, #0x10
    cp      #0x1a
    jr      c, 11$
    add     a, #(0x11 - 0x0a)
11$:
    ld      (de), a
    inc     de
    ld      a, (hl)
    and     #0x0f
    add     a, #0x10
    cp      #0x1a
    jr      c, 12$
    add     a, #(0x11 - 0x0a)
12$:
    ld      (de), a
    inc     de
    inc     hl
    djnz    10$

    ; パターンネームの転送
    ld      hl, #(_appPatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    ld      a, #0x20
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameTitle
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameClear

; ブロック
;
gameBlockMoves:

    .db     0x04, 0x03, 0x02, 0x01, 0x01, 0x01, 0x01, 0x01

; 文字列
;
gameStringHigh:

    .ascii  "MAX LEVEL %"
    .db     0x00

gameStringStart:

    .ascii  "LEVEL %"
    .db     0x00
    
gameStringOver:

    .ascii  "GAME OVER"
    .db     0x00
    
gameStringClear:

    .ascii  "LEVEL % CLEAR"
    .db     0x00
    
gameStringClearAll:

    .ascii  "ALL LEVEL CLEARED!"
    .db     0x00
    
; サウンド
;
gameSoundStart:

    .ascii  "T2V15O4C3R0C2R0C3R2C3E3R0E3G5"
    .db     0x00

gameSoundPlug:

    .ascii  "T1V15O4C3E3D3"
    .db     0x00

gameSoundOver:

    .ascii  "T2V15O4E3D3C3R0E3D3C3R2O3C3D3E3F3R5"
    .db     0x00

gameSoundClear:

    .ascii  "T4V15O4E4D4C5R2F4E4D5R2G4F4E4D4C5R5"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     0x01

; フレーム
;
gameFrame:

    .ds     0x02

; レベル
;
gameLevel:

    .ds     GAME_LEVEL_SIZE

; フィールド
;
gameFieldBefore:

    .ds     0x01

gameField:

    .ds     GAME_FIELD_SIZE

gameFieldAfter:

    .ds     0x01
    
; プレイヤ
;
gamePlayer:

    .ds     GAME_PLAYER_SIZE

; ブロック
;
gameBlock:

    .ds     GAME_BLOCK_SIZE

; デバッグ
;
gameDebug::

    .ds     0x10
