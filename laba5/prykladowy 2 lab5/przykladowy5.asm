.686
.model flat
public _odchylenie_standardowe

.code
_odchylenie_standardowe PROC
    
    push ebp
    mov ebp, esp
    push esi
    push ebx           

    ; [ebp+8]  -> adres tablicy (double*)
    ; [ebp+12] -> liczba elementów n (unsigned int)

    mov esi, [ebp+8]    ; ESI = adres tablicy
    mov ecx, [ebp+12]   ; ECX = n

    ;  Obliczenie Œredniej Arytmetycznej (M)
    
    fldz                ; ST(0) = 0.0 (Suma)
    
    
    push ecx            ; Kopia n na stosie
    push esi            ; Kopia adresu pocz¹tku tablicy na stosie

petla_srednia:
    fadd qword ptr [esi]
    add esi, 8          ; 
    loop petla_srednia  ; Powtarzaj n razy

    ; Po pêtli: ST(0) = Suma wszystkich elementów
    
    ; Dzielimy sumê przez n
    fild dword ptr [ebp+12] ; Za³aduj n (int) na stos FPU -> ST(0)=n, ST(1)=Suma
    fdivp st(1), st(0)      ; ST(1) = Suma / n. Wynik (Œrednia) zostaje w ST(0).

    ; W tym momencie:
    ; ST(0) = Œrednia (M)

    
    ; Obliczenie Sumy Kwadratów Ró¿nic: Suma((Xi - M)^2)
    
    
    ; Przywracamy wskaŸniki do stanu pocz¹tkowego
    pop esi             ; ESI znów wskazuje na pocz¹tek tablicy
    pop ecx             ; ECX znów równa siê n (licznik pêtli)

    fldz                ; Za³aduj 0.0 jako akumulator sumy kwadratów.
                        ; Teraz stos wygl¹da tak:
                        ; ST(0) = 0.0 (SumaKwadratów)
                        ; ST(1) = Œrednia (M)

petla_wariancja:
    ; Obliczanie (Xi - M)^2
    fld qword ptr [esi] ; Za³aduj Xi. Stos: Xi, SumaKw, M
    fsub st(0), st(2)   ; Odejmij M od Xi. Stos: (Xi-M), SumaKw, M
    fmul st(0), st(0)   ; Podnieœ do kwadratu. Stos: (Xi-M)^2, SumaKw, M
    
    faddp st(1), st(0)  ; Dodaj wynik do SumyKwadratów i zdejmij wierzcho³ek.
                        ; Stos: NowaSumaKw, M
    
    add esi, 8          ; Nastêpny element (double = 8 bajtów)
    dec ecx
    jnz petla_wariancja

    

    
    ; Dzielenie przez (n - 1) i Pierwiastek
    
    
    ; Obliczamy n - 1
    mov eax, [ebp+12]   ; Za³aduj n
    dec eax             ; Zmniejsz o 1 (n-1)
    push eax            ; Wrzuæ (n-1) na zwyk³y stos, ¿eby FPU móg³ to pobraæ
    fild dword ptr [esp]; Za³aduj (n-1) na FPU. Stos: (n-1), SumaKw, M
    pop eax             ; Czyœcimy zwyk³y stos

    fdivp st(1), st(0)  ; Dzielenie: SumaKw / (n-1). Wynik to Wariancja.
                        ; Stos: Wariancja, M

    fsqrt               ; Pierwiastek kwadratowy z Wariancji -> Odchylenie Std.
                        ; Stos: Odchylenie, M

  
  
    

   
    pop ebx
    pop esi
    pop ebp
    ret
_odchylenie_standardowe ENDP
END