# Instrukcja uruchomienia:
1. wget https://github.com/soramenium/debset/archive/refs/heads/main.zip
2. unzip main.zip
3. cd debset-main
4. chmod +x debset.sh
5. SU
6. (wpisz root-pwd)
7. ./debset.sh
8. baw się dobrze

# Opis funkcji
  ## "Wykonaj wszystko"
  
  Skrypt automatycznie wykona poniższe funkcje.
  
  W razie problemów powinien się zatrzymać i zwrócić wszystkie błędy
    
  Funkcje które zostaną wykonane:
  
    - Instalacja pakietów
    - Konfiguracja GRUB
    - Autologowanie
    - Konfiguracja SSH
    - Kioskifikuj
    - Wyłącz DE
  
## Instalacja pakietów
  Automatycznie zainstaluje (jeśli nie ma) poniższe pakiety:
  
     - linux-image-rt-amd64
     - linux-headers-rt-amd64
     - libsocketcan2
     - libsocketcan-dev
     - dconf-cli

## Konfiguracja GRUB
  - ustawi naszą tapetę jako tło gruba
  - ustawi jądro RT jako domyślne
  - wyłączy oczekiwanie na wybór użytkownika


## Autologowanie
  Powinno sprawić że przy uruchomieniu systemu w trybie z GUI, automex zaloguje się automatycznie.
  
  Powinno.
  
  Bo w sumie to zapomniałem to przetestować XD
    
  
## Konfiguracja SSH
  zmienia port z domyślnego 22 na 2222, tak żeby trudniej było hakować nasze mejnfrejmy XD
  
  **UWAGA** po wykonaniu tej funkcji może rozłączyć SSH
  
  **UWAGA** ponowne połączenie wymaga dodania flagi '-P 2222'
  

  
## Wyłączenie DE
  sprawia, że system domyślnie odpala się w trybie CLI

## Włączenie DE
  sprawia, ze system domyślnie odpala się w trybie GUI

## kioskifikacja
  Zmienia ustawienia DE:
  
    - ustawia naszą tapetę
    - wyłącza wygaszanie ekranu
    - wyłącza usypianie komputera
    - zmienia funkcje Power Buttona, żeby nic nie robił (not working, need fix)


## Wyjście
  wychodzi ze skryptu :v
