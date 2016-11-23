<cflock scope="application" timeout="30">
  <cfparam name="application.secrets.keyFilePath" type="string" default="/config/secrets-pwd.cfm">
  <cfparam name="application.secrets.storeFilePath" type="string" default="/config/secrets.cfm">
  <cfparam name="application.secrets.algorithm" type="string" default="AES/CBC/PKCS5Padding">
  <cfparam name="application.secrets.encoding" type="string" default="Base64">
  <cfparam name="application.secrets.keyName" type="string" default="secretsKey">
</cflock>
