sed -i -e "s#env.IMAGE_NAME=[^ ]*#env.IMAGE_NAME=\"registry.sensetime.com/industry/spock-service:v0.2.0\"#g" image-name.groovy
sed -i -e "s#env.BRANCH_NAME=[^ ]*#env.BRANCH_NAME=\"${CI_COMMIT_BRANCH}\"#g" image-name.groovy
sed -i -e "s#env.COMMIT_SHA=[^ ]*#env.COMMIT_SHA=\"${CI_COMMIT_SHA}\"#g" image-name.groovy
sed -i -e "s#env.AUTHOR_EMAIL=[^ ]*#env.AUTHOR_EMAIL=\"${GITLAB_USER_EMAIL}\"#g" image-name.groovy