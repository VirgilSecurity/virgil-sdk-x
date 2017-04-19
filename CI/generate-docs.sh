#appledoc Xcode script
# Start constants
company="Virgil Security";
companyID="com.virgilsecurity";
companyURL="https://virgilsecurity.com/";
target="iphoneos";
outputPath="${VIRGIL_SDK_HTML_PATH_DST}";
projectName="VirgilSDK"
# End constants
appledoc \
--project-name "${projectName}" \
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
"${TRAVIS_BUILD_DIR}/Source";

mv ${VIRGIL_SDK_HTML_PATH_DST}/html/* ${VIRGIL_SDK_HTML_PATH_DST};
rm -r ${VIRGIL_SDK_HTML_PATH_DST}/html;