# htbmachine
### by h4rck4n0


[](https://github.com/h4rck4n0/htbmachine#htbmachine)

Questo script cerca i video delle macchine HTB risolte da S4vitar 

HTB-Search-Machine HELP:

-u Aggiorna files:     ./htbmachine.sh -u

-m Ricerca per NOME della macchina HTB    es.: ./htbmachine.sh -m Nomemacchina

-i Ricerca per Indirizzo IP della macchina HTB    es.: ./htbmachine.sh -i 10.10.10.10

-y Visualizza link youtube per nome della macchina risolta HTB    es: ./htbmachine.sh -y Nomemacchina

-d Elenca le macchine secondo livello scelto -d < Facile/Medio/Difficile/Insane >    es.: ./htbmachine.sh -d Medio

-o Elenca le macchine HTB per Sistema Operativo -o < Linux / Windows >   es.: ./htbmachine.sh -o Linux

-s Elenca le macchine HTB per skills -s < "Nome Skills" >    es: ./htbmachine.sh -s "Active Directory"     --> le virgolette sono neccessarie

-h Help  ./htbmachine.sh -h     Visualizza l'Help dello script


i parametri -o -d si possono abbinare: -o < Linux / Windows > -d < Facile/Medio/Difficile/Insane >    es.: ./htbmachine -o Windows -d Facile

Importante che al primo utilizzo eseguiamo:

./htbmachine.sh -u (serve anche per aggiornare)

lo script crea un file .js che servirà allo script di fare tutte le ricerche che vogliamo.

Periodicamente si consiglia di ripetere questo comando per aggiornare il programma, in modo di avere le nuove macchine HTB risolte da s4vitar.

Questo script l'ho realizzato grazie al corso linux che ho seguito dall'accademia [Hacknow.it]https://www.hacknow.it di Roby7979



