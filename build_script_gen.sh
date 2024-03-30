# Name of the resource we're selectively copying
FIREBASE_APP_ID_FILE=firebase_app_id_file.json

# Get references to dev and prod versions of firebase_app_id_file.json
# NOTE: These should only live on the file system and should NOT be part of the target (since we'll be adding them to the target manually)

FIREBASE_APP_ID_FILE_DEV=${PROJECT_DIR}/${TARGET_NAME}/config/dev/${FIREBASE_APP_ID_FILE}
FIREBASE_APP_ID_FILE_STAGING=${PROJECT_DIR}/${TARGET_NAME}/config/staging/${FIREBASE_APP_ID_FILE}
FIREBASE_APP_ID_FILE_PROD=${PROJECT_DIR}/${TARGET_NAME}/config/prod/${FIREBASE_APP_ID_FILE}
echo ${PROJECT_DIR}
echo ${TARGET_NAME}



# Make sure the dev version of firebase_app_id_file.json exists
echo "Looking for ${FIREBASE_APP_ID_FILE} in ${FIREBASE_APP_ID_FILE_DEV}"
if [ ! -f $FIREBASE_APP_ID_FILE_DEV ]
then
    echo "No dev firebase_app_id_file.json found. Please ensure it's in the proper directory."
    exit 1
fi


# Make sure the staging version of firebase_app_id_file.json exists
echo "Looking for ${FIREBASE_APP_ID_FILE} in ${FIREBASE_APP_ID_FILE_STAGING}"
if [ ! -f $FIREBASE_APP_ID_FILE_STAGING ]
then
    echo "No staging firebase_app_id_file.json found. Please ensure it's in the proper directory."
    exit 1
fi


# Make sure the prod version of firebase_app_id_file.json exists
echo "Looking for ${FIREBASE_APP_ID_FILE} in ${FIREBASE_APP_ID_FILE_PROD}"
if [ ! -f $FIREBASE_APP_ID_FILE_PROD ]
then
    echo "No prod firebase_app_id_file.json found. Please ensure it's in the proper directory."
    exit 1
fi

# Get a reference to the destination location for firebase_app_id_file.json
FILE_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app
echo "Will copy ${FIREBASE_APP_ID_FILE} to final destination: ${FILE_DESTINATION}"

# Copy over the correct firebase_app_id_file.json for the current build configuration
if [ "${CONFIGURATION}" == "Debug-dev" ] || [ "${CONFIGURATION}" == "Release-dev" ] || [ "${CONFIGURATION}" == "Profile-dev" ]
then
    echo "Using ${FIREBASE_APP_ID_FILE_PROD}"
    cp "${FIREBASE_APP_ID_FILE_PROD}" "${FILE_DESTINATION}"

elif [ "${CONFIGURATION}" == "Debug-staging" ] || [ "${CONFIGURATION}" == "Release-staging" ] || [ "${CONFIGURATION}" == "Profile-staging" ]
then
    echo "Using ${FIREBASE_APP_ID_FILE_PROD}"
    cp "${FIREBASE_APP_ID_FILE_PROD}" "${FILE_DESTINATION}"

elif [ "${CONFIGURATION}" == "Debug-prod" ] || [ "${CONFIGURATION}" == "Release-prod" ] || [ "${CONFIGURATION}" == "Profile-prod" ]
then
    echo "Using ${FIREBASE_APP_ID_FILE_PROD}"
    cp "${FIREBASE_APP_ID_FILE_PROD}" "${FILE_DESTINATION}"

else
    echo "Error: invalid configuration specified: ${CONFIGURATION}"
fi
