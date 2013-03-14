<cfcomponent name="saltAndHash"  output="false" >
	<cffunction name="init" access="public" returntype="saltAndHash" output="false">
		<!--- I only support SHA 256, 384, and 512 so I work on CF standard --->
		<cfscript>
			variables.instance = structNew();
			variables.instance.validHashes = [256,384,512];
		</cfscript>
		<cfreturn this />

	</cffunction>

	<cffunction name="makeSalt" access="private" returntype="string" output="false">
		<cfreturn generateRandomString(38,45,true,true) & createUUID() />
	</cffunction>
	<cffunction name="generateRandomString" access="private" returntype="string" output="false">
		<cfargument name="minLength"	type="numeric"	default="0" />
		<cfargument name="maxLength"	type="numeric"	default="10" />
		<cfargument name="numeric"	type="boolean"	default="true" />
		<cfargument name="symbols"	type="boolean"	default="true" />


		<cfset var local = structNew() />
		<cfset local.randomString = "" />

		<cfscript>
			sleep(1);
			randomize(TimeFormat(Now(),"l"));
			local.length = arguments.minLength;
			local.symbolArray = ArrayNew(1);
			ArraySet(local.symbolArray, 1, 4, "");
			local.symbolArray[1] = "@";
			local.symbolArray[2] = "^";
			local.symbolArray[3] = "$";
			local.symbolArray[4] = "~";
			local.symbolList = ArrayToList(local.symbolArray);

			if(arguments.minLength LT arguments.maxLength){
				local.length = randrange(arguments.minLength, arguments.maxLength);
			} else if(arguments.minLength EQ 0 and arguments.maxLength EQ 0){
				local.length = 6;
			}

			for(local.i=1; local.i LTE local.length; local.i=local.i+1){
				local.charType = 1;
				if(arguments.numeric){
					if(arguments.symbols){
						local.charType = randRange(1,3);
					} else {
						local.charType = randRange(1,2);
					}
				} else {
					if(arguments.symbols){
						local.charType = 3;
					}
				}

				switch(local.charType){
					case "1":
					{
						local.char= chr(randRange(97,122));
						local.randomString = local.randomString & local.char;
						break;
					}
					case "2":
					{
						local.char= chr(randRange(48,57));
						local.randomString = local.randomString & local.char;
						break;
					}
					case "3":
					{
						local.char= ListGetAt(local.symbolList,randRange(1,4));
						local.randomString = local.randomString & local.char;
						break;
					}

				}
			}
		</cfscript>

		<cfreturn local.randomString />
	</cffunction>
	<cffunction name="pickHashMethod" access="private" returntype="numeric" hint="I only support SHA 256, 384, and 512 so I work on CF standard" output="false">
		<cfscript>
			sleep(1);
			randomize(TimeFormat(Now(),"l"));
			return variables.instance.validHashes[RandRange(1,3)];
		</cfscript>
	</cffunction>


	<cffunction name="validateHashedString" access="public" returntype="boolean" output="false" hint="makes sure comparision always takes as long as possible based on the two strings">
		<cfargument name="stringToBeHashed"	type="string" required="true" />
		<cfargument name="salt"			type="string" required="true"/>
		<cfargument name="hashMethod"		type="numeric" required="true"  hint="must be 0, 256,384, or 512" />
		<cfargument name="hashedString"		type="string" required="true" />

		<cfset var newHash = saltAndHash(stringToBeHashed, salt, hashMethod) />
		<cfset var newAry = charsetdecode(newHash.hashedString, "us-ascii") />
		<cfset var oldAry = charsetdecode(hashedString, "us-ascii") />

		<cfreturn slowEquals(oldAry, newAry) />

	</cffunction>

	<cffunction name="slowEquals" access="private" returntype="boolean" output="false" hint="makes sure comparision always takes as long as possible based on the two arrays">
		<cfargument name="a" type="array" required="true" />
		<cfargument name="b" type="array" required="true" />
		<cfscript>
			var i = 0;
			var diff = ArrayLen(arguments.a) NEQ ArrayLen(arguments.b);
			for(i=0; i LT ArrayLen(arguments.a) AND i LT ArrayLen(arguments.b); i=i+1){
				diff = (arguments[a] NEQ arguments[b]) AND diff;
			}
			return NOT diff;
		</cfscript>
	</cffunction>


	<cffunction name="saltAndHash" access="public" returntype="struct" hint="struct contains hashed string, hash method, and salt" output="false">
		<cfargument name="stringToBeHashed"	type="string" required="true" />
		<cfargument name="salt"			type="string" required="false"  default="" />
		<cfargument name="hashMethod"		type="numeric" required="false" default="0"  hint="must be 0, 256,384, or 512" />

		<cfset var returnStruct = StructNew() />
		<cfset var hashedString = arguments.stringToBeHashed />
		<cfset var hashCount = 0 />

		<cfset sleep(1) /> <!--- make sure this can never be called twice in a row at the exact same millisecond --->

		<cfif arguments.hashMethod AND NOT ArrayFind(variables.instance.validHashes, arguments.hashMethod)>
			<cfthrow message="Invalid hash method provided.  Must be one of the following:  0, 256,384, or 512" />
		</cfif>

		<cfif NOT arguments.hashMethod>
			<cfset arguments.hashMethod = pickHashMethod()  />
		</cfif>
		<cfif NOT LEN(arguments.salt)>
			<cfset arguments.salt = makeSalt() />
		</cfif>


		<cfset returnStruct["hashMethod"] = arguments.hashMethod />
		<cfset returnStruct["salt"] = arguments.salt />

		<cfloop index="hashCount" from="1" to="5000">
			<cfset hashedString =  Hash(hashedString & arguments.salt, "SHA-" & arguments.hashMethod) />
		</cfloop>

		<cfset returnStruct["hashedString"] =hashedString >

		<cfreturn returnStruct />
	</cffunction>
</cfcomponent>