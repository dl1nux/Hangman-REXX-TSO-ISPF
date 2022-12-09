/* REXX
   Hangman / Galgenmaennchen by Attila Kocis 17.11.2022
*/

/* Maennchen definieren */
A="/"; B="\"; C="/"; D="\"; E="O"; F="/";
G="0"; H="\"; I="V"; J="Ö"; K="^"; L="^"

/* Variablen vordefinieren */
BENUTZT=
GUELTIG="ABCDEFGHIJKLMNOPQRSTUVWXYZäöüß"
ERGEBNIS="Vorzeitiges Spielende mit 'exit'"
ZAEHLER=0
ABFRAGE="Bitte Buchstabe eingeben:"

/* Datenquelle fuer Woerterbuch definieren */
WOERTERBUCH="PS793.USER.EXEC(WOERTER)"

/* Ratewort zufaellig auswaehlen */
"ALLOC DD(QUELLE) DA('"WOERTERBUCH"') SHR REUSE"
"EXECIO * DISKR QUELLE (STEM WOERTER. FINIS"
"FREE DD (QUELLE)"
x = random(1,WOERTER.0)
RATEWORT=translate(strip(WOERTER.x))
LOESUNG=RATEWORT

/* Neue Variable mit Suchbegriff (BEGRIFF) definieren */
TRANSNEU="------------------------------"
TRANSALT="ABCDEFGHIJKLMNOPQRSTUVWXYZäöüß"
BEGRIFF=translate(RATEWORT,TRANSNEU,TRANSALT)

/* Schleifenbearbeitung fuer Spiel beginnen */
do until ENDE="YES"
   /* Panel aufrufen und Eingabe anfordern */
   address ispexec "display PANEL(HANG)"
   /* Notausgang pruefen */
   if EINGABE="EXIT" then leave
   /* Pruefen ob Eingabe gueltig ist */
   if pos(EINGABE,GUELTIG)^=0 then do
      /* Wenn Eingabe gueltig, dann auswerten */
      if pos(EINGABE,RATEWORT)>0 then do
         do while pos(EINGABE,RATEWORT)^=0
            POSITION=pos(EINGABE,RATEWORT)
            RATEWORT=overlay('-',RATEWORT,POSITION)
            BEGRIFF=overlay(EINGABE,BEGRIFF,POSITION)
         end
      end
      else do
         if pos(EINGABE,BENUTZT) = 0 then ZAEHLER = ZAEHLER +1
         zedsmsg="Nicht enthalten!"
         "ispexec setmsg msg(isrz001)"
      end
      /* Verwendete Buchstaben dem Benutzt-String hinzufuegen */
      if pos(EINGABE,BENUTZT) = 0 then BENUTZT = BENUTZT EINGABE
      /* Bei bereits verwendetem Buchstaben darauf hinweisen */
      else do
         zedsmsg="Bereits verwendet!"
         "ispexec setmsg msg(isrz001)"
      end
   end
   /* Falls Eingabe ungueltig, Fehlerhinweis ausgeben */
   else do
      zedsmsg="Eingabe ungueltig!"
      "ispexec setmsg msg(isrz001)"
   end
   /* Spielende wenn alle Buchstaben erraten wurden. => Gewonnen */
   if pos("-",BEGRIFF) = 0 then do
      STATUS="GEWONNEN"
      ABFRAGE=
      ENDE="YES"
   end
   /* Nach 12 falschen Buchstaben spiel beenden => Verloren */
   if ZAEHLER=12 then do
      STATUS="VERLOREN"
      ABFRAGE=
      ENDE="YES"
   end
end

/* Spielergebnis definieren */
select
   when STATUS="GEWONNEN" then do
      ERGEBNIS="Sie haben die Partie gewonnen. Spiel beenden mit Eingabetaste."
      end
   when STATUS="VERLOREN" then do
      ERGEBNIS="Sie haben leider verloren. Spiel beenden mit Eingabetaste."
      end
   otherwise ERGEBNIS="Das Spiel wurde abgebrochen. Eingabetaste zum Beenden."
end

/* Spielergebnis bekanntgeben */
address ispexec "display PANEL(HANG)"

exit