#!/bin/bash
git stash
git pull origin master --tags
git stash pop

VersionString=`grep -E 's.version.*=' CTJSBridgeSwift.podspec`
VersionNumber=`tr -cd 0-9 <<<"$VersionString"`
NewVersionNumber=$(($VersionNumber + 1))
LineNumber=`grep -nE 's.version.*=' CTJSBridgeSwift.podspec | cut -d : -f1`
sed -i "" "${LineNumber}s/${VersionNumber}/${NewVersionNumber}/g" CTJSBridgeSwift.podspec

echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"


git commit -am ${NewVersionNumber}
git tag ${NewVersionNumber}
git push origin master --tags
pod trunk push ./CTJSBridgeSwift.podspec --verbose --use-libraries --allow-warnings --use-modular-headers
