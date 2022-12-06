unit crx_utility;

{$mode objfpc}{$H+}
{$MACRO ON}
{$TYPEDADDRESS ON}
{$CODEPAGE UTF8}

interface
{$REGION INTERFACE}
uses
{uses} crx,
{uses} sysutils,
{uses} FileUtil;

	function crx_utility_enforcePathAsDirectoryPath(pPath : CrxString) : CrxString;
	function crx_utility_getLastIndexOf(pAnsiChar : AnsiChar; pCrxString : CrxString;
			pDefault : Integer) : Integer;
	function crx_utility_doesStringBeginsWith(pCrxString : CrxString; pSearch : CrxString) : Boolean;	
{$ENDREGION}


implementation
{$REGION IMPLEMENTATION}
	{ONE COULD ALSO USE IncludeTrailingPathDelimiter()}
	function crx_utility_enforcePathAsDirectoryPath(pPath : CrxString) : CrxString;
		var vPath : CrxString {=''};

		begin
		vPath := crx_makeCrxStringFrom(sysutils.Trim(pPath));
		
		if((crx_getLengthOf(vPath) = 0) or 
				(vPath[crx_getLengthOf(vPath)] <> System.DirectorySeparator)) then begin
			crx_appendTo(vPath, System.DirectorySeparator);
			result := vPath; exit;
			end
		else begin
			result := vPath; exit;
		end;
	end;
	
	{NOTE: IMPLEMENTAION IS CURRENTLY ILL DEFINED. DEFAULT CAN BE RETURNED IF OUT OF RANGE.}
	function crx_utility_getLastIndexOf(pAnsiChar : AnsiChar; pCrxString : CrxString;
			pDefault : Int32) : Int32;
		var tReturn : Int32 = 0;
		var tI : size_t = 0;

		begin
		tReturn := pDefault;

		tI := crx_getLengthOf(pCrxString);

		if(tI <= $ffffffff) then begin
			for tI := crx_getLengthOf(pCrxString) downto 1 do begin
				if(pCrxString[tI] = pAnsiChar) then begin
					tReturn := tI - 1;
					break;
				end;
			end;
		end;

		result := tReturn; exit;
	end;
	{NOTE: IMPLEMENTAION IS CURRENTLY ILL DEFINED. DEFAULT CAN BE RETURNED IF OUT OF RANGE.}
	function crx_utility_doesStringBeginsWith(pCrxString : CrxString; pSearch : CrxString) : Boolean;
		var {block} tI : size_t = 0;

		begin
		if(crx_getLengthOf(pSearch) > crx_getLengthOf(pCrxString)) then begin
			result := false; exit;
		end else begin
			for {var} tI := 1 to crx_getLengthOf(pSearch) do begin
				if(pCrxString[tI] <> pSearch[tI]) then begin
					result := false; exit;
				end;
			end;

			result := true; exit;
		end;		
	end;
{$ENDREGION}

end.
