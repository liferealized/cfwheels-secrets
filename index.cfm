<cfsetting enablecfoutputonly="true" />
<cfscript>
  secretsMeta.version = "0.0.1";
  selfUrl = "?controller=wheels&action=wheels&view=plugins&name=secrets";

  if (structKeyExists(form, "name") && structKeyExists(form, "value")) {
    setSecret(form.name, form.value);
    variables.secretSaved = true;
  }
</cfscript>


<cfoutput>
  <div style="margin-bottom: 10px;">
    <h1>Secrets v#secretsMeta.version#</h1>
    <h2>Safely store your secrets without risk of compromise!</h2>
    <p>Enter your secret information below and Secrets will encrypt them with your encryption key.</p>
  </div>

  <cfif structKeyExists(variables, "secretSaved")>
    <div class="row">
      <fieldset>
        <legend>Your Secret was Successfully Saved!</legend>
        <p>Use the getSecret() method in your code to access your secret.</p>
      </fieldset>
    </div>
  </cfif>

  <form action="#selfUrl#" method="post">
    <div style="margin-bottom: 10px;">
      <label>Name</label>
      <input type="text" name="name" maxlength="20" required="required">
    </div>
    <div style="margin-bottom: 10px;">
      <label>Value</label>
      <textarea name="value" cols="100" rows="3" required="required"></textarea>
    </div>
    <div style="margin-bottom: 10px;">
      <input type="submit" value="Encrypt &amp; Save">
    </div>
  </form>

</cfoutput>
