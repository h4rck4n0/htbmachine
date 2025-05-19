#!/bin/bash

# Questo script cerca le macchine di HTB dal sito di S4VATAR


# -----------------------------------------
#  BashColors
#  ----------------------------------------

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# -------------------------------------------
# Variabili Globali
# -------------------------------------------

main_url=https://htbmachines.github.io/bundle.js # sito da dove prendiamo le informazioni per il nostro motore di ricerca

# -------------------------------------------
# Funzioni
# -------------------------------------------

function ctrl_c(){
  echo -e "\n${redColour}[!]${endColour} ${greenColour} Programma interrotto dall'utente...${endColour}\n"
  tput cnorm 
  exit 1
}

function helpPannel(){
  echo -e "\n${blueColour}[?] HTB-Search-Machine\n\t${endColour}${turquoiseColour}HELP: ${endColour}"
  echo -e "\t ${yellowColour} -u${endColour} ${grayColour}Aggiorna files ${endColour}"
  echo -e "\t ${yellowColour} -m${endColour} ${grayColour}Ricerca per NOME della macchina HTB ${endColour}"
  echo -e "\t ${yellowColour} -i${endColour} ${grayColour}Ricerca per Indirizzo IP della macchina HTB ${endColour}"
  echo -e "\t ${yellowColour} -y${endColour} ${grayColour}Visualizza link youtube per nome della macchina risolta HTB ${endColour}"
  echo -e "\t ${yellowColour} -d${endColour} ${grayColour}Elenca le macchine secondo livello scelto${endColour} ${blueColour}-d < Facile/Medio/Difficile/Insane >${endColour}"
  echo -e "\t ${yellowColour} -o${endColour} ${grayColour}Elenca le macchine HTB per Sistema Operativo${endColour}${blueColour} -o < Linux / Windows >${endColour}"
  echo -e "\t ${yellowColour} -o${endColour} ${grayColour}Elenca le macchine HTB per skills${endColour}${blueColour} -s < \"Nome Skills\" >${endColour}"
  echo -e "\t ${yellowColour} -h${endColour} ${blueColour}Help ${endColour}"
  echo -e "\n ${grayColour} i parametri ${redColour}-o  -d${endColour}${grayColour} si possono abbinare:  -o < Linux / Windows > -d < Facile/Medio/Difficile/Insane > ${endColour}"
  exit 0 # esce dallo script 
}

function searchMachine(){
  machineName="$1"  # $1 fa riferimento al primo parametro che l'utente ha passato in questo caso il parametro m quindi machineName
  esiste=$(cat bundle.js | grep "\"$machineName\"") # filtra il valore $machineName nel file bundle.js se non lo trova la variabile sarà vuota
  if [ "$esiste" != "" ]; then # se la variabile è diverso dal vuoto significa che la macchina esiste 
    echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Dettagli della macchina HTB${endColour} ${greenColour} $machineName ${endColour} : \n"
    echo -e "${redColour}"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed "s/^ *//"
    echo -e "${endColour}"
  else 
    echo -e "\n${redColour}[!] Macchina ${greenColour} $machineName ${endColour} ${redColour} NON trovata !!! ${endColour}"
    echo -e "\n${purpleColour}- Controlla se hai digitato bene il nome, ricorda che è importante anche le maiuscole e le minuscole${endColour}"
  fi
}


function updateFiles(){ # Questa funzione controlla se esiste/scarica/aggiorna il file bundle.js 
  echo -e "\n${yellowColour}[!]${endColour} ${greenColour}Controllo Aggiornamenti...${endColour}"
  if [ ! -f bundle.js ]; then  # se il file bundle non esiste lo scarica e lo tratta con js-beautify.js (renderlo leggibile nel formato js)
    tput civis #toglie cursore al video
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Scaricando Files Necessari...${endColour}\n"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    tput cnorm #rimette il cursore
  else
    tput civis
    curl -s $main_url > bundle_tmp.js                    # se il file bundle.js esiste scarichiamo il file bundle e lo chiamiamo bundle_tmp 
    js-beautify bundle_tmp.js | sponge bundle_tmp.js     # trattiamo il file con js-beautify (per renderlo leggibile nel formato js)
    md5_tmp=$(md5sum bundle_tmp.js | awk '{print $1}')   #| 
    md5_original=$(md5sum bundle.js | awk '{print $1}')  #|i due file bundle.js e bundle_tmp.js ottenuti li hashiamo con md5sum 
    if [ $md5_tmp != $md5_original ]; then                 # se gli hash sono diversi significa che bundle_tmp.js è quello aggiornato
      rm bundle.js                                       # quindi cancelliamo bundle.js (versione vecchia)
      mv bundle_tmp.js bundle.js                         # rinominiamo bundle.tmp.js in bundle.js così facendo abbiamo il file bundle.js è aggiornato
      echo -e "${yellowColour}\n[+]${endColour} ${greenColour} Ci sono nuovi aggiornamenti....\n\t\t\t.....Files Aggiornati...$endColour"
    else
      echo -e "\n${yellowColour}[!]${endColour} ${greenColour}Non ci sono aggiornamenti...$endColour"
      rm bundle_tmp.js # rimoviamo il file perchè non è più necessario
    fi
    tput cnorm
  fi
}

function search_ip(){ # Cerca la macchina tramite IP inserito dall'utente
  macchine_ip="$1" # passiamo IP inserito dall'utente con il parametro -i
  echo -e "\n${yellowColour}[+]${endColour} ${greenColour}IP da ricercare${endColour} ${grayColour}$macchine_ip ${endColour}"
  macchinename_IP=$(cat bundle.js | grep  "ip: \"$macchine_ip\"" -B 3 | grep "name: "| awk '{print $2}'| tr -d "," | tr -d '"') # Mettiamo nella variabile il nome della macchina corrispondente al IP 
  if [ "$macchinename_IP" != "" ]; then   # se la variabile non è vuota significa che ha trovato il nome della macchina
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Nome Macchina corrispondente all'IP $macchine_ip : ${redColour}$macchinename_IP${endColour}"
    # searchMachine $macchinename_IP    # dettagli della macchina trovata
  else # altrimenti la variabile è vuota quindi non ha trovato nessuna macchina con l'IP inserito
    echo -e "\n${yellowColour}[!]${endColour} ${greenColour}Non è stata trovata nessuna macchina con IP inserito :${endColour} ${redColour}$macchine_ip${endColour} "
  fi
}

function search_youtube(){ # Trova il link del video youtube di una macchina passandogli il nome della macchina / questa funzione funziona come le altre function "stesso modus-operandi"
  machineName=$1
  link_youtube=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed "s/^ *//" | grep "youtube" | awk 'NF{print $NF}')
  if [ "$link_youtube" != "" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Link del video youtube della macchina${endColour} ${redColour}$machineName${endColour} ${purpleColour}$link_youtube${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour} ${greenColour}Macchina ${redColour}$machineName${endColour}${greenColour} NON trovata!!!${endColour}"
    echo -e "\n${purpleColour}- Controlla se hai digitato bene il nome, ricorda che è importante anche le maiuscole e le minuscole${endColour}"
  fi 
}

function traduzione_livello(){ # Questa funzione traduce da italiano a spagnolo l'argomento per la difficoltà Facile/Medio/Difficile/Insane --> Fácil/Media/Difícil/Insane
  livello=$1                        # il sito che stiamo laavorando è in spagnolo quindi questa funzione facilita l'utente italiano (ci sono accenti nelle parole spagnole)
  if [ "$livello" == "Facile" ]; then
    livello="Fácil"
  elif [ "$livello" == "Medio" ]; then
    livello="Media"
  elif [ "$livello" == "Difficile" ]; then
    livello="Difícil"
  elif [ "$livello" == "Insane" ]; then
    livello="Insane"
  else
    echo -e "\n${yellowColour}[!]${endColour} ${redColour}Livello inserito non valido!!!...${endColour}"
    helpPannel
  fi     
}

function traduzione_livello2spa(){ # l'inverso della funzione "traduzione_livello" --> da SPAGNOLO A ITALIANO  da avere un output italiano
 livello=$1
 if [ "$livello" == "Fácil" ]; then
   livello="Facile"
 elif [ "$livello" == "Media" ]; then
   livello="Medio"
 elif [ "$livello" == "Difícil" ]; then
   livello="Difficile"
 elif [ "$livello" == "Insane" ]; then
   livello="Insane"
 else # Questa condizione else non si avvera mai in questo script 
   echo -e "\n${yellowColour}[!]${endColour} ${redColour}Livello inserito non valido!!!...${endColour}"
   helpPannel 
 fi 
}

function show_Livello(){ # elenca le macchine secondo livello inserito dall'utente
  livello=$1
  livello_machine=$(cat bundle.js | grep "dificultad: \"$livello\"" -B 5 | grep "name" | awk 'NF {print $NF}'| tr -d '"' | tr -d ','| column)
  
  counter=$(cat bundle.js | grep "dificultad: \"$livello\"" -B 5 | grep "name" -c) # con l'opzione -c contiamo le macchine trovate
  traduzione_livello2spa $livello
  if [ "$livello_machine" != "" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Livello $livello${endColour}\n\n${purpleColour}$livello_machine${endColour}"
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}ci sono ${blueColour}$counter${endColour} ${greenColour}macchine $livello${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour} ${redColour}Livello inserito non valido!!!...${endColour}"
    helpPannel
  fi   
}


function search_so(){
  so=$1
  machine_os=$(cat bundle.js | grep "so: \"$so\"" -B 4| grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ','| column)
  counter=$(cat bundle.js | grep "so: \"$so\"" -B 4| grep "name" -c) # con l'opzione -c contiamo le macchine trovate
  if [ "$machine_os" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Macchine HTB con SO ${redColour}$so${endColour}\n\n$purpleColour$machine_os${endColour}"
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}ci sono ${blueColour}$counter${endColour} ${greenColour}macchine $so${endColour}"
  else 
    echo -e "\n${yellowColour}[!]${endColour} ${greenColour}Sistema Operativo inserito ${redColour}$so${endColour}${greenColour} NON trovata!!!${endColour}"
    echo -e "\n${purpleColour}- Controlla se hai digitato bene il Sistema Operativo, ricorda che è importante anche le maiuscole e le minuscole${endColour}"
  fi
}

function search_diff_so(){
  livello=$1
  so=$2
  diff_os=$(cat bundle.js | grep "so: \"$so\"" -C 4 | grep "dificultad: \"$livello\"" -B 5 | grep "name: " | awk 'NF{print $NF}'|tr -d '"' | tr -d ','| column)
  
  counter=$(cat bundle.js | grep "so: \"$so\"" -C 4 | grep "dificultad: \"$livello\"" -B 5 | grep "name: " -c) # con l'opzione -c contiamo le macchine trovate
  traduzione_livello2spa $livello
  if [ "$diff_os" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Macchine HTB con SO ${redColour}$so${endColour} ${greenColour}e con difficoltà${endColour} ${redColour}$livello${endColour}${endColour}\n\n${purpleColour}$diff_os${endColour}"
    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}ci sono ${blueColour}$counter${endColour} ${greenColour}macchine con $so e di livello $livello${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour} ${greenColour}Match SO/Difficoltà ${redColour}$so${endColour}${greenColour} NON trovata!!!${endColour}"
    echo -e "\n${purpleColour}- Controlla se hai digitato bene i parametri, ricorda che è importante anche le maiuscole e le minuscole${endColour}"
  fi
}

function search_skill(){
  skills=$1
  machineName=$(cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6| grep "name: "| awk 'NF{print $NF}'| tr '"' ' ' | tr ',' ' '| column)
  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+] ${endColour} Macchine HTB con skills ${redColour}$skills${endColour}\n\n${purpleColour}$machineName${endColour}"
  else
    echo -e "\n${yellowColour}[!] ${endColour} ${greenColour} La skills ${redColour}$skills${endColour} ${greenColour}NON è stata trovata!!!${endColour}"
    echo -e "\n${purpleColour}- Controlla se hai digitato correttamente....${endColour}"
  fi
}

# -------------------------------------------
# Indicatori
# -------------------------------------------
#
declare -i parameter_count=0 # dichiariamo con il parametro -i una variabile parameter_count di tipo numero INTERO(-i) e lo inizializiamo con valore 0

#--------------------------------------------
# Chiavi
# -------------------------------------------
#

# dichiariamo 2 variabili "Chiavi" di tipo intero che ci serviranno per abbinare più opzioni 
declare -i chiave_Difficolta=0 
declare -i chiave_SO=0

###### Inizio Script #####


#CTRL+C 
trap ctrl_c INT

# argomenti che passiamo al nostro script
# -m nome della macchina che vogliamo trovare
# -h il nostro help dello script
while getopts "m:i:y:d:o:s:uh" arg; do #argomenti che passiamo allo script m: il ':' seve ad indicare che dobbiamo passare un nome
                             # h serve per l'help e u per fare un upgrade al file boundle.js, non ci sono i ":" perchè l'utente non deve passare nessun argomento
  case $arg in
    m) machineName=$OPTARG; let parameter_count+=1;; # se viene immesso il parametro -m allora cambia il valore parameter_count aggiungendo +1
    u) let parameter_count+=2;; # se viene immesso il parametro -u significa che lo script deve fare l'upgrade del file boundle.js
    i) ip_Address=$OPTARG; let parameter_count+=3;; # se viene immesso il parametro -i con idirizzo ip come argomento il valore parameter_count avrà valore 3
    y) machineName=$OPTARG; let parameter_count+=4;;
    s) skills="$OPTARG"; let parameter_count+=7;; # visualizza le macchine con il skills immesso dall'utente
    d) livello=$OPTARG; chiave_Difficolta=1; let parameter_count+=5;;
    o) so=$OPTARG; chiave_SO=1; let parameter_count+=6;;
    h) helpPannel; 
  esac  
done

if [ $parameter_count -eq 1 ]; then  # se parameter_count è uguale a 1 significa che abbiamo il parametro -m con il nome della macchina da ricercare
  searchMachine $machineName
elif [ $parameter_count -eq 2 ]; then
  updateFiles
elif [ $parameter_count -eq 3 ]; then
  search_ip $ip_Address
elif [ $parameter_count -eq 4 ]; then
  search_youtube $machineName
elif [ $parameter_count -eq 5 ]; then
  traduzione_livello $livello # traduciamo da italiano a spagnolo
  show_Livello $livello
elif [ $parameter_count -eq 6 ]; then
  search_so $so
elif [ $chiave_Difficolta -eq 1 ] && [ $chiave_SO -eq 1 ]; then
  traduzione_livello $livello # traduciamo da italiano a spagnolo
  search_diff_so $livello $so
elif [ $parameter_count -eq 7 ]; then
  search_skill "$skills"
else
  helpPannel
fi

