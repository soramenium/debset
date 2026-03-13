# Instrukcja uruchomienia:

	wget https://github.com/soramenium/debset/archive/refs/heads/main.zip
	unzip main.zip
	chmod +x ./debset-main/debset.sh
	
pamiętaj że skrypt trzeba odpalić jako root
	
	SU
	(wpisz root-pwd)
	./debset.sh
baw się dobrze

# Opis funkcji
  ## 1. Wykonaj wszystko
  
  Skrypt automatycznie wykona poniższe funkcje.
  
  W razie problemów powinien się zatrzymać i zwrócić wszystkie błędy
    
  Funkcje które zostaną wykonane:
  
    - Instalacja pakietów
    - Konfiguracja GRUB
    - Autologowanie
    - Konfiguracja SSH
    - Kioskifikuj
    - Wyłącz DE
	- Matrixify
	- LOB
Na koniec zrobi reboot. 
  
## 2. Instalacja pakietów
  Automatycznie zainstaluje (jeśli nie ma) poniższe pakiety:
  
     - linux-image-rt-amd64
     - linux-headers-rt-amd64
     - libsocketcan2
     - libsocketcan-dev
     - dconf-cli
		 - net-tools
		 - mc
		 - htop
		 - can-utils
		 - nmap
		 - tmux
		 - make
		 - gcc
		 - g++
		 - cmake
		 - tio
		 - cmatrix

## 3. Konfiguracja GRUB
  - ustawi naszą tapetę jako tło gruba
  - ustawi jądro RT jako domyślne
  - wyłączy oczekiwanie na wybór użytkownika


## 4. Autologowanie
  Powinno sprawić że przy uruchomieniu systemu w trybie z GUI, automex zaloguje się automatycznie.
  
  Powinno.
  
  Bo w sumie to zapomniałem to przetestować XD
    
  
## 5. Konfiguracja SSH
  zmienia port z domyślnego 22 na 2222, tak żeby trudniej było hakować nasze mejnfrejmy XD
  
  **UWAGA** po wykonaniu tej połączenie SSH zostanie zerwane
  
  **UWAGA** ponowne połączenie wymaga dodania flagi '-P 2222'
  

  
## 6. Włącz/wyłącz DE
  Włącza lub wyłącza GUI

## 7. Zhakuj mainfame (obfuskacja terminala)
Obfuskacja terminala - każdy terminal, SSH itp (oprócz SU/SUDO/ROOT) domyślnie odpala cmatrix w ramach obfuskacji.
[q] lub [ctrl]+[c] żeby powrócić do normalnego terminala

## 8. Kioskifikacja
  Zmienia ustawienia DE:
  
    - ustawia naszą tapetę
    - wyłącza wygaszanie ekranu
    - wyłącza usypianie komputera
    - zmienia funkcje Power Buttona, żeby nic nie robił (not working, need fix)

## 9. Stwórz Launch On Boot
  Tworzy skrypt uruchomieniowy lob.sh w katalogu domowym oraz serwis który ten skrypt będzie wywoływać.
  Docelowo będzie usetapiać auto uruchomienie parma, ale obecnie będzie odpalać pętlę testową (również tworzona automatycznie przez tę funkcję)
  
## n. konfiguracja statycznego IP / DHCP
Pozwala przełączać się między profilami sieciowymi. Jeśli profil nie istnieje to zostanie od razu utworzony.
Żeby zmienić ustawienia statycznego IP należy usunąć profile i jeszcze raz wywołać właściwą funkcję.
Domyślnie system powienien przełączyć się na DHCP po usunięciu profili.
**UWAGA** Zmiana ustawień sieciowych spowoduje rozłączenie SSH

## u. Update debset
  automatycznie pobierze z githuba i zainstaluje najnowszą wersję skryptu, po czym zakończy działanie aktualnie uruchomionego skryptu

## Wyjście
  wychodzi ze skryptu, duuhhhh :v
