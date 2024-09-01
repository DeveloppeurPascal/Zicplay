# 20240901 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* mise à niveau des dépendances
* mise à jour des docs FR/EN en reprenant la version en cours depuis le template de projets Delphi et en complétant avec les bons liens (site, téléchargement, achat, dépôt, dépendances)
* adaptation des chemins des unités de "DeveloppeurPascal/librairies" vers la nouvelle arborescence ("/src" au lieu de la racine)
* adaptation des chemins des unités de "DeveloppeurPascal/AboutDialog-Delphi-Component" vers la nouvelle arborescence ("/src" au lieu de "/sources")
* déplacement des images de "/design" vers "/assets" pour les éléments publics redistribuables (icones du programme et SVG de Pictogrammers)
* ajout du "FMX-Tools-Starter-Kit" en sous module du projet (pour utiliser ses fonctionnalités de base)
* regénération des icones pour avoir les formats ajoutés depuis la dernière génération
* mise à niveau du projet en Delphi 12 Athens avec prise en charge des nouvelles dépendances entre unités du projet
* génération des icônes du projet (et rattachement des nouvelles en RELEASE) depuis le générateur d'Artwork ajouté en Delphi 12 Athens.
* correction des icones déployées pour macOS et Windows en RELEASE (où l'ancienne était transmise par défaut en plus de la personnalisée)
* ajout des fichiers du FMX Tools Starter Kit dans le projet
* renommage de uConfig.pas en Zicplay.Config.pas et sa classe TConfig en TZPConfig pour éliminer un conflit avec le starter Kit
* remplacement de la boite de dialogue "about" locale par celle du starter kit
* mise à jour de la description, la politique de confidentialité, la licence et des infos légales du projet pour la boite de dialogue "à propos"
* mise à jour de l'icone liée à la boite de dialogue "à propos"
* reprise&renommage du précédent fichier de paramètres dont le nom entrait en conflit avec le stockage de paramètres standard (via uConfig et Olf.RTL.Params)
* suppression de l'ancien data module contenant l'icone utlisée dans la boite de dialogue "à propos" avant basculement sur celle du starter kit
* mise en place des fonctionnalités de traduction du starter kit dans la fiche principale du projet
* mise en place des fonctionnalités de traduction du starter kit dans l'écran de paramétrage d'une playlist
* mise en place des fonctionnalités de traduction du starter kit dans l'écran de sélection d'un connecteur
* mise en place des fonctionnalités de traduction du starter kit dans l'écran de paramétrage du connecteur "sélecteur de fichiers"
* prise en charge de la touche F1 sur la fiche principale (si activée dans les constantes) pour afficher la boite de dialogue "à propos"
* mise en place des fonctionnalité de gestion des options de menu provenant du starter kit dans la fiche principale : sélection d'option pour Windows ou Mac, déplacement en fonctiond e l'OS, visibilité des menus et sous menus
* mise en place des fonctions d'activation du style par défaut en fonction des paramètres utilisateur dans la fiche principale
* ajout d'un thème clair "Polar light"
* ajout d'un thème clair "Polar dark"
* ajout d'un thème clair "Impressive light"
* ajout d'un thème clair "Impressive dark"
* activation du thème Polar (clair ou sombre) en fonction des paramètres de l'OS
* ajout des fichiers en .M4A lors de la recherche de fichiers d'une arborescence (pris en charge sur MacOS, pas sous Windows). La récupération de leurs données ne fonctionne pas, il faudra l'implémenter ultérieurement.
* ajout de DeveloppeurPascal/Delphi-FMXExtend-Library sous module
* utilisation du sélecteur de dossier au lieu du sélecteur de fichiers pour choisir le dossier à utiliser sur une nouvelle playlist
* correction des violations d'accès sur macOS en fermeture de la fenêtre de sélection d'un dossier sur les playlists de type "file system"
* correction de violations d'accès sur macOS (non constatées sur Windows mais probables) liées au multi threading et au rafraichissement de la liste des morceaux lors du chargmeent ou de la mise à jour d'une playlist
* affectation de valeurs basées sur l'arborescence de fichiers MP3/M4A dont les tags ID3 ne sont pas renseignés si le fichier est dans une arborescence de type "Music/SousDossier/SousDossier/Fichier.mp3" en considérant que c'est "Music/Artiste/Album/Titre.mp3"

* fixed : création des dossiers de stockage des paramètres et caches de listes de lecture s'ils n'existent pas au moment de l'enregistrement des données
* fixed : test du type de chemin avant de le considérer comme un dossier lors du parcourt d'une arborescence avec les connecteurs "ma musique" ou "système de fichier" (certains fichiers sont vus comme des dossiers sur macOS et certains faux dossiers sont vus comme un dossier sous Windows)
* fixed : le champs de saisie du dossier lié à une playlist de type "file system" n'était pas modifiable lorsqu'un chemin avait été sélectionné par le bouton associé au champ
* fixed : le thème Polar écrase les TagXXX des éléments de menu. Il a été désactivé pour pouvoir à nouveau afficher les fenêtres de paramétrage des connecteurs ou des listes de lecture sous Windows. (comme le thème ne s'appliquait pas sous macOS le problème n'appraissait pas) - cf https://embt.atlassian.net/servicedesk/customer/portal/1/RSS-1675
