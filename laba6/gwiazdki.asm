; Program: gwiazdki.asm


rozkazy SEGMENT
    ASSUME CS:rozkazy, DS:rozkazy

; --- ZMIENNE ---
pozycja     dw 2000     ; Adres na ekranie (œrodek ekranu)
stare_tlo   dw 0        ; Tu przechowamy znak i kolor, który by³ pod gwiazdk¹

zacznij:
    mov ax, rozkazy
    mov ds, ax

    ; Ustawienie trybu tekstowego 80x25
    mov ax, 3
    int 10h

    ; ES na pamiêæ ekranu (B800h)
    mov ax, 0B800h
    mov es, ax

    ; Zapisanie t³a pod pierwsz¹ gwiazdk¹ i narysowanie jej
    mov bx, cs:pozycja
    mov ax, es:[bx]
    mov cs:stare_tlo, ax
    
    mov byte PTR es:[bx], '*'
    mov byte PTR es:[bx+1], 0Eh ; kolor ¿ó³ty

petla_klawiszy:
    ; Czekanie na naciœniêcie klawisza (BIOS int 16h, ah=0)
    mov ah, 0
    int 16h

    ; Sprawdzenie 'X' lub 'x' -> Wyjœcie
    cmp al, 'x'
    je go_koniec
    cmp al, 'X'
    je go_koniec

    ; Sprawdzenie klawiszy kierunkowych (R, L, U, D)
    cmp al, 'r'
    je go_prawo
    cmp al, 'R'
    je go_prawo
    cmp al, 'l'
    je go_lewo
    cmp al, 'L'
    je go_lewo
    cmp al, 'u'
    je go_gora
    cmp al, 'U'
    je go_gora
    cmp al, 'd'
    je go_dol
    cmp al, 'D'
    je go_dol

    jmp petla_klawiszy ; Inny klawisz -> ignoruj

; Mostki dla skoków 
go_koniec: jmp koniec
go_prawo:  jmp ruch_prawo
go_lewo:   jmp ruch_lewo
go_gora:   jmp ruch_gora
go_dol:    jmp ruch_dol

ruch_prawo:
    mov bx, cs:pozycja
    mov ax, bx
    mov dl, 160
    div dl
    cmp ah, 158         ; Sprawdzenie prawej krawêdzi
    jae p_mostek
    call przywroc_tlo
    add bx, 2
    call narysuj_nowa
    jmp petla_klawiszy

ruch_lewo:
    mov bx, cs:pozycja
    mov ax, bx
    mov dl, 160
    div dl
    cmp ah, 0           ; Sprawdzenie lewej krawêdzi
    je p_mostek
    call przywroc_tlo
    sub bx, 2
    call narysuj_nowa
    jmp petla_klawiszy

ruch_gora:
    mov bx, cs:pozycja
    cmp bx, 160         ; Sprawdzenie górnej krawêdzi
    jb p_mostek
    call przywroc_tlo
    sub bx, 160
    call narysuj_nowa
    jmp petla_klawiszy

ruch_dol:
    mov bx, cs:pozycja
    cmp bx, 3840        ; Sprawdzenie dolnej krawêdzi
    jae p_mostek
    call przywroc_tlo
    add bx, 160
    call narysuj_nowa
p_mostek: jmp petla_klawiszy

koniec:
    ; Odtworzenie t³a przed wyjœciem (usuwamy gwiazdkê)
    mov bx, cs:pozycja
    mov ax, cs:stare_tlo
    mov es:[bx], ax
    
    mov ax, 4C00h
    int 21h

; --- PROCEDURY ---

przywroc_tlo PROC
    mov ax, cs:stare_tlo
    mov es:[bx], ax     ; Wstawienie oryginalnego znaku i koloru z powrotem
    ret
przywroc_tlo ENDP

narysuj_nowa PROC
    mov cs:pozycja, bx  ; Zapamiêtanie nowej pozycji
    mov ax, es:[bx]     ; Pobranie oryginalnego t³a z nowego miejsca
    mov cs:stare_tlo, ax
    mov byte PTR es:[bx], '*'
    mov byte PTR es:[bx+1], 0Eh
    ret
narysuj_nowa ENDP

rozkazy ENDS
END zacznij