//Anastasiia Kniazhevska 196629
#define _CRT_SECURE_NO_WARNINGS 
#include <stdio.h>

extern float odchylenie_standardowe(const double* tablica_dane, unsigned int n);

int main()
{
    double tablica[100];     // bez const
    unsigned int n;

    printf("Podaj ilosc elementow: ");
    if (scanf("%u", &n) && n > 0 && n <= 100) {
        printf("Podaj %u liczb zmiennoprzecinkowych:\n", n);
        for (unsigned int i = 0; i < n; i++) {
            printf("Liczba %u: ", i + 1);
            scanf("%lf", &tablica[i]);   // %lf dla double
        }

        float wynik2 = odchylenie_standardowe(tablica, n);
        printf("Wynik odchylenia standardowego %f\n", wynik2);
    }

    else {
        printf("Bledna ilosc danych.\n");
    }

    return 0;
}