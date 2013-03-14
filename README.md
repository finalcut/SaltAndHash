SaltAndHash
===========

Coldfusion Salt and Hash Implementation

This basically just provides an easy encapsulated way to salt and hash strings using either SHA 256,  384,  or 512 so that it will work on the CF Standard Edition as well.
I believe this will work on CF 9 and newer (though it should be trivial to get it to work on CF 8 if it doesn't)


There are three sleep calls of one millisecond each; these are intentional and have a negligible effect on performance.  I basically use them to help the randomizers used
by the various functions be a little more random.

Credit in large part goes to http://crackstation.net/hashing-security.htm where I gained a much better understanding of salted hashing.  It's a great read.

Usage:

```
<!---  salt and hash a password before saving it --->
<cfscript>
	saltAndHasher = createObject("component", "saltAndHash").init();
	passwordData = saltAndHasher.saltAndHash("myPassword");
</cfscript>
	<cfquery name="savePassword" datasource="x">
		INSERT INTO user_profile
			(
				password
				, salt
				, hashid
				)
			VALUES (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#passwordData.hashedString#") />,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#passwordData.salt#") />,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#passwordData.hashMethod#") />
			)
	</cfquery>


<!--- reproduce the hash if you have the hash method and salt already --->

<cfscript>
	passwordIsValid = saltAndHasher.validatedHashedString("myPassword", passwordData.salt, passwordData.hashMethod, passwordData.hashedString)

	assertTrue(passwordIsValid);
</cfscript>


<

