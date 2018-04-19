#!groovy
import com.bit13.jenkins.*

properties ([
	buildDiscarder(logRotator(numToKeepStr: '25', artifactNumToKeepStr: '25')),
	disableConcurrentBuilds(),
	pipelineTriggers([
		pollSCM('H/30 * * * *')
	]),
])


node ("docker") {
	def ProjectName = "fivem-server"
	def teamName = "bit13labs"
	def slack_notify_channel = null

	def MAJOR_VERSION = 0
	def MINOR_VERSION = 1

	env.PROJECT_MAJOR_VERSION = MAJOR_VERSION
	env.PROJECT_MINOR_VERSION = MINOR_VERSION

	env.CI_BUILD_VERSION = Branch.getSemanticVersion(this)
	env.CI_DOCKER_ORGANIZATION = "bit13"
	env.CI_PROJECT_NAME = ProjectName
	currentBuild.result = "SUCCESS"
	def errorMessage = null

	if(env.BRANCH_NAME ==~ /master$/) {
			return
	}

	wrap([$class: 'TimestamperBuildWrapper']) {
		wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
			Notify.slack(this, "STARTED", null, slack_notify_channel)
			try {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.CI_DOCKER_HUB_CREDENTIAL_ID,
										usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
					withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.CI_ARTIFACTORY_CREDENTIAL_ID,
										usernameVariable: 'ARTIFACTORY_USERNAME', passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
						withCredentials([[$class: 'StringBinding', credentialsId: env.CI_VAULT_CREDENTIAL_ID, variable: 'VAULT_AUTH_TOKEN']]) {
							stage ("install" ) {
								deleteDir()
								Branch.checkout(this, "${env.CI_PROJECT_NAME}-docker", teamName)
								Pipeline.install(this)

								env.FM_RCON_PASSWORD = SecretsVault.get(this, "secret/${env.CI_PROJECT_NAME}", "FM_RCON_PASSWORD")
								env.SERVER_LICENSE_KEY = SecretsVault.get(this, "secret/${env.CI_PROJECT_NAME}", "SERVER_LICENSE_KEY")
								env.SERVER_NAME = SecretsVault.get(this, "secret/${env.CI_PROJECT_NAME}", "SERVER_NAME")
								env.SERVER_TAGS = SecretsVault.get(this, "secret/${env.CI_PROJECT_NAME}", "SERVER_TAGS")
							}
							stage ("lint") {
								sh script: "${WORKSPACE}/.deploy/lint.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
							}
							stage ("build") {
								sh script: "${WORKSPACE}/.deploy/build.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
							}
							stage ("test") {
								sh script: "${WORKSPACE}/.deploy/test.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
							}
							stage ("deploy") {
								sh script: "${WORKSPACE}/.deploy/deploy.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
							}
							stage ('publish') {
								sh script:  "${WORKSPACE}/.deploy/validate.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"

								Branch.publish_to_master(this)
								Pipeline.publish_buildInfo(this)
							}
						}
					}
				}
			} catch(err) {
				currentBuild.result = "FAILURE"
				errorMessage = err.message
				throw err
			}
			finally {
				Pipeline.finish(this, currentBuild.result, errorMessage)
			}
		}
	}
}
