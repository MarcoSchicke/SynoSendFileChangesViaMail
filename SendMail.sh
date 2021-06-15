##### Source: https://community.synology.com/enu/forum/1/post/135582

##### Sends email to users when defined folder has been modified.

##### If the defined folder has not been modified, an email can be sent to the admin by setting SEND_UNCHANGED to 1.

##### Comparison lists can be recursive or not, depending on RECURSIVE_LIST parameter value.

##### Comparison is only performed on file names, and not contents.

##### During the first run, creates lists for comparison and store them in '/homes/admin/_nasData_scripts' folder (see REP_DATA parameter)

##### TODO: send difference list as attachment, as too large string sent in mail body can cause empty mail!

##### ------------------------------------ user's parameters

EXPLORE_FOLDER="/var/services/homes/admin/TestAutoEMail/SendChanges"

# Separate multiple users by comma in USERS_MAIL_LIST. Example: "user1@domain1.com,user2@domain2.com"

USERS_MAIL_LIST="maillist@gmail.com"

ADM_MAIL="admmail@gmail.com"

FROM_MAIL="nas@gmail.com"

RECURSIVE_LIST=0

SEND_UNCHANGED=1

##### ------------------------------------ advanced parameters

REP_DATA="/var/services/homes/admin/TestAutoEMail/WorkingDir"

FOLDER_SHORT_NAME=$(echo $(basename "$EXPLORE_FOLDER"))

CURR_FILE="_"${FOLDER_SHORT_NAME//[,; :*+&#~\/\"\'\(\)\\]/}"_curr_list.txt"

PRIOR_FILE="_"${FOLDER_SHORT_NAME//[,; :*+&#~\/\"\'\(\)\\]/}"_prior_list.txt"

EMAIL_TITLE="NAS - Folder \'$FOLDER_SHORT_NAME\' analysis"

EMAIL_INTRO="[This is an automatic email sent from the NAS to all users ]"

##### ------------------------------------

USERS_MAIL_LIST="$ADM_MAIL,$USERS_MAIL_LIST"

RESULT_ALL=""

RESULT_ADM=""

# --------- collecte des paramètre pour retour admin

PARAMS="Parameters:

    EXPLORE_FOLDER: $EXPLORE_FOLDER

    FOLDER_SHORT_NAME: $FOLDER_SHORT_NAME

    REP_DATA: $REP_DATA

    CURR_FILE: $CURR_FILE

    PRIOR_FILE: $PRIOR_FILE

    RECURSIVE_LIST: $RECURSIVE_LIST

    SEND_UNCHANGED: $SEND_UNCHANGED"

# --------- creation REP_DATA pour fichiers CURR_FILE & PRIOR_FILE

mkdir -p "$REP_DATA"

if [ ! -d "$REP_DATA" ]; then

    /usr/bin/php -r "mail('$ADM_MAIL', '$EMAIL_TITLE: error', 'Error : unable to create $REP_DATA folder.', 'From: $FROM_MAIL');";

    exit

fi

if [ ! -d "$EXPLORE_FOLDER" ]; then

    RESULT_ADM="NAS folder \'$FOLDER_SHORT_NAME\' error.

Unable to locate folder \'$EXPLORE_FOLDER\'

 

$PARAMS"

    /usr/bin/php -r "mail('$ADM_MAIL', '$EMAIL_TITLE: error', '$RESULT_ADM', 'From: $FROM_MAIL');";

    exit

fi

# --------- écriture du contenu du dossier passé dans CURR_FILE
#TODO both parts have the same arguments
if [ "$RECURSIVE_LIST" != 0 ]; then

    ls --ignore-backups --ignore="*Thumbs.db*" --ignore="@eaDir" --ignore="*@SynoResource" --recursive "$EXPLORE_FOLDER"> "$REP_DATA/$CURR_FILE"

else

    ls --ignore-backups --ignore="*Thumbs.db*" --ignore="@eaDir" --ignore="*@SynoResource" "$EXPLORE_FOLDER"> "$REP_DATA/$CURR_FILE"

fi

# --------- comparaison PRIOR_FILE et CURR_FILE

if [ -f "$REP_DATA/$PRIOR_FILE" ]; then

    # --------- le fichier 'prior' existe : comparaison possible

    DIFF_LIST=$(diff --ignore-file-name-case --unchanged-group-format="" --old-group-format="

-------- %dn file%(n=1?:s) added:

%<" --new-group-format="

-------- %dN file%(N=1?:s) deleted:

%>" --exclude="*.db" "$REP_DATA/$CURR_FILE" "$REP_DATA/$PRIOR_FILE")

    if [ "$DIFF_LIST" != "" ]; then

    DATA_TO_SEND=${DIFF_LIST//\'/\\\'}

    DATA_TO_SEND=${DATA_TO_SEND//\"/\\\"}

    RESULT_ALL="NAS folder \'$FOLDER_SHORT_NAME\' has been modified:

-------------------------------------------------------

$DATA_TO_SEND"

    else

    if [ "$SEND_UNCHANGED" != 0 ]; then

    RESULT_ADM="NAS folder \'$FOLDER_SHORT_NAME\' is unchanged.

 

$PARAMS"

    fi

    fi

else

    # --------- alerte de création des fichiers

    RESULT_ADM="NAS folder \'$FOLDER_SHORT_NAME\' analysis:

 

File \'$REP_DATA/$CURR_FILE\' has been created.

 

$PARAMS"

fi

# ----------- copie de liste actuelle (CURR_FILE) pour comparaison future

cp "$REP_DATA/$CURR_FILE" "$REP_DATA/$PRIOR_FILE"

# ----------- envoi email a l'admin ou aux utilisateurs

if [ "$RESULT_ALL" != "" ]; then

   /usr/bin/php -r "mail('$USERS_MAIL_LIST', '$EMAIL_TITLE', '$EMAIL_INTRO $RESULT_ALL', 'From: $FROM_MAIL');";

else

   /usr/bin/php -r "mail('$ADM_MAIL', '$EMAIL_TITLE', '$RESULT_ADM', 'From: $FROM_MAIL');";

fi

