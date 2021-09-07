pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          namespace: spock
        spec:
          imagePullSecrets:
          - name: regcred
          containers:
          - name: deploy
            image: registry.sensetime.com/industry/library/autopilotci:v2.2.0
            tty: true
        '''
    }
  }
    options {
        disableConcurrentBuilds()
        lock resource: 'test-env'
    }

    environment {
        APP_NAME = 'noman'
        ENV = 'test'
        GOPROXY = 'https://goproxy.io,direct'
        TASK_PROGRESS_URL = 'https://sep-coffee.sensetime.com/ci/ci_pipeline/task_progress?pipeline_id=1223&'
        SERIAL_ID_1 = '202108261653151223'
        SERIAL_ID_2 = '202108261420441223'
    }

    stages {
        stage ('checkout scm') {
            steps {
                checkout(scm)
                load "image-name.groovy"
                echo "test multi pushes"
            }
        }
        stage ('parse') {
            steps {
                script{
                    def jsontext1 = sh ( script: "curl \"https://sep-coffee.sensetime.com/ci/ci_pipeline/task_progress?pipeline_id=1223&serial=$SERIAL_ID_1\"", returnStdout: true)
                    def jsontext2 = sh ( script: "curl \"https://sep-coffee.sensetime.com/ci/ci_pipeline/task_progress?pipeline_id=1223&serial=$SERIAL_ID_2\"", returnStdout: true)
                    println("Response 1: "+jsontext1 + '  type:' + jsontext1.getClass())
                    println("Response 2: "+jsontext2)
                    error("Failed because some SEP Step didn't pass.")
                    def parsedJson1 = readJSON text: jsontext1
                    def parsedJson2 = readJSON text: jsontext2
                    def ID1 = "$parsedJson1.pipeline_status"
                    def ID11 = parsedJson1['pipeline_status']
                    def ID2 = "$parsedJson2.pipeline_status"
                    println("ID1: $ID1, ID2: $ID2" + '  type1:' + ID1.getClass() + '  type11:' + ID11.getClass())
                    if (ID1 == 2) {
                        println ("1 Completed!")
                    } else {
                        println ("1 Running still!")
                    }
                    if (ID11 == 2) {
                        println ("11  Completed!")
                    } else {
                        println ("11  Running still!")
                    }

                    // assert parsedJson2['data']['failed'] == []
                    // assert parsedJson1['data']['failed'] == []

                    // def failed1Element = parsedJson1['data']['failed'].keySet()
                    // //def failed2Element = parsedJson2['data']['failed'][0]
                    // println("failed 1: $failed1, failed 2: $failed2" + '  1type:' + failed.getClass() + '  2type:' + failed2.getClass())
                    // println("failed 1ee: $failed1Element")
                    if (parsedJson1['data']['failed'].toList().isEmpty()) {
                        println ("failed1 Empty!!")
                        println(parsedJson1['data']['failed'].toList())
                    } else {
                        println ("failed1 Not Empty!!")
                        println(parsedJson1['data']['failed'].toList())
                    }
                    if (parsedJson2['data']['failed'].toList().isEmpty()) {
                        println ("failed2 Empty!!")
                        println(parsedJson2['data']['failed'].toList())
                    } else {
                        println ("failed2 Not Empty!!")
                        println(parsedJson2['data']['failed'].toList())
                    }
                }
            }
        }
        stage('loop') {
            steps{
                container('deploy'){
                    script{
                        def pipeline_status = 2
                        def response_json = ""
                        int build=0;
                        while(pipeline_status == 2 && build < 20){
                            response_json = sh ( script: 'curl https://sep-coffee.sensetime.com/ci/ci_pipeline/task_progress?pipeline_id=1223&serial=202108261653151223', returnStdout: true)
                            pipeline_status = sh ( script: 'curl https://sep-coffee.sensetime.com/ci/ci_pipeline/task_progress?pipeline_id=1223&serial=202108261653151223 | jq ".pipeline"', returnStdout: true)
                            println('HELLO ' + build + ' ' + pipeline_status);
                            sleep(10)
                            build++;
                        }
                    }
                }
            }
        }
        stage('call api') {
            steps {    
                // callback_url = registerWebhook()
                sh "env"
                sh "curl -X POST http://10.4.30.20:8080/users -d \'{\"name\":\"Joe\",\"email\":\"joe@invalid-domain\",\"callback\":\"${env.BUILD_URL}input/Async-input/proceedEmpty\"}\' -H \"Content-Type:application/json\""
                // waitForWebhook callback_url
                timeout(time: 20, unit: 'MINUTES'){
                    input (id: 'Async-input', message: 'Waiting for remote system',
                        parameters: [
                            string(defaultValue: 'None', description: 'Status of SEP CI task', name: 'status'),
                            string(defaultValue: 'None', description: 'Test param', name: 'testkey')
                        ]
                    )
                }
                sh 'echo "$status and $testkey"'
            }
        }
        stage('Initialize') {
            steps {
                script {
                    map.each { entry ->
                        stage (entry.key) {
                            timestamps{
                                echo "$entry.value"
                            }
                        }
                    }
                }
            }
        }
        stage('set var') {
            steps {
                withCredentials([kubeconfigFile(credentialsId: "kubeconfig-dev", variable: 'KUBECONFIG')]){
                    container ('deploy') {
                        script {
                            CURRENT_REVISION = sh (
                                script: "kubectl  rollout history deployment/spock-service -nspock | tail -n 2 | head -n 1 | awk '{print \$1}'",
                                returnStdout: true
                            ).trim()
                            echo "CURRENT REVISION: ${CURRENT_REVISION}"
                        }  
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'One way or another, I have finished'
            echo "I GOT the CURRENT REVISION: ${CURRENT_REVISION}"
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }
}