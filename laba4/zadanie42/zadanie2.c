#include <stdio.h>


int min_even(const int tabl[], unsigned int n);

int main()
{

    int tablica[] = { 11, 5, 10, -8, 3, -12, 4, 7 };
    unsigned int n = sizeof(tablica) / sizeof(tablica[0]);
    int wynik;

    printf("Tablica: 11, 5, 10, -8, 3, -12, 4, 7\n");
    printf("Szukam najmniejszej wartosci parzystej...\n");

   
    wynik = min_even(tablica, n);

    printf("\nWynik: Najmniejsza liczba parzysta to: %d\n", wynik);

    return 0;
}