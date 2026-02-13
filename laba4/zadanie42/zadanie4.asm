.686
.model flat

public _min_even

.code

_min_even PROC
   
    push ebp                
    mov ebp, esp            
    
  
    push ebx
    push esi
    push edi

   
    mov ebx, [ebp+8]        
    mov ecx, [ebp+12]       

    ;Inicjalizacja
    xor esi, esi            ; ESI bêdzie indeksem 
    
    
    ; 0 = jeszcze nie znaleziono ¿adnej liczby parzystej
    ; 1 = znaleziono ju¿ pierwsz¹ liczbê parzyst¹ 
    xor edi, edi            
    
    mov eax, 0              ; EAX przechowuje wynik. Wstêpnie 0.

petla:
    cmp ecx, 0              
    je koniec               

    
   
    mov edx, [ebx + esi*4]

  
    test edx, 1             ; Test najm³odszego bitu
    jnz nastepny            

   
    cmp edi, 0              
    je pierwsza_parzysta

   
    cmp edx, eax            
    jge nastepny            
    
    ; Znaleziono nowe minimum
    mov eax, edx            
    jmp nastepny

pierwsza_parzysta:
    mov eax, edx           
    mov edi, 1              

nastepny:
    inc esi                
    dec ecx                 
    jmp petla               

koniec:
    ; Przywrócenie rejestrów w odwrotnej kolejnoœci
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
_min_even ENDP
END