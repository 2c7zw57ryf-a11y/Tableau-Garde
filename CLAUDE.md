# Tableau de garde — Anesthésiologie (CHAUR, Trois-Rivières)

Application web pour un groupe de 18 anesthésiologistes : horaire de garde (G1/G2), ordre de choix de salle,
vacances/absences, échanges de gardes, module de gestion (responsables) et générateur d'horaire.
Langue de l'interface et du code (commentaires, noms) : français québécois. Toujours répondre en français.

## Architecture
- **Un seul fichier** : `index.html` (HTML + CSS + JS, aucune étape de build). Déployé par GitHub Pages
  à https://2c7zw57ryf-a11y.github.io/Tableau-Garde/ — chaque push sur `main` redéploie en ~1 min.
- **Données** : Supabase (projet `rwfctaghsmnmdsivycsx`, région Canada). Schéma dans `supabase-schema.sql`.
  Tables : membres, gardes, choix, absences, feries, verrous, echanges, journal, reglages. RLS activée :
  lecture = membre actif connecté (courriel dans `membres.courriel`), écriture = `responsable`, échanges par chacun.
- **Config** dans `index.html`, tout en haut : `window.TG_CONFIG={url, key}`. La clé est la clé PUBLIQUE
  (`sb_publishable_…`). Ne JAMAIS mettre une clé `service_role`/`secret` dans le code ni dans le dépôt.
- **Deux modes** dans le même fichier : en ligne (TG_CONFIG renseignée → `StoreOnline`, auth par lien courriel)
  et local (TG_CONFIG vide → `StoreLocal`, données de démonstration dans `<script id="data">`, localStorage).
  Les écrans n'appellent que `Store.*` (`setGarde`, `setChoix`, `saveMembre`, `delMembre`, `setFeries`, `log`,
  `save`) ; garder cette séparation.

## Structure du code (index.html)
- Données : `D` (gardes `{jour:{g1|g1j|g1n|g2}}`, choix `{jour:{ordre[],nuit,postGarde[],absents[],hb?}}`,
  vacances `[{membre,debut,fin,motif?,echange?}]`, feries[], locks{}, echanges[], journal[], reglages, blocs, capacites).
- Vues : Semaine, Mois, Mes jours, Échanges, Impression ; Gestion (responsables) : Horaire, Vacances, Générateur,
  Membres, Fériés, Journal, Outils.
- Générateur : `trimestreDe`, `semainesDe`, `compteurs`, `scoreDe`, `genererEssai` (constructions),
  `ameliorer` (recuit simulé), `genererSalles`, `lancerGeneration` → aperçu puis `appliquerGeneration`.
- Échanges : `placeDe`, `swapDay` (permutation de places un jour donné, vacances comprises), `patchFor`,
  `applyReq`, `classer` (encans), `purgerCaduques`.

## Règles métier (résumé — détails dans docs/specifications-tableau-de-garde.md)
- G2 toujours 24 h. G1 = 24 h ou fractionné J (jour) / N (nuit) selon `mode` (semaine) et `modeFds`.
- Post-garde : G1 de nuit seulement ; ne s'applique PAS à l'intérieur d'une fin de semaine (ven→sam→dim).
- Vendredi séparé (`venSep`) : le vendredi est détaché de la FDS de la personne (FDS = sam-dim).
- Équité par trimestre sur l'attribution initiale (échanges sans effet) ; solde reporté au trimestre suivant.
- Règles dures : pas 2 FDS consécutives, pas de nuit le lundi au retour de vacances, jamais en garde en vacances.
- Règles souples par ordre : équité G1/G2 > max 1 FDS/mois > pas de garde de semaine autour de sa FDS >
  répartition lun-ven > jeudi avant vacances.
- Ordre de choix de salle : positions 1-2 = G1 jour, G2 ; blocs 3-7 et 8-12+ ; HB (hors bloc) = N dernières positions.
- Fériés et semaines des Fêtes : saisie manuelle par le coordonnateur (le générateur les saute).

## Façon de travailler
- Avant de pousser : vérifier la syntaxe JS (`node -e` sur le contenu du <script> principal) et ouvrir la page.
- Petits commits avec message en français ; ne jamais réécrire l'historique de `main`.
- Ne pas modifier le schéma Supabase sans le dire explicitement à François et sans ajouter la migration SQL au dépôt.
- Toute nouvelle règle métier doit être ajoutée à `docs/specifications-tableau-de-garde.md`.
