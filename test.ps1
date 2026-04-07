### Apprentissage sur les permissions ###
# Objectif: Maîtriser les notions de lecture, d'écriture, d'exécution, de modification et du contrôle total 
#           S'assurer de les avoir comprises et de savoir les utiliser convenablement
# Pour ce faire, nous devons créer un environnement informatique pour deux nouveaux stagiaires qui arriveront le 25 mai et s'en iront le 14 août
# On doit:
#       - Créer deux comptes d'utilisateur portant le nom de "Jessica DesBois" et de "Rodrigue Mercier" avec des mots de passe communs et sécurisés "stageinfo!" qui seront changés à leur première utilisation  
#       - Créer le compte d'utilisateur du nouveau chef de département qu'on vient d'engager avec le nom de "Marc-André" et mot de passe sécurisé de "NouveauChefDeDepartement". 
#       - S'assurer que le mot de passe du chef de département sera changé à sa première utilisation et n'expirera jamais, mais doit être changé tous les 6 mois
#       - Créer un groupe nommé "Apprentis stagiaires" avec la descrition "Stagiaires d'été 2026", on y ajoutera les stagiaires et le chef de département en informatique
#       - Donner tous les droits au chef de département (Fullcontrol) et donner juste le droits de lecture et d'exécution aux stagiaires
#       - S'assurer que ces stagiaires n'héritent pas de la classe parente, mais que leurs descendants héritent de la nouvelle règle qui sera créée (ReadAndExecute)

# Conditions: Si le chef de département crée :
#    *un fichier nommé :
#       - "Bug_informatique.txt", donner le droit d'écriture (Write) aux stagiaires (puisqu'ils vont déboguer)
#       - "Document_confidentiel.txt", donner juste le droit de lecture (Read) aux stagiaires (puisque c'est juste pour les informer)
#    *un dossier nommé :
#       - "Solutions informatiques", donner juste le droit de lecture (Read) aux stagiaires (puisque c'est juste pour les aider)
#       - "Problèmes rencontrés", donner le droit de modification (Modify) aux stagiaires (puisqu'ils vont essayer de resoudre ces problèmes)
# Note: Le chef de département créera un dossier seulement s'il y a trop de bugs informatiques ou s'il y a plusieurs propositions de solutions.
# Astuces: Utiliser des variables compréhensibles par tous (n'oubliez pas que, sur windows, les commandes sont très explicites)
# Recommandation : Utiliser les notes de cours de Patrick Rochon comme guide 

#" ***** Environnement de travail ***** .
    # Création du compte des stagiaires (3 points)
    #" Indice : une fonction qui créera les comptes des stagiaires en fonction des paramètres entrés (il n'y a que le nom qui change)"
    function CreateUser ($name){
        $PassWord = ConvertTo-SecureString "stageinfo!" -AsPlainText
        $DateExpiration = Get-Date -Year 2026 -Month 08 -Day 14 -Hour 18 -Minute 00
        New-LocalUser -Name $name -Password $PassWord -FullName $name -UserMayNotChangePassword -AccountExpires $DateExpiration | Out-File -Path $Result -Append
    }

    # Vérifie si l'utilisateur existe
    function UserExist ($name) {
        foreach ($utilisateur in Get-LocalUser) {
            if ($utilisateur.name -eq $name) {
                return $true
            }
        } return $false
        
    }

    # Vérifie si le groupe existe 
    function GroupExist ($NameGroup) {
        foreach ($groupe in Get-LocalGroup) {
            if ($groupe.name -eq $Namegroup) {
                return $true
            }
        } return $false
    }

    # Vérifie si les utilisateurs sont déjà dans le groupe 
    function UserInGroup ($utilisateur, $NameGroup) {
        $ListMember = Get-LocalGroupMember -name $NameGroup
        foreach ($UserGroup in $ListMember) {
            if ($UserGroup.name -eq $utilisateur) {
                return $true
            }
        } return $false
    }

    # Création du groupe et ajoute les comptes crées (2 + 3 points)
    #" Indice : une fonction qui créera le groupe "
    function CreateGroup ($NameGroup) {
        if (GroupExist -NameGroup $NameGroup) {
            Write-Host "The group '$($NameGroup)' is already created !"
        }else{
            New-LocalGroup -Name $NameGroup -Description "Stagiaires d'été 2026" | Out-File -Path $Result -Append
            Write-Host "The group '$($NameGroup)' is created !"
        }
    } 

    # Règles pour le chef de département et les stagiaires (1 + 4 points)
    # " Indice : une fonction qui créera et retournera chacune des règles demandées en fonction des paramètres entrés "
    function Rules ($user, $permission, $way) {
        $ACL = Get-ACL -Path $Way
        $ACL.SetAccessRuleProtection($true, $false)
        if ($way.Substring(($way.Length - 3)) -eq "txt") {
            $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $permission, "Allow")
        }
        else{
            $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $permission, "ContainerInherit, ObjectInherit", "None", "Allow")
        }
        $ACL.AddAccessRule($Rule)
        Set-Acl -Path $Way -AclObject $Acl
    }

    # Fonction qui définit les permissions des 3 personnes dans le groupe 
    function RulesOfAll ($chemin){
        Rules -user "Info" -permission "Fullcontrol" -way $chemin
        Rules -user "Marc" -permission "Fullcontrol" -way $chemin
        Rules -user "Rodrigue" -permission "ReadAndExecute" -way $chemin
        Rules -user "Jessica" -permission "ReadAndExecute" -way $chemin
    }        
    
    # Application des règles (2 points)
    #" Indice : une fonction qui appliquera la règle en écrasant l'héritage "
    function ApplicationRules () {
        # Permissions de base
        RulesOfAll -chemin $FolderInternship
        
        # Application des regles selon les conditions sur les fichiers
        $bug = "C:\Stages2026\Bug*.txt"
        if (Test-Path -Path $bug) {
            RulesOfAll -chemin $bug # Pour faire l'ajout d'une permission
            Rules -user "Rodrigue" -permission "Write" -way $bug
            Rules -user "Jessica" -permission "Write" -way $bug
        }
        $conf = "C:\Stages2026\*confidentiel.txt"
        
        # Ici, on veut écraser les permissions présédentes
        if (Test-Path -Path "C:\Stages2026\*confidentiel.txt") {
            RulesOfAll -chemin $conf # Pour faire l'ajout d'une permission
            Rules -user "Rodrigue" -permission "Read" -way $conf
            Rules -user "Jessica" -permission "Read" -way $conf
        
        }
        # Application des regles selon les conditions sur les dossiers
        $solution = "C:\Stages2026\Solutions*"
        if (Test-Path -Path "C:\Stages2026\Solutions*") {
            RulesOfAll -chemin $solution # Pour faire l'ajout d'une permission
            Rules -user "Rodrigue" -permission "Read" -way $solution
            Rules -user "Jessica" -permission "Read" -way $solution
        }
        $problem = "C:\Stages2026\Problemes*"
        if (Test-Path -Path "C:\Stages2026\Problemes*") {
            RulesOfAll -chemin $problem # Pour faire l'ajout d'une permission
            Rules -user "Rodrigue" -permission "Write" -way $problem
            Rules -user "Jessica" -permission "Write" -way $problem
        }
    }

    
    # Vérifie si les chemins appelés existent
    function PathExist ($test) {
        if (-not (Test-Path -Path $test)) {
            return $false
        }
        return $true
    }

    
#" ***** Appel des fonctions ***** "

#Création du dossier de stages 
"Creation of the internship directory in progress ..."
$FolderInternship = "C:\Stages2026"
$Result = "C:\Users\Info\Rendu.txt"

Write-Host "`nCreation of the directory of internship"
if (-not (PathExist -test $FolderInternship)) {
    New-Item -Path $FolderInternship -Itemtype Directory | Out-File -Path $Result
    Write-Host "The directory of internship $($FolderInternship.Substring(3)) is created !"
}else{
    Write-Host "The directory of internship $($FolderInternship.Substring(3)) is already existed !"
}

# Création du compte du chef de département et appel de la fonction pour la création des stagiaires (5 points)
$List = @("Marc", "Jessica", "Rodrigue")
$NameGroup = "Apprentis stagiaires"

Write-Host "`nCreation of group"
CreateGroup -NameGroup $NameGroup

Write-Host "`nCreation of localusers and addition of these users in the group"
foreach ($Intern in $List) {
    if (-not(UserExist -name $Intern)) {
        if ($Intern -eq "Marc") {
            $motDePasse = ConvertTo-SecureString "NouveauChefDeDepartement" -AsPlainText
            New-LocalUser -Name "Marc" -Password $motDePasse -AccountNeverExpires -UserMayNotChangePassword | Out-File -Path $Result
        }else{
            CreateUser -name $Intern
            # Groupe
            if (-not(UserInGroup -utilisateur $Intern -NameGroup $NameGroup)) {
                Add-LocalGroupMember -member $Intern -name $NameGroup
                Write-Host "The group $($NameGroup) is created !"
            }else{
                Write-Host "The group $($NameGroup) is already created !"
            }
        }
        Write-Host "The user account of $($Intern) is created !"
    }else{
        Write-Host "The user account of $($Intern) is already existed !"
    }  
}

# Tests
$ListTests = @("Problemes_informatiques", "Solutions_informatiques", "Bug_informatique.txt", "Document_confidentiel.txt")
foreach ($elt in $ListTests) {
    $FinalyWay = $FolderInternship + "\" + $elt
    if (PathExist -test $FinalyWay) {
        Write-Host "The path that leads to $($elt) is already existed !"
    }else{
        if ($elt.Substring(($elt.Length - 3)) -eq "txt") {
            New-Item -Path $FinalyWay -Itemtype File | Out-File -Path $Result -Append
        }
        else{
            New-Item -Path $FinalyWay -Itemtype Directory | Out-File -Path $Result -Append
        }
        Write-Host "The path that leads to $($elt) is created "
    }
}
Write-Host "The folder and file for the tests is ready !`nYou can start the tests !  "

# Appel de la fonction qui appliquera les règles en fonction des conditions exigées (4 points)
ApplicationRules
" Envrinonment is ready !"