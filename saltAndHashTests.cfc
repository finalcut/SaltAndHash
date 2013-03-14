<cfcomponent name="aemis.unittests.saltAndHashTests" extends="mxunit.framework.TestCase" output="false">
		<cffunction name="simpleSaltAndHashTest" access="public">

			<cfset var i = 0 />
			<cfset var local = structNew() />
			<cfset var saltAndHasher = createObject("component","aemis.com.saltAndHash").init() />

			<cfloop from="1" to="10" index="i">
				<cfset local.password = i />
				<cfset local.hash =  saltAndHasher.saltAndHash(local.password) />
				<cfset local.secondHash = saltAndHasher.saltAndHash(local.password) />


				<cfset assertFalse(local.hash.hashedString EQ local.secondHash.hashedString, "failure: hashes are equal! on iteration #i#")>

				<cfset assertTrue(saltAndHasher.validateHashedString(local.password, local.hash.salt, local.hash.hashMethod, local.hash.hashedString), "failure: unable to validate the hash! on iteration #i#")>


			</cfloop>
		</cffunction>


</cfcomponent>