# Voto Palese
Nel caso del voto palese, non si è interessati a mantenere l'anonimia del voto. Algorand offre una guida all'implementazione di un voto palese sia permissiones che permissionless. Siamo interessati al caso permissioned.

# Voto Anonimo
Nel caso del voto anonimo, si è interessati a mantenere l'anonimia del voto. È necessario dunque che non ci sia traccia della preferenza all'interno di una transazione, in quanto, essendo pubbliche, sarebbe poi facile leggere. È necessario inoltre che lo stato della votazione (l'urna) sia nascosto, che non sia possibile la lettura live dei valori.

# Feature di Algorand
- Asset algorand: fungono da scheda elettorale
- Atomic transfer: possibilità di legare in grupppo e le transazioni da far processare
- Smart Contract stateful: mantengono aggiornato il copunter del voto e validano ogni transazione di voto, verificando che sia fatta in combinazione con una transazione di spesa del token

# Attori
- Vote stakeholder: chi ha interesse nella votazione e fornisce l'accesso al voto (*Permissioned*)
- Voter: chi esprime una preferenza
- Ballot: Terza parte (*Infocert*) che raccoglie il voto del Voter, verificandone la possibilità di voto
- Algorand: permette la trasparenza di una transazione, consente salvataggio di dati on chain
- Dizme: si occupa del layer di autenticazione del Voter 