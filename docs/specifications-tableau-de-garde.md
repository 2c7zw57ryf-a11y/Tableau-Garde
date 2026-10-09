# Tableau de garde — Anesthésiologie

## Contexte
Application web pour le groupe d'anesthésiologie (16 à 25 membres) : horaire de garde, vacances et ordre de choix de salle d'opération. EN UTILISATION RÉELLE depuis le 2026-09-03 : François a saisi les 18 vrais membres (SBG, DG, PJ, OL, DH 24/12, MP, FC, MEB 24/12+venSep, EMC, RD, PA, MAL 12h+venSep, SEB 12/24, AFGB 12/24, SR/VB/MAL2/PM 24h+venSep) et ajusté les blocs à 3-7 / 8-12+. Toute mise à jour du code doit FUSIONNER le seed JSON de la dernière version publiée (le mécanisme de conflit du publish la fournit) — jamais écraser ses données.

## Décisions prises (2026-09-02)
- Format : application web publiée comme artifact Claude. L'état est sauvegardé dans la page via « Publier les modifications » — chaque publication crée une version visible par tous les lecteurs du lien.
- Artifact : https://claude.ai/code/artifact/883e38fe-3c50-4721-9467-b0dfb3ad31df — fichier source : tableau-garde.html (capacité `artifact`).
- Garde : 2 niveaux par jour (1er et 2e de garde). Le G2 est toujours 24 h (jamais fractionné) et travaille le lendemain matin.
- TROIS ATTRIBUTS PAR PERSONNE : `mode` (semaine, 24 h ou 12 h), `modeFds` (fin de semaine), `venSep` (vendredi séparé).
  - **24 h** : le G1 fait jour + nuit; congé le lendemain (post-garde).
  - **12 h / fractionnée** : G1 jour (part à 18 h) et G1 nuit (arrive à 18 h; congé le lendemain), tous deux des membres qui fractionnent CE TYPE DE JOUR (semaine = `mode`, ven-sam-dim = `modeFds`). Le G1 jour compte pour la rémunération — toujours l'afficher.
  - **Vendredi séparé** (`venSep`) — CORRIGÉ 2026-10-02 : le vendredi est DÉTACHÉ de la fin de semaine de cette personne (sa FDS = samedi-dimanche). La garde du vendredi est attribuée à quelqu'un d'autre, selon le mode de semaine de la personne choisie (24 h ou J/N). Aucune coupure du vendredi en 12 h, aucune mécanique de « renfort » ni de demi-G1 (ancienne formulation retirée). Le nombre de vendredis réalisés doit être équitable entre membres (compteur à part).
  - Lendemains de garde : uniquement les G1 de nuit, dimanche inclus (absent le lundi).
- Séquences de FIN DE SEMAINE (ven→dim) :
  - Trio 12 h (A-B-C) : V = G1j:A, G1n:B, G2:C · S = G1j:C, G1n:A, G2:B · D = G1j:B, G1n:C, G2:A.
  - Paire 24 h (A-B) : V = G1:A, G2:B · S = G1:B, G2:A · D = G1:A, G2:B. Si A ou B est `venSep` : vendredi détaché (garde de semaine attribuée à d'autres), S = G1:A, G2:B · D = G1:B, G2:A.
  - Trio 12 h avec un membre `venSep` (provisoire, « à voir à l'usage ») : vendredi détaché, S = J:A, N:B, G2:C · D = J:C, N:A, G2:B; compensation par l'équité du trimestre.
- ÉQUITÉ DES GARDES : par trimestre, sur le nombre de G1 et le nombre de G2 (jour = ½, nuit = ½, 24 h = 1, G2 = 1). Le trimestre d'une garde = celui du lundi de sa semaine. Le solde (dette) d'un trimestre se reporte sur le suivant (plafonné à ±1). Compteurs distincts : vendredis, fériés, fins de semaine, passages par bloc de salle. Tous sur l'ATTRIBUTION INITIALE (les échanges n'y changent rien).
- VACANCES ET PART DE GARDES : aucune réduction — les gardes se concentrent dans les semaines de présence.
- ORDRE DE CHOIX DE SALLE : lun-ven seulement; positions 1-2 = G1 du jour puis G2 (hors blocs); positions 3+ = rotation équitable par blocs configurables (nombre de blocs + dernière position de chacun; réglage actuel de François : 3-7 / 8-12+); G1 nuit et post-garde affichés en retrait hors blocs; ajustements manuels par date comptés dans l'équité; rejeu déterministe du trimestre.
- Vacances : grille trimestrielle cliquable (clic = semaine lun→dim; partielles en demi-teinte; fusion des contiguës), rangée « Absents » informative (seuil retiré à la demande de François — sans limite, des vacances trop concentrées peuvent créer des jours sans équipe admissible; le rapport de génération les nomme), tour de choix, saisie « du – au ».
- CALENDRIER TRIMESTRIEL (bornes finales, 2026-09-03) :
  - **Automne** : commence à la SEMAINE QUI CONTIENT LE 1er SEPTEMBRE (même si son lundi est en août — ex. semaine du 31 août 2026) et va jusqu'à la semaine avant celle de Noël.
  - **Hiver** : après la semaine du jour de l'An → fin avril (déborde sur la 1re semaine de mai).
  - **Été** : du début mai à la semaine AVANT celle qui contient le 1er septembre.
  - Les 2 semaines des Fêtes (Noël, jour de l'An) hors choix de vacances; règles de garde particulières à documenter plus tard. La frontière du 1er septembre s'applique partout : grille de vacances, équité (trimestreDe), génération, blocs.
- GÉNÉRATION PAR TRIMESTRE (2026-09-03) : la fenêtre de génération propose Hiver/Été/Automne/Fêtes avec flèches (défaut : trimestre du mois affiché) et couvre exactement les semaines de la période — plus de choix de mois.

## Règles de l'horaire
1. Pas de garde de semaine (lun-jeu) la semaine avant ni après sa FDS de garde (SOUPLE depuis 2026-10-02, rang 3).
2. Idéalement max 1 FDS de garde par mois (souple, rang 2).
3. Pas 2 FDS de garde consécutives (dur).
4. Pas de nuit de garde le lundi en revenant de vacances (dur).
5. Idéalement, même nombre de lundis/…/vendredis de garde par membre (souple, rang 4).
6. Jeudi privilégié pour qui part en vacances la semaine suivante (souple, rang 5).
7. Hiérarchie des règles souples : 1) équité G1/G2 du trimestre > 2) max 1 FDS/mois > 3) pas de garde de semaine autour de sa FDS > 4) répartition lun-ven > 5) jeudi avant vacances.

## Fonctionnalités v10 (publiée 2026-09-03)
- Génération en trois temps (gloutonne trimestrielle G1/G2 → optimisation par réassignations → 6 essais, meilleur retenu), par trimestre, rapport détaillé (trous nommés, renforts, dépassements R2, réassignations).
- Confirmations intégrées (confirm() natif bloqué dans les artifacts).
- Statistiques par trimestre (G1/G2 + écarts, FDS, L→V) + table des blocs de choix de salle.
- Grille de vacances trimestrielle, tour de choix, choix de salle par blocs, équipe (champ nom agrandi, modes, ven. sép.).

## À valider / suite possible
- Règles de garde des 2 semaines des Fêtes (existent, à documenter).
- Fériés de semaine : comptés comme jours réguliers pour les blocs; lundi férié rattaché ou non à la FDS?
- Règles fines du tour de choix des vacances (nb de semaines par tour, serpentin?).
- Export (Excel/PDF) si besoin.
- Dossier connecté sur le Mac de François : « Projet Logiciel Horaire de garde » (photos IMG_1635/1636).

## Réorientation (2026-09-22) — application hors claude.ai
- Cible : HTML/JS pur hébergé sur GitHub Pages + Supabase (comptes par courriel, données partagées, rôles). Fusion prévue avec le module « choix des vacances » de la collègue (GitHub + Supabase).
- Ordre : maquette complète en HTML local (couche de données « Store » isolée) → branchement Supabase ensuite.
- Maquette actuelle : https://claude.ai/artifact/1783DhzKJn9Ljk49HEz6yW (dossier tableau-garde/index.html).
- Vues : Semaine (G1/G2 + ordre de choix à partir de 3), Mois (jours colorés selon mes gardes, lendemains, vacances, badge de position; clic = carte sous le calendrier), Mes jours (filtres G1 24 h / J / N / G2, lendemains, vacances, position </> N), Impression (sélection visuelle des semaines par année), Échanges, Gestion (responsables).
- Gestion : Horaire (garde + ordre de choix par jour, glisser-déposer, rouge = post-garde, jaune = absent, compteur HB par jour), Membres (fiche, courriel, désactivation), Fériés, Journal, Outils (blocs, HB par défaut, délai d'encan).
- Échanges : échange / don / encan; permutation de places par jour (G1, G1 J, G1 N, G2, position, vacances, congé); aperçu avant/après systématique avec les deux parties en couleur; demandes caduques automatiques quand le tableau change; encan = candidatures, classement (dernière garde reçue à l'encan la plus ancienne, puis ordre d'arrivée), attribution par le responsable, délai réglable, clôture écourtée si la garde est imminente; courriel quotidien à 18 h à tout le groupe; bilan informatif pour le responsable (n'affecte pas l'équité).

## Conditions du générateur d'horaire — récapitulatif (2026-09-23)

### 1. Membres et attributs
- Trois attributs : mode de semaine (24 h / 12 h fractionné), mode de fin de semaine (24 h / 12 h), vendredi séparé.
- Actif/inactif; un inactif n'est plus proposé, son historique reste.
- Effectif : 18 membres (24 h : SBG, DG, PJ, OL, MP, FC; 24 h + ven. sép. : SR, VB, MAL2, PM; 12 h : EMC, RD, PA; mixtes : DH 24/12, MEB 24/12 + ven. sép., MAL 12 h + ven. sép., SEB 12/24, AFGB 12/24).

### 2. Structure d'une garde
- Deux niveaux par jour : G1 et G2. G2 toujours 24 h, jamais fractionné, travaille le lendemain matin.
- G1 24 h : jour + nuit, congé le lendemain. G1 fractionné : G1 J (part à 18 h, compte pour la rémunération, toujours affiché) + G1 N (arrive à 18 h, congé le lendemain), tous deux des membres qui fractionnent ce type de jour.
- Vendredi séparé : vendredi détaché de la FDS de la personne (FDS = sam-dim); vendredi attribué à d'autres selon leur mode; équité des vendredis (compteur à part).
- Post-garde : uniquement les G1 de nuit, dimanche inclus (absent le lundi).

### 3. Séquences de fin de semaine (ven → dim)
- Trio 12 h (A-B-C) : V = J:A, N:B, G2:C · S = J:C, N:A, G2:B · D = J:B, N:C, G2:A.
- Paire 24 h (A-B) : V = G1:A, G2:B · S = G1:B, G2:A · D = G1:A, G2:B; si A ou B venSep : vendredi détaché, S = G1:A, G2:B · D = G1:B, G2:A.
- Rééquilibrage G2 : un membre 12 h peut prendre le G2 d'une seule journée (samedi de préférence) d'une FDS 24 h.

### 4. Règles dures
- Pas deux FDS de garde consécutives.
- Pas de nuit de garde le lundi au retour de vacances.
- Jamais en garde pendant ses vacances; jamais deux rôles le même jour; pas de garde le jour d'un post-garde.

### 5. Règles souples (score)
- Dans l'ordre : 1) équité G1/G2 du trimestre; 2) max 1 FDS de garde par mois; 3) pas de garde de semaine (lun-jeu) la semaine avant ni après sa FDS; 4) même nombre de lundis, …, vendredis par membre; 5) jeudi privilégié pour qui part en vacances la semaine suivante.

### 6. Équité
- Par trimestre, sur G1 et G2 : jour = ½, nuit = ½, 24 h = 1, G2 = 1, renfort = ½ G1. Trimestre d'une garde = celui du lundi de sa semaine.
- Vacances : aucune réduction de la part (gardes concentrées dans les semaines de présence).
- Échanges et dons : aucun effet sur le compte officiel (attribution initiale).
- Idée en attente : nouveau membre ou membre de retour entre au niveau du groupe, sans iniquité à rattraper.
- Idée en attente : un membre peut se déclarer prêt à 1 ou 2 gardes dans l'autre mode que sa préférence (24 h → quelques J/N, ou l'inverse).

### 7. Calendrier
- Automne : semaine contenant le 1er septembre → semaine avant celle de Noël. Hiver : après la semaine du jour de l'An → fin avril (déborde sur la 1re semaine de mai). Été : début mai → semaine avant celle contenant le 1er septembre.
- Deux semaines des Fêtes hors choix de vacances; règles de garde particulières à documenter (à confirmer).
- Fériés : liste et compteur d'équité à part, attribués à la main par le coordonnateur dans la première version (le générateur ne les attribue pas; pas d'ordre de choix de salle ce jour-là); lundi férié non rattaché à la FDS.
- Génération par trimestre (Hiver/Été/Automne/Fêtes), semaines exactes de la période, rejeu déterministe.

### 8. Vacances
- Saisie par semaine lun→dim, partielles possibles, fusion des contiguës, tour de choix, saisie « du – au ».
- Pas de seuil d'absents; le rapport nomme les jours sans équipe admissible.
- Règles fines du tour de choix (semaines par tour, serpentin) : à confirmer; module de la collègue à fusionner.

### 9. Ordre de choix de salle
- Lundi à vendredi. Positions 1-2 = G1 du jour (G1 ou G1 J) puis G2.
- Positions 3+ : rotation équitable par blocs configurables; actuel DEUX blocs : 3-7 et 8-12+ (HB à part). Équité = nombre de passages par bloc, sur l'attribution initiale.
- Hors ordre, en retrait : G1 N, post-garde, absents.
- HB (hors bloc) : les N dernières positions; N par défaut réglable (1 actuellement) et ajustable jour par jour selon les salles disponibles.
- Ajustements manuels par date comptés dans l'équité de rotation; rejeu déterministe.

### 10. Contraintes issues de la gestion et des échanges
- Le générateur fusionne avec l'existant : ne jamais écraser sans le signaler une garde ou un ordre modifié à la main ou issu d'un échange conclu.
- Une garde fractionnée par un membre (G1 → J + N) reste telle quelle.
- Toute modification est consignée au journal.

### 11. Rapport de génération attendu
- Trous nommés, renforts utilisés, dépassements de « 1 FDS par mois », réassignations de l'optimisation, statistiques par trimestre (G1/G2 et écarts, FDS, répartition L→V), table des blocs.

## Décisions d'architecture du générateur (2026-09-24 → 2026-10-04)
1. Séquence en quatre étapes : choix de vacances (module de la collègue) → fins de semaine → semaine (lun-jeu + vendredis détachés) → choix de salle. Chaque étape lançable séparément, « Tout générer » les enchaîne; relancer une étape amont efface les étapes aval non verrouillées (avertissement de cascade).
2. Le passé est intouchable; seules les journées à venir sont regénérées. Sélecteur visuel des semaines à inclure (liste de semaines par année, comme l'impression). Échanges conclus et jours verrouillés à la main préservés et nommés dans le rapport.
3. Règles souples hiérarchisées : équité G1/G2 > max 1 FDS/mois > pas de garde de semaine autour de sa FDS > répartition lun-ven > jeudi avant vacances.
4. FDS réparties entre trios 12 h et paires 24 h au prorata des effectifs (modeFds); but : même nombre de FDS par membre; réglage manuel possible.
5. G2 ouvert à tous; pour corriger un déficit de G2, un membre 12 h peut prendre le G2 d'une seule journée (samedi de préférence) d'une FDS 24 h. Équité comptée telle quelle.
6. Le solde d'équité se reporte au trimestre suivant (plafond ±1; remise à zéro manuelle possible par le responsable).
7. Vendredi séparé = vendredi détaché (voir ci-dessus); équité des vendredis; trio sur sam-dim provisoire.
8. Semaines des Fêtes : manuel dans la première version.
9. Fériés : liste et compteur à part, attribution manuelle par le coordonnateur dans la première version.
10. Salles : deux blocs (3-7, 8-12+), HB à part; compteur de passages par bloc sur l'attribution initiale; ajustements manuels comptés.
11. Un seul bouton; budget fixe de 60 s, arrêt anticipé après 30 essais sans amélioration, bouton « Arrêter et garder le meilleur », graine affichée et rejouable.
12. Pas de brouillon : application directe au tableau; module réservé aux responsables; rapport avant/après et « Annuler la dernière génération ».
