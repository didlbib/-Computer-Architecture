.686
.model flat
extern  _ExitProcess@4 : PROC
extern  __write : PROC ; (dwa znaki podkreœlenia)
extern  __read  : PROC ; (dwa znaki podkreœlenia)
extern  _MessageBoxW@16 : PROC
public  _main


.data
tekst_pocz db 10, 'Prosze napisac jakis tekst '
           db 'i nacisnac Enter', 10
koniec_t   db ?
magazyn    db 80 dup (?) ; Bufor na 80 znaków
nowa_linia    db 10
liczba_znakow dd ?
tytul dw 'W','c','z','y','t','a','n','y',' ', 't','e','k','s', 't',0 ; <-- tytu³ okienka MessageBox


tekst_wide dw 80 dup(0)


.code
;OPTION JUMPS:NEAR

_main   PROC


; wyœwietlenie tekstu informacyjnego

; liczba znaków tekstu
    mov     ecx,(OFFSET koniec_t) - (OFFSET tekst_pocz)
    push    ecx

    push    OFFSET tekst_pocz  ; adres tekstu
    push    1  ; nr urz¹dzenia (tu: ekran - nr 1)
    call    __write  ; wyœwietlenie tekstu pocz¹tkowego

    add     esp, 12  ; usuniecie parametrów ze stosu

; czytanie wiersza z klawiatury
    push    80 ; maksymalna liczba znaków
    push    OFFSET magazyn
    push    0  ; nr urz¹dzenia (tu: klawiatura - nr 0)
    call    __read ; czytanie znaków z klawiatury
    add     esp, 12 ; usuniecie parametrów ze stosu

    mov     liczba_znakow, eax
    mov     ecx, eax
    mov     ebx, 0  ; indeks pocz¹tkowy



    xor     esi, esi        
    mov     edi, 0          

    cmp     ecx, 0
    je      after_letters_scan

scan_loop:
    mov     dl, magazyn[ebx]

   
    cmp     dl, 'A'
    jb      check_lower
    cmp     dl, 'Z'
    jbe     letter_found
check_lower:
    cmp     dl, 'a'
    jb      check_polish
    cmp     dl, 'z'
    jbe     letter_found

check_polish:
    
    cmp     dl, 165  ; ¹
    je      letter_found
    cmp     dl, 164  ; ¥
    je      letter_found
    cmp     dl, 134  ; æ
    je      letter_found
    cmp     dl, 143  ; Æ
    je      letter_found
    cmp     dl, 169  ; ê
    je      letter_found
    cmp     dl, 168  ; Ê
    je      letter_found
    cmp     dl, 136  ; ³
    je      letter_found
    cmp     dl, 157  ; £
    je      letter_found
    cmp     dl, 228  ; ñ
    je      letter_found
    cmp     dl, 227  ; Ñ
    je      letter_found
    cmp     dl, 162  ; ó
    je      letter_found
    cmp     dl, 224  ; Ó
    je      letter_found
    cmp     dl, 152  ; œ
    je      letter_found
    cmp     dl, 151  ; Œ
    je      letter_found
    cmp     dl, 171  ; Ÿ
    je      letter_found
    cmp     dl, 141  ; 
    je      letter_found
    cmp     dl, 190  ; ¿
    je      letter_found
    cmp     dl, 189  ; ¯
    je      letter_found

   
    ; jeœli dotychczasowa sekwencja mia³a >=3 znaków, zamieñ j¹ na '*'
    cmp     esi, 3
    jb      no_replace_now

    mov     edx, edi        ; start
    mov     eax, esi        ; ile znaków
rep_replace:
    mov     byte ptr magazyn[edx], '*'
    inc     edx
    dec     eax
    jnz     rep_replace

no_replace_now:
    xor     esi, esi        ; zeruj d³ugoœæ sekwencji
    inc     ebx
    dec     ecx
    jnz     scan_loop
    jmp     after_letters_scan

letter_found:
    ; litera znaleziono
    cmp     esi, 0
    jne     inc_seq
    mov     edi, ebx        ; zapamiêtaj start sekwencji
inc_seq:
    inc     esi
    inc     ebx
    dec     ecx
    jnz     scan_loop

after_letters_scan:

    cmp     esi, 3
    jb      continue_after_scan

    mov     edx, edi
    mov     eax, esi
rep_replace_end:
    mov     byte ptr magazyn[edx], '*'
    inc     edx
    dec     eax
    jnz     rep_replace_end

continue_after_scan:


; Konwersja ASCII -> UTF-16

            mov ecx, liczba_znakow
            mov ebx, 0

konwersja:
            cmp     ebx, ecx
            jge     konwersja_done
            mov dl, magazyn[ebx]
            mov dh, 0
            mov ax, dx
            mov word ptr tekst_wide[ebx*2], ax
            inc ebx
            jmp konwersja

konwersja_done:
            ; terminator UTF-16 (NUL)
            mov word ptr tekst_wide[ebx*2], 0

; wyœwietlenie przekszta³conego tekstu
            push    0       ; sta³a MB_OK 
            ;push    liczba_znakow
            push    OFFSET tytul
            push    OFFSET tekst_wide
            push    0
            call    _MessageBoxW@16 ; wyœwietlenie przekszta³conego
            add     esp, 16 ; usuniecie parametrów ze stosu




    mov     eax, liczba_znakow ; ile znaków
    push    eax
    push    OFFSET magazyn
    push    1                 ; urz¹dzenie 1 = ekran
    call    __write
    add     esp, 12

            push    0
            call    _ExitProcess@4      ; zakoñczenie programu
_main  ENDP
END
