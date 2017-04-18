#appledoc Xcode script
# Start constants
company="Virgil Security";
companyID="com.virgilsecurity";
companyURL="https://virgilsecurity.com/";
target="iphoneos";
outputPath="${VIRGIL_SDK_HTML_PATH_DST}";
# End constants
/usr/local/bin/appledoc \
--project-name "${PROJECT_NAME}" \
--project-company "${company}" \
--company-id "${companyID}" \
--output "${outputPath}" \
--logformat xcode \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--exit-threshold 2 \
--no-create-docset \
--clean-output \
"${PROJECT_DIR}/Source"