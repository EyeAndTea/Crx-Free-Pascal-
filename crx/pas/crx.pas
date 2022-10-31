unit crx;

{$mode objfpc}{$H+}
{$MACRO ON}
{$TYPEDADDRESS ON}
{$CODEPAGE UTF8}
{$modeswitch advancedrecords+}
 
{$if not(defined(FPC_VERSION)) or ((FPC_VERSION = 1) and ((FPC_RELEASE < 9) or 
		(FPC_PATCH < 3)))}
	{FPC1.9.3 IS WHEN $Selseif PRE PROCESSOR DIRECTIVE WAS INTRODUCED}
	{$fatal CRX: NO SUPPORT FOR FPC < v1.9.3}
{$endif}

{$REGION NOTES: STRINGS}
{USAGE:
	- CrxString IS THE FUNDAMENTAL TYPE. USE CrxString WITHOUT THE OVERLOADED OPERATORS
			FOR THE HIGHEST COMPATIBLITY WITH FPC VERSIONS.
	- IF YOU WISH TO USE THE OPERATORS, AND WISH TO RETAIN THE MOST COMPATIBLITY,
			CAST THE FIRST TERM IN AN EXPRESSION USING THE OVERLOADED OPERATORS
			TO CrxStringWrapper. WITH THIS COMPATIBLITY EXCLUDES FPC VERSIONS THAT
			DO NOT HAVE OPERATOR OVERLOADING.
	- IF YOU DO NOT USE CrxStringWrapper, YOU ALSO EXCLUDE COMPATIBLITY WITH FPC VERSIONS
			THAT DO NOT HAVE OPERATOR OVERLOADING FOR BUILT IN TYPES. THIS INCLUDES
			FPC2.6.4
	- IF YOU ONLY USE CrxString2, YOU ALSO EXCLUDE COMPATIBLITY WITH FPC VERSIONS THAT
			DO NOT HAVE ADVANCED RECORDS. HOWEVER, IF YOU TREAT CrxString2 AS
			CrxStringWrapper, YOU BRING BACK COMPATIBLITY WITH FPC VERSIONS THAT
			DO NOT HAVE OEPRATOR OVERLOADING FOR BUILT IN TYPES.
			
	FOR ASSIGNMENT:
	- IF ASSIGNING A STRING, NOT THE RESULT OF THE and OPERATOR OR OTHER FACILITIES PROVIDED
			HERE, THEN YOU MUST USE crx_makeCrxStringFrom(). FOR EXAMPLE:
					x : CrxString;
					x := crx_makeCrxStringFrom('fdgfd');
			AND NOT  
					x : CrxString;
					x := 'fdgfd';
			THE ABOVE WILL FAIL AND CAUSE AN ASSERTION ERROR DOWN THE LINE. HOWEVER THIS IS NOT NEEDED
			FOR CrxString2, ONLY CrxString. IF YOU ARE USING CrxStringWrapper, YOU CAN ALSO
			CAST TO CrxStringWrapper INSTEAD OF USING crx_makeCrxStringFrom(). FOR EXAMPLE:
					x : CrxString;
					x := CrxStringWrapper('fdgfd');
			
	FOR CODE POINTS USAGE:
	- USE crx_makeCrxStringFromCodePoints() AND crx_makeCrxStringFromCodePoints() WITH THE SYNTAX:
					 .. and crx_makeCrxStringFromCodePoints([3432, 42543, 543543, ..., 543], CODE_PAGE_ID)
			OR
					 crx_makeCrxStringFrom(.., 
							crx_makeCrxStringFromCodePoints([3432, 42543, 543543, ..., 543], CODE_PAGE_ID)) 
			AND SIMILAR FOR MAXIMUM COMPATIBILITY.
	- IF YOU WISH FOR THE EASIEST SYNTAX, USE
					.. and [CODE_PAGE_ID, 3432, 42543, 543543, ..., 543]
			BUT THIS WILL ONLY WORK IN FPC >= 3.2. IF USING FUNCTIONS SUCH AS crx_makeCrxStringFrom(),
			YOU WOULD STILL NEED TO USE crx_makeCrxStringFromCodePoints().
}
{NOTES: 
	
	- ADVANCED RECORDS WERE INTRODUCED IN FPC2.6.0 IT SEEMS, WHILE OPERATOR
			OVERLOADING WAS INTRODUCED MUCH EARLIER. ALTHOUGH MY REFERENCE
			IS FPC2.6.4, I CHOOSE TO KEEP CrxString AND CrxStringWrapper AS PART
			OF THE DESIGN FOR BACKWARD COMPAIBILITY WITH PRE REFERENCE.
	- CrxString2 IS FOR COMPATIBILITY OF OPERATOR OVERLOADS WITH GENERICS.
}
{ISSUES:
	- THE CODE DOES NOT MEET MY STANDARD.
	- THE CURRENT IMPLEMENTATION IS NOT REDUCED. ANALYSIS NEEDS TO BE DONE
			TO SEE WHERE THE COMPILER WILL BE MAKING COPIES FOR EXAMPLE.
			THE CODE FOLLOWS NEITHER TOP DOWN, NOR DOWN UP LAYOUT (SEE
			MY STANDARD)
	- CrxString2 BREAKS MY STANDARD BECAUSE OF ITS USAGE OF ADVANCED RECORDS.
	- CrxString MUST NEVER HAVE A CODE PAGE SET, BUT AN EMPTY CRX STRING HAS A CODE
			PAGE THAT CAN NOT BE CHANGED BECAUSE AN EMPTY STRING IS SIMPLY A NULL POINTER!!
			THIS IS WHY CrxString DOES NOT WORK WITH THE + OPERATOR
			AND INSTEAD ONE MUST USE THE and OPERATOR PROVIDED.
	- ONE IS LIMITED BY THE COMPILER ON WHAT OPERATORS CAN BE DEFINED FOR
			CrxString DESPITE DEFINING IT AS A NEW TYPE OF AnsiString RATHER
			THAN AN ALIAS. IF FPC2.6.4, NEW OPERATOR OVERLOADING IS NOT ALLOWED
			AT ALL FOR THE BUILT IN TYPE, HENCE THE EXISTANCE OF CrxStringWrapper.
			ON NEWER FPC, SUCH OVERLOADING IS ALLOWED, BUT YOU STILL CAN NOT
			DEFINE AN OPERATOR FOR AN OPERATION ALREADY DEFINED ELSE WHERE, 
			WHICH IS WELL DEFINED, EXCEPT THAT CrxString IS NOT BEING SEEN
			AS A TYPE DIFFERENT FROM AnsiString, HENCE THE USE OF OEPRATOR
			and INSTEAD OF +.
	- THE OPERATORS and AND << ARE CHOSEN SUCH AS THEY ARE OF EQUAL
			PRECEDANCE. HOWEVER THEY ARE OF HIGHER PRECEDENCE THAN THE OPERATOR
			+ THAT IS NATIVELY USED FOR STRING CONCATENATION. THIS CAN POSE
			A PROBLEM IN SEMANTICS.
			UPDATE: THE OPERATOR << IS NO LONGER USED
	- ARRAY OF CONST DOES NOT WORK WITH OPERATOR OVERLOADING BASEED ON MY TRIES.
	- Crx_PointerToCrxString DOES NOT ALWAYS WORK IF THE STRING IS EMPTY. I REMEMBER STRUGGLING
			WITH THIS BEFORE AND SEEING THAT IT DID NOT WORK, AND HENCE WHY I WAS FORCED TO USE 
			A REFERENCE IN CERTAIN FUNCTIONS BREAKING MY STANDARD. PERHAPS IT DEPENDS ON WHICH 
			FREE PASCAL VERSION I AM USING. LAST TIME I WAS PRIMARILY DEVELOPING ON FREE PASCAL 3.X,
			BUT AT THE TIME OF WRITING THIS NOTE I WAS PRIMARILY DEVELOPING A PROJECT ON 
			FREE PASCAL 2.6.4 AND THE PROBLEM DID NOT EXIST LIKE IT DID WHEN USING REFERENCE. OFCOURSE
			USING THE STRING ITSELF DOES BRING THE PROBLEM BACK. REMEMBER THAT USING A POINTER TO,
			CRXSTRING, OR Crx_PointerToCrxString, AMOUNTS TO POINTER TO POINTER.
			IN ANY CASE, THE FUNCTION crx_removeAnsiCharsFromFrontOf() WAS INTRODUCED SPECIFICALLY
			FOR THIS PROBLEM AND TO AVOID THE NEED TO WORRY ABOUT CODE PAGES AND THEIR VALUE
			FOR WHITE SPACE IF FOR EXAMPLE I IMPLEMENTED A TRIM FUNCTION INSTEAD. THIS WAY, CODE CAN 
			SET A STRING THAT IS TO BE POINTED TO TO ' ' OR EVEN SOMETHING ELSE, AND LATER 
			crx_removeAnsiCharsFromFrontOf() CAN BE USED TO REMOVE THE FIRST BOGUS CHARACTER. THE
			FUNCTION crx_removeAnsiCharsFromBackOf() WAS THEN INTRODUCED FOR COMPLETENESS.
}
{DESIGN:
	- TYPES:
		- CrxString IS THE FOUNDATION FOR ALL THE THREE TYPES, CrxString, CrxStringWrapper,
				AND CrxString2. CrxString IS DEFINED TO ALWAYS HAS THE CODE PAGE CP_NONE
				SET. THIS IS UNLIKE RawByteString WHICH SIMPLY HAS A FLOATING CODE PAGE.
				CRX STRING IS THE EQUIVILANT OF std::string IN C++.
		- IT MUST BE POSSIBLE TO EXCHANGE CrxString WITH CrxString2 AT ANY TIME. IT DOES NOT
				NEED TO BE POSSIBLE TO EXCHANGE CrxString2 WITH CrxString. THIS MEANS THAT
				IF CODE IS WRITTEN ORIGINALY USING CrxString, WHATEVER THAT CODE IS MUST
				WORK WITH CrxString2. THIS ONLY COVERS THE MECHANISMS PROVIDED HERE.
		- CrxStringWrapper IS FOR BACKWARD COMPATIBILITY WITH FPC2.6.4 WHEN USING
				OVERLOADED OPERATORS. IT IS FOR VERSIONS OF FPC WHERE OVERLOADING OF
				OPERATORS IS ALLOWED, BUT NOT ALLOWED AT ALL FOR BUILT IN TYPES.
	- CREATION:
		- CREATION
			- MUST BE POSSIBLE FOR BOTH CrxString AND CrxString2 FROM:
				- SINGLE BYTE NATIVE STRINGS: THESE INCLUDE ANSI STRINGS, AND CHARACTER ARRAYS
				- INTEGERS: I WAS UNSURE WHETHER TO USE THESE FOR UNICODE CHARACTERS OR ACTUAL
						INTEGERS. IN THE END I CHOOSE INTEGERS BECAUSE IT IS THE MORE COMMON
						USAGE FOR CREATING STRINGS.
				- FLOATS
				- BOOLEANS. THIS WAS NOT PART OF THE ORIGINAL DESIGN.
			- IS NOT POSSIBLE FOR CrxStringWrapper. CrxStringWrapper IS CREATED AS A CAST
					FROM CrxString ONLY.
			- MECHANISMS:
				- CrxString IS CREATED USING THE crx_makeCrxStringFrom() FUNCTIONS. THESE
						FUNCTIONS ARE DESIGNED WHILE TAKING ADVANTAGE OF IMPLICIT CASTS ALREADY
						DEFINED BY THE LANGUAGE. HENCE crx_makeCrxStringFrom(shortString)
						DOES NOT EXIST FOR EXAMPLE.
		- EXPLICIT CREATION
			- EXPLICIT HERE MEANS, MECHANISMS OTHER THAN THE MAIN CREATION MECHANISM PROVIDED
					FOR CREATION. EXPLICIT HERE IS NOT REFERING TO "EXPLICIT CAST"
			- IS NOT POSSIBLE FOR CrxStringWrapper.
			- EXPLICIT CREATION SHOULD BE POSSIBLE FROM
				- UNICODE CHARACTER POINT: CURRENTLY, THE TYPE UCS4Char IS USED. HOWEVER, THIS
						MIGHT PROVE PROBLOMATIC BECAUSE THE UCS4Char IS JUST AN INTEGRAL
						TYPE WHICH MIGHT CONFUSE THE COMPILER.
	- APPEND:
		- APPEND OPERATIONS MUST MIRROR THE CREATION OPERATONS.
	- CONCATENATE
		
}
{EXAMPLE USAGE
	CONSIDER:
					vCrxString := crx_makeCrxStringFrom(
									'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
							crx_makeCrxStringFrom('tuytu') +
							crx_makeCrxStringFromCodePoint($7403) + 
							crx_makeCrxStringFrom(''#$e6#$b1#$bd) +
							crx_makeCrxStringFromCodePoint($6C7D);
	NOTE THAT NO COMBINATION OF
					crx_makeCrxStringFrom
					AnsiString
					RawByteString
					OR NOTHING
	WORKS RELIABLY IN THE CONCATENATION UNLESS ALL ARE 
					crx_makeCrxStringFrom
	FOR EXAMPLE: NONE OF THE FOLLOWING WORKS
					crx_makeCrxStringFrom(
							'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
					'tuytu'
	OR
					crx_makeCrxStringFrom(
							'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
					RawByteString('tuytu')
	OR
					RawByteString(
							'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
					RawByteString('tuytu')
					
		VALID ALTERNATIVES TO THE ORIGINAL EXAMPLES ARE
					vCrxString := crx_makeCrxStringFrom(AnsiStringWithFloatingCodePage(
							'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
							'tuytu' +
							crx_makeAnsiStringFromCodePoint($7403) + 
							''#$e6#$b1#$bd +
							crx_makeAnsiStringFromCodePoint($6C7D));
		OR
					vCrxString := crx_makeCrxStringFrom([
							'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83, 
							'tuytu',
							crx_makeAnsiStringFromCodePoint($7403), 
							''#$e6#$b1#$bd,
							crx_makeAnsiStringFromCodePoints([$6C7D])]);
		OR						
					vCrxString := CrxStringWrapper('') and 
							crx_makeCrxStringFrom(
									'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) and 
							'tuytu' and
							crx_makeAnsiStringFromCodePoint($7403) and 
							''#$e6#$b1#$bd and
							crx_makeAnsiStringFromCodePoints([$6C7D]);					
		IN THE LAST ALTERNATIVE ABOVE, CrxStringWrapper CAST IS NEEDED FOR 
		FPC2.6.4. SO IN NEWER VERSIONS, INSTEAD OF 
					CrxStringWrapper('')
		WE COULD SIMPLY USE
					''			<=== (..(UNSURE IF THIS IS CORRECT. I MIGHT HAVE MADE A MISTAKE AND MEANT
										crx_makeCrxStringFrom('') OR NOTHING, BOTH BECAUSE OF 
										EMPTY STRYING.)..)
		BUT DEFEATS THE PURPOSE OF A NORMAL FORM.
		NOTE THAT THE FUNCTIONALITY FOR CRXSTRING OPERATORS IS WRITTEN PER LEFT HAND 
		SEMANTICS.
		
		IF YOU DO NOT CARE ABOUT COMPATIBILITY AT ALL, YOU CAN ALSO WRITE
					vCrxString := crx_makeCrxStringFrom(
									'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) and 
							'tuytu' and
							[CP_UTF8, $7403] and 
							''#$e6#$b1#$bd and
							[CP_UTF8, $6C7D];

	IF USING A POINTER TO CRXSTRING MAKE SURE THAT THE STRING IS NOT EMPTY EVEN IF THE CODE
		APPEARS TO WORK. FOR EXAMPLE
					var vCrxString : CrxString = ' ';
					var vCrxString__pointer : Crx_PointerToCrxString = Nil;
					.
					.
					vCrxString__pointer = @vCrxString;					
		LATER WHEN YOU FINISH WORKING DO
					crx_removeAnsiCharsFromFrontOf(vCrxString__pointer, 1);
					
}
{$ENDREGION}
{$REGION NOTES: MACROS}
{ISSUES:
	- CURRENTLY, NO MATTER WHAT I TRIED, MACROS DEFINED IN UNITS ARE NOT AVAILABLE FOR
			OTHER UNITS. I TRIED WRITING A MACRO IN THE interface SECTION, THE implementation
			SECTION, BEFORE THE interface SECTION, AFTER THE implementation SECTION, BEFORE
			THE unit DECLERATION, AND NOTHING WORKED. THIS WAS IN FPC 2.6.4
			IT SEEMS I WOULD HAVE TO RELY ON THE INCLUDE STATEMENTS TO MAKE THIS WORK.
	- FOR THE IDENTIFIERS, AS DEFINED IN MY STANDARD, USE COMMENTS. THESE INCLUDE THE
			IDENTIFIERS, CRX_NOT_MINE, CRX_NOT_NULL, AND CRX_PASSING. ALSO FREE PASCAL
			WOULD NEED, CRX_PRIVATE, CRX_PUBLIC, CRX_PROTECTED, CRX_PUBLIC_PRIVATE, ETC,
			BUT BECAUSE YOU ARE USING COMMENTS, NOT MACROS, IN FREE PASCAL, YOU COULD JUST USE
			THE IDENTIFIERS WITHOUT THE CRX_ PART.
}
{$ENDREGION}

interface
{$REGION INTERFACE}
	{$REGION DEFINES}
{------------------------------------------------------------------------------}
{$define CRX_TRUE := 1}
{$define CRX_FALSE := 0}

{$ifndef FPC_FULLVERSION}
	{$if FPC_VERSION = 1}
		{$if FPC_RELEASE = 9}
			{$if FPC_PATCH == 0}
				{$define FPC_FULLVERSION := 10900}
			{$elseif FPC_PATCH = 1}
				{$define FPC_FULLVERSION := 10901}
			{$elseif FPC_PATCH = 2}
				{$define FPC_FULLVERSION := 10902}
			{$elseif FPC_PATCH = 3}
				{$define FPC_FULLVERSION := 10903}
			{$elseif FPC_PATCH = 4}
				{$define FPC_FULLVERSION := 10904}
			{$elseif FPC_PATCH = 5}
				{$define FPC_FULLVERSION := 10905}
			{$elseif FPC_PATCH = 6}
				{$define FPC_FULLVERSION := 10906}
			{$elseif FPC_PATCH = 7}
				{$define FPC_FULLVERSION := 10907}
			{$elseif FPC_PATCH = 8}
				{$define FPC_FULLVERSION := 10908}
			{$elseif FPC_PATCH = 9}
				{$define FPC_FULLVERSION := 10909}
			{$elseif FPC_PATCH = 10}
				{$define FPC_FULLVERSION := 10910}
			{$else}
				{$fatal UNKNOWN PASCAL VERSION}
			{$endif}
		{$else}
			{$fatal UNKNOWN PASCAL VERSION}
		{$endif}
	{$elseif FPC_VERSION = 2}
		{$if FPC_RELEASE = 0}
			{$if FPC_PATCH == 0}
				{$define FPC_FULLVERSION := 20000}
			{$elseif FPC_PATCH = 1}
				{$define FPC_FULLVERSION := 20001}
			{$elseif FPC_PATCH = 2}
				{$define FPC_FULLVERSION := 20002}
			{$elseif FPC_PATCH = 3}
				{$define FPC_FULLVERSION := 20003}
			{$elseif FPC_PATCH = 4}
				{$define FPC_FULLVERSION := 20004}
			{$else}
				{$fatal UNKNOWN PASCAL VERSION}
			{$endif}
		{$elseif FPC_RELEASE = 1}
			{$if FPC_PATCH == 0}
				{$define FPC_FULLVERSION := 20100}
			{$elseif FPC_PATCH = 1}
				{$define FPC_FULLVERSION := 20101}
			{$elseif FPC_PATCH = 2}
				{$define FPC_FULLVERSION := 20102}
			{$elseif FPC_PATCH = 3}
				{$define FPC_FULLVERSION := 20103}
			{$elseif FPC_PATCH = 4}
				{$define FPC_FULLVERSION := 20104}
			{$else}
				{$fatal UNKNOWN PASCAL VERSION}
			{$endif}
		{$elseif FPC_RELEASE = 2}
			{$if FPC_PATCH == 0}
				{$define FPC_FULLVERSION := 20200}
			{$elseif FPC_PATCH = 1}
				{$define FPC_FULLVERSION := 20201}
			{$elseif FPC_PATCH = 2}
				{$define FPC_FULLVERSION := 20202}
			{$elseif FPC_PATCH = 3}
				{$define FPC_FULLVERSION := 20203}
			{$else}
				{$fatal UNKNOWN PASCAL VERSION}
			{$endif}
		{$else}
			{$fatal UNKNOWN PASCAL VERSION}
		{$endif}
	{$endif} 
{$endif}

{$if FPC_FULLVERSION >= 20600}
	{$define CRX__FPC__HAS_ADVANCED_RECORDS := 1}
{$else}
	{$define CRX__FPC__HAS_ADVANCED_RECORDS := 0}
{$endif}
{$if FPC_FULLVERSION >= 20200}
	{$define CRX__FPC__HAS_PARTIAL_ARRAYS_FOR_OPEN_ARRAYS := 1}
{$else}
	{$define CRX__FPC__HAS_PARTIAL_ARRAYS_FOR_OPEN_ARRAYS := 0}
{$endif}
{$if FPC_FULLVERSION >= 20402}
	{NOTE: CONFIRMED FROM AVAILABLE SOURCE CODE ON SOURCEFORGE}
	{$define CRX__FPC__CLASS__HAS_TO_STRING := 1}
{$else}
	{$define CRX__FPC__CLASS__HAS_TO_STRING := 0}
{$endif}
{$if FPC_FULLVERSION > 20604}
	{$define CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS := 1}
{$else}
	{$define CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS := 0}
{$endif}
{$if FPC_FULLVERSION <= 20604}
	{$define CRX__FPC__HAS_OPERATOR_OVERLOADING_FOR_BUILT_IN_TYPES := 0}
{$else}
	{$define CRX__FPC__HAS_OPERATOR_OVERLOADING_FOR_BUILT_IN_TYPES := 1}
{$endif}
{$if FPC_FULLVERSION < 30200}
	{$define CRX__FPC__HAS_INLINE_ARRAY_CONSTRUCTORS := 0}
{$else}
	{$define CRX__FPC__HAS_INLINE_ARRAY_CONSTRUCTORS := 1}
{$endif}

{------------------------------------------------------------------------------}
	{$ENDREGION}

	{$REGION INCLUDES}
{------------------------------------------------------------------------------}
uses windows,
{$if FPC_FULLVERSION <= 20604}
{uses} LConvEncoding,
{$endif}
{uses} sysUtils;
{------------------------------------------------------------------------------}
	{$ENDREGION}
	
	{$REGION TYPES}
	{
		THE << OPERATOR IS USED TO APPEND STRINGS USING UNICODE CODE POINTS. THE TYPE CrxInfoAndUCS4Char
		WAS MEANT TO ALLOW ENCODING THE CODE POINT ALONG WITH THE CODE PAGE. ORIGINAL DESIGN FAILED
		BECAUSE THERE IS NO SUPPORT IN THE LANGUAGE THAT WOULD ALLOW THE FOLLOWING TO WORK:
				gString := "gfdd" << [52, CP_UTF7]
		BUT IN FPC3.2 THE ABOVE MIGHT NOW BE SUPPORTED, BUT WHEN IT COMES TO BACKWARD COMPATIBILITY,
		THIS IS NOT VERY USEFUL. FURTHERMORE, [52, CP_UTF7] WOULD BE CONSIDERED AN OPEN ARRAY,
		AND HENCE WOULD NEVER EVALUATE TO CrxInfoAndUCS4Char WHICH IS AN ARRAY OF ONLY TWO ELEMENTS
		FURTHERMORE, THIS OPEN ARRAY WOULD BE ARRAY OF ELEMENTS OF THE TYPE OF THE FIRST ELEMENT, 52,
		AND NOT OF UCS4Char. IN THIS CASE, A CALLER WOULD ALSO HAVE TO CAST THE FIRST ELEMENT
		TO UCS4Char, BUT THE ARRAY WOULD STILL NOT EVALUATE TO CrxInfoAndUCS4Char AS MENTIONED
		EARLIER. HENCE IN THE FUTURE, THE OPERATOR << WILL TAKE AN "array of UCS4Char" AS IT CURRENTLY
		DOES, BUT THE FIRST ARRAY ELEMENT WILL BE ASSUMED TO BE THE CODE PAGE, AND HENCE BE MANDATORY.
		
		POSSIBLE SYNTAX APPROACHES FOR FUTURE WORK:
		... << someType
		... << array of someType
		... << [232, 4324, 654, ...] //EXPLICIT CODE POINT ARRAY WITH FIRST ELEMENT BEING CODE PAGE
		... << newMyCharArray(codePage, [232, 4324, 654, ...])  //WHERE SECOND PARAMETER IS ARRAY OF CONST
		... << newMyCharArray(codePage, [232, 4324, 654, ...])  //WHERE SECOND PARAMETER IS ARRAY OF CODE POINTS
		
		NOTE THAT THE FORM newMyCharArray WOULD BE REQUIRED FOR WHEN USING crx_makeCrxStringFrom()
		AND SIMILAR. THE TWO IMPLEMENTATIONS OF newMyCharArray WOULD BE REQUIRED TO SUPPORT
		DIFFERENT VERSION OF FREE PASCAL, ENABLING ONLY OF THE IMPLEMENTATIONS AT A TIME. 
		
		NOTE ATTEMPTING TO USE ARRAY OF CONST WHEN INLINE ARRAY CONSTRUCTORS ARE NOT AVAILABLE
		DID NOT WORK WITH OPERATOR OVERLOADING.
	}
	{type CrxInfoAndUCS4Char = array[0..1] of UCS4Char;
	type CrxInfoAndCollectionOfUCS4Char = record
		gCodePage : cardinal;
		gUCS4Chars : array of UCS4Char;
	end;}
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
	type CrxString = type AnsiString;	
	type AnsiStringWithFloatingCodePage = type AnsiString;
	type CrxStringWrapper = record
		gCrxString : CrxString;
	end;
{$else}
	type CrxString = type RawByteString;
	type AnsiStringWithFloatingCodePage = type RawByteString;
	type CrxStringWrapper = CrxString;
{$endif}
	{WARNING: POINTED TO CrxString CAN NOT BE EMPTY.}
	type Crx_PointerToCrxString = ^CrxString;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	type CrxString2 = record
		public gCrxString : CrxString;
		class operator :=(const pCrxString2 : CrxString2) : CrxString;
		class operator :=(const pCrxString : CrxString) : CrxString2;
		class operator :=(const pAnsiChars : shortString) : CrxString2;
		class operator :=(const pLongInt : longInt) : CrxString2;
		class operator :=(const pExtended : extended) : CrxString2;

		class operator and(const pCrxString2 : CrxString2; const pCrxString2__2 : CrxString2) : 
				CrxString2;
		class operator and(const pCrxString2 : CrxString2; const pCrxString : CrxString) : CrxString2;
		class operator and(const pCrxString2 : CrxString2; const pLongInt : longInt) : CrxString2;
		class operator and(const pCrxString2 : CrxString2; const pExtended : extended) : CrxString2;

		{class operator <<(const pCrxString2 : CrxString2; pUnicodeValue : UCS4Char) : CrxString2;}
		{WARNING: THE FIRST ELEMENT IN pUnicodeValues IS EXPECTED TO BE THE CODE PAGE}
		class operator and(const pCrxString2 : CrxString2; pUnicodeValues : array of UCS4Char) : CrxString2;
		{class operator and(const pCrxString2 : CrxString2; pCrxInfoAndUCS4Char : CrxInfoAndUCS4Char) :
				CrxString2;
		class operator and(const pCrxString2 : CrxString2; 
				pCrxInfoAndCollectionOfUCS4Char : CrxInfoAndCollectionOfUCS4Char) :	CrxString2;}
	end;
{$endif}
	{$ENDREGION}

	{$REGION GLOBALS}
		{$REGION CONSTANTS}
	const CRX__FPC_VERSION = FPC_FULLVERSION;
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
	const CP_ACP = 0;
	const CP_ASCII = 20127;
	const CP_NONE = $FFFF;
	const CP_OEMCP = 1;
	const CP_UTF16 = 1200;
	const CP_UTF16BE = 1201;
	const CP_UTF7 = 65000;
	const CP_UTF8 = 65001;
{$endif}
		{$ENDREGION}

	function crx_makeCrxStringFrom(const pCrxString : CrxString) : CrxString;
	function crx_makeCrxStringFrom(const pLongInt : longInt) : CrxString;
	function crx_makeCrxStringFrom(const pExtended : extended) : CrxString;
	function crx_makeCrxStringFrom(const pBoolean : Boolean) : CrxString; //ADDED RECENTLY. UNSURE IF WRONG.
	function crx_makeCrxStringFrom(pArgs: array of const) : CrxString;
	
	function crx_getLengthOf(const pCrxString : CrxString) : size_t;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_getLengthOf(const pCrxString2 : CrxString2) : size_t;
{$endif}

	{NOTE THAT THE INDEX IS 0 BASED. THIS CHOICE WAS MADE BCAUSE PASCAL'S ARRAYS ARE ZERO INDEXED.}
	function crx_getAnsiCharAt(const pLongInt : longInt; const pCrxString : CrxString) : ansiChar;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_getAnsiCharAt(const pLongInt : longInt; const pCrxString2 : CrxString2) : ansiChar;
{$endif}
	
	procedure crx_appendTo(var pCrxString : CrxString; const pCrxString__2 : CrxString);
	procedure crx_appendTo(var pCrxString : CrxString; const pLongInt : longInt);
	procedure crx_appendTo(var pCrxString : CrxString; const pExtended : extended);
	procedure crx_appendTo(var pCrxString : CrxString; pArgs: array of const);
{$if CRX__FPC__HAS_ADVANCED_RECORDS} 
	procedure crx_appendTo(var pCrxString2 : CrxString2; var pCrxString2__2 : CrxString2);
	procedure crx_appendTo(var pCrxString2 : CrxString2; const pLongInt : longInt);
	procedure crx_appendTo(var pCrxString2 : CrxString2; const pExtended : extended);
	procedure crx_appendTo(var pCrxString2 : CrxString2; const pCrxString : CrxString);
	procedure crx_appendTo(var pCrxString2 : CrxString2; pArgs: array of const);	
{$endif}
	
{$if not(CRX__FPC__HAS_OPERATOR_OVERLOADING_FOR_BUILT_IN_TYPES)}
	operator := (const pCrxString : CrxString) : CrxStringWrapper;
	operator := (const pCrxStringWrapper : CrxStringWrapper) : CrxString;
	operator and(const pCrxStringWrapper : CrxStringWrapper; const pCrxString : CrxString) : 
			CrxStringWrapper;
	operator and(const pCrxStringWrapper : CrxStringWrapper; const pLongInt : longInt) : 
			CrxStringWrapper;
	operator and(const pCrxStringWrapper : CrxStringWrapper; const pExtended : extended) : 
			CrxStringWrapper;
	{operator <<(const pCrxStringWrapper : CrxStringWrapper; pUnicodeValue : UCS4Char) :
			CrxStringWrapper;}
	{WARNING: THE FIRST ELEMENT IN pUnicodeValues IS EXPECTED TO BE THE CODE PAGE}
	operator and(const pCrxStringWrapper : CrxStringWrapper; pUnicodeValues : array of UCS4Char) :
			CrxStringWrapper;
	{operator and(const pCrxStringWrapper : CrxStringWrapper; pCrxInfoAndUCS4Char : CrxInfoAndUCS4Char) :
			CrxStringWrapper;
	operator and(const pCrxStringWrapper : CrxStringWrapper; 
			pCrxInfoAndCollectionOfUCS4Char : CrxInfoAndCollectionOfUCS4Char) :	CrxStringWrapper;}
{$else}
	operator and(const pCrxString : CrxString; const pCrxString__2 : CrxString) : 
			CrxString;
	operator and(const pCrxString : CrxString; const pLongInt : longInt) : 
			CrxString;
	operator and(const pCrxString : CrxString; const pExtended : extended) : 
			CrxString;
	{operator <<(const pCrxString : CrxString; pUnicodeValue : UCS4Char) :
			CrxString;}
	{WARNING: THE FIRST ELEMENT IN pUnicodeValues IS EXPECTED TO BE THE CODE PAGE}
	operator and(const pCrxString : CrxString; pUnicodeValues : array of UCS4Char) :
			CrxString;
	{operator and(const pCrxString : CrxString; pCrxInfoAndUCS4Char : CrxInfoAndUCS4Char) :
			CrxString;
	operator and(const pCrxString : CrxString; 
			pCrxInfoAndCollectionOfUCS4Char : CrxInfoAndCollectionOfUCS4Char) : CrxString;}
{$endif}
	
	function crx_makeCrxStringFromCodePoint(pUnicodeValue : UCS4Char; pCodePageId : cardinal = CP_UTF8) : 
			CrxString;
	function crx_makeCrxStringFromCodePoints(pUnicodeValues : array of UCS4Char; 
			pCodePageId : cardinal = CP_UTF8) : CrxString;
{$if not(CRX__FPC__HAS_INLINE_ARRAY_CONSTRUCTORS)}
	{
		WARNING: pUnicodeValues MUST ONLY COTNAIN UCS4Char ELEMENTS.

		THIS FUNCTION IS TO ADD SUPPORT FOR CALLING THE FUNCTION USING THE SYNTAX:
				crx_makeCrxStringFromCodePoints([33, 455, 4, ..., 3244], CP_UTF8)
		IN OLDER PASCAL WHERE INLINE ARRAY CONSTRUCTORS ARE NOT SUPPORTED.
	}
	function crx_makeCrxStringFromCodePoints(pUnicodeValues : array of const;
			pCodePageId : cardinal = CP_UTF8) : CrxString;
{$endif}
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_makeCrxString2FromCodePoint(pUnicodeValue : UCS4Char; pCodePageId : cardinal = CP_UTF8) : 
			CrxString2;
	function crx_makeCrxString2FromCodePoints(pUnicodeValues : array of UCS4Char; 
			pCodePageId : cardinal = CP_UTF8) : CrxString2;
{$endif}

	function crx_converCrxStringToAnsiString(const pCrxString : CrxString;
			pCodePage__from : cardinal; pCodePage__to : cardinal) : AnsiStringWithFloatingCodePage;
	function crx_convertCrxStringToUnicodeString(const pCrxString : CrxString; pCodePageId : cardinal) :
			UnicodeString;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_converCrxString2ToAnsiString(const pCrxString2 : CrxString2;
			pCodePage__from : cardinal; pCodePage__to : cardinal) : AnsiStringWithFloatingCodePage;
	function crx_convertCrxString2ToUnicodeString(const pCrxString2 : CrxString2; 
			pCodePageId : cardinal) : UnicodeString;
{$endif}

	function crx_convertUnicodeStringToCrxString(const pUnicodeString: UnicodeString; 
			pCodePageId: cardinal) : CrxString;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_convertUnicodeStringToCrxString2(const pUnicodeString: UnicodeString; 
			pCodePageId: cardinal) : CrxString2;
{$endif}

	procedure crx_converCodePageOf(var pCrxString : CrxString;
			pCodePage__from : cardinal; pCodePage__to : cardinal);
	procedure crx_converCodePageOf(var pCrxString2 : CrxString2;
			pCodePage__from : cardinal; pCodePage__to : cardinal);
			
	function crx_join(const pDelimeterString : AnsiStringWithFloatingCodePage;
			const pStrings : array of AnsiStringWithFloatingCodePage) : CrxString;
	function crx_join(const pDelimeterString : AnsiStringWithFloatingCodePage;
			const pArgs : array of const) : CrxString;

	procedure crx_removeAnsiCharsFromFrontOf(var pCrxString : CrxString; pNumberOfAnsiChars : size_t);
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	procedure crx_removeAnsiCharsFromFrontOf(var pCrxString2 : CrxString2; pNumberOfAnsiChars : size_t);
{$endif}
	procedure crx_removeAnsiCharsFromBackOf(var pCrxString : CrxString; pNumberOfAnsiChars : size_t);
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	procedure crx_removeAnsiCharsFromBackOf(var pCrxString2 : CrxString2; pNumberOfAnsiChars : size_t);
{$endif}

	function crx_makeAnsiStringFromCodePoint(pUnicodeValue : UCS4Char; pCodePageId : cardinal = CP_UTF8) : 
			AnsiStringWithFloatingCodePage;
	function crx_makeAnsiStringFromCodePoints(pUnicodeValues : array of UCS4Char;
			pCodePageId : cardinal = CP_UTF8) : AnsiStringWithFloatingCodePage;
			
	function crx_convertWideStringToAnsiString(pWideString : WideString;
			pCodePageId : cardinal) : AnsiString;

	function _crx_test_crxString() : AnsiStringWithFloatingCodePage;
	{$ENDREGION}
{$ENDREGION}
			

implementation
{$REGION IMPLEMENTATION}
	function crx_isValidCrxString(const pCrxString : CrxString) : boolean;
		begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		result := true;
{$else}
		result := ((pCrxString = '') or (stringCodePage(pCrxString) = CP_NONE));
{$endif}
	end;
	
	{
		THE IMPORTANT CONVERSIONS ARE:
			ANSI + CODE PAGE ID => UNICODE
			UNICODE => ANSI + CODE PAGE ID
		I MIGHT ALSO LATER ADD WIDE STRING, AND IF SO
		THE FOLLOWING CONVERSIONS:
			ANS + CODE PAGE ID => WIDE
			WIDE => ANSI + CODE PAGE ID
			UNICODE => WIDE
			WIDE => UNICODE

		WE USE CrxString INSTEAD OF AnsiString
	}
	
	{
		WARNING: IF STRING IS EMPTY, THE RETURN VALUE IS NOT OF TYPE
		CrxString. THIS IS BECAUSE setCodePage WILL NOT WORK, AND THE
		RETURN VALUE WILL NOT HAVE A CODE PAGE OF CP_NONE. THIS IS
		REGARDLESS OF THE FACT THAT AN EMPTY AnsiString IS JUST A NIL.
		THE EFFECTIVE CODE PAGE OF THE EMPTY STRING IS NOT CP_NONE,
		AND THIS IS WHAT MATTERS.
	}
	function crx_makeCrxStringFrom(const pCrxString : CrxString) : CrxString;
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		var vReturn : CrxString;
{$endif}
		begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		result := pCrxString; exit;	
{$else}
		vReturn := pCrxString;
		{if(vReturn = '') then
			vReturn := ' ';
			setCodePage(vReturn, CP_NONE, false);
			ShowMessage(IntToStr(StringCodePage(vReturn)));
			vReturn := trim(vReturn);
			ShowMessage(IntToStr(StringCodePage(vReturn)));}
		//UniqueString(vReturn);
		//ShowMessage(IntToStr(StringCodePage(vReturn)));
		setCodePage(vReturn, CP_NONE, false);
		//ShowMessage(IntToStr(StringCodePage(vReturn)));
		result := vReturn; exit;
{$endif}
	end;
	function crx_makeCrxStringFrom(const pLongInt : longInt) : CrxString;
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		var vReturn : CrxString;
{$endif}
		begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		result := intToStr(pLongInt); exit;	
{$else}
		vReturn := intToStr(pLongInt);
		setCodePage(vReturn, CP_NONE, false);

		result := vReturn; exit;
{$endif}
	end;
	function crx_makeCrxStringFrom(const pExtended : extended) : CrxString;
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		var vReturn : CrxString;
{$endif}
		begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		result := floatToStr(pExtended); exit;	
{$else}
		vReturn := floatToStr(pExtended);
		setCodePage(vReturn, CP_NONE, false);

		result := vReturn; exit;
{$endif}
	end;
	function crx_makeCrxStringFrom(const pBoolean : Boolean) : CrxString;
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		var vReturn : CrxString;
{$endif}
		begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		if(pBoolean) then begin
			result := 'true'; exit;
		end else begin
			result := 'false'; exit;
		end; 	
{$else}
		if(pBoolean) then begin
			vReturn := 'true'; exit;
		end else begin
			vReturn := 'false'; exit;
		end;

		setCodePage(vReturn, CP_NONE, false);

		result := vReturn; exit;
{$endif}
    end;
	function crx_makeCrxStringFrom(pArgs: array of const) : CrxString;
		var vReturn : CrxString;
		var {block} tI : cardinal = 0;
		
		begin
		vReturn := crx_makeCrxStringFrom('');

		if High(pArgs) < 0 then begin  
			result := vReturn; exit;
		end else begin
			for tI:=0 to High(pArgs) do begin
				case pArgs[tI].vtype of  
					vtinteger: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								intToStr(pArgs[tI].vinteger)));
					end;
					vtboolean: begin
						if pArgs[tI].vboolean then begin
							crx_appendTo(vReturn,
									crx_makeCrxStringFrom('true'));
						end else begin
							crx_appendTo(vReturn, 
									crx_makeCrxStringFrom('false'));
						end;
					end;  
					vtchar: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].vchar));
					end;
					vtExtended: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								floatToStr(pArgs[tI].VExtended^)));
					end;
					vtstring: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].VString^));
					end;
					vtpChar: begin
						if pArgs[tI].VPChar <> NIL then begin
							crx_appendTo(vReturn, 
									crx_makeCrxStringFrom(pArgs[tI].VPChar));
						end;
					end;
					vtObject: begin {NOTE THAT THIS IS AN INSTANCE OF A CLASS, NOT AN INSTANCE OF AN OBJECT}
{$if CRX__FPC__CLASS__HAS_TO_STRING}
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].VObject.toString()));
{$else}
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].VObject.Classname()));
{$endif}
					end;
					vtClass: begin {NOTE THAT THIS IS THE CLASS DEFINITION OBJECT}
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].VClass.className()));
					end; 
					vtAnsiString: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								AnsiString(pArgs[tI].VAnsiString)));
					end;  
					else begin
					end;  
				end; 
			end; 
		end;
		
		result := vReturn; exit;
	end;
	
	function crx_getLengthOf(const pCrxString : CrxString) : size_t; begin
		assert(crx_isValidCrxString(pCrxString));

		result := length(pCrxString);
	end;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_getLengthOf(const pCrxString2 : CrxString2) : size_t; begin
		assert(crx_isValidCrxString(pCrxString2));
		
		result := length(pCrxString2.gCrxString);
	end;
{$endif}

	function crx_getAnsiCharAt(const pLongInt : longInt; const pCrxString : CrxString) : ansiChar; begin
		assert(crx_isValidCrxString(pCrxString));
		
		result := pCrxString[pLongInt + 1];
	end;
	function crx_getAnsiCharAt(const pLongInt : longInt; const pCrxString2 : CrxString2) : ansiChar; begin
		assert(crx_isValidCrxString(pCrxString2));
		
		result := pCrxString2.gCrxString[pLongInt + 1];
	end;
	
	{NOTE: ASKING FOR A REFERENCE TO A STRING BECAUSE OF THE WAY PASCAL DEALS WITH
			STRINGS THAT ARE EMPTY, WHICH ARE ESSENTIALLY WITHOUT THEIR STRUCTURE.
			STRINGS ARE POINTERS BEHIND THE SCENE, AND AN EMPTY STRING IN PASCAL
			IS A NULL POINTER, THUS CAUSING THE PROBLEMS, AND THE NEED TO USE
			A REFERENCE INSTEAD OF A POINTER. A VALIDATION OF THE PROOF IN MY STANDARD
			THAN NULL DOES NOT EQUAL EMPTY.}
	procedure crx_appendTo(var pCrxString : CrxString; const pCrxString__2 : CrxString);
		var vAvailableSpace : size_t = 0;
		var vExtraSpace : size_t = 0;

		begin
		assert(crx_isValidCrxString(pCrxString));
		assert(crx_isValidCrxString(pCrxString__2));

		//vCrxString := pCrxString^;
		UniqueString(pCrxString);
		vAvailableSpace := length(pCrxString);
		vExtraSpace := length(pCrxString__2);

		if vExtraSpace > 0 then begin
			setLength(pCrxString, vAvailableSpace + vExtraSpace);
			
			move(pCrxString__2[1], pCrxString[vAvailableSpace + 1], vExtraSpace);

{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
			if vAvailableSpace = 0 then begin
				setCodePage(pCrxString, CP_NONE, false);
			end;
{$endif}
		end;
	end;
	procedure crx_appendTo(var pCrxString : CrxString; const pLongInt : longInt);
		begin
		crx_appendTo(pCrxString, crx_makeCrxStringFrom(pLongInt));
	end;
	procedure crx_appendTo(var pCrxString : CrxString; const pExtended : extended);
		begin
		crx_appendTo(pCrxString, crx_makeCrxStringFrom(pExtended));
	end;
	procedure crx_appendTo(var pCrxString : CrxString; pArgs: array of const);
		var {block} tI : cardinal = 0;
		
		begin
		assert(crx_isValidCrxString(pCrxString));

		if High(pArgs) < 0 then begin  
		end	else begin
			for tI:=0 to High(pArgs) do begin
				case pArgs[tI].vtype of  
					vtinteger: begin
						crx_appendTo(pCrxString, crx_makeCrxStringFrom(
								intToStr(pArgs[tI].vinteger)));
					end;
					vtboolean: begin
						if pArgs[tI].vboolean then begin
							crx_appendTo(pCrxString,
									crx_makeCrxStringFrom('true'));
						end else begin
							crx_appendTo(pCrxString, 
									crx_makeCrxStringFrom('false'));
						end;
					end;  
					vtchar: begin
						crx_appendTo(pCrxString, crx_makeCrxStringFrom(
								pArgs[tI].vchar));
					end;
					vtstring: begin
						crx_appendTo(pCrxString, crx_makeCrxStringFrom(
								pArgs[tI].VString^));
					end;
					vtpChar: begin
						if pArgs[tI].VPChar <> NIL then begin
							crx_appendTo(pCrxString, 
									crx_makeCrxStringFrom(pArgs[tI].VPChar));
						end;
					end;
					vtObject: begin
						crx_appendTo(pCrxString, crx_makeCrxStringFrom(
								pArgs[tI].VObject.Classname));
					end;
					vtClass: begin
						crx_appendTo(pCrxString, crx_makeCrxStringFrom(
								pArgs[tI].VClass.Classname));
					end; 
					vtAnsiString: begin
						crx_appendTo(pCrxString, crx_makeCrxStringFrom(
								AnsiString(pArgs[tI].VAnsiString)));
					end;  
					else begin
					end;  
				end; 
			end; 
		end;
	end;
	procedure crx_appendTo(var pCrxString2 : CrxString2; var pCrxString2__2 : CrxString2);
		begin
		crx_appendTo(pCrxString2.gCrxString, pCrxString2__2.gCrxString);
	end;
	procedure crx_appendTo(var pCrxString2 : CrxString2; const pCrxString : CrxString);
		begin
			crx_appendTo(pCrxString2.gCrxString, pCrxString);
	end;
	procedure crx_appendTo(var pCrxString2 : CrxString2; const pLongInt : longInt);
		begin
		crx_appendTo(pCrxString2.gCrxString, crx_makeCrxStringFrom(pLongInt));
	end;
	procedure crx_appendTo(var pCrxString2 : CrxString2; const pExtended : extended);
		begin
		crx_appendTo(pCrxString2.gCrxString, crx_makeCrxStringFrom(pExtended));
	end;
	procedure crx_appendTo(var pCrxString2 : CrxString2; pArgs: array of const);
		begin
			crx_appendTo(pCrxString2.gCrxString, pArgs);
	end;
	
{$if not(CRX__FPC__HAS_OPERATOR_OVERLOADING_FOR_BUILT_IN_TYPES)}
	operator := (const pCrxString : CrxString) : CrxStringWrapper; begin
		assert(crx_isValidCrxString(pCrxString));

		result.gCrxString := pCrxString;
	end;
	operator := (const pCrxStringWrapper : CrxStringWrapper) : CrxString; begin
		result := pCrxStringWrapper.gCrxString;
	end;
	operator and(const pCrxStringWrapper : CrxStringWrapper; const pCrxString : CrxString) : 
			CrxStringWrapper; begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, pCrxString]); exit;
	end;
	operator and(const pCrxStringWrapper : CrxStringWrapper; const pLongInt : longInt) : 
			CrxStringWrapper; begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, pLongInt]); exit;
	end;
	operator and(const pCrxStringWrapper : CrxStringWrapper; const pExtended : extended) : 
			CrxStringWrapper; begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, pExtended]); exit;
	end;
	{operator <<(const pCrxStringWrapper : CrxStringWrapper; pUnicodeValue : UCS4Char) :
			CrxStringWrapper;
		begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, 
				crx_makeCrxStringFromCodePoint(pUnicodeValue)]);
	end;}
	operator and(const pCrxStringWrapper : CrxStringWrapper; pUnicodeValues : array of UCS4Char) :
			CrxStringWrapper;
		var vUCS4Chars : array of UCS4Char;
		var t : size_t = 0;

		begin
		assert(length(pUnicodeValues) > 1);
		t := length(pUnicodeValues) - 1;

	{$if CRX__FPC__HAS_PARTIAL_ARRAYS_FOR_OPEN_ARRAYS}
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, 
				crx_makeCrxStringFromCodePoints(pUnicodeValues[1..t], pUnicodeValues[0])]);
	{$else}
		setLength(vUCS4Chars, t);
		move(((@pUnicodeValues[0]) + sizeof(UCS4Char))^, vUCS4Chars, t); 
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, 
				crx_makeCrxStringFromCodePoints(vUCS4Chars, pUnicodeValues[0])]);
	{$endif}
	end;
	{operator and(const pCrxStringWrapper : CrxStringWrapper; pCrxInfoAndUCS4Char : CrxInfoAndUCS4Char) :
			CrxStringWrapper;
		begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, 
				crx_makeCrxStringFromCodePoint(pCrxInfoAndUCS4Char[1], pCrxInfoAndUCS4Char[0])]);
	end;
	operator and(const pCrxStringWrapper : CrxStringWrapper; 
			pCrxInfoAndCollectionOfUCS4Char : CrxInfoAndCollectionOfUCS4Char) : CrxStringWrapper;
		begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxStringWrapper.gCrxString, 
				crx_makeCrxStringFromCodePoints(pCrxInfoAndCollectionOfUCS4Char.gUCS4Chars, 
				pCrxInfoAndCollectionOfUCS4Char.gCodePage)]);
	end;}
{$else}
	operator and (const pCrxString : CrxString; const pCrxString__2 : CrxString) : 
			CrxString; begin
		result := crx_makeCrxStringFrom([pCrxString, pCrxString__2]); exit;
	end;
	operator and(const pCrxString : CrxString; const pLongInt : longInt) : 
			CrxString; begin
		result := crx_makeCrxStringFrom([pCrxString, pLongInt]); exit;
	end;
	operator and(const pCrxString : CrxString; const pExtended : extended) : 
			CrxString; begin
		result := crx_makeCrxStringFrom([pCrxString, pExtended]); exit;
	end;
	{operator <<(const pCrxString : CrxString; pUnicodeValue : UCS4Char) :
			CrxString;
		begin
		result := crx_makeCrxStringFrom([pCrxString, 
				crx_makeCrxStringFromCodePoint(pUnicodeValue)]);
	end;}
	operator and(const pCrxString : CrxString; pUnicodeValues : array of UCS4Char) :
			CrxString;
	{$if not(CRX__FPC__HAS_PARTIAL_ARRAYS_FOR_OPEN_ARRAYS)}
		var vUCS4Chars : array of UCS4Char;
	{$endif}
		var vNumberOfUCSChars : size_t = 0;

		begin
		assert(length(pUnicodeValues) > 1);
		vNumberOfUCSChars := length(pUnicodeValues) - 1;

	{$if CRX__FPC__HAS_PARTIAL_ARRAYS_FOR_OPEN_ARRAYS}
		result := crx_makeCrxStringFrom([pCrxString, 
				crx_makeCrxStringFromCodePoints(pUnicodeValues[1..vNumberOfUCSChars], pUnicodeValues[0])]);
	{$else}
		setLength(vUCS4Chars, vNumberOfUCSChars);
		move(((@pUnicodeValues[0]) + sizeof(UCS4Char))^, vUCS4Chars, vNumberOfUCSChars); 
		result := crx_makeCrxStringFrom([pCrxString, 
				crx_makeCrxStringFromCodePoints(vUCS4Chars, pUnicodeValues[0])]);
	{$endif}
	end;
	{operator and(const pCrxString : CrxString; pCrxInfoAndUCS4Char : CrxInfoAndUCS4Char) :
			CrxString;
		begin
		result := crx_makeCrxStringFrom([pCrxString, 
				crx_makeCrxStringFromCodePoint(pCrxInfoAndUCS4Char[1], pCrxInfoAndUCS4Char[0])]);
	end;
	operator and(const pCrxString : CrxString; pCrxInfoAndCollectionOfUCS4Char : CrxInfoAndCollectionOfUCS4Char) :
			CrxString;
		begin
		result := crx_makeCrxStringFrom([pCrxString, 
				crx_makeCrxStringFromCodePoints(pCrxInfoAndCollectionOfUCS4Char.gUCS4Chars, 
				pCrxInfoAndCollectionOfUCS4Char.gCodePage)]);
	end;}
{$endif}

	function crx_makeCrxStringFromCodePoint(pUnicodeValue : UCS4Char; pCodePageId : cardinal = CP_UTF8) : 
			CrxString;
		var vUCS4String : UCS4String;

		begin
		setLength(vUCS4String, 2);
		vUCS4String[0] := pUnicodeValue;
		vUCS4String[1] := 0;

		result := crx_convertUnicodeStringToCrxString(
				UCS4StringToUnicodeString(vUCS4String), pCodePageId); exit;
	end;
	function crx_makeCrxStringFromCodePoints(pUnicodeValues : array of UCS4Char; 
			pCodePageId : cardinal = CP_UTF8) : CrxString;
		var vReturn : CrxString {= ''};
		var {block} tI : size_t;
		
		begin
		if High(pUnicodeValues) >= 0 then begin
		    for {var} tI := low(pUnicodeValues) to High(pUnicodeValues) do begin
			    if(vReturn = '') then begin
				    vReturn := crx_makeCrxStringFromCodePoint(pUnicodeValues[tI], pCodePageId);
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
					setCodePage(vReturn, CP_NONE, false);
{$endif}
				end else begin
				    vReturn := vReturn + crx_makeCrxStringFromCodePoint(pUnicodeValues[tI])
			    end;
			end;
		end;

		result := vReturn; exit;
	end;
{$if not(CRX__FPC__HAS_INLINE_ARRAY_CONSTRUCTORS)}
	function crx_makeCrxStringFromCodePoints(pUnicodeValues : array of const;
			pCodePageId : cardinal = CP_UTF8) : CrxString;
		var vUCS4Chars : array of UCS4Char;
		var {block} tCurrentIndex : size_t;
		var {block} tI : size_t;

		begin
		if High(pUnicodeValues) < 0 then begin  
		end else begin
			{var} tCurrentIndex := 0;
			
			setLength(vUCS4Chars, length(pUnicodeValues));

			for tI:=0 to High(pUnicodeValues) do begin
				case pUnicodeValues[tI].vtype of
					vtinteger: begin
						vUCS4Chars[tCurrentIndex] := pUnicodeValues[tI].vinteger;
						tCurrentIndex := tCurrentIndex + 1;
					end;
				end;
			end;
			
			setLength(vUCS4Chars, tCurrentIndex);
		end;

		result := crx_makeCrxStringFromCodePoints(vUCS4Chars, pCodePageId);
	end;
{$endif}
	
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_makeCrxString2FromCodePoint(pUnicodeValue : UCS4Char; pCodePageId : cardinal = CP_UTF8) : 
			CrxString2; begin
		result.gCrxString := crx_makeCrxStringFromCodePoint(pUnicodeValue, pCodePageId);
	end;
	function crx_makeCrxString2FromCodePoints(pUnicodeValues : array of UCS4Char; 
			pCodePageId : cardinal = CP_UTF8) : CrxString2; begin
		result.gCrxString := crx_makeCrxStringFromCodePoints(pUnicodeValues, pCodePageId);
	end;
	{$if not(CRX__FPC__HAS_INLINE_ARRAY_CONSTRUCTORS)}
	function crx_makeCrxString2FromCodePoints(pUnicodeValues : array of const;
			pCodePageId : cardinal = CP_UTF8) : CrxString2; begin
		result.gCrxString := crx_makeCrxStringFromCodePoints(pUnicodeValues, pCodePageId);
	end;
	{$endif}
{$endif}

	function crx_converCrxStringToAnsiString(const pCrxString : CrxString;
			pCodePage__from : cardinal; pCodePage__to : cardinal) : AnsiStringWithFloatingCodePage; 
		var vReturn : AnsiStringWithFloatingCodePage;

		begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		result := pCrxString; exit;
{$else}
		vReturn := pCrxString;
		setCodePage(vReturn, pCodePage__from, false);
		setCodePage(vReturn, pCodePage__to, true);
		
		result := vReturn; exit;
{$endif}
	end;
	function crx_convertCrxStringToUnicodeString(const pCrxString : CrxString; pCodePageId : cardinal) :
			UnicodeString;
		var	vReturn : UnicodeString;
		var {block} tLength : size_t = 0;
		var {block} tLength2 : size_t = 0;
		var {block} tAnsiChars : PAnsiChar = NIL;
		var {block} tWideChars : PWideChar = NIL;

		begin
		vReturn := '';

		if pCrxString = '' then begin
			result := vReturn; exit;
		end else begin
			if pCodePageId = CP_UTF8 then begin
				{var} tLength := 0;

				result := utf8Decode(pCrxString); exit;
				{result := utf8ToUtf16(pCrxString); exit; 	//THIS WORKS BUT NEEDS UNIT LazUTF8
															//	FROM LAZARUS}
			end else begin
				{var} tAnsiChars := @pCrxString[1];
				{var} tLength := MultiByteToWideChar(pCodePageId, 0, tAnsiChars, Length(pCrxString), nil, 0);

				if tLength <= 0 then begin
					result := vReturn; exit;
				end else begin
					{var} tWideChars := NIL;
					{var} tLength2 := 0;

					SetLength(vReturn, tLength);
					tWideChars := @vReturn[1];
					tLength2 := MultiByteToWideChar(pCodePageId, 0, tAnsiChars, Length(pCrxString), tWideChars, tLength);

					if tLength <> tLength2 then begin
						SetLength(vReturn, Min(tLength, tLength2));
					end;

					result := vReturn; exit;
				end;
			end;
		end;
	end;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	function crx_converCrxString2ToAnsiString(const pCrxString2 : CrxString2;
			pCodePage__from : cardinal; pCodePage__to : cardinal) : AnsiStringWithFloatingCodePage;
		begin
		result := crx_converCrxStringToAnsiString(pCrxString2.gCrxString, pCodePage__from, pCodePage__to);
	end;
	function crx_convertCrxString2ToUnicodeString(const pCrxString2 : CrxString2; pCodePageId : cardinal) :
			UnicodeString;
		begin
		result := crx_convertCrxStringToUnicodeString(pCrxString2.gCrxString, pCodePageId);
	end;
{$endif}

	function crx_convertUnicodeStringToCrxString(const pUnicodeString: UnicodeString; 
			pCodePageId: cardinal) : CrxString;
		var vReturn : CrxString = '';
		var {block} tCodePageId : cardinal; 
		var {block} tWideChars : PWideChar;
		var {block} tLength : size_t;
		var {block} tLength2 : size_t;

		begin
		if pUnicodeString = '' then begin
			result := vReturn; exit;
		end else begin
			if pCodePageId = CP_UTF8 then begin
				// UTF8
				vReturn := UTF8Encode(pUnicodeString);
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
				setCodePage(vReturn, CP_NONE, False);
{$endif}
				result := vReturn; exit;
			end else begin
				{var} tCodePageId := pCodePageId;
				{var} tWideChars :=	 @pUnicodeString[1];
				{var} tLength := 0;
				{var} tLength2 := 0;

				if tCodePageId = CP_UTF16 then begin
					// Unicode codepage
					tCodePageId := CP_ACP;
				end;

				tLength := wideCharToMultibyte(pCodePageId, 0, tWideChars, length(pUnicodeString), nil, 0, nil, nil);

				if tLength <= 0 then begin
					result := vReturn; exit;
				end;

				setLength(vReturn, tLength);
				tLength2 := WideCharToMultibyte(pCodePageId, 0, tWideChars, length(pUnicodeString),
						@vReturn[1], tLength, nil, nil);

				if tLength <> tLength2 then begin
					SetLength(vReturn, Min(tLength, tLength2));
				end;
				
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
				setCodePage(vReturn, CP_NONE, False);
{$endif}

				result := vReturn; exit;
			end;
		end;
	end;
	function crx_convertUnicodeStringToCrxString2(const pUnicodeString: UnicodeString; pCodePageId: cardinal) : 
			CrxString2;
		begin
		result.gCrxString := crx_convertUnicodeStringToCrxString(pUnicodeString, pCodePageId);
	end;
	
	{FOR CONSISTENCY WITH crx_appendTo WE USE A REFERENCE}
	procedure crx_converCodePageOf(var pCrxString : CrxString;
			pCodePage__from : cardinal; pCodePage__to : cardinal);
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		var vAnsiString : AnsiString;
		var vReturn : AnsiString;
{$endif}

		begin
		assert(crx_isValidCrxString(pCrxString));

		if pCrxString <> '' then begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		{checkout LConvEncoding}
			if true then begin
				case pCodePage__from of
					437: begin
						vAnsiString := CP437ToUTF8(pCrxString);
					end;
					850: begin
						vAnsiString := CP850ToUTF8(pCrxString);
					end;
					852: begin
						vAnsiString := CP852ToUTF8(pCrxString);
					end;
					866: begin
						vAnsiString := CP866ToUTF8(pCrxString);
					end;
					874: begin
						vAnsiString := CP874ToUTF8(pCrxString);
					end;
					1200: begin
						vAnsiString := UCS2LEToUTF8(pCrxString);
					end;
					1201: begin
						vAnsiString := UCS2BEToUTF8(pCrxString);
					end;
					1250: begin
						vAnsiString := CP1250ToUTF8(pCrxString);
					end;
					1251: begin
						vAnsiString := CP1251ToUTF8(pCrxString);
					end;
					1252: begin
						vAnsiString := CP1252ToUTF8(pCrxString);
					end;
					1253: begin
						vAnsiString := CP1253ToUTF8(pCrxString);
					end;
					1254: begin
						vAnsiString := CP1254ToUTF8(pCrxString);
					end;
					1255: begin
						vAnsiString := CP1255ToUTF8(pCrxString);
					end;
					1256: begin
						vAnsiString := CP1256ToUTF8(pCrxString);
					end;
					1257: begin
						vAnsiString := CP1257ToUTF8(pCrxString);
					end;
					1258: begin 
						vAnsiString := CP1258ToUTF8(pCrxString);
					end;
					20866: begin 
						vAnsiString := KOI8ToUTF8(pCrxString);
					end;
					28591: begin 
						vAnsiString := ISO_8859_1ToUTF8(pCrxString);
					end;
					28592: begin 
						vAnsiString := ISO_8859_2ToUTF8(pCrxString);
					end;
					28605: begin 
						vAnsiString := ISO_8859_15ToUTF8(pCrxString);
					end;
					65001: begin
					end;
					65535: begin
						{vAnsiString := ConvertEncodingToUTF8(GuessEncoding(pCrxString));}
					end;
					else begin
					end;
				end;
			end;
			if true then begin
				case pCodePage__to of
					437: begin
						pCrxString := UTF8ToCP437(vAnsiString);
					end;
					850: begin
						pCrxString := UTF8ToCP850(vAnsiString);
					end;
					852: begin
						pCrxString := UTF8ToCP852(vAnsiString);
					end;
					866: begin
						pCrxString := UTF8ToCP866(vAnsiString);
					end;
					874: begin
						pCrxString := UTF8ToCP874(vAnsiString);
					end;
					1200: begin
						pCrxString := UTF8ToUCS2LE(vAnsiString);
					end;
					1201: begin
						pCrxString := UTF8ToUCS2BE(vAnsiString);
					end;
					1250: begin
						pCrxString := UTF8ToCP1250(vAnsiString);
					end;
					1251: begin
						pCrxString := UTF8ToCP1251(vAnsiString);
					end;
					1252: begin
						pCrxString := UTF8ToCP1252(vAnsiString);
					end;
					1253: begin
						pCrxString := UTF8ToCP1253(vAnsiString);
					end;
					1254: begin
						pCrxString := UTF8ToCP1254(vAnsiString);
					end;
					1255: begin
						pCrxString := UTF8ToCP1255(vAnsiString);
					end;
					1256: begin
						pCrxString := UTF8ToCP1256(vAnsiString);
					end;
					1257: begin
						pCrxString := UTF8ToCP1257(vAnsiString);
					end;
					1258: begin 
						pCrxString := UTF8ToCP1258(vAnsiString);
					end;
					20866: begin 
						pCrxString := UTF8ToKOI8(vAnsiString);
					end;
					28591: begin 
						pCrxString := UTF8ToISO_8859_1(vAnsiString);
					end;
					28592: begin 
						pCrxString := UTF8ToISO_8859_2(vAnsiString);
					end;
					28605: begin 
						pCrxString := UTF8ToISO_8859_15(vAnsiString);
					end;
					65001: begin
					end;
					65535: begin
					end;
					else begin
					end;
				end;
			end;
{$else}
			setCodePage(pCrxString, pCodePage__from, false);
			setCodePage(pCrxString, pCodePage__to, true);
			setCodePage(pCrxString, CP_NONE, false);
{$endif}
		end;
	end;
	procedure crx_converCodePageOf(var pCrxString2 : CrxString2;
			pCodePage__from : cardinal; pCodePage__to : cardinal);
		begin
		crx_converCodePageOf(pCrxString2.gCrxString, pCodePage__from, pCodePage__to);
	end;
	
	function crx_join(const pDelimeterString : AnsiStringWithFloatingCodePage; 
			const pStrings : array of AnsiStringWithFloatingCodePage) : CrxString;
		var vReturn : CrxString;
		var {block} tI : size_t;

		begin

		vReturn := crx_makeCrxStringFrom('');
		
		for tI := low(pStrings) to high(pStrings) do begin
			if tI <> 0 then begin
				crx_appendTo(vReturn, pDelimeterString);
			end;

			crx_appendTo(vReturn, pStrings[tI]);
		end;
		
		result := vReturn;
	end;
	function crx_join(const pDelimeterString : AnsiStringWithFloatingCodePage;
			const pArgs : array of const) : CrxString;
		var vReturn : CrxString {= ''};
		var {block} tI : size_t;

		begin
		if High(pArgs) < 0 then begin  
		end else begin
			for tI:=0 to High(pArgs) do begin
				if tI <> 0 then begin
					crx_appendTo(vReturn, pDelimeterString);
				end;

				case pArgs[tI].vtype of  
					vtinteger: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								intToStr(pArgs[tI].vinteger)));
					end;
					vtboolean: begin
						if pArgs[tI].vboolean then begin
							crx_appendTo(vReturn,
									crx_makeCrxStringFrom('true'));
						end else begin
							crx_appendTo(vReturn, 
									crx_makeCrxStringFrom('false'));
						end;
					end;  
					vtchar: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].vchar));
					end;
					vtstring: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].VString^));
					end;
					vtpChar: begin
						if pArgs[tI].VPChar <> NIL then begin
							crx_appendTo(vReturn, 
									crx_makeCrxStringFrom(pArgs[tI].VPChar));
						end;
					end;
					vtObject: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].VObject.Classname));
					end;
					vtClass: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								pArgs[tI].VClass.Classname));
					end; 
					vtAnsiString: begin
						crx_appendTo(vReturn, crx_makeCrxStringFrom(
								AnsiString(pArgs[tI].VAnsiString)));
					end;  
					else begin
					end;  
				end; 
			end; 
		end;
		
		result := vReturn;
	end;

	procedure crx_removeAnsiCharsFromFrontOf(var pCrxString : CrxString; pNumberOfAnsiChars : size_t);
		var vLength : size_t = 0;
		
		begin
		assert(crx_isValidCrxString(pCrxString));

		vLength := length(pCrxString);

		if(pNumberOfAnsiChars > 0) then begin
			UniqueString(pCrxString);
			
			if(pNumberOfAnsiChars < vLength) then begin
				move(pCrxString[pNumberOfAnsiChars + 1], pCrxString[1], vLength - pNumberOfAnsiChars);
				setLength(pCrxString, vLength - pNumberOfAnsiChars);
			end else begin
				setLength(pCrxString, 0);
			end;
		end;
	end;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	procedure crx_removeAnsiCharsFromFrontOf(var pCrxString2 : CrxString2; pNumberOfAnsiChars : size_t);
		begin
		crx_removeAnsiCharsFromFrontOf(pCrxString2.gCrxString, pNumberOfAnsiChars);
	end;
{$endif}
	procedure crx_removeAnsiCharsFromBackOf(var pCrxString : CrxString; pNumberOfAnsiChars : size_t);
		var vLength : size_t = 0;
		
		begin
		assert(crx_isValidCrxString(pCrxString));

		vLength := length(pCrxString);

		if(pNumberOfAnsiChars > 0) then begin
			UniqueString(pCrxString);
			
			if(pNumberOfAnsiChars < vLength) then begin
				setLength(pCrxString, vLength - pNumberOfAnsiChars);
			end else begin
				setLength(pCrxString, 0);
			end;
		end;
	end;
{$if CRX__FPC__HAS_ADVANCED_RECORDS}
	procedure crx_removeAnsiCharsFromBackOf(var pCrxString2 : CrxString2; pNumberOfAnsiChars : size_t);
		begin
		crx_removeAnsiCharsFromBackOf(pCrxString2.gCrxString, pNumberOfAnsiChars);
	end;
{$endif}

	function crx_makeAnsiStringFromCodePoint(pUnicodeValue : UCS4Char; pCodePageId : cardinal = CP_UTF8) : 
			AnsiStringWithFloatingCodePage;
		var vUCS4String : UCS4String;
		var vReturn : AnsiStringWithFloatingCodePage;
		

		begin
		setLength(vUCS4String, 2);
		vUCS4String[0] := pUnicodeValue;
		vUCS4String[1] := 0;

		vReturn := crx_convertUnicodeStringToCrxString(
				UCS4StringToUnicodeString(vUCS4String), pCodePageId);
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		system.setCodePage(vReturn, pCodePageId, false);
{$endif}
		result := vReturn; exit;
	end;
	function crx_makeAnsiStringFromCodePoints(pUnicodeValues : array of UCS4Char; pCodePageId : cardinal = CP_UTF8) : 
			AnsiStringWithFloatingCodePage;
		var vReturn : AnsiStringWithFloatingCodePage {= ''};
		var {block} tI : size_t;
		

		begin
		for tI := low(pUnicodeValues) to High(pUnicodeValues) do begin
			if(vReturn = '') then begin
				vReturn := crx_makeCrxStringFromCodePoint(pUnicodeValues[tI], pCodePageId);
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
				setCodePage(vReturn, CP_NONE, false);
{$endif}
			end else begin
				vReturn := vReturn + crx_makeCrxStringFromCodePoint(pUnicodeValues[tI])
			end;
		end;

		result := vReturn; exit;
	end;

	function crx_convertWideStringToAnsiString(pWideString : WideString;
			pCodePageId : cardinal) : AnsiString;
		var vAnsiString : AnsiString = '';
		var vNumberOfBytes : size_t = 0;

		begin
		setLength(vAnsiString, length(pWideString) * 2);
		vNumberOfBytes := WideCharToMultiByte(pCodePageId, 0,
				PWideChar(pWideString), length(pWideString),
				PAnsiChar(vAnsiString), length(pWideString) * 2,
				nil, nil);
		setLength(vAnsiString, vNumberOfBytes);

		exit(vAnsiString);
	end;
	
	procedure crx_setCodePageOf(var s: AnsiStringWithFloatingCodePage; 
			e: Word; c: Boolean = true); begin
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		system.setCodePage(s, e, c);
{$endif}
	end;
	
	{$REGION RECORD: CrxString}
	class operator CrxString2.:=(const pCrxString : CrxString) : CrxString2; begin
			result.gCrxString := pCrxString;
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		system.setCodePage(result.gCrxString, CP_NONE, false);
{$endif}
	end;
	class operator CrxString2.:=(const pCrxString2 : CrxString2) : CrxString; begin
		result := pCrxString2.gCrxString;
	end;
	class operator CrxString2.:=(const pAnsiChars : shortString) : CrxString2;
{$if CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS}
		var vCrxString : CrxString;
{$endif}
		begin
{$if not(CRX__FPC__HAS_CODE_PAGE_ANSI_STRINGS)}
		result.gCrxString := pAnsiChars; exit;	
{$else}
		vCrxString := pAnsiChars;
		setCodePage(vCrxString, CP_NONE, false);

		result.gCrxString := vCrxString; exit;
{$endif}
	end;
	class operator CrxString2.:=(const pLongInt : longInt) : CrxString2; begin
		result.gCrxString := crx_makeCrxStringFrom(pLongInt);
	end;
	class operator CrxString2.:=(const pExtended : extended) : CrxString2; begin
		result.gCrxString := crx_makeCrxStringFrom(pExtended);
	end;
 
	class operator CrxString2.and(const pCrxString2 : CrxString2; const pCrxString2__2 : CrxString2) : 
			CrxString2; begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, pCrxString2__2.gCrxString]); exit;
	end;
	class operator CrxString2.and(const pCrxString2 : CrxString2; const pCrxString : CrxString) : 
			CrxString2; begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, pCrxString]); exit;
	end;
	class operator CrxString2.and(const pCrxString2 : CrxString2; const pLongInt : longInt) : 
			CrxString2; begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, pLongInt]); exit;
	end;
	class operator CrxString2.and(const pCrxString2 : CrxString2; const pExtended : extended) : 
			CrxString2; begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, pExtended]); exit;
	end;
	
	{class operator CrxString2.<<(const pCrxString2 : CrxString2; pUnicodeValue : UCS4Char) : CrxString2;
		begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, 
				crx_makeCrxStringFromCodePoint(pUnicodeValue)]);
	end;}
	class operator CrxString2.and(const pCrxString2 : CrxString2; pUnicodeValues : array of UCS4Char) : 
			CrxString2;
 {$if not(CRX__FPC__HAS_PARTIAL_ARRAYS_FOR_OPEN_ARRAYS)}
		var vUCS4Chars : array of UCS4Char;
 {$endif}
		var vNumberOfUCS4Chars : size_t = 0;

		begin
		assert(length(pUnicodeValues) > 1);
		vNumberOfUCS4Chars := length(pUnicodeValues) - 1;
{$if CRX__FPC__HAS_PARTIAL_ARRAYS_FOR_OPEN_ARRAYS}
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, 
				crx_makeCrxStringFromCodePoints(pUnicodeValues[1..vNumberOfUCS4Chars], pUnicodeValues[0])]);
{$else}
		setLength(vUCS4Chars, vNumberOfUCS4Chars);
		move(((@pUnicodeValues[0]) + sizeof(UCS4Char))^, vUCS4Chars, vNumberOfUCS4Chars); 
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, 
				crx_makeCrxStringFromCodePoints(vUCS4Chars, pUnicodeValues[0])]);
{$endif}
	end;
	{class operator CrxString2.and(const pCrxString2 : CrxString2; pCrxInfoAndUCS4Char : CrxInfoAndUCS4Char) :
			CrxString2;
		begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, 
				crx_makeCrxStringFromCodePoint(pCrxInfoAndUCS4Char[1], pCrxInfoAndUCS4Char[0])]);
	end;
	class operator CrxString2.and(const pCrxString2 : CrxString2; 
			pCrxInfoAndCollectionOfUCS4Char : CrxInfoAndCollectionOfUCS4Char) :	CrxString2;
		begin
		result.gCrxString := crx_makeCrxStringFrom([pCrxString2.gCrxString, 
				crx_makeCrxStringFromCodePoints(pCrxInfoAndCollectionOfUCS4Char.gUCS4Chars, 
				pCrxInfoAndCollectionOfUCS4Char.gCodePage)]);
	end;}
	{$ENDREGION}
	
	
	function _crx_test_crxString() : AnsiStringWithFloatingCodePage;
		var vCrxString : CrxString; {= 'n';}
		//var vCrxString : CrxString2; {= (gCrxString: 'n');}
		var vTime : dWord = 0;
		var {block} tI : longint = 0;
		{var vCrxString : CrxString2;}

		begin
		//vCrxString := crx_makeCrxStringFrom('n');
		{
			NOTE THAT NO COMBINATION OF
						crx_makeCrxStringFrom
						AnsiString
						RawByteString
						OR NOTHING
				WORKS RELIABLY IN THE CONCATENATION UNLESS ALL ARE 
						crx_makeCrxStringFrom
				FOR EXAMPLE: NONE OF THE FOLLOWING WORKS
						crx_makeCrxStringFrom(
						'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
						'tuytu'
				OR
						crx_makeCrxStringFrom(
						'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
						RawByteString('tuytu')
				OR
						RawByteString(
						'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
						RawByteString('tuytu')
						
			A VALID ALTERNATIVE TO WHAT IS BELOW IS
			vCrxString := crx_makeCrxStringFrom(RawByteString(
					'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
					'tuytu' +
					crx_makeAnsiStringFromCodePoint($7403) + 
					''#$e6#$b1#$bd +
					crx_makeAnsiStringFromCodePoint($6C7D));
		}
		{vCrxString := crx_makeCrxStringFrom(
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
				crx_makeCrxStringFrom('tuytu') +
				crx_makeCrxStringFromCodePoint($7403) + 
				crx_makeCrxStringFrom(''#$e6#$b1#$bd) +
				crx_makeCrxStringFromCodePoint($6C7D);}
		{vCrxString := crx_makeCrxStringFrom(AnsiStringWithFloatingCodePage(
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) + 
				'tuytu' +
				crx_makeAnsiStringFromCodePoint($7403) + 
				''#$e6#$b1#$bd +
				crx_makeAnsiStringFromCodePoint($6C7D));}
		{vCrxString := crx_makeCrxStringFrom([
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83, 
				'tuytu',
				crx_makeAnsiStringFromCodePoint($7403), 
				''#$e6#$b1#$bd,
				crx_makeAnsiStringFromCodePoints([$6C7D])]);}
		{CrxStringWrapper CAST IS NEEDED FOR FPC2.6.4}
		{vCrxString := CrxStringWrapper('') and crx_makeCrxStringFrom(
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) and 
				'tuytu' and
				crx_makeAnsiStringFromCodePoint($7403) and 
				''#$e6#$b1#$bd and
				crx_makeAnsiStringFromCodePoints([$6C7D]);}
		{vCrxString := CrxStringWrapper('') and crx_makeCrxStringFrom(
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) and 
				'tuytu' <<
				$7403 and 
				''#$e6#$b1#$bd <<
				($6C7D);} //NOTE: THIS IS NOT WORKING AS AN ARRAY
		{vCrxString := CrxStringWrapper('') and crx_makeCrxStringFrom(
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) and 
				'tuytu' and
				[CP_UTF8, $7403] and 
				''#$e6#$b1#$bd and
				[CP_UTF8, $6C7D];}
		vCrxString := CrxStringWrapper('') and crx_makeCrxStringFrom(
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83) and 
				'tuytu' and
				crx_makeCrxStringFromCodePoints([$7403], CP_UTF8) and 
				''#$e6#$b1#$bd and
				crx_makeCrxStringFromCodePoints([$6C7D], CP_UTF8);
				
				

		{vTime := getTickCount();
		
		for tI := 0 to 1 do begin
			crx_appendTo(vCrxString, crx_makeCrxStringFrom([
			{vCrxString := vCrxString and crx_makeCrxStringFrom([}
				'ABC: '#$E6#$B5#$B7#$E6#$B4#$8B#$E5#$9C#$B0#$E7#$90#$83, 
				'tuytu',
				crx_makeAnsiStringFromCodePoint($7403), 
				''#$e6#$b1#$bd,
				crx_makeAnsiStringFromCodePoints([$6C7D])
				]));
		end;
		vTime := getTickCount() - vTime;}
		
		//crx_setCodePage(vCrxString, CP_NONE, false);
		//crx_converCodePageOf(vCrxString, CP_UTF8, 20000);
		//crx_converCodePageOf(vCrxString, CP_UTF8, 936);
		//crx_converCodePageOf(vCrxString, CP_UTF8, 437);
		//result := crx_convertCrxStringToUnicodeString(vCrxString, CP_UTF8);
		//result := crx_convertCrxStringToUnicodeString(vCrxString, 1254); //this should look wrong
		//result := IntToStr(cardinal(crx_getAnsiCharAt(25000, vCrxString)));
		//result := IntToStr(crx_getLengthOf(vCrxString));
		result := vCrxString;
		//result := vCrxString.gCrxString;
		//result := converCrxStringToAnsiString(vCrxString, CP_UTF8, CP_UTF8);
		//result := IntToStr(StringCodePage(vCrxString)); //should be 65535
		//result := IntToStr(vTime);
	end;
{$ENDREGION}
end.
