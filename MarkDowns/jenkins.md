## JENKINS

#### switch JAVA JDK to use in Pipeline
```
node('vagrant-slave') {
    env.JAVA_HOME="${tool 'jdk-8u45'}"
    env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
    sh 'java -version'
}
```
or
```
node {
  jdk = tool name: 'JDK17'
  env.JAVA_HOME = "${jdk}"

  echo "jdk installation path is: ${jdk}"

  // next 2 are equivalents
  sh "${jdk}/bin/java -version"

  // note that simple quote strings are not evaluated by Groovy
  // substitution is done by shell script using environment
  sh '$JAVA_HOME/bin/java -version'
}
```



#### Fetch a userid and password from a Credential object in a Pipeline job.
----
For an Unix slave
```
node('<MY_UNIX_SLAVE>') {
withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: '<CREDENTIAL_ID>',
usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {

sh 'echo uname=$USERNAME pwd=$PASSWORD'
 }
}
```
Windows slave

```
node('<MY_WINDOWS_SLAVE>') {
  withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: '<CREDENTIAL_ID>',
                    usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
bat '''
      echo %USERNAME%
    '''
  }
}
```
#### Retrive in Groovy var

```
node('<MY_SLAVE>') {
  withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: '<CREDENTIAL_ID>',
                    usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {

println(env.USERNAME)
  }
}
```
----
####  use sonarqube token in pipeline (Jenkins 1.65)
```
node {
stage('SonarQube Scan') {
  //def scannerHome = tool 'SonarScanner';
  sh "${SonarScannerHome}/bin/sonar-scanner \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.projectName=HKLD-CMS \
      -Dsonar.projectVersion=0.1.0 \
      -Dsonar.projectKey=HKLD-CMS \
      -Dsonar.projectDescription='Static code analysis with SonarJS' \
      -Dsonar.login='2dfdc98e8937f14297a31f05cea8312c5a98bdd7' \
      -Dsonar.sources=''"
       }
}
```

#### get git repo branch name 
a free style job, use variable $GIT_BRANCH
```
echo $GIT_BRANCH
```

#### allow pictures in HTML report publisher
run below command in script console (for one-time change)
```
System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "sandbox allow-forms allow-scripts; default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';") 
```