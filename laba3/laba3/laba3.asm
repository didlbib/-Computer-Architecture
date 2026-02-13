.686
.model flat

extern __write : PROC
extern __read : PROC
extern _ExitProcess@4 : PROC

public _main

.data

dekoder db '0123456789ABCDEF'
dziesiec dd 10 


val_N   dd ?    
val_A0  dd ?    
val_Q   dd ?    


msg_N       db 'Podaj ilosc elementow ciagu (N): '
len_N       equ $ - msg_N

msg_A0      db 'Podaj pierwszy wyraz (A0): '
len_A0      equ $ - msg_A0

msg_Q       db 'Podaj iloraz ciagu (Q): '
len_Q       equ $ - msg_Q

; Zaktualizowany nag³ówek tabeli
msg_Wynik   db 10, 'Wyniki (HEX | OCT | DEC):', 10
len_Wynik   equ $ - msg_Wynik

.code

_main PROC
   

    ; Wczytanie N
    push len_N
    push OFFSET msg_N
    push 1
    call __write
    add esp, 12
    call wczytaj_do_EAX
    mov val_N, eax          

    ; Wczytanie A0
    push len_A0
    push OFFSET msg_A0
    push 1
    call __write
    add esp, 12
    call wczytaj_do_EAX
    mov val_A0, eax         

    ; Wczytanie Q
    push len_Q
    push OFFSET msg_Q
    push 1
    call __write
    add esp, 12
    call wczytaj_do_EAX
    mov val_Q, eax          

    
    
    ; Nag³ówek
    push len_Wynik
    push OFFSET msg_Wynik
    push 1
    call __write
    add esp, 12

    mov ecx, val_N          
    cmp ecx, 0
    je koniec_programu

    mov eax, val_A0         

petla_ciagu:
    push ecx                ; Zapisz licznik pêtli

    
    call wyswietl_EAX_hex   
    
    
    call wyswietl_EAX_oct   

   
    call wyswietl_EAX_dzies

   
    mul dword PTR val_Q     
    
    pop ecx                 
    loop petla_ciagu        

koniec_programu:
    push 0
    call _ExitProcess@4
_main ENDP

wczytaj_do_EAX PROC
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 12
    mov esi, esp
    push dword PTR 12
    push esi
    push dword PTR 0
    call __read
    add esp, 12
    mov eax, 0
    mov ebx, esi
pobieraj_znaki:
    mov cl, [ebx]
    inc ebx
    cmp cl, 10
    je byl_enter
    sub cl, 30H
    movzx ecx, cl
    mul dword PTR dziesiec 
    add eax, ecx
    jmp pobieraj_znaki
byl_enter:
    add esp, 12
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
wczytaj_do_EAX ENDP


wyswietl_EAX_hex PROC
    pusha
    sub esp, 12
    mov edi, esp
    
    mov byte PTR [edi][0], 10 ; Enter przed wierszem (dla estetyki)
    mov ecx, 8
    mov esi, 1

ptl3hex:
    rol eax, 4
    mov ebx, eax
    and ebx, 0000000FH
    mov dl, dekoder[ebx]

    cmp dl, '0'
    jne wpisz_znak_hex
    cmp esi, 1      
    je pomin_zero_hex

wpisz_znak_hex:
    mov [edi][esi], dl
    inc esi

pomin_zero_hex:
    loop ptl3hex

    cmp esi, 1
    jne koniec_hex
    mov byte PTR [edi][esi], '0'
    inc esi

koniec_hex:
    ; Spacje po kolumnie HEX
    mov byte PTR [edi][esi], ' '
    inc esi
    mov byte PTR [edi][esi], ' '
    inc esi
    mov byte PTR [edi][esi], ' '
    inc esi

    push esi
    push edi
    push 1
    call __write
    add esp, 24
    popa
    ret
wyswietl_EAX_hex ENDP


;  SPACJE ZAMIAST ENTERA

wyswietl_EAX_oct PROC
    pusha
    sub esp, 16
    mov edi, esp
    mov esi, 0          

    rol eax, 2
    mov ebx, eax
    and ebx, 3
    add bl, '0'

    cmp bl, '0'
    jne wpisz_pierwsza
    jmp pomin_pierwsza

wpisz_pierwsza:
    mov [edi][esi], bl
    inc esi
pomin_pierwsza:

    mov ecx, 10
ptl3oct:
    rol eax, 3
    mov ebx, eax
    and ebx, 7
    add bl, '0'

    cmp bl, '0'
    jne wpisz_oct
    cmp esi, 0      
    je pomin_zero_oct

wpisz_oct:
    mov [edi][esi], bl
    inc esi
pomin_zero_oct:
    loop ptl3oct

    cmp esi, 0
    jne finalizuj_oct
    mov byte PTR [edi][esi], '0'
    inc esi

finalizuj_oct:
   
    mov byte PTR [edi][esi], ' '
    inc esi
    mov byte PTR [edi][esi], ' '
    inc esi
    mov byte PTR [edi][esi], ' '
    inc esi

    push esi
    push edi
    push 1
    call __write
    add esp, 28
    popa
    ret
wyswietl_EAX_oct ENDP


;  Wyœwietla liczbê w systemie dziesiêtnym, u¿ywaj¹c dzielenia.

wyswietl_EAX_dzies PROC
    pusha              
    sub esp, 12        
    mov edi, esp        


    mov ecx, 0         
    mov ebx, 10         ; Dzielnik

petla_dzielenia:
    mov edx, 0          ; Zerowanie starszej czêœci przed dzieleniem
    div ebx             
    
    add dl, '0'         ; Zamiana reszty na kod ASCII
    push dx             
    inc ecx             
    
    cmp eax, 0          
    jne petla_dzielenia 

  
    mov esi, 0          

zapis_do_bufora:
    pop dx              
    mov [edi][esi], dl  
    inc esi
    loop zapis_do_bufora

   
    mov byte PTR [edi][esi], 10
    inc esi

    ; Wyœwietlenie
    push esi            ; D³ugoœæ
    push edi            ; Adres bufora
    push 1              ; Ekran
    call __write
    
    add esp, 12         ; Params __write
    add esp, 12         ; Bufor
    popa
    ret
wyswietl_EAX_dzies ENDP

END