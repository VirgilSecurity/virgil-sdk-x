# Bug when installing appledoc via Homebrew. Load missing file
curl -o /usr/local/Cellar/appledoc/2.2.1/Templates/html/css/style.css https://github.com/tomaz/appledoc/blob/master/Templates/html/css/style.css

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