unit crx_container;

{$mode objfpc}{$H+}
{$MACRO ON}
{$TYPEDADDRESS ON}
{$CODEPAGE UTF8}

interface
uses
{uses} crx,
{uses} gcontnrs;

{$REGION INTERFACE}
	type HashTable_GetSuitableForContainersHash = class
		{ORIGINAL NAME: TG_StringHash.rawhash}
    	function call(const pCrxString: CrxString): LongInt;
	end;
	type HashTable_AreKeysEqual = class
		function call(const pKey : CrxString; const pKey__2: CrxString): Boolean;
	end;

	type HashTableForTObject = class(specialize gcontnrs.TGenHashMap<CrxString, TObject>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	{public function DefaultItemToString(const Item: TObject): String; override;}
		public procedure callDestroyOnElementsAndClear();
    end;

	type HashTableForCrxString = class(specialize gcontnrs.TGenHashMap<CrxString, CrxString>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: CrxString): String; override;
    end;
	
	
	type HashTableForShortInt = class(specialize gcontnrs.TGenHashMap<CrxString, ShortInt>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: ShortInt): String; override;
    end;
	type HashTableForByte = class(specialize gcontnrs.TGenHashMap<CrxString, Byte>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: Byte): String; override;
    end;

	type HashTableForSmallInt = class(specialize gcontnrs.TGenHashMap<CrxString, SmallInt>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: SmallInt): String; override;
    end;
	type HashTableForWord = class(specialize gcontnrs.TGenHashMap<CrxString, Word>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: Word): String; override;
    end;

	type HashTableForLongInt = class(specialize gcontnrs.TGenHashMap<CrxString, LongInt>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: LongInt): String; override;
    end;
	type HashTableForLongWord = class(specialize gcontnrs.TGenHashMap<CrxString, LongWord>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: LongWord): String; override;
    end;
	type HashTableForCardinal = HashTableForLongWord;
{$if(sizeof(integer) = 2)}
	type HashTableForInteger = HashTableForSmallInt;
{$elseif(sizeof(integer) = 4)}
	type HashTableForInteger = HashTableForLongInt;
{$endif}

	type HashTableForDouble = class(specialize gcontnrs.TGenHashMap<CrxString, Double>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: Double): String; override;
    end;
	
	type HashTableForBoolean = class(specialize gcontnrs.TGenHashMap<CrxString, Boolean>)
    	public function DefaultHashKey(const pKey: CrxString): Integer; override;
    	public function DefaultKeysEqual(const pKey : CrxString; const pKey__2 : CrxString): Boolean; override;
    	public function DefaultKeyToString(const pKey: CrxString): String; override;
    	public function DefaultItemToString(const Item: Boolean): String; override;
    end;

	var gGetSuitableForContainersHash : HashTable_GetSuitableForContainersHash;
	var gAreKeysEqual : HashTable_AreKeysEqual;
{$ENDREGION}


implementation
{$REGION IMPLEMENTATION}
	{$REGION CLASS: HashTable_GetSuitableForContainersHash}
        function HashTable_GetSuitableForContainersHash.call(const pCrxString: CrxString): LongInt;
    	    var p : PChar;
		    var pmax : PChar;
    
    	    begin		
		    {DISABLE OVERFLOW CHECKING}
    	    {$push}
    	    {$Q-}
    	    
		    Result:=0;
    	    p:=@pCrxString[1];
    	    pmax:=@pCrxString[length(pCrxString)+1];
    	    
		    while (p<pmax) do begin
    		    Result:=LongWord(LongInt(Result shl 5) - LongInt(Result)) xor LongWord(P^);
    		    Inc(p);
    	    end;
    	    
		    {$pop}
	    end;
	{$ENDREGION}

	{$REGION CLASS: HashTable_AreKeysEqual}
        function HashTable_AreKeysEqual.call(const pKey : CrxString; const pKey__2: CrxString): Boolean;
    	    begin
			result := (pKey = pKey__2); exit;
	    end;
	{$ENDREGION}
	
	{$REGION CLASS: HashTableForTObject}
        function HashTableForTObject.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForTObject.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForTObject.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        {function HashTableForTObject.DefaultItemToString(const Item: String): String;
	        begin
	        Result := Item;
        end;}
		
		procedure HashTableForTObject.callDestroyOnElementsAndClear();
			var vTHashMapCursor : THashMapCursor {= ?};

			begin
			vTHashMapCursor := self.First;

            while vTHashMapCursor.HasItem() do begin
            	self.ItemAt[vTHashMapCursor].Destroy();
            	vTHashMapCursor.MoveNext;
			end;

			self.Clear();
		end;

 {$ENDREGION}
	
	{$REGION CLASS: HashTableForCrxString}
        function HashTableForCrxString.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForCrxString.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForCrxString.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForCrxString.DefaultItemToString(const Item: CrxString): String;
	        begin
	        WriteStr(result, Item); exit;
        end;
	{$ENDREGION}

	{$REGION CLASS: HashTableForShortInt}
        function HashTableForShortInt.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForShortInt.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForShortInt.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForShortInt.DefaultItemToString(const Item: ShortInt): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}
	{$REGION CLASS: HashTableForByte}
        function HashTableForByte.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForByte.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForByte.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForByte.DefaultItemToString(const Item: Byte): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}

	{$REGION CLASS: HashTableForSmallInt}
        function HashTableForSmallInt.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForSmallInt.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForSmallInt.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForSmallInt.DefaultItemToString(const Item: SmallInt): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}
	{$REGION CLASS: HashTableForWord}
        function HashTableForWord.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForWord.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForWord.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForWord.DefaultItemToString(const Item: Word): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}
	
	{$REGION CLASS: HashTableForLongInt}
        function HashTableForLongInt.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForLongInt.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForLongInt.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForLongInt.DefaultItemToString(const Item: LongInt): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}
	{$REGION CLASS: HashTableForLongWord}
        function HashTableForLongWord.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForLongWord.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForLongWord.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForLongWord.DefaultItemToString(const Item: LongWord): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}
	
	{$REGION CLASS: HashTableForDouble}
        function HashTableForDouble.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForDouble.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForDouble.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForDouble.DefaultItemToString(const Item: Double): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}
	
	{$REGION CLASS: HashTableForBoolean}
        function HashTableForBoolean.DefaultHashKey(const pKey: CrxString): Integer;
        	begin
            result := gGetSuitableForContainersHash.call(pKey); exit;
        end;
        
        function HashTableForBoolean.DefaultKeysEqual(const pKey : CrxString; const pKey__2: CrxString): Boolean;
            begin
            result := (pKey = pKey__2); exit;
        end;
        
        function HashTableForBoolean.DefaultKeyToString(const pKey: CrxString): String;
            begin
            WriteStr(result, pKey); exit;
        end;
        
        function HashTableForBoolean.DefaultItemToString(const Item: Boolean): String;
	        begin
	        WriteStr(result, crx_makeCrxStringFrom(Item)); exit;
        end;
	{$ENDREGION}
{$ENDREGION}
end.
