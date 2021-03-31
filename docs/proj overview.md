# Voto Palese
Nel caso del voto palese, non si è interessati a mantenere l'anonimia del voto. Algorand offre una guida all'implementazione di un voto palese sia permissiones che permissionless. Siamo interessati al caso permissioned.

## Oggetti coinvolti
- Asset algorand: fungono da scheda elettorale
- Smart Contract stateful: mantengono aggiornato il copunter del voto e validano ogni transazione di voto, verificando che sia fatta in combinazione con una transazione di spesa del token

## Attori
- Vote stakeholder: chi ha interesse nella votazione e fornisce l'accesso al voto (*Permissioned*)
- Voter: chi esprime una preferenza
- Ballot: Terza parte (*Infocert*) che raccoglie il voto del Voter, verificandone la possibilità di voto
- Algorand: permette la trasparenza di una transazione, consente salvataggio di dati on chain
- Dizme: si occupa del layer di autenticazione del Voter 