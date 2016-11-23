<cfscript>
  component output="false" {

    include template="events/onapplicationstart.cfm";

    public Secrets function init() {
      _install();
      this.version = "1.4.5";
      return this;
    }

    public any function getSecret(required string name) {

      local.encrypted = get(arguments.name);
      local.key = get("secretsKey");

      local.decrypted = decrypt(
          local.encrypted
        , local.key
        , $getSecretSetting("algorithm")
        , $getSecretSetting("encoding")
      );

      if (!isJSON(local.decrypted))
        return local.decrypted;

      return deserializeJSON(local.decrypted);
    }

    public void function setSecret(required string name, required any value) {

      // lets see if the secret already exists in the application scope and if
      // so don't do anything
      try {
        local.exists = get(arguments.name);
        return;
      } catch (any e) {
        // continue
      }

      local.key = get($getSecretsSetting("keyName"));

      // if we have a complex object, serialize it to json
      if (!isSimpleValue(arguments.value))
        arguments.value = serializeJSON(arguments.value);

      local.encrypted = encrypt(
          arguments.value
        , local.key
        , $getSecretSetting("algorithm")
        , $getSecretSetting("encoding")
      );

      // write the secret to our storage file
      writeSecret(arguments.name, local.encrypted);

      // set it in our application scope since we've not reloaded the application
      set("#arguments.name#"=local.encrypted);
    }

    public void function writeSecret(required string name
      , required string value, string path=$gss("storeFilePath")) {

      local.storeFile = expandPath(arguments.path);

      // since we include our secrets file on application start, we need to
      // just write set() to the file so that all encrypted data is put into the
      // application scope for retrieval while the app is running
      local.secContent =
          "<cfset set("
        & arguments.name
        & "="""
        & arguments.value
        & """)>";

      // append our content to the file
      local.file = fileOpen(local.storeFile, "append");
      fileWriteLine(local.file, local.secContent);
      fileClose(local.file);
    }

    public string function $gss() {
      return $getSecretsSetting(argumentCollection=arguments);
    }

    public string function $getSecretsSetting(required string setting) {

      if (!structKeyExists(application.secrets, arguments.setting))
        throw(
            type="Wheels.IncorrectSettingValue"
          , message="The setting #arguments.setting# does not exist."
        );

      return application.secrets[arguments.setting];
    }

    /**************************************
      PRIVATE METHODS
    ***************************************/

    private void function _install() {

      local.storePath = $getSecretsSetting("storeFilePath");
      local.keyPath = $getSecretsSetting("keyFilePath");
      local.algo = $getSecretsSetting("algorithm");
      local.key = generateSecretKey(listFirst(local.algo, "/"));

      _updateGitIgnore(argumentCollection=local);
      _updateOnApplicationStart(argumentCollection=local);
      _createKeyFile(argumentCollection=local);
      _createStoreFile(argumentCollection=local);
    }

    private void function _updateGitIgnore(
      required string storePath, required string keyPath) {

      local.contents = "";

      // set how we determine new lines
      local.newLine = server.separator.line;

      // create the updates string to add to .gitignore
      // we only want to ignore the password file as this
      // is the import part and storing our secrets encrypted
      // in the repo is OK
      local.updates = arguments.keyPath & local.newLine;

      // where our gitignore file should be located
      local.file = expandPath("/.gitignore");

      if (fileExists(local.file))
        local.contents = fileRead(local.file);

      // no need to update if we've already written to the file
      if (findNoCase(local.updates, local.contents))
        return;

      local.contents = local.updates & local.contents;

      fileWrite(local.file, local.contents);

      return;
    }

    private void function _createKeyFile(
      required string keyPath, required string key) {

      local.pasFile = expandPath(arguments.keyPath);

      // do nothing if we've already generated the key file
      if (fileExists(local.pasFile))
        return;

      local.pasContent =
          "<cfset set("
        & $gss("keyName")
        & "="""
        & arguments.key
        & """)>";

      fileWrite(local.pasFile, local.pasContent);
    }

    private void function _createStoreFile(
      required string storePath, required string key) {

      local.storeFile = expandPath(arguments.storePath);

      local.newLine = server.separator.line;

      // do nothing if we've already generated the store file
      if (fileExists(local.storeFile))
        return;

      local.testValue = encrypt(
          createUUID()
        , arguments.key
        , $getSecretSetting("algorithm")
        , $getSecretSetting("encoding")
      );

      local.secContent =
          "<cfset set(testSecret="""
        & local.testValue
        & """)>"
        & local.newLine;

      fileWrite(local.storeFile, local.secContent);
    }

    private void function _updateOnApplicationStart(
      required string storePath, required string keyPath) {

      local.contents = "";

      local.file = "/events/onapplicationstart.cfm";

      // set how we determine new lines
      local.newLine = server.separator.line;

      local.updates =
          "<cfset $include(template="""
        & arguments.storePath
        & """)>"
        & local.newLine;

      local.updates &=
          "<cfset $include(template="""
        & arguments.keyPath
        & """)>"
        & local.newLine;

      if (fileExists(local.file))
        local.contents = fileRead(local.file);

      // no need to update if we've already written to the file
      if (findNoCase(local.updates, local.contents))
        return;

      local.contents = local.updates & local.contents;

      fileWrite(local.file, local.contents);
    }
  }
</cfscript>
