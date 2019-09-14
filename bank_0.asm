
text1:
    .db "Welcome to the jungle baby      "
    .db "You're gonna die!               "
    .db "                                "
    .db "Welcome to the jungle           "
    .db "We've  got fun and games        "
    .db "We got everything you want honey"
    .db "But we know the names           "
    .db "We are the people who can find  "
text2:
    .db "Whatever you may need           "
    .db "If you got the money, honey     "
    .db "We got your disease             "
    .db "In the jungle                   "
    .db "Welcome to the jungle           "
    .db "Watch it bring you to your      "
    .db "shananananananana knees, knees  "
    .db "Ooh I, I wanna watch you bleed  "


pal1:              ; Bright color palette                      ;;
    .db $0f,$11,$16,$15 ; Background colors                         ;;
    .db $0f,$11,$1B,$11                                             ;;
    .db $0f,$11,$13,$11                                             ;;
    .db $0f,$11,$30,$30                                             ;;
    .db $0f,$13,$12,$11 ; Sprite colors                             ;;
    .db $0f,$1C,$1B,$1A                                             ;;
    .db $0f,$19,$18,$17                                             ;;
    .db $0f,$16,$15,$14

b0_reset:
        jmp reset

    .pad $bffe,$ff

    .word b0_reset
