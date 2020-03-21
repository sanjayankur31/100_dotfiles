#!/bin/bash
#
# pbs_free
#
# Auteur : Michel Béland, Calcul Québec, michel.beland at calculquebec.ca
# Dernière version : janvier 2015
#

#. /etc/pbs.conf
if [ -n "$PBS_DEFAULT" ]
then
   PBS_SERVER=$PBS_DEFAULT
else
      recherche="/var/spool/torque /var/spool/pbs /opt/torque"
      for dir in $recherche
      do
            if [ -r $dir/server_name ]
            then
                  PBS_SERVER=`cat $dir/server_name`
            fi

      done
fi

########################################################################
usage()
{
      echo "Usage : pbs_free [-1] [-2] [-3] ... [-f] [-ns] [-s] [-x] [:p] [ serveur ]"
      echo "      -n (ou n est un entier) :"
      echo "            affiche les noeuds sur le nombre de colonnes spécifié,"
      echo "            par exemple, -3 affichera sur trois colonnes"
      echo "            (par défaut le nombre de colonnes s'ajuste avec"
      echo "            la taille de la fenêtre)"
      echo "      -f  : ne considère que les noeuds ayant des processeurs libres"
      echo "      -l  : affiche la liste des noeuds, avec le sommaire"
      echo "      -ns : affiche seulement les noeuds, sans le sommaire"
      echo "            ou le nom du serveur"
      echo "      -p  : affiche les processeurs et noeuds libres pour"
      echo "            toutes les propriétés"
      echo "      -s  : affiche seulement le sommaire, pas les noeuds (défaut)"
      echo "      -x  : considère les noeuds partiellement libres comme"
      echo "            non disponibles"
      echo "      :p  : ne considère que les noeuds ayant la propriété p"
      echo "            (la commande pbsnodes affiche les propriétés"
      echo "            définies pour chaque noeud)"
      echo " serveur  : afficher les noeuds de calcul associés à un autre"
      echo "            serveur"

      exit 1
}
########################################################################
affichage()
{
awk -v col=$COLUMNS -v col1=$COL1 -v free=$FREE -v liste=$LISTE -v listeprop="$LISTEPROP" -v prop=$prop -v som=$SOM -v excl=$EXCL '{
hostline[NR]=$0;
longueurlocale=index($0,"proprietes=")-2 #length()
if (longueur<longueurlocale) longueur=longueurlocale
  if ($3 != "down") {
        totalfreencpus+=$3
        if ($3 > 0 || free==0) printhost[NR]=1
        totalavailncpus+=$5
        if ($3 > 0 && $3 < $5) totalpartlyfreenodes++
        if ($3 == $5) totalcompletelyfreenodes++
        totalavailnodes++
  } else {
        if (free==0) printhost[NR]=1
  }
  totalnodes++
}
END {
if (NR > 15) nc=int((col-1)/longueur)
else nc=1

if (nc==0) nc=1
if (col1>0) nc=col1

if (liste == 1) {
      fmt="%-" longueur "s"
      ic=0
      for (i=1; i<=NR; i++) {
            if (printhost[i]==1) {
                  ic++
                  printf(fmt,substr(hostline[i],1,index(hostline[i],"proprietes=")-2))
                  if ((ic % nc) == 0) printf("\n")
            }
      }
      if ((ic % nc) != 0) printf("\n")
}
if (som == 1) {
   if (listeprop==0) {
      print "--------------------------------------------------------------------------------"
      printf("  Nombre de processeurs libres : %d / %d\n",totalfreencpus,totalavailncpus)
      printf("  Nombre de noeuds totalement libres : %d\n",totalcompletelyfreenodes)
      if (excl==0) printf("  Nombre de noeuds partiellement libres : %d\n",totalpartlyfreenodes)
      printf("  Nombre de noeuds en fonction : %d / %d\n",totalavailnodes,totalnodes)
      print "--------------------------------------------------------------------------------"
   } else {
      printf("%15s %6d / %-6d %15d ",prop,totalfreencpus,totalavailncpus, totalcompletelyfreenodes)
      if (excl==0) printf("%15d ",totalpartlyfreenodes)
      printf("%6d / %-6d\n",totalavailnodes,totalnodes)
   }
}
if (liste == 0 && listeprop == 0) {
   print "Pour afficher la liste des noeuds, utilisez l'\''option -l."
}
}'

}
########################################################################

n=0
COL1=0
FREE=0
LISTE=0
SOM=1
PROP=0
EXCL=0
propriete=""
for i
do
      case $i in
            -[0-9]*) COL1=${i#-} ; LISTE=1 ;;
            -f) FREE=1 ;;
            -l) LISTE=1 ;;
            -ns) SOM=0 ; LISTE=1 ;;
            -p) PROP=1 ;;
            -s) SOM=1 ;;
            -x) EXCL=1 ;;
            -*) usage ;;
            :*) propriete="$i" ;;
            *) PBS_SERVER="${i#@}"
               let n=n+1 ;;
      esac
done

if [ $n -gt 1 ]
then
      usage
fi

if [ $PROP = 1 ]
then
   SOM=1
   LISTE=0
fi

reponsetty=`env LANG=C tty`
if [ "$reponsetty" != "not a tty" ]
then
   resize=`type resize 2> /dev/null`
   if [ -n "$resize" ]
   then
      set $resize
      resize=$3
      eval `$resize -u`
   else
      COLUMNS=80
   fi
else
   COLUMNS=80
fi

# Chercher où se trouve pbsnodes
recherche="/usr/torque/bin /opt/torque/bin /opt/torque/x86_64/bin"
for dir in $recherche
do
      if [ -x $dir/pbsnodes ]
      then
            PBSNODES=$dir/pbsnodes
      fi
done
if [ -z "$PBSNODES" ]
then
      PBSNODES=`which pbsnodes 2> /dev/null`
fi
if [ -z "$PBSNODES" ]
then
      echo "Impossible de trouver la commande pbsnodes dans l'un des"
      echo "répertoires $recherche."
      echo "Définissez la variable d'environnement PBSNODES pour"
      echo "qu'elle pointe vers pbsnodes et recommencez."
      exit
fi

case "$PBS_SERVER" in
      frontal|frontal0[12]) EXCL=0
                            SORTSEP=-
                            SORTKEY1=1
                            SORTKEY2=2 ;;
      udem-cray1*|c*-n*) SORTSEP=-
                         SORTKEY1=1
                         SORTKEY2=2 ;;
      cottos*) SORTSEP=-
               SORTKEY1=1
               SORTKEY2=3 ;;
      egeon*|hades|psi*)  SORTSEP=-
                     SORTKEY1=2
                     SORTKEY2=3 ;;
      mp2)   EXCL=1
             SORTSEP=-
             SORTKEY1=1
             SORTKEY2=1 ;;
      moab.colosse*) EXCL=1
                     SORTSEP=n
                     SORTKEY1=1
                     SORTKEY2=2 ;;
      *) SORTSEP=-
         SORTKEY1=1
         SORTKEY2=1 ;;
esac

options="-a"

if [ "$SOM" -eq 1 ]
then
   echo "--------------------------------------------------------------------------------"
   echo "  Serveur $PBS_SERVER"
   if [ "$LISTE" -eq 1 ]
   then
      echo "--------------------------------------------------------------------------------"
      echo "  Processeurs libres sur chaque noeud :"
      echo ""
   fi
fi

liste=`$PBSNODES $options $propriete -s $PBS_SERVER |
awk -v excl=$EXCL '/^[a-z]/ {
      ncpus=0
      vnode = $1
}
{
      if ($1 == "state"){state=$3}
      hostname[vnode]=vnode
      hostlocal=vnode
      if ($1 == "np") {
            availncpus=$3
      }
      if ($1 == "properties") {proprietes[vnode]=$3}
      if ($1 == "jobs") {
            ncpus=NF-2
      }
      if ($1 == "status") {
            if (index(state,"down")==0 )  {
                  if (index(state,"offline")==0 ) {
                        hostavailncpus[hostlocal]+=availncpus
                        if (index(state,"job-exclusive")!=0) {
                              hostassignedncpus[hostlocal]+=availncpus
                        } else if (excl == 1 && ncpus > 0) {
                              hostassignedncpus[hostlocal]+=availncpus
                        } else {
                              hostassignedncpus[hostlocal]+=ncpus
                        }
                  } else {
                        # Le noeud est « offline ».
                        if (index(state,"job-exclusive")==0) {
                              # On considère que si le noeud n est pas
                              # « job-exclusive », le nombre de processeurs
                              # disponibles pour un noeud « offline »
                              # est égal au nombre de processeurs
                              # assignés.
                              hostassignedncpus[hostlocal]+=ncpus
                              hostavailncpus[hostlocal]+=ncpus
                        } else {
                              # Pour un noeud « job-exclusive », tous
                              # les processeurs sont considérés
                              # assignés.
                              hostassignedncpus[hostlocal]+=availncpus
                              hostavailncpus[hostlocal]+=availncpus
                        }
                  }
            }
      }
      if (maxavail < hostavailncpus[hostlocal]) maxavail=hostavailncpus[hostlocal]
}
END { 
longueur=length(maxavail)
for (var in hostname) {
      if (hostavailncpus[var] == 0) {
            printf("    %s : down proprietes=%s\n",var,proprietes[var])
      } else {
            hostfreencpus=hostavailncpus[var]-hostassignedncpus[var]
            fmt="    %s : %" longueur "d / %" longueur "d proprietes=%s\n"
            printf(fmt,var,hostfreencpus,hostavailncpus[var],
                   proprietes[var])
      }
}
}' | sort -b -t "$SORTSEP" -k$SORTKEY1,$SORTKEY1 -k${SORTKEY2}n`

proprietes=`echo "$liste" | sed -e 's/.*proprietes=//' | tr , '\n' |sort -u`

if [ $PROP = 0 ]
then
   # On n'affiche pas les résultats par propriété, on fait l'affichage
   # classique de pbs_free
   echo "$liste" | LISTEPROP=0 affichage
else
   # On boucle sur les propriétés et on affiche une ligne par propriété
   echo "--------------------------------------------------------------------------------"
   printf "%17s %15s %15s " "Propriété" "Processeurs" "Noeuds"
   if [ "$EXCL" = 0 ]
   then
      printf "%15s "                                           "Noeuds"
   fi
   printf "%15s\n"                                                             "Noeuds en"
   printf "%15s %15s %15s " " "         "libres"      "totalement"
   if [ "$EXCL" = 0 ]
   then
      printf "%15s "                                           "partiellement"
   fi
   printf "%15s\n"                                                             "fonction"
   printf "%15s %15s %15s " " "         " "           "libres"
   if [ "$EXCL" = 0 ]
   then
      printf "%15s"                                          "libres"
   fi
   echo
   for prop in $proprietes
   do
      echo "$liste" | grep -w 'proprietes=.*'$prop | LISTE=0 LISTEPROP=1 affichage
   done
   echo "--------------------------------------------------------------------------------"
   echo "$liste" | prop=Total LISTE=0 LISTEPROP=1 affichage
fi
