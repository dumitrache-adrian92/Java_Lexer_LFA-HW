Dumitrache Adrian-George 334CC
Tema LFA (Var C) - Analiza sintactica a limbajului Java cu analizatorul lexical FLEX

Platforma utilizata: Linux (Ubuntu 23.10)
Limbaj de programare folosit: C++
Compilat cu: g++ 13.2.0 si flex 2.6.4

Pentru a compila programul, se foloseste comanda:
make

Pentru a rula programul, se foloseste comanda:
./JavaLexer <fisier_de_intrare>

Acesta va afisa la stdout numarul de clase gasite si numele lor. Pentru fiecare
clasa se va afisa daca toate atributele sale au getteri si setteri si numarul
de instante ale clasei gasite in metoda main.

Se afiseaza mesaje relevante de eroare in cazul in care fisierul de intrare nu
este valid (exista doua clase publice, se gasesc tokeni care nu au sens in
contextul in care se afla etc.).

Abordarea generala pe care am aplicat-o a fost sa parcurg fisierul de intrare,
sa retin in diverse structuri de date informatiile relevante si sa le afisez
dupa terminarea analizei lexicale.

In starea initial caut inceputul definitiei unei clase (adica fie keyword-ul
class, fie public) si ignor caracterele de tip whitespace (lucru ce se intampla
in majoritatea starilor din automat).

Cand gasesc un astfel de keyword, stiu ca urmeaza numele unei clase. Pe care il
pot stoca pentru a rezolva cerinta 1.
Restul continutului unei clase se afla intre acolade, initial am ignorat
continutul acestora utilizand urmatoarea metoda:
- daca gasesc un caracter de tip '{' in starea ce reprezinta scope-ul clasei,
adica `INSIDE_CLASS`, utilizez stiva de stari ca sa intru in starea
`OTHER_IMBRICATION` si sa retin faptul ca ma aflam in starea clasei inainte
- daca gasesc un caracter de tip '{' in starea `OTHER_IMBRICATION`, fac acelasi
lucru
- daca gasesc un caracter de tip '}' in starea `OTHER_IMBRICATION`, scot o
stare de pe stiva, pentru ca am iesit dintr-un scope de imbricare
- daca gasesc un caracter de tip '}' in starea `INSIDE_CLASS`, stiu ca am
terminat de de parcurs continutul clasei si pot sa ies din starea
`INSIDE_CLASS`

Aceasta abordare este necesara pentru ca altfel nu avem cum sa stim care '}'
inchide scope-ul clasei si care inchide un scope de imbricare.

Astfel, solutia pentru subpunctul 1 consta in cautarea semnaturii unei clase
pentru a extrage numele, ignorarea continutului clasei, si cautarea urmatoarei
semnaturi de clasa pana cand terminam fisierul.

Am continuat cu subpunctul 3, aici am nevoie sa determin atributele unei clase
si pentru fiecare metoda sa verific daca este getter sau setter pentru un
atribut.

Principala dificultate a fost faptul ca singurul mod de a diferentia intre
atribute si metode este gasirea unei paranteze.
Exemplu grafic:
public int a;
public int a() {
    return a;
}

Parcurgand litera cu litera, observam ca nu putem da seama ca o definitie in
interiorul clasei este atribut sau metoda pana cand nu se termina definitia
sau apare o paranteza sau un egal.

Din aceasta cauza, am tratat definitia de atribute si definitia de metode
intr-un mod similar, cautand inceputul lor si determinand pe parcurs daca avem
o metoda sau un atribut prin caracterele ce urmeaza.
Daca gasim un atribut, il retinem in tabla hash pentru atribute specifica
clasei, daca gasim o metoda, verificam daca aceasta este un getter sau un
setter pentru unul dintre atributele noastre. Daca da, retinem acest fapt.

Pentru subpunctul 2 am determinat care este metoda main, relativ simplu
pentru ca in Java nu sunt foarte multe moduri de a face asta, si am inceput
sa parcurg instructiunile din interiorul acesteia.

Am facut reguli care sa-mi accepte declaratii de variabile, declaratii de
variabile cu initializare, declaratii de array-uri, atribuirea unei valori unei
variabile si inceputul unui for.

De fiecare data cand orice fel de variabila obisnuita este initializata, verific
daca este o clasa si in caz afirmativ, incrementez numarul de instante ale
clasei respective.

Pentru array-uri, de fiecare data cand sunt in cadrul unui for, verific daca
daca exista vreo atribuire pentru un element al array-ului si in caz afirmativ,
cresc numarul de instante ale clasei respective cu numarul total de obiecte in
array.

