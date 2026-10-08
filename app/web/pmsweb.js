rtl.module("System",[],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"TObject",null,function () {
    this.$init = function () {
    };
    this.$final = function () {
    };
    this.Create = function () {
      return this;
    };
    this.Destroy = function () {
    };
    this.Free = function () {
      this.$destroy("Destroy");
    };
    this.AfterConstruction = function () {
    };
    this.BeforeDestruction = function () {
    };
  });
  this.vtInteger = 0;
  this.vtExtended = 3;
  this.vtWideChar = 9;
  this.vtCurrency = 12;
  this.vtUnicodeString = 18;
  this.vtNativeInt = 19;
  rtl.recNewT(this,"TVarRec",function () {
    this.VType = 0;
    this.VJSValue = undefined;
    this.$eq = function (b) {
      return (this.VType === b.VType) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue);
    };
    this.$assign = function (s) {
      this.VType = s.VType;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      return this;
    };
  });
  this.VarRecs = function () {
    var Result = [];
    var i = 0;
    var v = null;
    Result = [];
    while (i < arguments.length) {
      v = $mod.TVarRec.$new();
      v.VType = rtl.trunc(arguments[i]);
      i += 1;
      v.VJSValue = arguments[i];
      i += 1;
      Result.push($mod.TVarRec.$clone(v));
    };
    return Result;
  };
  this.Frac = function (A) {
    return A % 1;
  };
  this.Trunc = function (A) {
    if (!Math.trunc) {
      Math.trunc = function(v) {
        v = +v;
        if (!isFinite(v)) return v;
        return (v - v % 1) || (v < 0 ? -0 : v === 0 ? v : 0);
      };
    }
    $mod.Trunc = Math.trunc;
    return Math.trunc(A);
  };
  this.Int = function (A) {
    var Result = 0.0;
    Result = $mod.Trunc(A);
    return Result;
  };
  this.Copy = function (S, Index, Size) {
    if (Index<1) Index = 1;
    return (Size>0) ? S.substring(Index-1,Index+Size-1) : "";
  };
  this.Copy$1 = function (S, Index) {
    if (Index<1) Index = 1;
    return S.substr(Index-1);
  };
  this.Delete = function (S, Index, Size) {
    var h = "";
    if ((Index < 1) || (Index > S.get().length) || (Size <= 0)) return;
    h = S.get();
    S.set($mod.Copy(h,1,Index - 1) + $mod.Copy$1(h,Index + Size));
  };
  this.Pos = function (Search, InString) {
    return InString.indexOf(Search)+1;
  };
  this.Insert = function (Insertion, Target, Index) {
    var t = "";
    if (Insertion === "") return;
    t = Target.get();
    if (Index < 1) {
      Target.set(Insertion + t)}
     else if (Index > t.length) {
      Target.set(t + Insertion)}
     else Target.set($mod.Copy(t,1,Index - 1) + Insertion + $mod.Copy(t,Index,t.length));
  };
  this.upcase = function (c) {
    return c.toUpperCase();
  };
  this.val = function (S, NI, Code) {
    NI.set($impl.valint(S,-9007199254740991,9007199254740991,Code));
  };
  this.StringOfChar = function (c, l) {
    var Result = "";
    var i = 0;
    if ((l>0) && c.repeat) return c.repeat(l);
    Result = "";
    for (var $l = 1, $end = l; $l <= $end; $l++) {
      i = $l;
      Result = Result + c;
    };
    return Result;
  };
  this.Writeln = function () {
    var i = 0;
    var l = 0;
    var s = "";
    l = arguments.length - 1;
    if ($impl.WriteCallBack != null) {
      for (var $l = 0, $end = l; $l <= $end; $l++) {
        i = $l;
        $impl.WriteCallBack(arguments[i],i === l);
      };
    } else {
      s = $impl.WriteBuf;
      for (var $l1 = 0, $end1 = l; $l1 <= $end1; $l1++) {
        i = $l1;
        s = s + ("" + arguments[i]);
      };
      console.log(s);
      $impl.WriteBuf = "";
    };
  };
  $mod.$implcode = function () {
    $impl.WriteBuf = "";
    $impl.WriteCallBack = null;
    $impl.valint = function (S, MinVal, MaxVal, Code) {
      var Result = 0;
      var x = 0.0;
      if (S === "") {
        Code.set(1);
        return Result;
      };
      x = Number(S);
      if (isNaN(x)) {
        var $tmp = $mod.Copy(S,1,1);
        if ($tmp === "$") {
          x = Number("0x" + $mod.Copy$1(S,2))}
         else if ($tmp === "&") {
          x = Number("0o" + $mod.Copy$1(S,2))}
         else if ($tmp === "%") {
          x = Number("0b" + $mod.Copy$1(S,2))}
         else {
          Code.set(1);
          return Result;
        };
      };
      if (isNaN(x) || (x !== $mod.Int(x))) {
        Code.set(1)}
       else if ((x < MinVal) || (x > MaxVal)) {
        Code.set(2)}
       else {
        Result = $mod.Trunc(x);
        Code.set(0);
      };
      return Result;
    };
  };
  $mod.$init = function () {
    rtl.exitcode = 0;
  };
},[]);
rtl.module("RTLConsts",["System"],function () {
  "use strict";
  var $mod = this;
  $mod.$resourcestrings = {SArgumentMissing: {org: 'Missing argument in format "%s"'}, SInvalidFormat: {org: 'Invalid format specifier : "%s"'}, SInvalidArgIndex: {org: 'Invalid argument index in format: "%s"'}};
});
rtl.module("JS",["System"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("SysUtils",["System","RTLConsts","JS"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.recNewT(this,"TFormatSettings",function () {
    this.CurrencyDecimals = 0;
    this.CurrencyFormat = 0;
    this.CurrencyString = "";
    this.DateSeparator = "";
    this.DecimalSeparator = "";
    this.LongDateFormat = "";
    this.LongTimeFormat = "";
    this.NegCurrFormat = 0;
    this.ShortDateFormat = "";
    this.ShortTimeFormat = "";
    this.ThousandSeparator = "";
    this.TimeAMString = "";
    this.TimePMString = "";
    this.TimeSeparator = "";
    this.TwoDigitYearCenturyWindow = 0;
    this.InitLocaleHandler = null;
    this.$new = function () {
      var r = Object.create(this);
      r.DateTimeToStrFormat = rtl.arraySetLength(null,"",2);
      r.LongDayNames = rtl.arraySetLength(null,"",7);
      r.LongMonthNames = rtl.arraySetLength(null,"",12);
      r.ShortDayNames = rtl.arraySetLength(null,"",7);
      r.ShortMonthNames = rtl.arraySetLength(null,"",12);
      return r;
    };
    this.$eq = function (b) {
      return (this.CurrencyDecimals === b.CurrencyDecimals) && (this.CurrencyFormat === b.CurrencyFormat) && (this.CurrencyString === b.CurrencyString) && (this.DateSeparator === b.DateSeparator) && rtl.arrayEq(this.DateTimeToStrFormat,b.DateTimeToStrFormat) && (this.DecimalSeparator === b.DecimalSeparator) && (this.LongDateFormat === b.LongDateFormat) && rtl.arrayEq(this.LongDayNames,b.LongDayNames) && rtl.arrayEq(this.LongMonthNames,b.LongMonthNames) && (this.LongTimeFormat === b.LongTimeFormat) && (this.NegCurrFormat === b.NegCurrFormat) && (this.ShortDateFormat === b.ShortDateFormat) && rtl.arrayEq(this.ShortDayNames,b.ShortDayNames) && rtl.arrayEq(this.ShortMonthNames,b.ShortMonthNames) && (this.ShortTimeFormat === b.ShortTimeFormat) && (this.ThousandSeparator === b.ThousandSeparator) && (this.TimeAMString === b.TimeAMString) && (this.TimePMString === b.TimePMString) && (this.TimeSeparator === b.TimeSeparator) && (this.TwoDigitYearCenturyWindow === b.TwoDigitYearCenturyWindow);
    };
    this.$assign = function (s) {
      this.CurrencyDecimals = s.CurrencyDecimals;
      this.CurrencyFormat = s.CurrencyFormat;
      this.CurrencyString = s.CurrencyString;
      this.DateSeparator = s.DateSeparator;
      this.DateTimeToStrFormat = s.DateTimeToStrFormat.slice(0);
      this.DecimalSeparator = s.DecimalSeparator;
      this.LongDateFormat = s.LongDateFormat;
      this.LongDayNames = s.LongDayNames.slice(0);
      this.LongMonthNames = s.LongMonthNames.slice(0);
      this.LongTimeFormat = s.LongTimeFormat;
      this.NegCurrFormat = s.NegCurrFormat;
      this.ShortDateFormat = s.ShortDateFormat;
      this.ShortDayNames = s.ShortDayNames.slice(0);
      this.ShortMonthNames = s.ShortMonthNames.slice(0);
      this.ShortTimeFormat = s.ShortTimeFormat;
      this.ThousandSeparator = s.ThousandSeparator;
      this.TimeAMString = s.TimeAMString;
      this.TimePMString = s.TimePMString;
      this.TimeSeparator = s.TimeSeparator;
      this.TwoDigitYearCenturyWindow = s.TwoDigitYearCenturyWindow;
      return this;
    };
    this.GetJSLocale = function () {
      return Intl.DateTimeFormat().resolvedOptions().locale;
    };
    this.Create = function () {
      var Result = $mod.TFormatSettings.$new();
      Result.$assign($mod.TFormatSettings.Create$1($mod.TFormatSettings.GetJSLocale()));
      return Result;
    };
    this.Create$1 = function (ALocale) {
      var Result = $mod.TFormatSettings.$new();
      Result.LongDayNames = $impl.DefaultLongDayNames.slice(0);
      Result.ShortDayNames = $impl.DefaultShortDayNames.slice(0);
      Result.ShortMonthNames = $impl.DefaultShortMonthNames.slice(0);
      Result.LongMonthNames = $impl.DefaultLongMonthNames.slice(0);
      Result.DateTimeToStrFormat[0] = "c";
      Result.DateTimeToStrFormat[1] = "f";
      Result.DateSeparator = "-";
      Result.TimeSeparator = ":";
      Result.ShortDateFormat = "yyyy-mm-dd";
      Result.LongDateFormat = "ddd, yyyy-mm-dd";
      Result.ShortTimeFormat = "hh:nn";
      Result.LongTimeFormat = "hh:nn:ss";
      Result.DecimalSeparator = ".";
      Result.ThousandSeparator = ",";
      Result.TimeAMString = "AM";
      Result.TimePMString = "PM";
      Result.TwoDigitYearCenturyWindow = 50;
      Result.CurrencyFormat = 0;
      Result.NegCurrFormat = 0;
      Result.CurrencyDecimals = 2;
      Result.CurrencyString = "$";
      if ($mod.TFormatSettings.InitLocaleHandler != null) $mod.TFormatSettings.InitLocaleHandler($mod.UpperCase(ALocale),$mod.TFormatSettings.$clone(Result));
      return Result;
    };
  },true);
  rtl.createClass(this,"Exception",pas.System.TObject,function () {
    this.LogMessageOnCreate = false;
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.fMessage = "";
    };
    this.Create$1 = function (Msg) {
      this.fMessage = Msg;
      if (this.LogMessageOnCreate) pas.System.Writeln("Created exception ",this.$classname," with message: ",Msg);
      return this;
    };
    this.CreateFmt = function (Msg, Args) {
      this.Create$1($mod.Format(Msg,Args));
      return this;
    };
  });
  rtl.createClass(this,"EConvertError",this.Exception,function () {
  });
  this.Trim = function (S) {
    return S.replace(/^[\s\uFEFF\xA0\x00-\x1f]+/,'').replace(/[\s\uFEFF\xA0\x00-\x1f]+$/,'');
  };
  this.TrimLeft = function (S) {
    return S.replace(/^[\s\uFEFF\xA0\x00-\x1f]+/,'');
  };
  this.UpperCase = function (s) {
    return s.toUpperCase();
  };
  this.LowerCase = function (s) {
    return s.toLowerCase();
  };
  this.SameText = function (s1, s2) {
    return s1.toLowerCase() == s2.toLowerCase();
  };
  this.Format = function (Fmt, Args) {
    var Result = "";
    Result = $mod.Format$1(Fmt,Args,$mod.FormatSettings);
    return Result;
  };
  this.Format$1 = function (Fmt, Args, aSettings) {
    var Result = "";
    var ChPos = 0;
    var OldPos = 0;
    var ArgPos = 0;
    var DoArg = 0;
    var Len = 0;
    var Hs = "";
    var ToAdd = "";
    var Index = 0;
    var Width = 0;
    var Prec = 0;
    var Left = false;
    var Fchar = "";
    var vq = 0;
    function ReadFormat() {
      var Result = "";
      var Value = 0;
      function ReadInteger() {
        var Code = 0;
        var ArgN = 0;
        if (Value !== -1) return;
        OldPos = ChPos;
        while ((ChPos <= Len) && (Fmt.charAt(ChPos - 1) <= "9") && (Fmt.charAt(ChPos - 1) >= "0")) ChPos += 1;
        if (ChPos > Len) $impl.DoFormatError(1,Fmt);
        if (Fmt.charAt(ChPos - 1) === "*") {
          if (Index === 255) {
            ArgN = ArgPos}
           else {
            ArgN = Index;
            Index += 1;
          };
          if ((ChPos > OldPos) || (ArgN > (rtl.length(Args) - 1))) $impl.DoFormatError(1,Fmt);
          ArgPos = ArgN + 1;
          var $tmp = Args[ArgN].VType;
          if ($tmp === 0) {
            Value = Args[ArgN].VJSValue}
           else if ($tmp === 19) {
            Value = Args[ArgN].VJSValue}
           else {
            $impl.DoFormatError(1,Fmt);
          };
          ChPos += 1;
        } else {
          if (OldPos < ChPos) {
            pas.System.val(pas.System.Copy(Fmt,OldPos,ChPos - OldPos),{get: function () {
                return Value;
              }, set: function (v) {
                Value = v;
              }},{get: function () {
                return Code;
              }, set: function (v) {
                Code = v;
              }});
            if (Code > 0) $impl.DoFormatError(1,Fmt);
          } else Value = -1;
        };
      };
      function ReadIndex() {
        if (Fmt.charAt(ChPos - 1) !== ":") {
          ReadInteger()}
         else Value = 0;
        if (Fmt.charAt(ChPos - 1) === ":") {
          if (Value === -1) $impl.DoFormatError(2,Fmt);
          Index = Value;
          Value = -1;
          ChPos += 1;
        };
      };
      function ReadLeft() {
        if (Fmt.charAt(ChPos - 1) === "-") {
          Left = true;
          ChPos += 1;
        } else Left = false;
      };
      function ReadWidth() {
        ReadInteger();
        if (Value !== -1) {
          Width = Value;
          Value = -1;
        };
      };
      function ReadPrec() {
        if (Fmt.charAt(ChPos - 1) === ".") {
          ChPos += 1;
          ReadInteger();
          if (Value === -1) Value = 0;
          Prec = Value;
        };
      };
      Index = 255;
      Width = -1;
      Prec = -1;
      Value = -1;
      ChPos += 1;
      if (Fmt.charAt(ChPos - 1) === "%") {
        Result = "%";
        return Result;
      };
      ReadIndex();
      ReadLeft();
      ReadWidth();
      ReadPrec();
      Result = pas.System.upcase(Fmt.charAt(ChPos - 1));
      return Result;
    };
    function Checkarg(AT, err) {
      var Result = false;
      Result = false;
      if (Index === 255) {
        DoArg = ArgPos}
       else DoArg = Index;
      ArgPos = DoArg + 1;
      if ((DoArg > (rtl.length(Args) - 1)) || (Args[DoArg].VType !== AT)) {
        if (err) $impl.DoFormatError(3,Fmt);
        ArgPos -= 1;
        return Result;
      };
      Result = true;
      return Result;
    };
    Result = "";
    Len = Fmt.length;
    ChPos = 1;
    OldPos = 1;
    ArgPos = 0;
    while (ChPos <= Len) {
      while ((ChPos <= Len) && (Fmt.charAt(ChPos - 1) !== "%")) ChPos += 1;
      if (ChPos > OldPos) Result = Result + pas.System.Copy(Fmt,OldPos,ChPos - OldPos);
      if (ChPos < Len) {
        Fchar = ReadFormat();
        var $tmp = Fchar;
        if ($tmp === "D") {
          if (Checkarg(0,false)) {
            ToAdd = $mod.IntToStr(Args[DoArg].VJSValue)}
           else if (Checkarg(19,true)) ToAdd = $mod.IntToStr(Args[DoArg].VJSValue);
          Width = Math.abs(Width);
          Index = Prec - ToAdd.length;
          if (ToAdd.charAt(0) !== "-") {
            ToAdd = pas.System.StringOfChar("0",Index) + ToAdd}
           else pas.System.Insert(pas.System.StringOfChar("0",Index + 1),{get: function () {
              return ToAdd;
            }, set: function (v) {
              ToAdd = v;
            }},2);
        } else if ($tmp === "U") {
          if (Checkarg(0,false)) {
            ToAdd = $mod.IntToStr(Args[DoArg].VJSValue >>> 0)}
           else if (Checkarg(19,true)) ToAdd = $mod.IntToStr(Args[DoArg].VJSValue);
          Width = Math.abs(Width);
          Index = Prec - ToAdd.length;
          ToAdd = pas.System.StringOfChar("0",Index) + ToAdd;
        } else if ($tmp === "E") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffExponent,3,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffExponent,3,Prec,aSettings);
        } else if ($tmp === "F") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffFixed,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffFixed,9999,Prec,aSettings);
        } else if ($tmp === "G") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffGeneral,Prec,3,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffGeneral,Prec,3,aSettings);
        } else if ($tmp === "N") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffNumber,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffNumber,9999,Prec,aSettings);
        } else if ($tmp === "M") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffCurrency,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffCurrency,9999,Prec,aSettings);
        } else if ($tmp === "S") {
          if (Checkarg(18,false)) {
            Hs = Args[DoArg].VJSValue}
           else if (Checkarg(9,true)) Hs = Args[DoArg].VJSValue;
          Index = Hs.length;
          if ((Prec !== -1) && (Index > Prec)) Index = Prec;
          ToAdd = pas.System.Copy(Hs,1,Index);
        } else if ($tmp === "P") {
          if (Checkarg(0,false)) {
            ToAdd = $mod.IntToHex(Args[DoArg].VJSValue,8)}
           else if (Checkarg(0,true)) ToAdd = $mod.IntToHex(Args[DoArg].VJSValue,16);
        } else if ($tmp === "X") {
          if (Checkarg(0,false)) {
            vq = Args[DoArg].VJSValue;
            Index = 16;
          } else if (Checkarg(19,true)) {
            vq = Args[DoArg].VJSValue;
            Index = 31;
          };
          if (Prec > Index) {
            ToAdd = $mod.IntToHex(vq,Index)}
           else {
            Index = 1;
            while ((rtl.shl(1,Index * 4) <= vq) && (Index < 16)) Index += 1;
            if (Index > Prec) Prec = Index;
            ToAdd = $mod.IntToHex(vq,Prec);
          };
        } else if ($tmp === "%") ToAdd = "%";
        if (Width !== -1) if (ToAdd.length < Width) if (!Left) {
          ToAdd = pas.System.StringOfChar(" ",Width - ToAdd.length) + ToAdd}
         else ToAdd = ToAdd + pas.System.StringOfChar(" ",Width - ToAdd.length);
        Result = Result + ToAdd;
      };
      ChPos += 1;
      OldPos = ChPos;
    };
    return Result;
  };
  this.TStringReplaceFlag = {"0": "rfReplaceAll", rfReplaceAll: 0, "1": "rfIgnoreCase", rfIgnoreCase: 1};
  this.StringReplace = function (aOriginal, aSearch, aReplace, Flags) {
    var Result = "";
    var REFlags = "";
    var REString = "";
    REFlags = "";
    if ($mod.TStringReplaceFlag.rfReplaceAll in Flags) REFlags = "g";
    if ($mod.TStringReplaceFlag.rfIgnoreCase in Flags) REFlags = REFlags + "i";
    REString = aSearch.replace(new RegExp($impl.RESpecials,"g"),"\\$1");
    Result = aOriginal.replace(new RegExp(REString,REFlags),aReplace);
    return Result;
  };
  this.IntToStr = function (Value) {
    var Result = "";
    Result = "" + Value;
    return Result;
  };
  this.TryStrToInt = function (S, res) {
    var Result = false;
    var NI = 0;
    Result = $mod.TryStrToInt$1(S,{get: function () {
        return NI;
      }, set: function (v) {
        NI = v;
      }});
    Result = Result && (-2147483648 <= NI) && (NI <= 2147483647);
    if (Result) res.set(NI);
    return Result;
  };
  this.TryStrToInt$1 = function (S, res) {
    var Result = false;
    Result = $impl.IntTryStrToInt(S,res,$mod.FormatSettings.DecimalSeparator);
    return Result;
  };
  this.StrToIntDef = function (S, aDef) {
    var Result = 0;
    var R = 0;
    if ($mod.TryStrToInt$1(S,{get: function () {
        return R;
      }, set: function (v) {
        R = v;
      }})) {
      Result = R}
     else Result = aDef;
    return Result;
  };
  this.IntToHex = function (Value, Digits) {
    var Result = "";
    Result = "";
    if (Value < 0) if (Value<0) Value = 0xFFFFFFFF + Value + 1;
    Result=Value.toString(16);
    Result = $mod.UpperCase(Result);
    while (Result.length < Digits) Result = "0" + Result;
    return Result;
  };
  this.TFloatFormat = {"0": "ffFixed", ffFixed: 0, "1": "ffGeneral", ffGeneral: 1, "2": "ffExponent", ffExponent: 2, "3": "ffNumber", ffNumber: 3, "4": "ffCurrency", ffCurrency: 4};
  this.FloatToStr = function (Value) {
    var Result = "";
    Result = $mod.FloatToStr$1(Value,$mod.FormatSettings);
    return Result;
  };
  this.FloatToStr$1 = function (Value, aSettings) {
    var Result = "";
    Result = $mod.FloatToStrF$1(Value,$mod.TFloatFormat.ffGeneral,15,0,aSettings);
    return Result;
  };
  this.FloatToStrF$1 = function (Value, format, Precision, Digits, aSettings) {
    var Result = "";
    var TS = "";
    var DS = "";
    DS = aSettings.DecimalSeparator;
    TS = aSettings.ThousandSeparator;
    var $tmp = format;
    if ($tmp === $mod.TFloatFormat.ffGeneral) {
      Result = $impl.FormatGeneralFloat(Value,Precision,DS)}
     else if ($tmp === $mod.TFloatFormat.ffExponent) {
      Result = $impl.FormatExponentFloat(Value,Precision,Digits,DS)}
     else if ($tmp === $mod.TFloatFormat.ffFixed) {
      Result = $impl.FormatFixedFloat(Value,Digits,DS)}
     else if ($tmp === $mod.TFloatFormat.ffNumber) {
      Result = $impl.FormatNumberFloat(Value,Digits,DS,TS)}
     else if ($tmp === $mod.TFloatFormat.ffCurrency) Result = $impl.FormatNumberCurrency(Value * 10000,Digits,aSettings);
    if ((format !== $mod.TFloatFormat.ffCurrency) && (Result.length > 1) && (Result.charAt(0) === "-")) $impl.RemoveLeadingNegativeSign({get: function () {
        return Result;
      }, set: function (v) {
        Result = v;
      }},DS,TS);
    return Result;
  };
  this.TryStrToFloat$2 = function (S, res) {
    var Result = false;
    Result = $mod.TryStrToFloat$3(S,res,$mod.FormatSettings);
    return Result;
  };
  this.TryStrToFloat$3 = function (S, res, aSettings) {
    var Result = false;
    var J = undefined;
    var N = "";
    N = S;
    if (aSettings.ThousandSeparator !== "") N = $mod.StringReplace(N,aSettings.ThousandSeparator,"",rtl.createSet($mod.TStringReplaceFlag.rfReplaceAll));
    if (aSettings.DecimalSeparator !== ".") N = $mod.StringReplace(N,aSettings.DecimalSeparator,".",{});
    J = parseFloat(N);
    Result = !isNaN(J);
    if (Result) res.set(rtl.getNumber(J));
    return Result;
  };
  this.StrToFloatDef = function (S, aDef) {
    var Result = 0.0;
    if (!$mod.TryStrToFloat$3(S,{get: function () {
        return Result;
      }, set: function (v) {
        Result = v;
      }},$mod.FormatSettings)) Result = aDef;
    return Result;
  };
  this.TimeSeparator = "";
  this.DateSeparator = "";
  this.ShortDateFormat = "";
  this.LongDateFormat = "";
  this.ShortTimeFormat = "";
  this.LongTimeFormat = "";
  this.DecimalSeparator = "";
  this.ThousandSeparator = "";
  this.TimeAMString = "";
  this.TimePMString = "";
  this.ShortMonthNames = rtl.arraySetLength(null,"",12);
  this.LongMonthNames = rtl.arraySetLength(null,"",12);
  this.ShortDayNames = rtl.arraySetLength(null,"",7);
  this.LongDayNames = rtl.arraySetLength(null,"",7);
  this.FormatSettings = this.TFormatSettings.$new();
  this.CurrencyFormat = 0;
  this.NegCurrFormat = 0;
  this.CurrencyDecimals = 0;
  this.CurrencyString = "";
  $mod.$implcode = function () {
    $impl.DefaultShortMonthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    $impl.DefaultLongMonthNames = ["January","February","March","April","May","June","July","August","September","October","November","December"];
    $impl.DefaultShortDayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    $impl.DefaultLongDayNames = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    $impl.feInvalidFormat = 1;
    $impl.feMissingArgument = 2;
    $impl.feInvalidArgIndex = 3;
    $impl.DoFormatError = function (ErrCode, fmt) {
      var $tmp = ErrCode;
      if ($tmp === 1) {
        throw $mod.EConvertError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SInvalidFormat"),pas.System.VarRecs(18,fmt)])}
       else if ($tmp === 2) {
        throw $mod.EConvertError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SArgumentMissing"),pas.System.VarRecs(18,fmt)])}
       else if ($tmp === 3) throw $mod.EConvertError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SInvalidArgIndex"),pas.System.VarRecs(18,fmt)]);
    };
    $impl.maxdigits = 15;
    $impl.ReplaceDecimalSep = function (S, DS) {
      var Result = "";
      var P = 0;
      P = pas.System.Pos(".",S);
      if (P > 0) {
        Result = pas.System.Copy(S,1,P - 1) + DS + pas.System.Copy(S,P + 1,S.length - P)}
       else Result = S;
      return Result;
    };
    $impl.FormatGeneralFloat = function (Value, Precision, DS) {
      var Result = "";
      var P = 0;
      var PE = 0;
      var Q = 0;
      var Exponent = 0;
      if ((Precision === -1) || (Precision > 15)) Precision = 15;
      Result = rtl.floatToStr(Value,Precision + 7);
      Result = $mod.TrimLeft(Result);
      P = pas.System.Pos(".",Result);
      if (P === 0) return Result;
      PE = pas.System.Pos("E",Result);
      if (PE === 0) {
        Result = $impl.ReplaceDecimalSep(Result,DS);
        return Result;
      };
      Q = PE + 2;
      Exponent = 0;
      while (Q <= Result.length) {
        Exponent = ((Exponent * 10) + Result.charCodeAt(Q - 1)) - 48;
        Q += 1;
      };
      if (Result.charAt((PE + 1) - 1) === "-") Exponent = -Exponent;
      if (((P + Exponent) < PE) && (Exponent > -6)) {
        Result = rtl.strSetLength(Result,PE - 1);
        if (Exponent >= 0) {
          for (var $l = 0, $end = Exponent - 1; $l <= $end; $l++) {
            Q = $l;
            Result = rtl.setCharAt(Result,P - 1,Result.charAt((P + 1) - 1));
            P += 1;
          };
          Result = rtl.setCharAt(Result,P - 1,".");
          P = 1;
          if (Result.charAt(P - 1) === "-") P += 1;
          while ((Result.charAt(P - 1) === "0") && (P < Result.length) && (pas.System.Copy(Result,P + 1,DS.length) !== DS)) pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P,1);
        } else {
          pas.System.Insert(pas.System.Copy("00000",1,-Exponent),{get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P - 1);
          Result = rtl.setCharAt(Result,P - Exponent - 1,Result.charAt(P - Exponent - 1 - 1));
          Result = rtl.setCharAt(Result,P - 1,".");
          if (Exponent !== -1) Result = rtl.setCharAt(Result,P - Exponent - 1 - 1,"0");
        };
        Q = Result.length;
        while ((Q > 0) && (Result.charAt(Q - 1) === "0")) Q -= 1;
        if (Result.charAt(Q - 1) === ".") Q -= 1;
        if ((Q === 0) || ((Q === 1) && (Result.charAt(0) === "-"))) {
          Result = "0"}
         else Result = rtl.strSetLength(Result,Q);
      } else {
        while (Result.charAt(PE - 1 - 1) === "0") {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},PE - 1,1);
          PE -= 1;
        };
        if (Result.charAt(PE - 1 - 1) === DS) {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},PE - 1,1);
          PE -= 1;
        };
        if (Result.charAt((PE + 1) - 1) === "+") {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},PE + 1,1)}
         else PE += 1;
        while (Result.charAt((PE + 1) - 1) === "0") pas.System.Delete({get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},PE + 1,1);
      };
      Result = $impl.ReplaceDecimalSep(Result,DS);
      return Result;
    };
    $impl.FormatExponentFloat = function (Value, Precision, Digits, DS) {
      var Result = "";
      var P = 0;
      DS = $mod.FormatSettings.DecimalSeparator;
      if ((Precision === -1) || (Precision > 15)) Precision = 15;
      Result = rtl.floatToStr(Value,Precision + 7);
      while (Result.charAt(0) === " ") pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      P = pas.System.Pos("E",Result);
      if (P === 0) {
        Result = $impl.ReplaceDecimalSep(Result,DS);
        return Result;
      };
      P += 2;
      if (Digits > 4) Digits = 4;
      Digits = (Result.length - P - Digits) + 1;
      if (Digits < 0) {
        pas.System.Insert(pas.System.Copy("0000",1,-Digits),{get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},P)}
       else while ((Digits > 0) && (Result.charAt(P - 1) === "0")) {
        pas.System.Delete({get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},P,1);
        if (P > Result.length) {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P - 2,2);
          break;
        };
        Digits -= 1;
      };
      Result = $impl.ReplaceDecimalSep(Result,DS);
      return Result;
    };
    $impl.FormatFixedFloat = function (Value, Digits, DS) {
      var Result = "";
      if (Digits === -1) {
        Digits = 2}
       else if (Digits > 18) Digits = 18;
      Result = rtl.floatToStr(Value,0,Digits);
      if ((Result !== "") && (Result.charAt(0) === " ")) pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      Result = $impl.ReplaceDecimalSep(Result,DS);
      return Result;
    };
    $impl.FormatNumberFloat = function (Value, Digits, DS, TS) {
      var Result = "";
      var P = 0;
      if (Digits === -1) {
        Digits = 2}
       else if (Digits > 15) Digits = 15;
      Result = rtl.floatToStr(Value,0,Digits);
      if ((Result !== "") && (Result.charAt(0) === " ")) pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      P = pas.System.Pos(".",Result);
      if (P <= 0) P = Result.length + 1;
      Result = $impl.ReplaceDecimalSep(Result,DS);
      P -= 3;
      if ((TS !== "") && (TS !== "\x00")) while (P > 1) {
        if (Result.charAt(P - 1 - 1) !== "-") pas.System.Insert(TS,{get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},P);
        P -= 3;
      };
      return Result;
    };
    $impl.RemoveLeadingNegativeSign = function (AValue, DS, aThousandSeparator) {
      var Result = false;
      var i = 0;
      var TS = "";
      var StartPos = 0;
      Result = false;
      StartPos = 2;
      TS = aThousandSeparator;
      for (var $l = StartPos, $end = AValue.get().length; $l <= $end; $l++) {
        i = $l;
        Result = (AValue.get().charCodeAt(i - 1) in rtl.createSet(48,DS.charCodeAt(),69,43)) || (AValue.get().charAt(i - 1) === TS);
        if (!Result) break;
      };
      if (Result && (AValue.get().charAt(0) === "-")) pas.System.Delete(AValue,1,1);
      return Result;
    };
    $impl.FormatNumberCurrency = function (Value, Digits, aSettings) {
      var Result = "";
      var Negative = false;
      var P = 0;
      var CS = "";
      var DS = "";
      var TS = "";
      DS = aSettings.DecimalSeparator;
      TS = aSettings.ThousandSeparator;
      CS = aSettings.CurrencyString;
      if (Digits === -1) {
        Digits = aSettings.CurrencyDecimals}
       else if (Digits > 18) Digits = 18;
      Result = rtl.floatToStr(Value / 10000,0,Digits);
      Negative = Result.charAt(0) === "-";
      if (Negative) pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      P = pas.System.Pos(".",Result);
      if (TS !== "") {
        if (P !== 0) {
          Result = $impl.ReplaceDecimalSep(Result,DS)}
         else P = Result.length + 1;
        P -= 3;
        while (P > 1) {
          pas.System.Insert(TS,{get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P);
          P -= 3;
        };
      };
      if (Negative) $impl.RemoveLeadingNegativeSign({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},DS,TS);
      if (!Negative) {
        var $tmp = aSettings.CurrencyFormat;
        if ($tmp === 0) {
          Result = CS + Result}
         else if ($tmp === 1) {
          Result = Result + CS}
         else if ($tmp === 2) {
          Result = CS + " " + Result}
         else if ($tmp === 3) Result = Result + " " + CS;
      } else {
        var $tmp1 = aSettings.NegCurrFormat;
        if ($tmp1 === 0) {
          Result = "(" + CS + Result + ")"}
         else if ($tmp1 === 1) {
          Result = "-" + CS + Result}
         else if ($tmp1 === 2) {
          Result = CS + "-" + Result}
         else if ($tmp1 === 3) {
          Result = CS + Result + "-"}
         else if ($tmp1 === 4) {
          Result = "(" + Result + CS + ")"}
         else if ($tmp1 === 5) {
          Result = "-" + Result + CS}
         else if ($tmp1 === 6) {
          Result = Result + "-" + CS}
         else if ($tmp1 === 7) {
          Result = Result + CS + "-"}
         else if ($tmp1 === 8) {
          Result = "-" + Result + " " + CS}
         else if ($tmp1 === 9) {
          Result = "-" + CS + " " + Result}
         else if ($tmp1 === 10) {
          Result = Result + " " + CS + "-"}
         else if ($tmp1 === 11) {
          Result = CS + " " + Result + "-"}
         else if ($tmp1 === 12) {
          Result = CS + " " + "-" + Result}
         else if ($tmp1 === 13) {
          Result = Result + "-" + " " + CS}
         else if ($tmp1 === 14) {
          Result = "(" + CS + " " + Result + ")"}
         else if ($tmp1 === 15) Result = "(" + Result + " " + CS + ")";
      };
      return Result;
    };
    $impl.RESpecials = "([\\$\\+\\[\\]\\(\\)\\\\\\.\\*\\^\\?\\|])";
    $impl.IntTryStrToInt = function (S, res, aSep) {
      var Result = false;
      var Radix = 10;
      var N = "";
      var J = undefined;
      N = S;
      if ((pas.System.Pos(aSep,N) !== 0) || (pas.System.Pos(".",N) !== 0)) return false;
      var $tmp = pas.System.Copy(N,1,1);
      if ($tmp === "$") {
        Radix = 16}
       else if ($tmp === "&") {
        Radix = 8}
       else if ($tmp === "%") Radix = 2;
      if ((Radix !== 16) && (pas.System.Pos("e",$mod.LowerCase(N)) !== 0)) return false;
      if (Radix !== 10) pas.System.Delete({get: function () {
          return N;
        }, set: function (v) {
          N = v;
        }},1,1);
      J = parseInt(N,Radix);
      Result = !isNaN(J);
      if (Result) res.set(rtl.trunc(J));
      return Result;
    };
  };
  $mod.$init = function () {
    $mod.ShortMonthNames = $impl.DefaultShortMonthNames.slice(0);
    $mod.LongMonthNames = $impl.DefaultLongMonthNames.slice(0);
    $mod.ShortDayNames = $impl.DefaultShortDayNames.slice(0);
    $mod.LongDayNames = $impl.DefaultLongDayNames.slice(0);
    $mod.FormatSettings.$assign($mod.TFormatSettings.Create());
    $mod.TimeSeparator = $mod.FormatSettings.TimeSeparator;
    $mod.DateSeparator = $mod.FormatSettings.DateSeparator;
    $mod.ShortDateFormat = $mod.FormatSettings.ShortDateFormat;
    $mod.LongDateFormat = $mod.FormatSettings.LongDateFormat;
    $mod.ShortTimeFormat = $mod.FormatSettings.ShortTimeFormat;
    $mod.LongTimeFormat = $mod.FormatSettings.LongTimeFormat;
    $mod.DecimalSeparator = $mod.FormatSettings.DecimalSeparator;
    $mod.ThousandSeparator = $mod.FormatSettings.ThousandSeparator;
    $mod.TimeAMString = $mod.FormatSettings.TimeAMString;
    $mod.TimePMString = $mod.FormatSettings.TimePMString;
    $mod.CurrencyFormat = $mod.FormatSettings.CurrencyFormat;
    $mod.NegCurrFormat = $mod.FormatSettings.NegCurrFormat;
    $mod.CurrencyDecimals = $mod.FormatSettings.CurrencyDecimals;
    $mod.CurrencyString = $mod.FormatSettings.CurrencyString;
  };
},[]);
rtl.module("Web",["System","JS"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("PMS.AppName",["System"],function () {
  "use strict";
  var $mod = this;
  this.PMSVersion = "0.1.0";
});
rtl.module("PMS.Types",["System"],function () {
  "use strict";
  var $mod = this;
  this.PMSMaxInputLen = 4096;
  this.PMSMaxDepth = 64;
  this.PMSMaxOps = 10000;
  this.PMSMaxSamples = 4096;
  this.TAngleMode = {"0": "amRadian", amRadian: 0, "1": "amDegree", amDegree: 1, "2": "amGrad", amGrad: 2};
  this.TNumberMode = {"0": "nmReal", nmReal: 0, "1": "nmComplex", nmComplex: 1};
  this.TCalcError = {"0": "ceNone", ceNone: 0, "1": "ceSyntax", ceSyntax: 1, "2": "ceUnknownFunction", ceUnknownFunction: 2, "3": "ceUnknownVariable", ceUnknownVariable: 3, "4": "ceDivisionByZero", ceDivisionByZero: 4, "5": "ceDomain", ceDomain: 5, "6": "ceOverflow", ceOverflow: 6, "7": "ceUnderflow", ceUnderflow: 7, "8": "ceInvalidMatrixDim", ceInvalidMatrixDim: 8, "9": "ceNoConvergence", ceNoConvergence: 9, "10": "ceUnsupported", ceUnsupported: 10, "11": "ceRecursionLimit", ceRecursionLimit: 11, "12": "ceCancelled", ceCancelled: 12, "13": "ceTooComplex", ceTooComplex: 13};
  this.CalcErrorMessage = function (E) {
    var Result = "";
    var $tmp = E;
    if ($tmp === $mod.TCalcError.ceNone) {
      Result = "ok"}
     else if ($tmp === $mod.TCalcError.ceSyntax) {
      Result = "Syntax error: could not parse the expression."}
     else if ($tmp === $mod.TCalcError.ceUnknownFunction) {
      Result = "Unknown function."}
     else if ($tmp === $mod.TCalcError.ceUnknownVariable) {
      Result = "Unknown variable."}
     else if ($tmp === $mod.TCalcError.ceDivisionByZero) {
      Result = "Division by zero."}
     else if ($tmp === $mod.TCalcError.ceDomain) {
      Result = "Value outside the function domain (e.g. log of a negative number in real mode)."}
     else if ($tmp === $mod.TCalcError.ceOverflow) {
      Result = "Numeric overflow."}
     else if ($tmp === $mod.TCalcError.ceUnderflow) {
      Result = "Numeric underflow."}
     else if ($tmp === $mod.TCalcError.ceInvalidMatrixDim) {
      Result = "Incompatible matrix dimensions."}
     else if ($tmp === $mod.TCalcError.ceNoConvergence) {
      Result = "Method did not converge."}
     else if ($tmp === $mod.TCalcError.ceUnsupported) {
      Result = "Operation not supported (yet)."}
     else if ($tmp === $mod.TCalcError.ceRecursionLimit) {
      Result = "Expression too deeply nested."}
     else if ($tmp === $mod.TCalcError.ceCancelled) {
      Result = "Computation cancelled."}
     else if ($tmp === $mod.TCalcError.ceTooComplex) Result = "Expression exceeds safety limits (length\/operations).";
    return Result;
  };
  rtl.recNewT(this,"TBinding",function () {
    this.Name = "";
    this.Value = 0.0;
    this.$eq = function (b) {
      return (this.Name === b.Name) && (this.Value === b.Value);
    };
    this.$assign = function (s) {
      this.Name = s.Name;
      this.Value = s.Value;
      return this;
    };
  });
  rtl.createClass(this,"TEvalContext",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FVars = [];
      this.AngleMode = 0;
      this.NumberMode = 0;
      this.Ans = 0.0;
      this.HasAns = false;
      this.OpCount = 0;
      this.Cancelled = false;
    };
    this.$final = function () {
      this.FVars = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Find = function (Name) {
      var Result = 0;
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.FVars) - 1; $l <= $end; $l++) {
        I = $l;
        if (this.FVars[I].Name === Name) return I;
      };
      Result = -1;
      return Result;
    };
    this.Create$1 = function () {
      pas.System.TObject.Create.call(this);
      this.AngleMode = $mod.TAngleMode.amRadian;
      this.NumberMode = $mod.TNumberMode.nmReal;
      this.Ans = 0;
      this.HasAns = false;
      this.OpCount = 0;
      this.Cancelled = false;
      this.FVars = rtl.arraySetLength(this.FVars,$mod.TBinding,0);
      return this;
    };
    this.SetVar = function (Name, Value) {
      var I = 0;
      I = this.Find(Name);
      if (I >= 0) {
        this.FVars[I].Value = Value}
       else {
        this.FVars = rtl.arraySetLength(this.FVars,$mod.TBinding,rtl.length(this.FVars) + 1);
        this.FVars[rtl.length(this.FVars) - 1].Name = Name;
        this.FVars[rtl.length(this.FVars) - 1].Value = Value;
      };
    };
    this.GetVar = function (Name, Value) {
      var Result = false;
      var I = 0;
      I = this.Find(Name);
      Result = I >= 0;
      if (Result) {
        Value.set(this.FVars[I].Value)}
       else Value.set(0);
      return Result;
    };
    this.DelVar = function (Name) {
      var I = 0;
      var J = 0;
      I = this.Find(Name);
      if (I < 0) return;
      for (var $l = I, $end = rtl.length(this.FVars) - 1 - 1; $l <= $end; $l++) {
        J = $l;
        this.FVars[J].$assign(this.FVars[J + 1]);
      };
      this.FVars = rtl.arraySetLength(this.FVars,$mod.TBinding,rtl.length(this.FVars) - 1);
    };
    this.CheckOps = function () {
      var Result = false;
      this.OpCount += 1;
      Result = (this.OpCount <= 10000) && !this.Cancelled;
      return Result;
    };
  });
});
rtl.module("Math",["System"],function () {
  "use strict";
  var $mod = this;
  this.IsInfinite = function (d) {
    return (d==Infinity) || (d==-Infinity);
  };
  this.Ceil = function (A) {
    var Result = 0;
    Result = pas.System.Trunc(Math.ceil(A));
    return Result;
  };
  this.Floor = function (A) {
    var Result = 0;
    Result = pas.System.Trunc(Math.floor(A));
    return Result;
  };
});
rtl.module("PMS.AST",["System"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TASTNode",pas.System.TObject,function () {
  });
  rtl.createClass(this,"TNumberNode",this.TASTNode,function () {
    this.$init = function () {
      $mod.TASTNode.$init.call(this);
      this.Value = 0.0;
    };
    this.Create$1 = function (AValue) {
      pas.System.TObject.Create.call(this);
      this.Value = AValue;
      return this;
    };
    this.Clone = function () {
      var Result = null;
      Result = $mod.TNumberNode.$create("Create$1",[this.Value]);
      return Result;
    };
  });
  rtl.createClass(this,"TVarNode",this.TASTNode,function () {
    this.$init = function () {
      $mod.TASTNode.$init.call(this);
      this.Name = "";
    };
    this.Create$1 = function (AName) {
      pas.System.TObject.Create.call(this);
      this.Name = AName;
      return this;
    };
    this.Clone = function () {
      var Result = null;
      Result = $mod.TVarNode.$create("Create$1",[this.Name]);
      return Result;
    };
  });
  rtl.createClass(this,"TUnaryNode",this.TASTNode,function () {
    this.$init = function () {
      $mod.TASTNode.$init.call(this);
      this.Op = "";
      this.Child = null;
    };
    this.$final = function () {
      this.Child = undefined;
      $mod.TASTNode.$final.call(this);
    };
    this.Create$1 = function (AOp, AChild) {
      pas.System.TObject.Create.call(this);
      this.Op = AOp;
      this.Child = AChild;
      return this;
    };
    this.Destroy = function () {
      rtl.free(this,"Child");
      pas.System.TObject.Destroy.call(this);
    };
    this.Clone = function () {
      var Result = null;
      Result = $mod.TUnaryNode.$create("Create$1",[this.Op,this.Child.Clone()]);
      return Result;
    };
  });
  rtl.createClass(this,"TBinaryNode",this.TASTNode,function () {
    this.$init = function () {
      $mod.TASTNode.$init.call(this);
      this.Op = "";
      this.Left = null;
      this.Right = null;
    };
    this.$final = function () {
      this.Left = undefined;
      this.Right = undefined;
      $mod.TASTNode.$final.call(this);
    };
    this.Create$1 = function (AOp, ALeft, ARight) {
      pas.System.TObject.Create.call(this);
      this.Op = AOp;
      this.Left = ALeft;
      this.Right = ARight;
      return this;
    };
    this.Destroy = function () {
      rtl.free(this,"Left");
      rtl.free(this,"Right");
      pas.System.TObject.Destroy.call(this);
    };
    this.Clone = function () {
      var Result = null;
      Result = $mod.TBinaryNode.$create("Create$1",[this.Op,this.Left.Clone(),this.Right.Clone()]);
      return Result;
    };
  });
  rtl.createClass(this,"TFuncNode",this.TASTNode,function () {
    this.$init = function () {
      $mod.TASTNode.$init.call(this);
      this.Name = "";
      this.Args = [];
    };
    this.$final = function () {
      this.Args = undefined;
      $mod.TASTNode.$final.call(this);
    };
    this.Create$1 = function (AName) {
      pas.System.TObject.Create.call(this);
      this.Name = AName;
      this.Args = rtl.arraySetLength(this.Args,null,0);
      return this;
    };
    this.Destroy = function () {
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.Args) - 1; $l <= $end; $l++) {
        I = $l;
        rtl.free(this.Args,I);
      };
      pas.System.TObject.Destroy.call(this);
    };
    this.AddArg = function (A) {
      this.Args = rtl.arraySetLength(this.Args,null,rtl.length(this.Args) + 1);
      this.Args[rtl.length(this.Args) - 1] = A;
    };
    this.Clone = function () {
      var Result = null;
      var I = 0;
      Result = $mod.TFuncNode.$create("Create$1",[this.Name]);
      for (var $l = 0, $end = rtl.length(this.Args) - 1; $l <= $end; $l++) {
        I = $l;
        Result.AddArg(this.Args[I].Clone());
      };
      return Result;
    };
  });
  rtl.createClass(this,"TAssignNode",this.TASTNode,function () {
    this.$init = function () {
      $mod.TASTNode.$init.call(this);
      this.Name = "";
      this.Expr = null;
    };
    this.$final = function () {
      this.Expr = undefined;
      $mod.TASTNode.$final.call(this);
    };
    this.Create$1 = function (AName, AExpr) {
      pas.System.TObject.Create.call(this);
      this.Name = AName;
      this.Expr = AExpr;
      return this;
    };
    this.Destroy = function () {
      rtl.free(this,"Expr");
      pas.System.TObject.Destroy.call(this);
    };
    this.Clone = function () {
      var Result = null;
      Result = $mod.TAssignNode.$create("Create$1",[this.Name,this.Expr.Clone()]);
      return Result;
    };
  });
  rtl.createClass(this,"TFuncDefNode",this.TASTNode,function () {
    this.$init = function () {
      $mod.TASTNode.$init.call(this);
      this.Name = "";
      this.Params = [];
      this.Body = null;
    };
    this.$final = function () {
      this.Params = undefined;
      this.Body = undefined;
      $mod.TASTNode.$final.call(this);
    };
    this.Create$1 = function (AName, ABody) {
      pas.System.TObject.Create.call(this);
      this.Name = AName;
      this.Body = ABody;
      this.Params = rtl.arraySetLength(this.Params,"",0);
      return this;
    };
    this.Destroy = function () {
      rtl.free(this,"Body");
      pas.System.TObject.Destroy.call(this);
    };
    this.AddParam = function (P) {
      this.Params = rtl.arraySetLength(this.Params,"",rtl.length(this.Params) + 1);
      this.Params[rtl.length(this.Params) - 1] = P;
    };
    this.Clone = function () {
      var Result = null;
      var I = 0;
      Result = $mod.TFuncDefNode.$create("Create$1",[this.Name,this.Body.Clone()]);
      for (var $l = 0, $end = rtl.length(this.Params) - 1; $l <= $end; $l++) {
        I = $l;
        Result.AddParam(this.Params[I]);
      };
      return Result;
    };
  });
});
rtl.module("PMS.Lexer",["System","SysUtils","PMS.Types"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.TTokenKind = {"0": "tkEOF", tkEOF: 0, "1": "tkNumber", tkNumber: 1, "2": "tkIdent", tkIdent: 2, "3": "tkPlus", tkPlus: 3, "4": "tkMinus", tkMinus: 4, "5": "tkStar", tkStar: 5, "6": "tkSlash", tkSlash: 6, "7": "tkCaret", tkCaret: 7, "8": "tkLParen", tkLParen: 8, "9": "tkRParen", tkRParen: 9, "10": "tkComma", tkComma: 10, "11": "tkEquals", tkEquals: 11, "12": "tkBang", tkBang: 12, "13": "tkPercent", tkPercent: 13};
  rtl.recNewT(this,"TToken",function () {
    this.Kind = 0;
    this.NumValue = 0.0;
    this.Text = "";
    this.Pos = 0;
    this.$eq = function (b) {
      return (this.Kind === b.Kind) && (this.NumValue === b.NumValue) && (this.Text === b.Text) && (this.Pos === b.Pos);
    };
    this.$assign = function (s) {
      this.Kind = s.Kind;
      this.NumValue = s.NumValue;
      this.Text = s.Text;
      this.Pos = s.Pos;
      return this;
    };
  });
  this.Tokenize = function (Src, Tokens, Err, ErrPos) {
    var Result = false;
    var I = 0;
    var Start = 0;
    var NumStr = "";
    function ScanNumber() {
      var HasExp = false;
      Start = I;
      while ((I <= Src.length) && $impl.IsDigit(Src.charAt(I - 1))) I += 1;
      if ((I <= Src.length) && (Src.charAt(I - 1) === ".")) {
        I += 1;
        while ((I <= Src.length) && $impl.IsDigit(Src.charAt(I - 1))) I += 1;
      };
      HasExp = (I <= Src.length) && ((Src.charAt(I - 1) === "e") || (Src.charAt(I - 1) === "E"));
      if (HasExp) {
        I += 1;
        if ((I <= Src.length) && ((Src.charAt(I - 1) === "+") || (Src.charAt(I - 1) === "-"))) I += 1;
        if ((I > Src.length) || !$impl.IsDigit(Src.charAt(I - 1))) {
          Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
          ErrPos.set(Start);
          Tokens.set([]);
          return;
        };
        while ((I <= Src.length) && $impl.IsDigit(Src.charAt(I - 1))) I += 1;
      };
      NumStr = pas.System.Copy(Src,Start,I - Start);
      if (!pas.SysUtils.TryStrToFloat$2(NumStr,{p: Tokens.get()[rtl.length(Tokens.get()) - 1], get: function () {
          return this.p.NumValue;
        }, set: function (v) {
          this.p.NumValue = v;
        }})) {
        Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
        ErrPos.set(Start);
        Tokens.set([]);
        return;
      };
      Tokens.get()[rtl.length(Tokens.get()) - 1].Text = NumStr;
    };
    Tokens.set([]);
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    ErrPos.set(0);
    Result = true;
    if (Src.length > 4096) {
      Err.set(pas["PMS.Types"].TCalcError.ceTooComplex);
      ErrPos.set(4096 + 1);
      return false;
    };
    I = 1;
    while (I <= Src.length) {
      if ((Src.charAt(I - 1) === " ") || (Src.charAt(I - 1) === "\t")) {
        I += 1;
        continue;
      };
      if ($impl.IsDigit(Src.charAt(I - 1)) || ((Src.charAt(I - 1) === ".") && (I < Src.length) && $impl.IsDigit(Src.charAt((I + 1) - 1)))) {
        $impl.Push(Tokens,$mod.TTokenKind.tkNumber,I);
        ScanNumber();
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return false;
        continue;
      };
      if ($impl.IsIdentStart(Src.charAt(I - 1))) {
        Start = I;
        while ((I <= Src.length) && $impl.IsIdentChar(Src.charAt(I - 1))) I += 1;
        $impl.Push(Tokens,$mod.TTokenKind.tkIdent,Start);
        Tokens.get()[rtl.length(Tokens.get()) - 1].Text = pas.System.Copy(Src,Start,I - Start);
        continue;
      };
      var $tmp = Src.charAt(I - 1);
      if ($tmp === "+") {
        $impl.Push(Tokens,$mod.TTokenKind.tkPlus,I)}
       else if ($tmp === "-") {
        $impl.Push(Tokens,$mod.TTokenKind.tkMinus,I)}
       else if ($tmp === "*") {
        $impl.Push(Tokens,$mod.TTokenKind.tkStar,I)}
       else if ($tmp === "\/") {
        $impl.Push(Tokens,$mod.TTokenKind.tkSlash,I)}
       else if ($tmp === "^") {
        $impl.Push(Tokens,$mod.TTokenKind.tkCaret,I)}
       else if ($tmp === "(") {
        $impl.Push(Tokens,$mod.TTokenKind.tkLParen,I)}
       else if ($tmp === ")") {
        $impl.Push(Tokens,$mod.TTokenKind.tkRParen,I)}
       else if ($tmp === ",") {
        $impl.Push(Tokens,$mod.TTokenKind.tkComma,I)}
       else if ($tmp === "=") {
        $impl.Push(Tokens,$mod.TTokenKind.tkEquals,I)}
       else if ($tmp === "!") {
        $impl.Push(Tokens,$mod.TTokenKind.tkBang,I)}
       else if ($tmp === "%") {
        $impl.Push(Tokens,$mod.TTokenKind.tkPercent,I)}
       else {
        Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
        ErrPos.set(I);
        Tokens.set([]);
        return false;
      };
      I += 1;
    };
    $impl.Push(Tokens,$mod.TTokenKind.tkEOF,Src.length + 1);
    return Result;
  };
  $mod.$implcode = function () {
    $impl.IsDigit = function (C) {
      var Result = false;
      Result = (C >= "0") && (C <= "9");
      return Result;
    };
    $impl.IsIdentStart = function (C) {
      var Result = false;
      Result = ((C >= "a") && (C <= "z")) || ((C >= "A") && (C <= "Z")) || (C === "_");
      return Result;
    };
    $impl.IsIdentChar = function (C) {
      var Result = false;
      Result = $impl.IsIdentStart(C) || $impl.IsDigit(C);
      return Result;
    };
    $impl.Push = function (Tokens, Kind, Pos) {
      Tokens.set(rtl.arraySetLength(Tokens.get(),$mod.TToken,rtl.length(Tokens.get()) + 1));
      Tokens.get()[rtl.length(Tokens.get()) - 1].Kind = Kind;
      Tokens.get()[rtl.length(Tokens.get()) - 1].NumValue = 0;
      Tokens.get()[rtl.length(Tokens.get()) - 1].Text = "";
      Tokens.get()[rtl.length(Tokens.get()) - 1].Pos = Pos;
    };
  };
},[]);
rtl.module("PMS.Parser",["System","SysUtils","PMS.Types","PMS.Lexer","PMS.AST"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.ParseExpression = function (Src, Root, Err, ErrPos) {
    var Result = false;
    var Tokens = [];
    var P = null;
    Root.set(null);
    if (!pas["PMS.Lexer"].Tokenize(Src,{get: function () {
        return Tokens;
      }, set: function (v) {
        Tokens = v;
      }},Err,ErrPos)) return false;
    P = $impl.TParser.$create("Create$1",[Tokens]);
    try {
      try {
        Root.set(P.Run());
        Err.set(pas["PMS.Types"].TCalcError.ceNone);
        ErrPos.set(0);
        Result = true;
      } catch ($e) {
        if ($impl.EParseError.isPrototypeOf($e)) {
          var E = $e;
          Root.set(null);
          Err.set(E.Code);
          ErrPos.set(E.Pos);
          Result = false;
        } else throw $e
      };
    } finally {
      P = rtl.freeLoc(P);
    };
    return Result;
  };
  $mod.$implcode = function () {
    rtl.createClass($impl,"EParseError",pas.SysUtils.Exception,function () {
      this.$init = function () {
        pas.SysUtils.Exception.$init.call(this);
        this.Code = 0;
        this.Pos = 0;
      };
    });
    rtl.createClass($impl,"TParser",pas.System.TObject,function () {
      this.$init = function () {
        pas.System.TObject.$init.call(this);
        this.FTokens = [];
        this.FPos = 0;
        this.FDepth = 0;
        this.FOwned = [];
      };
      this.$final = function () {
        this.FTokens = undefined;
        this.FOwned = undefined;
        pas.System.TObject.$final.call(this);
      };
      this.Peek = function () {
        var Result = pas["PMS.Lexer"].TToken.$new();
        Result.$assign(this.PeekAt(0));
        return Result;
      };
      this.PeekAt = function (Offset) {
        var Result = pas["PMS.Lexer"].TToken.$new();
        var I = 0;
        I = this.FPos + Offset;
        if (I >= rtl.length(this.FTokens)) {
          Result.$assign(this.FTokens[rtl.length(this.FTokens) - 1])}
         else Result.$assign(this.FTokens[I]);
        return Result;
      };
      this.Next = function () {
        var Result = pas["PMS.Lexer"].TToken.$new();
        Result.$assign(this.Peek());
        if (this.FPos < rtl.length(this.FTokens)) this.FPos += 1;
        return Result;
      };
      this.Own = function (N) {
        var Result = null;
        this.FOwned = rtl.arraySetLength(this.FOwned,null,rtl.length(this.FOwned) + 1);
        this.FOwned[rtl.length(this.FOwned) - 1] = N;
        Result = N;
        return Result;
      };
      this.Disown = function (N) {
        var I = 0;
        for (var $l = rtl.length(this.FOwned) - 1; $l >= 0; $l--) {
          I = $l;
          if (this.FOwned[I] === N) {
            this.FOwned[I] = this.FOwned[rtl.length(this.FOwned) - 1];
            this.FOwned = rtl.arraySetLength(this.FOwned,null,rtl.length(this.FOwned) - 1);
            return;
          };
        };
      };
      this.FreeOwned = function () {
        var I = 0;
        for (var $l = rtl.length(this.FOwned) - 1; $l >= 0; $l--) {
          I = $l;
          rtl.free(this.FOwned,I);
        };
        this.FOwned = rtl.arraySetLength(this.FOwned,null,0);
      };
      this.CheckDepth = function (Pos) {
        this.FDepth += 1;
        if (this.FDepth > 64) this.Fail(pas["PMS.Types"].TCalcError.ceRecursionLimit,Pos);
      };
      this.Fail = function (Code, Pos) {
        var E = null;
        this.FreeOwned();
        E = $impl.EParseError.$create("Create$1",["parse"]);
        E.Code = Code;
        E.Pos = Pos;
        throw E;
      };
      this.IsModOp = function () {
        var Result = false;
        Result = (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkIdent) && (pas.SysUtils.LowerCase(this.Peek().Text) === "mod");
        return Result;
      };
      this.ParseAssign = function () {
        var Result = null;
        var Name = "";
        var Child = null;
        Result = this.TryParseFuncDef();
        if (Result != null) return Result;
        if ((this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkIdent) && (this.PeekAt(1).Kind === pas["PMS.Lexer"].TTokenKind.tkEquals)) {
          Name = this.Next().Text;
          this.Next();
          Child = this.ParseAssign();
          Result = this.Own(pas["PMS.AST"].TAssignNode.$create("Create$1",[Name,Child]));
          this.Disown(Child);
          return Result;
        };
        Result = this.ParseAdditive();
        return Result;
      };
      this.TryParseFuncDef = function () {
        var Result = null;
        var I = 0;
        var J = 0;
        var Name = "";
        var Params = [];
        var Body = null;
        var Def = null;
        Result = null;
        if ((this.PeekAt(0).Kind !== pas["PMS.Lexer"].TTokenKind.tkIdent) || (this.PeekAt(1).Kind !== pas["PMS.Lexer"].TTokenKind.tkLParen)) return Result;
        I = this.FPos + 2;
        Params = rtl.arraySetLength(Params,"",0);
        if (this.FTokens[I].Kind !== pas["PMS.Lexer"].TTokenKind.tkRParen) {
          while (true) {
            if ((I >= rtl.length(this.FTokens)) || (this.FTokens[I].Kind !== pas["PMS.Lexer"].TTokenKind.tkIdent)) return Result;
            Params = rtl.arraySetLength(Params,"",rtl.length(Params) + 1);
            Params[rtl.length(Params) - 1] = this.FTokens[I].Text;
            I += 1;
            if ((I < rtl.length(this.FTokens)) && (this.FTokens[I].Kind === pas["PMS.Lexer"].TTokenKind.tkComma)) {
              I += 1;
              continue;
            };
            break;
          };
        };
        if ((I >= rtl.length(this.FTokens)) || (this.FTokens[I].Kind !== pas["PMS.Lexer"].TTokenKind.tkRParen)) return Result;
        I += 1;
        if ((I >= rtl.length(this.FTokens)) || (this.FTokens[I].Kind !== pas["PMS.Lexer"].TTokenKind.tkEquals)) return Result;
        Name = this.FTokens[this.FPos].Text;
        this.FPos = I + 1;
        this.CheckDepth(this.FTokens[I].Pos);
        Body = this.ParseAssign();
        this.FDepth -= 1;
        Def = pas["PMS.AST"].TFuncDefNode.$create("Create$1",[Name,Body]);
        for (var $l = 0, $end = rtl.length(Params) - 1; $l <= $end; $l++) {
          J = $l;
          Def.AddParam(Params[J]);
        };
        Result = this.Own(Def);
        this.Disown(Body);
        return Result;
      };
      this.ParseAdditive = function () {
        var Result = null;
        var Left = null;
        var Right = null;
        var Op = "";
        Left = this.ParseMultiplicative();
        while ((this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkPlus) || (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkMinus)) {
          if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkPlus) {
            Op = "+"}
           else Op = "-";
          this.Next();
          Right = this.ParseMultiplicative();
          Left = this.Own(pas["PMS.AST"].TBinaryNode.$create("Create$1",[Op,Left,Right]));
          this.Disown(Left.Left);
          this.Disown(Left.Right);
        };
        Result = Left;
        return Result;
      };
      this.ParseMultiplicative = function () {
        var Result = null;
        var Left = null;
        var Right = null;
        var Op = "";
        Left = this.ParseImplicit();
        while ((this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkStar) || (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkSlash) || this.IsModOp()) {
          if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkStar) {
            Op = "*"}
           else if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkSlash) {
            Op = "\/"}
           else Op = "m";
          this.Next();
          Right = this.ParseImplicit();
          Left = this.Own(pas["PMS.AST"].TBinaryNode.$create("Create$1",[Op,Left,Right]));
          this.Disown(Left.Left);
          this.Disown(Left.Right);
        };
        Result = Left;
        return Result;
      };
      this.ParseImplicit = function () {
        var Result = null;
        var Left = null;
        var Right = null;
        Left = this.ParseUnary();
        while (this.Peek().Kind in rtl.createSet(pas["PMS.Lexer"].TTokenKind.tkNumber,pas["PMS.Lexer"].TTokenKind.tkIdent,pas["PMS.Lexer"].TTokenKind.tkLParen)) {
          if (this.IsModOp()) break;
          this.CheckDepth(this.Peek().Pos);
          Right = this.ParseUnary();
          Left = this.Own(pas["PMS.AST"].TBinaryNode.$create("Create$1",["*",Left,Right]));
          this.Disown(Left.Left);
          this.Disown(Left.Right);
          this.FDepth -= 1;
        };
        Result = Left;
        return Result;
      };
      this.ParseUnary = function () {
        var Result = null;
        var Neg = false;
        var Inner = null;
        Neg = false;
        while ((this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkPlus) || (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkMinus)) {
          if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkMinus) Neg = !Neg;
          this.Next();
        };
        Inner = this.ParsePower();
        if (Neg) {
          Result = this.Own(pas["PMS.AST"].TUnaryNode.$create("Create$1",["-",Inner]));
          this.Disown(Inner);
        } else Result = Inner;
        return Result;
      };
      this.ParsePower = function () {
        var Result = null;
        var Base = null;
        var Expo = null;
        var Caret = pas["PMS.Lexer"].TToken.$new();
        Base = this.ParsePostfix();
        if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkCaret) {
          Caret.$assign(this.Next());
          this.CheckDepth(Caret.Pos);
          Expo = this.ParseUnary();
          this.FDepth -= 1;
          Result = this.Own(pas["PMS.AST"].TBinaryNode.$create("Create$1",["^",Base,Expo]));
          this.Disown(Base);
          this.Disown(Expo);
        } else Result = Base;
        return Result;
      };
      this.ParsePostfix = function () {
        var Result = null;
        var N = null;
        var Old = null;
        var T = pas["PMS.Lexer"].TToken.$new();
        N = this.ParsePrimary();
        while ((this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkBang) || (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkPercent)) {
          T.$assign(this.Next());
          Old = N;
          if (T.Kind === pas["PMS.Lexer"].TTokenKind.tkBang) {
            N = this.Own(pas["PMS.AST"].TUnaryNode.$create("Create$1",["!",Old]))}
           else N = this.Own(pas["PMS.AST"].TUnaryNode.$create("Create$1",["%",Old]));
          this.Disown(Old);
        };
        Result = N;
        return Result;
      };
      this.ParsePrimary = function () {
        var Result = null;
        var T = pas["PMS.Lexer"].TToken.$new();
        var F = null;
        var Arg = null;
        T.$assign(this.Peek());
        var $tmp = T.Kind;
        if ($tmp === pas["PMS.Lexer"].TTokenKind.tkNumber) {
          this.Next();
          Result = this.Own(pas["PMS.AST"].TNumberNode.$create("Create$1",[T.NumValue]));
        } else if ($tmp === pas["PMS.Lexer"].TTokenKind.tkIdent) {
          this.Next();
          if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkLParen) {
            this.Next();
            F = pas["PMS.AST"].TFuncNode.$create("Create$1",[T.Text]);
            this.Own(F);
            if (this.Peek().Kind !== pas["PMS.Lexer"].TTokenKind.tkRParen) {
              while (true) {
                Arg = this.ParseAssign();
                F.AddArg(Arg);
                this.Disown(Arg);
                if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkComma) {
                  this.Next();
                  continue;
                };
                break;
              };
            };
            if (this.Peek().Kind !== pas["PMS.Lexer"].TTokenKind.tkRParen) this.Fail(pas["PMS.Types"].TCalcError.ceSyntax,this.Peek().Pos);
            this.Next();
            Result = F;
          } else Result = this.Own(pas["PMS.AST"].TVarNode.$create("Create$1",[T.Text]));
        } else if ($tmp === pas["PMS.Lexer"].TTokenKind.tkLParen) {
          this.Next();
          Result = this.ParseAssign();
          if (this.Peek().Kind !== pas["PMS.Lexer"].TTokenKind.tkRParen) this.Fail(pas["PMS.Types"].TCalcError.ceSyntax,this.Peek().Pos);
          this.Next();
        } else {
          this.Fail(pas["PMS.Types"].TCalcError.ceSyntax,T.Pos);
          Result = null;
        };
        return Result;
      };
      this.Create$1 = function (Tokens) {
        pas.System.TObject.Create.call(this);
        this.FTokens = rtl.arrayRef(Tokens);
        this.FPos = 0;
        this.FDepth = 0;
        this.FOwned = rtl.arraySetLength(this.FOwned,null,0);
        return this;
      };
      this.Run = function () {
        var Result = null;
        if (this.Peek().Kind === pas["PMS.Lexer"].TTokenKind.tkEOF) this.Fail(pas["PMS.Types"].TCalcError.ceSyntax,this.Peek().Pos);
        Result = this.ParseAssign();
        if (this.Peek().Kind !== pas["PMS.Lexer"].TTokenKind.tkEOF) this.Fail(pas["PMS.Types"].TCalcError.ceSyntax,this.Peek().Pos);
        this.Disown(Result);
        this.FreeOwned();
        return Result;
      };
    });
  };
},[]);
rtl.module("PMS.Funcs",["System","SysUtils","Math","PMS.Types"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.ApplyFunc = function (Name, X, Ctx, Err) {
    var Result = 0.0;
    var L = "";
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    Result = 0;
    L = pas.SysUtils.LowerCase(Name);
    if (L === "sin") {
      Result = Math.sin($mod.ToRad(X,Ctx.AngleMode))}
     else if (L === "cos") {
      Result = Math.cos($mod.ToRad(X,Ctx.AngleMode))}
     else if (L === "tan") {
      Result = $impl.PMSTan($mod.ToRad(X,Ctx.AngleMode))}
     else if (L === "asin") {
      if (Math.abs(X) > 1) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      Result = $mod.FromRad(Math.asin(X),Ctx.AngleMode);
    } else if (L === "acos") {
      if (Math.abs(X) > 1) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      Result = $mod.FromRad(Math.acos(X),Ctx.AngleMode);
    } else if (L === "atan") {
      Result = $mod.FromRad(Math.atan(X),Ctx.AngleMode)}
     else if (L === "sinh") {
      Result = $impl.PMSSinh(X)}
     else if (L === "cosh") {
      Result = Math.cosh(X)}
     else if (L === "tanh") {
      Result = $impl.PMSTanh(X)}
     else if (L === "ln") {
      if (X <= 0) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      Result = Math.log(X);
    } else if (L === "log") {
      if (X <= 0) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      Result = Math.log10(X);
    } else if (L === "exp") {
      Result = Math.exp(X);
      if (pas.Math.IsInfinite(Result)) {
        Err.set(pas["PMS.Types"].TCalcError.ceOverflow);
        return Result;
      };
    } else if (L === "sqrt") {
      if (X < 0) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      Result = Math.sqrt(X);
    } else if (L === "cbrt") {
      Result = $impl.CbrtReal(X)}
     else if (L === "abs") {
      Result = Math.abs(X)}
     else if (L === "floor") {
      Result = $impl.PMSFloor(X)}
     else if (L === "ceil") {
      Result = $impl.PMSCeil(X)}
     else if (L === "round") {
      Result = $impl.PMSRound(X)}
     else Err.set(pas["PMS.Types"].TCalcError.ceUnknownFunction);
    if ((Err.get() === pas["PMS.Types"].TCalcError.ceNone) && (isNaN(Result) || pas.Math.IsInfinite(Result))) Err.set(pas["PMS.Types"].TCalcError.ceOverflow);
    return Result;
  };
  this.ToRad = function (X, M) {
    var Result = 0.0;
    var $tmp = M;
    if ($tmp === pas["PMS.Types"].TAngleMode.amDegree) {
      Result = (X * Math.PI) / 180.0}
     else if ($tmp === pas["PMS.Types"].TAngleMode.amGrad) {
      Result = (X * Math.PI) / 200.0}
     else {
      Result = X;
    };
    return Result;
  };
  this.FromRad = function (X, M) {
    var Result = 0.0;
    var $tmp = M;
    if ($tmp === pas["PMS.Types"].TAngleMode.amDegree) {
      Result = (X * 180.0) / Math.PI}
     else if ($tmp === pas["PMS.Types"].TAngleMode.amGrad) {
      Result = (X * 200.0) / Math.PI}
     else {
      Result = X;
    };
    return Result;
  };
  $mod.$implcode = function () {
    $impl.CbrtReal = function (X) {
      var Result = 0.0;
      var I = 0;
      if (X === 0) return 0;
      if (X < 0) return -$impl.CbrtReal(-X);
      Result = Math.pow(X,1.0 / 3.0);
      for (I = 1; I <= 3; I++) {
        if ((Result === 0) || pas.Math.IsInfinite(Result * Result * Result)) break;
        Result = Result - (((Result * Result * Result) - X) / (3 * Result * Result));
      };
      return Result;
    };
    $impl.PMSFloor = function (X) {
      var Result = 0.0;
      Result = pas.System.Int(X);
      if ((X < 0) && (pas.System.Frac(X) !== 0)) Result = Result - 1;
      return Result;
    };
    $impl.PMSCeil = function (X) {
      var Result = 0.0;
      Result = pas.System.Int(X);
      if ((X > 0) && (pas.System.Frac(X) !== 0)) Result = Result + 1;
      return Result;
    };
    $impl.PMSRound = function (X) {
      var Result = 0.0;
      if (X >= 0) {
        Result = $impl.PMSFloor(X + 0.5)}
       else Result = $impl.PMSCeil(X - 0.5);
      return Result;
    };
    $impl.PMSTan = function (X) {
      var Result = 0.0;
      Result = Math.sin(X) / Math.cos(X);
      return Result;
    };
    $impl.PMSSinh = function (X) {
      var Result = 0.0;
      Result = (Math.exp(X) - Math.exp(-X)) / 2;
      return Result;
    };
    $impl.PMSTanh = function (X) {
      var Result = 0.0;
      if (X > 20) {
        Result = 1}
       else if (X < -20) {
        Result = -1}
       else Result = (Math.exp(2 * X) - 1) / (Math.exp(2 * X) + 1);
      return Result;
    };
  };
},[]);
rtl.module("PMS.Consts",["System"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.GetConstant = function (Name, Value) {
    var Result = false;
    var I = 0;
    var L = "";
    L = pas.SysUtils.LowerCase(Name);
    for (I = 0; I <= 16; I++) if ($impl.Entries[I].Name === L) {
      Value.set($impl.Entries[I].Value);
      return true;
    };
    Value.set(0);
    Result = false;
    return Result;
  };
  $mod.$implcode = function () {
    rtl.recNewT($impl,"TConstEntry",function () {
      this.Name = "";
      this.Value = 0.0;
      this.$eq = function (b) {
        return (this.Name === b.Name) && (this.Value === b.Value);
      };
      this.$assign = function (s) {
        this.Name = s.Name;
        this.Value = s.Value;
        return this;
      };
    });
    $impl.Entries$a$clone = function (a) {
      var b = [];
      b.length = 17;
      for (var c = 0; c < 17; c++) b[c] = $impl.TConstEntry.$clone(a[c]);
      return b;
    };
    $impl.Entries = [$impl.TConstEntry.$clone({Name: "pi", Value: 3.14159265358979323846}),$impl.TConstEntry.$clone({Name: "e", Value: 2.71828182845904523536}),$impl.TConstEntry.$clone({Name: "phi", Value: 1.61803398874989484820}),$impl.TConstEntry.$clone({Name: "tau", Value: 6.28318530717958647692}),$impl.TConstEntry.$clone({Name: "sqrt2", Value: 1.41421356237309504880}),$impl.TConstEntry.$clone({Name: "sqrt3", Value: 1.73205080756887729352}),$impl.TConstEntry.$clone({Name: "c", Value: 299792458.0}),$impl.TConstEntry.$clone({Name: "g", Value: 6.67430e-11}),$impl.TConstEntry.$clone({Name: "h", Value: 6.62607015e-34}),$impl.TConstEntry.$clone({Name: "hbar", Value: 1.054571817e-34}),$impl.TConstEntry.$clone({Name: "kb", Value: 1.380649e-23}),$impl.TConstEntry.$clone({Name: "na", Value: 6.02214076e23}),$impl.TConstEntry.$clone({Name: "r", Value: 8.314462618}),$impl.TConstEntry.$clone({Name: "me", Value: 9.1093837015e-31}),$impl.TConstEntry.$clone({Name: "mp", Value: 1.67262192369e-27}),$impl.TConstEntry.$clone({Name: "qe", Value: 1.602176634e-19}),$impl.TConstEntry.$clone({Name: "avogadro", Value: 6.02214076e23})];
  };
},["SysUtils"]);
rtl.module("PMS.Eval",["System","SysUtils","Math","PMS.Types","PMS.AST","PMS.Parser","PMS.Funcs","PMS.Consts"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.EvalNode = function (Node, Ctx, Err) {
    var Result = 0.0;
    var A = 0.0;
    var B = 0.0;
    var F = null;
    var Args = [];
    Result = 0;
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    if (!$impl.NeedOps(Ctx,Err)) return Result;
    if (pas["PMS.AST"].TNumberNode.isPrototypeOf(Node)) {
      Result = Node.Value}
     else if (pas["PMS.AST"].TVarNode.isPrototypeOf(Node)) {
      if (Ctx.GetVar(Node.Name,{get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }})) {
        return Result}
       else if (pas.SysUtils.SameText(Node.Name,"ans") && Ctx.HasAns) {
        Result = Ctx.Ans;
        return Result;
      } else if (pas["PMS.Consts"].GetConstant(Node.Name,{get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }})) {
        return Result}
       else Err.set(pas["PMS.Types"].TCalcError.ceUnknownVariable);
    } else if (pas["PMS.AST"].TUnaryNode.isPrototypeOf(Node)) {
      A = $mod.EvalNode(Node.Child,Ctx,Err);
      if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
      var $tmp = Node.Op;
      if ($tmp === "-") {
        Result = -A}
       else if ($tmp === "+") {
        Result = A}
       else if ($tmp === "%") {
        Result = A / 100.0}
       else if ($tmp === "!") {
        Result = $impl.Factorial(A,Err)}
       else {
        Err.set(pas["PMS.Types"].TCalcError.ceUnsupported);
      };
    } else if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(Node)) {
      A = $mod.EvalNode(Node.Left,Ctx,Err);
      if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
      B = $mod.EvalNode(Node.Right,Ctx,Err);
      if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
      var $tmp1 = Node.Op;
      if ($tmp1 === "+") {
        Result = A + B}
       else if ($tmp1 === "-") {
        Result = A - B}
       else if ($tmp1 === "*") {
        Result = A * B}
       else if ($tmp1 === "\/") {
        if (B === 0) {
          Err.set(pas["PMS.Types"].TCalcError.ceDivisionByZero)}
         else Result = A / B}
       else if ($tmp1 === "^") {
        Result = $impl.PowerReal(A,B,Err)}
       else if ($tmp1 === "m") {
        if (B === 0) {
          Err.set(pas["PMS.Types"].TCalcError.ceDivisionByZero)}
         else Result = A - (pas.System.Trunc(A / B) * B)}
       else {
        Err.set(pas["PMS.Types"].TCalcError.ceUnsupported);
      };
      if ((Err.get() === pas["PMS.Types"].TCalcError.ceNone) && (isNaN(Result) || pas.Math.IsInfinite(Result))) Err.set(pas["PMS.Types"].TCalcError.ceOverflow);
    } else if (pas["PMS.AST"].TFuncNode.isPrototypeOf(Node)) {
      F = Node;
      if (rtl.length(F.Args) !== 1) {
        Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
        return Result;
      };
      Args = rtl.arraySetLength(Args,0.0,1);
      Args[0] = $mod.EvalNode(F.Args[0],Ctx,Err);
      if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
      Result = pas["PMS.Funcs"].ApplyFunc(F.Name,Args[0],Ctx,Err);
    } else if (pas["PMS.AST"].TAssignNode.isPrototypeOf(Node)) {
      Result = $mod.EvalNode(Node.Expr,Ctx,Err);
      if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
      Ctx.SetVar(Node.Name,Result);
    } else if (pas["PMS.AST"].TFuncDefNode.isPrototypeOf(Node)) {
      Err.set(pas["PMS.Types"].TCalcError.ceUnsupported)}
     else Err.set(pas["PMS.Types"].TCalcError.ceUnsupported);
    return Result;
  };
  this.EvalText = function (Src, Ctx, Value, Err, ErrPos) {
    var Result = false;
    var Root = null;
    Value.set(0);
    if (!pas["PMS.Parser"].ParseExpression(Src,{get: function () {
        return Root;
      }, set: function (v) {
        Root = v;
      }},Err,ErrPos)) return false;
    try {
      Value.set($mod.EvalNode(Root,Ctx,Err));
      if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return false;
      Ctx.Ans = Value.get();
      Ctx.HasAns = true;
      ErrPos.set(0);
      Result = true;
    } finally {
      Root = rtl.freeLoc(Root);
    };
    return Result;
  };
  $mod.$implcode = function () {
    $impl.NeedOps = function (Ctx, Err) {
      var Result = false;
      if (Ctx.Cancelled) {
        Err.set(pas["PMS.Types"].TCalcError.ceCancelled);
        return false;
      };
      if (!Ctx.CheckOps()) {
        Err.set(pas["PMS.Types"].TCalcError.ceTooComplex);
        return false;
      };
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      Result = true;
      return Result;
    };
    $impl.Factorial = function (X, Err) {
      var Result = 0.0;
      var I = 0;
      var N = 0;
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      Result = 0;
      if (isNaN(X) || pas.Math.IsInfinite(X)) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      if (X > 170) {
        Err.set(pas["PMS.Types"].TCalcError.ceOverflow);
        return Result;
      };
      if ((X < 0) || (pas.System.Frac(X) !== 0)) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      N = pas.System.Trunc(X);
      Result = 1;
      for (var $l = 2, $end = N; $l <= $end; $l++) {
        I = $l;
        Result = Result * I;
      };
      return Result;
    };
    $impl.PowerReal = function (Base, Expo, Err) {
      var Result = 0.0;
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      Result = 0;
      if ((Base === 0) && (Expo === 0)) {
        Result = 1;
        return Result;
      };
      if ((Base === 0) && (Expo < 0)) {
        Err.set(pas["PMS.Types"].TCalcError.ceDivisionByZero);
        return Result;
      };
      if ((Base < 0) && (pas.System.Frac(Expo) !== 0)) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      Result = Math.pow(Base,Expo);
      if (isNaN(Result)) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain)}
       else if (pas.Math.IsInfinite(Result)) Err.set(pas["PMS.Types"].TCalcError.ceOverflow);
      return Result;
    };
  };
},[]);
rtl.module("Classes",["System","RTLConsts","SysUtils","JS"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  $mod.$implcode = function () {
    $impl.ClassList = null;
  };
  $mod.$init = function () {
    $impl.ClassList = new Object();
  };
},[]);
rtl.module("PMS.ASTUtils",["System","SysUtils","PMS.AST"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.Pretty = function (Node) {
    var Result = "";
    var I = 0;
    var U = null;
    if (pas["PMS.AST"].TNumberNode.isPrototypeOf(Node)) {
      Result = $impl.NumStr(Node.Value)}
     else if (pas["PMS.AST"].TVarNode.isPrototypeOf(Node)) {
      Result = Node.Name}
     else if (pas["PMS.AST"].TUnaryNode.isPrototypeOf(Node)) {
      U = Node;
      var $tmp = U.Op;
      if ($tmp === "-") {
        if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(U.Child) || pas["PMS.AST"].TUnaryNode.isPrototypeOf(U.Child)) {
          Result = "-(" + $mod.Pretty(U.Child) + ")"}
         else Result = "-" + $mod.Pretty(U.Child)}
       else if ($tmp === "!") {
        Result = $mod.Pretty(U.Child) + "!"}
       else if ($tmp === "%") {
        Result = $mod.Pretty(U.Child) + "%"}
       else {
        Result = $mod.Pretty(U.Child);
      };
    } else if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(Node)) {
      Result = $impl.PrettyBin(Node.Op,Node.Left,Node.Right)}
     else if (pas["PMS.AST"].TFuncNode.isPrototypeOf(Node)) {
      Result = Node.Name + "(";
      for (var $l = 0, $end = rtl.length(Node.Args) - 1; $l <= $end; $l++) {
        I = $l;
        if (I > 0) Result = Result + ",";
        Result = Result + $mod.Pretty(Node.Args[I]);
      };
      Result = Result + ")";
    } else if (pas["PMS.AST"].TAssignNode.isPrototypeOf(Node)) {
      Result = Node.Name + "=" + $mod.Pretty(Node.Expr)}
     else if (pas["PMS.AST"].TFuncDefNode.isPrototypeOf(Node)) {
      Result = Node.Name + "(";
      for (var $l1 = 0, $end1 = rtl.length(Node.Params) - 1; $l1 <= $end1; $l1++) {
        I = $l1;
        if (I > 0) Result = Result + ",";
        Result = Result + Node.Params[I];
      };
      Result = Result + ")=" + $mod.Pretty(Node.Body);
    } else Result = "?";
    return Result;
  };
  $mod.$implcode = function () {
    $impl.PrecOf = function (Op) {
      var Result = 0;
      var $tmp = Op;
      if (($tmp === "+") || ($tmp === "-")) {
        Result = 1}
       else if (($tmp === "*") || ($tmp === "\/") || ($tmp === "m")) {
        Result = 2}
       else if ($tmp === "!") {
        Result = 5}
       else {
        Result = 4;
      };
      return Result;
    };
    $impl.NumStr = function (V) {
      var Result = "";
      Result = pas.SysUtils.FloatToStr(V);
      return Result;
    };
    $impl.PrettyBin = function (Op, L, R) {
      var Result = "";
      var LS = "";
      var RS = "";
      LS = $mod.Pretty(L);
      RS = $mod.Pretty(R);
      if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(L) && ($impl.PrecOf(L.Op) < $impl.PrecOf(Op))) LS = "(" + LS + ")";
      if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(R) && (($impl.PrecOf(R.Op) < $impl.PrecOf(Op)) || ((R.Op === Op) && ((Op === "-") || (Op === "\/") || (Op === "^"))))) RS = "(" + RS + ")";
      if (pas["PMS.AST"].TUnaryNode.isPrototypeOf(R) && (Op === "^")) RS = "(" + RS + ")";
      if (Op === "m") {
        Result = LS + " mod " + RS}
       else Result = LS + Op + RS;
      return Result;
    };
  };
},[]);
rtl.module("PMS.Deps",["System","SysUtils","PMS.Types","PMS.AST","PMS.ASTUtils","PMS.Parser","PMS.Eval"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.TDepKind = {"0": "dkVar", dkVar: 0, "1": "dkFunc", dkFunc: 1};
  rtl.recNewT(this,"TDepEntry",function () {
    this.Kind = 0;
    this.Name = "";
    this.Body = null;
    this.Value = 0.0;
    this.HasValue = false;
    this.Dirty = false;
    this.$new = function () {
      var r = Object.create(this);
      r.Params = [];
      return r;
    };
    this.$eq = function (b) {
      return (this.Kind === b.Kind) && (this.Name === b.Name) && (this.Params === b.Params) && (this.Body === b.Body) && (this.Value === b.Value) && (this.HasValue === b.HasValue) && (this.Dirty === b.Dirty);
    };
    this.$assign = function (s) {
      this.Kind = s.Kind;
      this.Name = s.Name;
      this.Params = rtl.arrayRef(s.Params);
      this.Body = s.Body;
      this.Value = s.Value;
      this.HasValue = s.HasValue;
      this.Dirty = s.Dirty;
      return this;
    };
  });
  rtl.createClass(this,"TDepStore",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FEntries = [];
      this.FCtx = null;
      this.FVisiting = [];
    };
    this.$final = function () {
      this.FEntries = undefined;
      this.FCtx = undefined;
      this.FVisiting = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Find = function (Name) {
      var Result = 0;
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.FEntries) - 1; $l <= $end; $l++) {
        I = $l;
        if (this.FEntries[I].Name === Name) return I;
      };
      Result = -1;
      return Result;
    };
    this.RefsName = function (Node, Name) {
      var Result = false;
      var I = 0;
      if (Node === null) return false;
      if (pas["PMS.AST"].TVarNode.isPrototypeOf(Node)) return Node.Name === Name;
      if (pas["PMS.AST"].TFuncNode.isPrototypeOf(Node) && (Node.Name === Name)) return true;
      if (pas["PMS.AST"].TFuncNode.isPrototypeOf(Node)) {
        for (var $l = 0, $end = rtl.length(Node.Args) - 1; $l <= $end; $l++) {
          I = $l;
          if (this.RefsName(Node.Args[I],Name)) return true;
        };
        return false;
      };
      if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(Node)) return this.RefsName(Node.Left,Name) || this.RefsName(Node.Right,Name);
      if (pas["PMS.AST"].TUnaryNode.isPrototypeOf(Node)) return this.RefsName(Node.Child,Name);
      Result = false;
      return Result;
    };
    this.MarkDirty = function (Name) {
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.FEntries) - 1; $l <= $end; $l++) {
        I = $l;
        if ((this.FEntries[I].Kind === $mod.TDepKind.dkVar) && this.RefsName(this.FEntries[I].Body,Name)) {
          if (!this.FEntries[I].Dirty) {
            this.FEntries[I].Dirty = true;
            this.MarkDirty(this.FEntries[I].Name);
          };
        };
      };
    };
    this.EvalVarIdx = function (Idx, V, Err) {
      var Result = false;
      var I = 0;
      var Exp = null;
      Result = false;
      V.set(0);
      if (!this.FEntries[Idx].Dirty && this.FEntries[Idx].HasValue) {
        V.set(this.FEntries[Idx].Value);
        Err.set(pas["PMS.Types"].TCalcError.ceNone);
        return true;
      };
      if (!this.PushVisit(this.FEntries[Idx].Name)) {
        Err.set(pas["PMS.Types"].TCalcError.ceUnsupported);
        return Result;
      };
      try {
        for (var $l = 0, $end = rtl.length(this.FEntries) - 1; $l <= $end; $l++) {
          I = $l;
          if ((I !== Idx) && (this.FEntries[I].Kind === $mod.TDepKind.dkVar) && this.RefsName(this.FEntries[Idx].Body,this.FEntries[I].Name)) {
            if (!this.EvalVarIdx(I,V,Err)) return Result;
            this.FCtx.SetVar(this.FEntries[I].Name,this.FEntries[I].Value);
          };
        };
        Exp = this.ExpandCalls(this.FEntries[Idx].Body,0,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Exp = rtl.freeLoc(Exp);
          return Result;
        };
        try {
          V.set(pas["PMS.Eval"].EvalNode(Exp,this.FCtx,Err));
          if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
        } finally {
          Exp = rtl.freeLoc(Exp);
        };
        this.FEntries[Idx].Value = V.get();
        this.FEntries[Idx].HasValue = true;
        this.FEntries[Idx].Dirty = false;
        this.FCtx.SetVar(this.FEntries[Idx].Name,V.get());
        Result = true;
      } finally {
        this.PopVisit();
      };
      return Result;
    };
    this.PushVisit = function (Name) {
      var Result = false;
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.FVisiting) - 1; $l <= $end; $l++) {
        I = $l;
        if (this.FVisiting[I] === Name) return false;
      };
      this.FVisiting = rtl.arraySetLength(this.FVisiting,"",rtl.length(this.FVisiting) + 1);
      this.FVisiting[rtl.length(this.FVisiting) - 1] = Name;
      Result = true;
      return Result;
    };
    this.PopVisit = function () {
      this.FVisiting = rtl.arraySetLength(this.FVisiting,"",rtl.length(this.FVisiting) - 1);
    };
    this.Create$1 = function () {
      pas.System.TObject.Create.call(this);
      this.FCtx = pas["PMS.Types"].TEvalContext.$create("Create$1");
      this.FEntries = rtl.arraySetLength(this.FEntries,$mod.TDepEntry,0);
      this.FVisiting = rtl.arraySetLength(this.FVisiting,"",0);
      return this;
    };
    this.Destroy = function () {
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.FEntries) - 1; $l <= $end; $l++) {
        I = $l;
        rtl.free(this.FEntries[I],"Body");
      };
      rtl.free(this,"FCtx");
      pas.System.TObject.Destroy.call(this);
    };
    this.Define = function (Text, Err, ErrPos) {
      var Result = false;
      var Root = null;
      var Idx = 0;
      var I = 0;
      Result = false;
      if (!pas["PMS.Parser"].ParseExpression(Text,{get: function () {
          return Root;
        }, set: function (v) {
          Root = v;
        }},Err,ErrPos)) return Result;
      try {
        if (pas["PMS.AST"].TAssignNode.isPrototypeOf(Root)) {
          Idx = this.Find(Root.Name);
          if ((Idx >= 0) && (this.FEntries[Idx].Kind === $mod.TDepKind.dkFunc)) {
            Err.set(pas["PMS.Types"].TCalcError.ceUnsupported);
            ErrPos.set(1);
            return Result;
          };
          if (Idx < 0) {
            this.FEntries = rtl.arraySetLength(this.FEntries,$mod.TDepEntry,rtl.length(this.FEntries) + 1);
            Idx = rtl.length(this.FEntries) - 1;
            this.FEntries[Idx].Kind = $mod.TDepKind.dkVar;
            this.FEntries[Idx].Name = Root.Name;
            this.FEntries[Idx].Body = null;
            this.FEntries[Idx].HasValue = false;
          } else rtl.free(this.FEntries[Idx],"Body");
          this.FEntries[Idx].Body = Root.Expr.Clone();
          this.FEntries[Idx].Params = rtl.arraySetLength(this.FEntries[Idx].Params,"",0);
          this.FEntries[Idx].Dirty = true;
          this.FEntries[Idx].HasValue = false;
          this.MarkDirty(this.FEntries[Idx].Name);
          Err.set(pas["PMS.Types"].TCalcError.ceNone);
          ErrPos.set(0);
          Result = true;
        } else if (pas["PMS.AST"].TFuncDefNode.isPrototypeOf(Root)) {
          Idx = this.Find(Root.Name);
          if (Idx < 0) {
            this.FEntries = rtl.arraySetLength(this.FEntries,$mod.TDepEntry,rtl.length(this.FEntries) + 1);
            Idx = rtl.length(this.FEntries) - 1;
            this.FEntries[Idx].Name = Root.Name;
            this.FEntries[Idx].HasValue = false;
          } else rtl.free(this.FEntries[Idx],"Body");
          this.FEntries[Idx].Kind = $mod.TDepKind.dkFunc;
          this.FEntries[Idx].Body = Root.Body.Clone();
          this.FEntries[Idx].Params = rtl.arraySetLength(this.FEntries[Idx].Params,"",rtl.length(Root.Params));
          for (var $l = 0, $end = rtl.length(Root.Params) - 1; $l <= $end; $l++) {
            I = $l;
            this.FEntries[Idx].Params[I] = Root.Params[I];
          };
          this.FEntries[Idx].Dirty = false;
          Err.set(pas["PMS.Types"].TCalcError.ceNone);
          ErrPos.set(0);
          Result = true;
        } else {
          Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
          ErrPos.set(1);
        };
      } finally {
        Root = rtl.freeLoc(Root);
      };
      return Result;
    };
    this.SetVar = function (Name, V) {
      var Result = false;
      var Idx = 0;
      Idx = this.Find(Name);
      if ((Idx < 0) || (this.FEntries[Idx].Kind !== $mod.TDepKind.dkVar)) return false;
      this.FEntries[Idx].Value = V;
      this.FEntries[Idx].HasValue = true;
      this.FEntries[Idx].Dirty = false;
      this.FCtx.SetVar(Name,V);
      this.MarkDirty(Name);
      Result = true;
      return Result;
    };
    this.EvalVar = function (Name, V, Err) {
      var Result = false;
      var Idx = 0;
      Idx = this.Find(Name);
      if ((Idx < 0) || (this.FEntries[Idx].Kind !== $mod.TDepKind.dkVar)) {
        V.set(0);
        Err.set(pas["PMS.Types"].TCalcError.ceUnknownVariable);
        return false;
      };
      Result = this.EvalVarIdx(Idx,V,Err);
      return Result;
    };
    this.EnsureRefs = function (Node, Err) {
      var Result = false;
      var I = 0;
      var V = 0.0;
      Result = false;
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      for (var $l = 0, $end = rtl.length(this.FEntries) - 1; $l <= $end; $l++) {
        I = $l;
        if ((this.FEntries[I].Kind === $mod.TDepKind.dkVar) && this.RefsName(Node,this.FEntries[I].Name)) {
          if (!this.EvalVarIdx(I,{get: function () {
              return V;
            }, set: function (v) {
              V = v;
            }},Err)) return Result;
        };
      };
      Result = true;
      return Result;
    };
    this.ExpandCalls = function (Node, Depth, Err) {
      var Result = null;
      var I = 0;
      var J = 0;
      var Idx = 0;
      var F = null;
      var ArgTrees = [];
      var Sub = null;
      var Exp = null;
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      Result = null;
      if (Depth > 64) {
        Err.set(pas["PMS.Types"].TCalcError.ceRecursionLimit);
        return Result;
      };
      if (pas["PMS.AST"].TFuncNode.isPrototypeOf(Node)) {
        Idx = this.Find(Node.Name);
        if ((Idx >= 0) && (this.FEntries[Idx].Kind === $mod.TDepKind.dkFunc)) {
          if (rtl.length(Node.Args) !== rtl.length(this.FEntries[Idx].Params)) {
            Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
            return Result;
          };
          ArgTrees = rtl.arraySetLength(ArgTrees,null,rtl.length(Node.Args));
          for (var $l = 0, $end = rtl.length(ArgTrees) - 1; $l <= $end; $l++) {
            I = $l;
            ArgTrees[I] = this.ExpandCalls(Node.Args[I],Depth + 1,Err);
            if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
              for (var $l1 = 0, $end1 = I - 1; $l1 <= $end1; $l1++) {
                J = $l1;
                rtl.free(ArgTrees,J);
              };
              return null;
            };
          };
          Sub = $impl.Substitute(this.FEntries[Idx].Body,this.FEntries[Idx].Params,ArgTrees);
          for (var $l2 = 0, $end2 = rtl.length(ArgTrees) - 1; $l2 <= $end2; $l2++) {
            I = $l2;
            rtl.free(ArgTrees,I);
          };
          Exp = this.ExpandCalls(Sub,Depth + 1,Err);
          Sub = rtl.freeLoc(Sub);
          if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
            Exp = rtl.freeLoc(Exp);
            return null;
          };
          return Exp;
        };
        F = pas["PMS.AST"].TFuncNode.$create("Create$1",[Node.Name]);
        for (var $l3 = 0, $end3 = rtl.length(Node.Args) - 1; $l3 <= $end3; $l3++) {
          I = $l3;
          Sub = this.ExpandCalls(Node.Args[I],Depth + 1,Err);
          if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
            F = rtl.freeLoc(F);
            return null;
          };
          F.AddArg(Sub);
        };
        return F;
      };
      if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(Node)) {
        Sub = this.ExpandCalls(Node.Left,Depth + 1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Sub = rtl.freeLoc(Sub);
          return null;
        };
        Exp = this.ExpandCalls(Node.Right,Depth + 1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Sub = rtl.freeLoc(Sub);
          Exp = rtl.freeLoc(Exp);
          return null;
        };
        return pas["PMS.AST"].TBinaryNode.$create("Create$1",[Node.Op,Sub,Exp]);
      };
      if (pas["PMS.AST"].TUnaryNode.isPrototypeOf(Node)) {
        Sub = this.ExpandCalls(Node.Child,Depth + 1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Sub = rtl.freeLoc(Sub);
          return null;
        };
        return pas["PMS.AST"].TUnaryNode.$create("Create$1",[Node.Op,Sub]);
      };
      if (pas["PMS.AST"].TVarNode.isPrototypeOf(Node)) return pas["PMS.AST"].TVarNode.$create("Create$1",[Node.Name]);
      if (pas["PMS.AST"].TNumberNode.isPrototypeOf(Node)) return pas["PMS.AST"].TNumberNode.$create("Create$1",[Node.Value]);
      if (pas["PMS.AST"].TAssignNode.isPrototypeOf(Node)) {
        Sub = this.ExpandCalls(Node.Expr,Depth + 1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Sub = rtl.freeLoc(Sub);
          return null;
        };
        return pas["PMS.AST"].TAssignNode.$create("Create$1",[Node.Name,Sub]);
      };
      return Node.Clone();
      return Result;
    };
    this.EntryCount = function () {
      var Result = 0;
      Result = rtl.length(this.FEntries);
      return Result;
    };
    this.EntryName = function (I) {
      var Result = "";
      Result = this.FEntries[I].Name;
      return Result;
    };
    this.EntryText = function (I) {
      var Result = "";
      var J = 0;
      if (this.FEntries[I].Kind === $mod.TDepKind.dkFunc) {
        Result = this.FEntries[I].Name + "(";
        for (var $l = 0, $end = rtl.length(this.FEntries[I].Params) - 1; $l <= $end; $l++) {
          J = $l;
          if (J > 0) Result = Result + ",";
          Result = Result + this.FEntries[I].Params[J];
        };
        Result = Result + ") = " + pas["PMS.ASTUtils"].Pretty(this.FEntries[I].Body);
      } else Result = this.FEntries[I].Name + " = " + pas["PMS.ASTUtils"].Pretty(this.FEntries[I].Body);
      return Result;
    };
    this.EntryKind = function (I) {
      var Result = 0;
      Result = this.FEntries[I].Kind;
      return Result;
    };
  });
  $mod.$implcode = function () {
    $impl.Substitute = function (Node, Params, Args) {
      var Result = null;
      var I = 0;
      var P = 0;
      var F = null;
      if (pas["PMS.AST"].TVarNode.isPrototypeOf(Node)) {
        for (var $l = 0, $end = rtl.length(Params) - 1; $l <= $end; $l++) {
          P = $l;
          if (Node.Name === Params[P]) return Args[P].Clone();
        };
        return pas["PMS.AST"].TVarNode.$create("Create$1",[Node.Name]);
      };
      if (pas["PMS.AST"].TNumberNode.isPrototypeOf(Node)) return pas["PMS.AST"].TNumberNode.$create("Create$1",[Node.Value]);
      if (pas["PMS.AST"].TUnaryNode.isPrototypeOf(Node)) return pas["PMS.AST"].TUnaryNode.$create("Create$1",[Node.Op,$impl.Substitute(Node.Child,Params,Args)]);
      if (pas["PMS.AST"].TBinaryNode.isPrototypeOf(Node)) return pas["PMS.AST"].TBinaryNode.$create("Create$1",[Node.Op,$impl.Substitute(Node.Left,Params,Args),$impl.Substitute(Node.Right,Params,Args)]);
      if (pas["PMS.AST"].TFuncNode.isPrototypeOf(Node)) {
        F = pas["PMS.AST"].TFuncNode.$create("Create$1",[Node.Name]);
        for (var $l1 = 0, $end1 = rtl.length(Node.Args) - 1; $l1 <= $end1; $l1++) {
          I = $l1;
          F.AddArg($impl.Substitute(Node.Args[I],Params,Args));
        };
        return F;
      };
      return Node.Clone();
      return Result;
    };
  };
},[]);
rtl.module("PMS.Matrix",["System","SysUtils","Math","PMS.Types"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("PMS.Viewport",["System","SysUtils","Math","PMS.Matrix"],function () {
  "use strict";
  var $mod = this;
  rtl.recNewT(this,"TViewport",function () {
    this.XMin = 0.0;
    this.XMax = 0.0;
    this.YMin = 0.0;
    this.YMax = 0.0;
    this.W = 0;
    this.H = 0;
    this.$eq = function (b) {
      return (this.XMin === b.XMin) && (this.XMax === b.XMax) && (this.YMin === b.YMin) && (this.YMax === b.YMax) && (this.W === b.W) && (this.H === b.H);
    };
    this.$assign = function (s) {
      this.XMin = s.XMin;
      this.XMax = s.XMax;
      this.YMin = s.YMin;
      this.YMax = s.YMax;
      this.W = s.W;
      this.H = s.H;
      return this;
    };
  });
  this.VDefault = function (W, H) {
    var Result = $mod.TViewport.$new();
    Result.XMin = -10;
    Result.XMax = 10;
    Result.YMin = -10;
    Result.YMax = 10;
    Result.W = W;
    Result.H = H;
    return Result;
  };
  this.VWorldToScreen = function (V, X, Y, SX, SY) {
    SX.set(((X - V.XMin) / (V.XMax - V.XMin)) * V.W);
    SY.set(V.H - (((Y - V.YMin) / (V.YMax - V.YMin)) * V.H));
  };
  this.VScreenToWorld = function (V, SX, SY, X, Y) {
    X.set(V.XMin + ((SX / V.W) * (V.XMax - V.XMin)));
    Y.set(V.YMin + (((V.H - SY) / V.H) * (V.YMax - V.YMin)));
  };
  this.VZoom = function (V, Factor, CX, CY) {
    if (Factor <= 0) return;
    V.XMin = CX + ((V.XMin - CX) * Factor);
    V.XMax = CX + ((V.XMax - CX) * Factor);
    V.YMin = CY + ((V.YMin - CY) * Factor);
    V.YMax = CY + ((V.YMax - CY) * Factor);
  };
  this.VPanPixels = function (V, DX, DY) {
    var Wx = 0.0;
    var Wy = 0.0;
    Wx = ((V.XMax - V.XMin) / V.W) * DX;
    Wy = ((V.YMax - V.YMin) / V.H) * DY;
    V.XMin = V.XMin - Wx;
    V.XMax = V.XMax - Wx;
    V.YMin = V.YMin + Wy;
    V.YMax = V.YMax + Wy;
  };
  this.VNiceTicks = function (Lo, Hi, MaxTicks, Ticks) {
    var Span = 0.0;
    var Raw = 0.0;
    var Mag = 0.0;
    var Norm = 0.0;
    var Step = 0.0;
    var T = 0.0;
    var N = 0;
    Ticks.set(rtl.arraySetLength(Ticks.get(),0.0,0));
    if ((MaxTicks < 2) || (Hi <= Lo) || isNaN(Lo) || isNaN(Hi) || pas.Math.IsInfinite(Lo) || pas.Math.IsInfinite(Hi)) return;
    Span = Hi - Lo;
    Raw = Span / MaxTicks;
    Mag = Math.pow(10,pas.Math.Floor(Math.log10(Raw)));
    Norm = Raw / Mag;
    if (Norm <= 1) {
      Step = 1}
     else if (Norm <= 2) {
      Step = 2}
     else if (Norm <= 5) {
      Step = 5}
     else Step = 10;
    Step = Step * Mag;
    T = pas.Math.Ceil(Lo / Step) * Step;
    if (T < Lo) T = Lo;
    N = 0;
    while ((T <= Hi) && (N <= (MaxTicks + 1))) {
      Ticks.set(rtl.arraySetLength(Ticks.get(),0.0,N + 1));
      Ticks.get()[N] = T;
      N += 1;
      T = T + Step;
    };
  };
});
rtl.module("PMS.DiffNum",["System","SysUtils","PMS.Types","PMS.AST","PMS.Eval"],function () {
  "use strict";
  var $mod = this;
  this.EvalAt = function (Node, VarName, At, Ctx, Err) {
    var Result = 0.0;
    var Had = false;
    var Old = 0.0;
    var SavedCount = 0;
    Had = Ctx.GetVar(VarName,{get: function () {
        return Old;
      }, set: function (v) {
        Old = v;
      }});
    SavedCount = Ctx.OpCount;
    Ctx.OpCount = 0;
    Ctx.SetVar(VarName,At);
    try {
      Result = pas["PMS.Eval"].EvalNode(Node,Ctx,Err);
    } finally {
      if (Had) {
        Ctx.SetVar(VarName,Old)}
       else Ctx.DelVar(VarName);
      Ctx.OpCount = SavedCount;
    };
    return Result;
  };
});
rtl.module("PMS.Sampler",["System","SysUtils","Math","PMS.Types","PMS.AST","PMS.Eval","PMS.DiffNum","PMS.Viewport"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.recNewT(this,"TSamplePt",function () {
    this.SX = 0.0;
    this.SY = 0.0;
    this.Pen = false;
    this.X = 0.0;
    this.Y = 0.0;
    this.$eq = function (b) {
      return (this.SX === b.SX) && (this.SY === b.SY) && (this.Pen === b.Pen) && (this.X === b.X) && (this.Y === b.Y);
    };
    this.$assign = function (s) {
      this.SX = s.SX;
      this.SY = s.SY;
      this.Pen = s.Pen;
      this.X = s.X;
      this.Y = s.Y;
      return this;
    };
  });
  this.SampleFunc = function (Node, VarName, V, Ctx, Err) {
    var Result = [];
    var Line = [];
    var YRange = 0.0;
    var N = 0;
    var I = 0;
    var X0 = 0.0;
    var Y0 = 0.0;
    var X1 = 0.0;
    var Y1 = 0.0;
    var OK0 = false;
    var OK1 = false;
    function Walk(AX0, AY0, AOK0, AX1, AY1, AOK1, D) {
      var XM = 0.0;
      var YM = 0.0;
      var YLin = 0.0;
      var OKM = false;
      if ((D <= 0) || (rtl.length(Line) >= 4096)) return;
      if (!(AOK0 && AOK1)) return;
      if (Math.abs(AY1 - AY0) > (25 * YRange)) {
        XM = (AX0 + AX1) / 2;
        OKM = $impl.EvalOK(Node,VarName,XM,Ctx,{get: function () {
            return YM;
          }, set: function (v) {
            YM = v;
          }});
        if (!OKM || (Math.abs(YM - ((AY0 + AY1) / 2)) > Math.abs(AY1 - AY0))) return;
      };
      XM = (AX0 + AX1) / 2;
      OKM = $impl.EvalOK(Node,VarName,XM,Ctx,{get: function () {
          return YM;
        }, set: function (v) {
          YM = v;
        }});
      if (!OKM) return;
      YLin = (AY0 + AY1) / 2;
      if (Math.abs(YM - YLin) > (0.002 * YRange)) {
        Walk(AX0,AY0,AOK0,XM,YM,true,D - 1);
        $impl.EmitPt({get: function () {
            return Line;
          }, set: function (v) {
            Line = v;
          }},V,XM,YM,true);
        Walk(XM,YM,true,AX1,AY1,AOK1,D - 1);
      };
    };
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    Line = rtl.arraySetLength(Line,$mod.TSamplePt,0);
    Result = [];
    if ((V.W < 8) || (V.H < 8) || (V.XMax <= V.XMin) || (V.YMax <= V.YMin)) {
      Err.set(pas["PMS.Types"].TCalcError.ceDomain);
      return Result;
    };
    YRange = V.YMax - V.YMin;
    N = V.W;
    if (N < 64) N = 64;
    if (N > 1024) N = 1024;
    X0 = V.XMin;
    OK0 = $impl.EvalOK(Node,VarName,X0,Ctx,{get: function () {
        return Y0;
      }, set: function (v) {
        Y0 = v;
      }});
    if (OK0) $impl.EmitPt({get: function () {
        return Line;
      }, set: function (v) {
        Line = v;
      }},V,X0,Y0,false);
    for (var $l = 1, $end = N; $l <= $end; $l++) {
      I = $l;
      X1 = V.XMin + (((V.XMax - V.XMin) * I) / N);
      OK1 = $impl.EvalOK(Node,VarName,X1,Ctx,{get: function () {
          return Y1;
        }, set: function (v) {
          Y1 = v;
        }});
      if (OK0 && OK1) Walk(X0,Y0,true,X1,Y1,true,4);
      if (OK1) $impl.EmitPt({get: function () {
          return Line;
        }, set: function (v) {
          Line = v;
        }},V,X1,Y1,OK0);
      OK0 = OK1;
      X0 = X1;
      Y0 = Y1;
    };
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    Result = rtl.arrayRef(Line);
    return Result;
  };
  this.SampleParam = function (XNode, YNode, TName, T0, T1, V, Ctx, Err) {
    var Result = [];
    var N = 0;
    var I = 0;
    var T = 0.0;
    var X = 0.0;
    var Y = 0.0;
    var PrevOK = false;
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    Result = rtl.arraySetLength(Result,$mod.TSamplePt,0);
    if ((T1 <= T0) || (V.W < 8)) {
      Err.set(pas["PMS.Types"].TCalcError.ceDomain);
      return Result;
    };
    N = 1024;
    PrevOK = false;
    for (var $l = 0, $end = N; $l <= $end; $l++) {
      I = $l;
      T = T0 + (((T1 - T0) * I) / N);
      if ($impl.EvalOK(XNode,TName,T,Ctx,{get: function () {
          return X;
        }, set: function (v) {
          X = v;
        }}) && $impl.EvalOK(YNode,TName,T,Ctx,{get: function () {
          return Y;
        }, set: function (v) {
          Y = v;
        }})) {
        $impl.EmitPt({get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},V,X,Y,PrevOK);
        PrevOK = true;
      } else PrevOK = false;
    };
    return Result;
  };
  this.SamplePolar = function (RNode, TName, T0, T1, V, Ctx, Err) {
    var Result = [];
    var N = 0;
    var I = 0;
    var T = 0.0;
    var R = 0.0;
    var PrevOK = false;
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    Result = rtl.arraySetLength(Result,$mod.TSamplePt,0);
    if ((T1 <= T0) || (V.W < 8)) {
      Err.set(pas["PMS.Types"].TCalcError.ceDomain);
      return Result;
    };
    N = 1024;
    PrevOK = false;
    for (var $l = 0, $end = N; $l <= $end; $l++) {
      I = $l;
      T = T0 + (((T1 - T0) * I) / N);
      if ($impl.EvalOK(RNode,TName,T,Ctx,{get: function () {
          return R;
        }, set: function (v) {
          R = v;
        }})) {
        $impl.EmitPt({get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},V,R * Math.cos(T),R * Math.sin(T),PrevOK);
        PrevOK = true;
      } else PrevOK = false;
    };
    return Result;
  };
  this.SampleImplicit = function (Node, XName, YName, V, NX, NY, Ctx, Lines, Err) {
    var FX = [];
    var FOK = [];
    var I = 0;
    var J = 0;
    var HadX = false;
    var HadY = false;
    var OldX = 0.0;
    var OldY = 0.0;
    function FAt(XX, YY, VV) {
      var Result = false;
      var E = 0;
      var SavedCount = 0;
      SavedCount = Ctx.OpCount;
      Ctx.OpCount = 0;
      Ctx.SetVar(XName,XX);
      Ctx.SetVar(YName,YY);
      VV.set(pas["PMS.Eval"].EvalNode(Node,Ctx,{get: function () {
          return E;
        }, set: function (v) {
          E = v;
        }}));
      Ctx.OpCount = SavedCount;
      Result = (E === pas["PMS.Types"].TCalcError.ceNone) && !isNaN(VV.get()) && !pas.Math.IsInfinite(VV.get());
      return Result;
    };
    function AddSeg(X1, Y1, X2, Y2) {
      var L = [];
      if (rtl.length(Lines.get()) >= 4096) return;
      L = rtl.arraySetLength(L,$mod.TSamplePt,2);
      pas["PMS.Viewport"].VWorldToScreen(V,X1,Y1,{p: L[0], get: function () {
          return this.p.SX;
        }, set: function (v) {
          this.p.SX = v;
        }},{p: L[0], get: function () {
          return this.p.SY;
        }, set: function (v) {
          this.p.SY = v;
        }});
      L[0].X = X1;
      L[0].Y = Y1;
      L[0].Pen = false;
      pas["PMS.Viewport"].VWorldToScreen(V,X2,Y2,{p: L[1], get: function () {
          return this.p.SX;
        }, set: function (v) {
          this.p.SX = v;
        }},{p: L[1], get: function () {
          return this.p.SY;
        }, set: function (v) {
          this.p.SY = v;
        }});
      L[1].X = X2;
      L[1].Y = Y2;
      L[1].Pen = true;
      Lines.set(rtl.arraySetLength(Lines.get(),[],rtl.length(Lines.get()) + 1));
      Lines.get()[rtl.length(Lines.get()) - 1] = rtl.arrayRef(L);
    };
    function CellX(K) {
      var Result = 0.0;
      Result = V.XMin + (((V.XMax - V.XMin) * K) / NX);
      return Result;
    };
    function CellY(K) {
      var Result = 0.0;
      Result = V.YMin + (((V.YMax - V.YMin) * K) / NY);
      return Result;
    };
    function Edge(JA, IA, JB, IB, XX, YY) {
      var Result = false;
      var FA = 0.0;
      var FB = 0.0;
      var T = 0.0;
      Result = false;
      if (!(FOK[JA][IA] && FOK[JB][IB])) return Result;
      FA = FX[JA][IA];
      FB = FX[JB][IB];
      if ((FA < 0) === (FB < 0)) return Result;
      if (FA === FB) return Result;
      T = Math.abs(FA) / (Math.abs(FA) + Math.abs(FB));
      XX.set((CellX(IA) * (1 - T)) + (CellX(IB) * T));
      YY.set((CellY(JA) * (1 - T)) + (CellY(JB) * T));
      Result = true;
      return Result;
    };
    var Pts = rtl.arraySetLength(null,0.0,4);
    var NP = 0;
    var X = 0.0;
    var Y = 0.0;
    var F = 0.0;
    var CX = 0.0;
    var CY = 0.0;
    var K = 0;
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    Lines.set(rtl.arraySetLength(Lines.get(),[],0));
    if ((NX < 8) || (NY < 8) || (NX > 300) || (NY > 300)) {
      NX = 120;
      NY = 120;
    };
    HadX = Ctx.GetVar(XName,{get: function () {
        return OldX;
      }, set: function (v) {
        OldX = v;
      }});
    HadY = Ctx.GetVar(YName,{get: function () {
        return OldY;
      }, set: function (v) {
        OldY = v;
      }});
    try {
      FX = rtl.arraySetLength(FX,0.0,NY + 1,NX + 1);
      FOK = rtl.arraySetLength(FOK,false,NY + 1,NX + 1);
      for (var $l = 0, $end = NY; $l <= $end; $l++) {
        J = $l;
        for (var $l1 = 0, $end1 = NX; $l1 <= $end1; $l1++) {
          I = $l1;
          X = CellX(I);
          Y = CellY(J);
          FOK[J][I] = FAt(X,Y,{get: function () {
              return F;
            }, set: function (v) {
              F = v;
            }});
          FX[J][I] = F;
        };
      };
      for (var $l2 = 0, $end2 = NY - 1; $l2 <= $end2; $l2++) {
        J = $l2;
        for (var $l3 = 0, $end3 = NX - 1; $l3 <= $end3; $l3++) {
          I = $l3;
          NP = 0;
          if (Edge(J,I,J,I + 1,{get: function () {
              return X;
            }, set: function (v) {
              X = v;
            }},{get: function () {
              return Y;
            }, set: function (v) {
              Y = v;
            }})) {
            Pts[0] = X;
            Pts[1] = Y;
            NP += 1;
          };
          if (Edge(J,I + 1,J + 1,I + 1,{get: function () {
              return X;
            }, set: function (v) {
              X = v;
            }},{get: function () {
              return Y;
            }, set: function (v) {
              Y = v;
            }})) {
            Pts[NP * 2] = X;
            Pts[(NP * 2) + 1] = Y;
            NP += 1;
          };
          if (Edge(J + 1,I + 1,J + 1,I,{get: function () {
              return X;
            }, set: function (v) {
              X = v;
            }},{get: function () {
              return Y;
            }, set: function (v) {
              Y = v;
            }})) {
            Pts[NP * 2] = X;
            Pts[(NP * 2) + 1] = Y;
            NP += 1;
          };
          if (Edge(J + 1,I,J,I,{get: function () {
              return X;
            }, set: function (v) {
              X = v;
            }},{get: function () {
              return Y;
            }, set: function (v) {
              Y = v;
            }})) {
            Pts[NP * 2] = X;
            Pts[(NP * 2) + 1] = Y;
            NP += 1;
          };
          if (NP === 2) {
            AddSeg(Pts[0],Pts[1],Pts[2],Pts[3])}
           else if (NP > 2) {
            CX = 0;
            CY = 0;
            for (var $l4 = 0, $end4 = NP - 1; $l4 <= $end4; $l4++) {
              K = $l4;
              CX = CX + Pts[K * 2];
              CY = CY + Pts[(K * 2) + 1];
            };
            CX = CX / NP;
            CY = CY / NP;
            for (var $l5 = 0, $end5 = NP - 1; $l5 <= $end5; $l5++) {
              K = $l5;
              AddSeg(Pts[K * 2],Pts[(K * 2) + 1],CX,CY);
            };
          };
        };
      };
    } finally {
      if (HadX) {
        Ctx.SetVar(XName,OldX)}
       else Ctx.DelVar(XName);
      if (HadY) {
        Ctx.SetVar(YName,OldY)}
       else Ctx.DelVar(YName);
    };
  };
  $mod.$implcode = function () {
    $impl.JumpTol = 25.0;
    $impl.BendTol = 0.002;
    $impl.EvalOK = function (Node, VarName, At, Ctx, Y) {
      var Result = false;
      var E = 0;
      Y.set(pas["PMS.DiffNum"].EvalAt(Node,VarName,At,Ctx,{get: function () {
          return E;
        }, set: function (v) {
          E = v;
        }}));
      Result = (E === pas["PMS.Types"].TCalcError.ceNone) && !isNaN(Y.get()) && !pas.Math.IsInfinite(Y.get());
      return Result;
    };
    $impl.EmitPt = function (Line, V, X, Y, Pen) {
      if (rtl.length(Line.get()) >= 4096) return;
      Line.set(rtl.arraySetLength(Line.get(),$mod.TSamplePt,rtl.length(Line.get()) + 1));
      pas["PMS.Viewport"].VWorldToScreen(V,X,Y,{p: Line.get()[rtl.length(Line.get()) - 1], get: function () {
          return this.p.SX;
        }, set: function (v) {
          this.p.SX = v;
        }},{p: Line.get()[rtl.length(Line.get()) - 1], get: function () {
          return this.p.SY;
        }, set: function (v) {
          this.p.SY = v;
        }});
      Line.get()[rtl.length(Line.get()) - 1].X = X;
      Line.get()[rtl.length(Line.get()) - 1].Y = Y;
      if (rtl.length(Line.get()) === 1) {
        Line.get()[rtl.length(Line.get()) - 1].Pen = false}
       else Line.get()[rtl.length(Line.get()) - 1].Pen = Pen;
    };
  };
},[]);
rtl.module("PMS.Workspace",["System","SysUtils","Classes","PMS.Types","PMS.AST","PMS.Parser","PMS.Eval","PMS.Deps","PMS.Viewport","PMS.Sampler"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.TWSKind = {"0": "wkFuncY", wkFuncY: 0, "1": "wkParam", wkParam: 1, "2": "wkPolar", wkPolar: 2, "3": "wkImplicit", wkImplicit: 3};
  rtl.recNewT(this,"TWSEntry",function () {
    this.Text = "";
    this.Kind = 0;
    this.AST1 = null;
    this.AST2 = null;
    this.VarX = "";
    this.VarY = "";
    this.T0 = 0.0;
    this.T1 = 0.0;
    this.ColorIdx = 0;
    this.Visible = false;
    this.CacheVer = 0;
    this.$new = function () {
      var r = Object.create(this);
      r.CacheLines = [];
      r.CacheV = pas["PMS.Viewport"].TViewport.$new();
      return r;
    };
    this.$eq = function (b) {
      return (this.Text === b.Text) && (this.Kind === b.Kind) && (this.AST1 === b.AST1) && (this.AST2 === b.AST2) && (this.VarX === b.VarX) && (this.VarY === b.VarY) && (this.T0 === b.T0) && (this.T1 === b.T1) && (this.ColorIdx === b.ColorIdx) && (this.Visible === b.Visible) && (this.CacheLines === b.CacheLines) && this.CacheV.$eq(b.CacheV) && (this.CacheVer === b.CacheVer);
    };
    this.$assign = function (s) {
      this.Text = s.Text;
      this.Kind = s.Kind;
      this.AST1 = s.AST1;
      this.AST2 = s.AST2;
      this.VarX = s.VarX;
      this.VarY = s.VarY;
      this.T0 = s.T0;
      this.T1 = s.T1;
      this.ColorIdx = s.ColorIdx;
      this.Visible = s.Visible;
      this.CacheLines = rtl.arrayRef(s.CacheLines);
      this.CacheV.$assign(s.CacheV);
      this.CacheVer = s.CacheVer;
      return this;
    };
  });
  rtl.recNewT(this,"TParamBinding",function () {
    this.Name = "";
    this.Lo = 0.0;
    this.Hi = 0.0;
    this.Step = 0.0;
    this.$eq = function (b) {
      return (this.Name === b.Name) && (this.Lo === b.Lo) && (this.Hi === b.Hi) && (this.Step === b.Step);
    };
    this.$assign = function (s) {
      this.Name = s.Name;
      this.Lo = s.Lo;
      this.Hi = s.Hi;
      this.Step = s.Step;
      return this;
    };
  });
  rtl.createClass(this,"TWorkspace",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FEntries = [];
      this.FParams = [];
      this.FVersion = 0;
      this.FNextColor = 0;
      this.Store = null;
    };
    this.$final = function () {
      this.FEntries = undefined;
      this.FParams = undefined;
      this.Store = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.KindVarX = function (K) {
      var Result = "";
      var $tmp = K;
      if ($tmp === $mod.TWSKind.wkFuncY) {
        Result = "x"}
       else if ($tmp === $mod.TWSKind.wkImplicit) {
        Result = "x"}
       else {
        Result = "t";
      };
      return Result;
    };
    this.FreeEntry = function (E) {
      rtl.free(E,"AST1");
      rtl.free(E,"AST2");
      E.AST1 = null;
      E.AST2 = null;
      E.CacheLines = rtl.arraySetLength(E.CacheLines,[],0);
    };
    this.SameViewport = function (A, B) {
      var Result = false;
      Result = (A.XMin === B.XMin) && (A.XMax === B.XMax) && (A.YMin === B.YMin) && (A.YMax === B.YMax) && (A.W === B.W) && (A.H === B.H);
      return Result;
    };
    this.Create$1 = function () {
      pas.System.TObject.Create.call(this);
      this.Store = pas["PMS.Deps"].TDepStore.$create("Create$1");
      this.FEntries = rtl.arraySetLength(this.FEntries,$mod.TWSEntry,0);
      this.FParams = rtl.arraySetLength(this.FParams,$mod.TParamBinding,0);
      this.FVersion = 0;
      this.FNextColor = 0;
      return this;
    };
    this.Destroy = function () {
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.FEntries) - 1; $l <= $end; $l++) {
        I = $l;
        this.FreeEntry(this.FEntries[I]);
      };
      rtl.free(this,"Store");
      pas.System.TObject.Destroy.call(this);
    };
    this.AddExpr = function (Text, Kind, Err, ErrPos) {
      var Result = 0;
      var E = $mod.TWSEntry.$new();
      var Semi = 0;
      var T1 = "";
      var T2 = "";
      Result = -1;
      E.Text = "";
      E.AST1 = null;
      E.AST2 = null;
      E.ColorIdx = 0;
      E.Visible = true;
      E.CacheVer = -1;
      E.CacheLines = rtl.arraySetLength(E.CacheLines,[],0);
      E.CacheV.$assign(pas["PMS.Viewport"].VDefault(0,0));
      E.Kind = Kind;
      E.VarX = this.KindVarX(Kind);
      E.VarY = "";
      E.T0 = -10;
      E.T1 = 10;
      var $tmp = Kind;
      if ($tmp === $mod.TWSKind.wkFuncY) {
        if (!$impl.ParseOne(Text,{p: E, get: function () {
            return this.p.AST1;
          }, set: function (v) {
            this.p.AST1 = v;
          }},Err,ErrPos)) return Result}
       else if ($tmp === $mod.TWSKind.wkParam) {
        Semi = pas.System.Pos(";",Text);
        if (Semi < 1) {
          Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
          ErrPos.set(Text.length + 1);
          return Result;
        };
        T1 = pas.SysUtils.Trim(pas.System.Copy(Text,1,Semi - 1));
        T2 = pas.SysUtils.Trim(pas.System.Copy(Text,Semi + 1,Text.length));
        if (!$impl.ParseOne(T1,{p: E, get: function () {
            return this.p.AST1;
          }, set: function (v) {
            this.p.AST1 = v;
          }},Err,ErrPos)) return Result;
        if (!$impl.ParseOne(T2,{p: E, get: function () {
            return this.p.AST2;
          }, set: function (v) {
            this.p.AST2 = v;
          }},Err,ErrPos)) {
          rtl.free(E,"AST1");
          E.AST1 = null;
          return Result;
        };
      } else if ($tmp === $mod.TWSKind.wkPolar) {
        if (!$impl.ParseOne(Text,{p: E, get: function () {
            return this.p.AST1;
          }, set: function (v) {
            this.p.AST1 = v;
          }},Err,ErrPos)) return Result;
        E.T0 = 0;
        E.T1 = 2 * Math.PI;
      } else if ($tmp === $mod.TWSKind.wkImplicit) {
        if (!$impl.ParseOne(Text,{p: E, get: function () {
            return this.p.AST1;
          }, set: function (v) {
            this.p.AST1 = v;
          }},Err,ErrPos)) return Result;
        E.VarY = "y";
      };
      E.Text = Text;
      E.ColorIdx = this.FNextColor;
      this.FNextColor = (this.FNextColor + 1) % 8;
      E.Visible = true;
      E.CacheVer = -1;
      this.FEntries = rtl.arraySetLength(this.FEntries,$mod.TWSEntry,rtl.length(this.FEntries) + 1);
      this.FEntries[rtl.length(this.FEntries) - 1].$assign(E);
      this.FVersion += 1;
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      ErrPos.set(0);
      Result = rtl.length(this.FEntries) - 1;
      return Result;
    };
    this.DefineVar = function (Text, Err, ErrPos) {
      var Result = false;
      Result = this.Store.Define(Text,Err,ErrPos);
      if (Result) this.FVersion += 1;
      return Result;
    };
    this.EnsureVar = function (Name, V) {
      var Result = false;
      var E = 0;
      var P = 0;
      var Dummy = 0.0;
      if (this.Store.EvalVar(Name,{get: function () {
          return Dummy;
        }, set: function (v) {
          Dummy = v;
        }},{get: function () {
          return E;
        }, set: function (v) {
          E = v;
        }})) {
        this.Store.SetVar(Name,V);
        this.FVersion += 1;
        return true;
      };
      Result = this.Store.Define(Name + "=" + pas.SysUtils.Format("%.10g",pas.System.VarRecs(3,V)),{get: function () {
          return E;
        }, set: function (v) {
          E = v;
        }},{get: function () {
          return P;
        }, set: function (v) {
          P = v;
        }});
      if (Result) {
        this.Store.SetVar(Name,V);
        this.FVersion += 1;
      };
      return Result;
    };
    this.SetVar = function (Name, V) {
      var Result = false;
      if (!this.EnsureVar(Name,V)) return false;
      this.FVersion += 1;
      Result = true;
      return Result;
    };
    this.GetVar = function (Name, V) {
      var Result = false;
      var E = 0;
      Result = this.Store.EvalVar(Name,V,{get: function () {
          return E;
        }, set: function (v) {
          E = v;
        }});
      return Result;
    };
    this.DeleteEntry = function (I) {
      var J = 0;
      if ((I < 0) || (I > (rtl.length(this.FEntries) - 1))) return;
      this.FreeEntry(this.FEntries[I]);
      for (var $l = I, $end = rtl.length(this.FEntries) - 1 - 1; $l <= $end; $l++) {
        J = $l;
        this.FEntries[J].$assign(this.FEntries[J + 1]);
      };
      this.FEntries = rtl.arraySetLength(this.FEntries,$mod.TWSEntry,rtl.length(this.FEntries) - 1);
      this.FVersion += 1;
    };
    this.ClearEntries = function () {
      var I = 0;
      for (var $l = 0, $end = rtl.length(this.FEntries) - 1; $l <= $end; $l++) {
        I = $l;
        this.FreeEntry(this.FEntries[I]);
      };
      this.FEntries = rtl.arraySetLength(this.FEntries,$mod.TWSEntry,0);
      this.FVersion += 1;
    };
    this.SetVisible = function (I, V) {
      if ((I < 0) || (I > (rtl.length(this.FEntries) - 1))) return;
      this.FEntries[I].Visible = V;
      this.FVersion += 1;
    };
    this.BindParam = function (Name, Lo, Hi, Step) {
      var Result = false;
      var I = 0;
      var V = 0.0;
      var E = 0;
      for (var $l = 0, $end = rtl.length(this.FParams) - 1; $l <= $end; $l++) {
        I = $l;
        if (this.FParams[I].Name === Name) {
          this.FParams[I].Lo = Lo;
          this.FParams[I].Hi = Hi;
          this.FParams[I].Step = Step;
          return true;
        };
      };
      if (!this.Store.EvalVar(Name,{get: function () {
          return V;
        }, set: function (v) {
          V = v;
        }},{get: function () {
          return E;
        }, set: function (v) {
          E = v;
        }})) return false;
      this.FParams = rtl.arraySetLength(this.FParams,$mod.TParamBinding,rtl.length(this.FParams) + 1);
      this.FParams[rtl.length(this.FParams) - 1].Name = Name;
      this.FParams[rtl.length(this.FParams) - 1].Lo = Lo;
      this.FParams[rtl.length(this.FParams) - 1].Hi = Hi;
      this.FParams[rtl.length(this.FParams) - 1].Step = Step;
      Result = true;
      return Result;
    };
    this.ParamCount = function () {
      var Result = 0;
      Result = rtl.length(this.FParams);
      return Result;
    };
    this.ParamInfo = function (I) {
      var Result = $mod.TParamBinding.$new();
      Result.$assign(this.FParams[I]);
      return Result;
    };
    this.EntryCount = function () {
      var Result = 0;
      Result = rtl.length(this.FEntries);
      return Result;
    };
    var KindTag = [""," (param)"," (polar)"," (implicit)"];
    this.EntryText = function (I) {
      var Result = "";
      Result = this.FEntries[I].Text + KindTag[this.FEntries[I].Kind];
      return Result;
    };
    this.EntryRawText = function (I) {
      var Result = "";
      Result = this.FEntries[I].Text;
      return Result;
    };
    this.EntryKind = function (I) {
      var Result = 0;
      Result = this.FEntries[I].Kind;
      return Result;
    };
    this.EntryVisible = function (I) {
      var Result = false;
      Result = this.FEntries[I].Visible;
      return Result;
    };
    this.EntryColor = function (I) {
      var Result = 0;
      Result = this.FEntries[I].ColorIdx;
      return Result;
    };
    this.ExpandEntry = function (I, Part, Err) {
      var Result = null;
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      Result = null;
      if ((I < 0) || (I > (rtl.length(this.FEntries) - 1))) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      if (Part === 2) {
        if (this.FEntries[I].AST2 === null) {
          Err.set(pas["PMS.Types"].TCalcError.ceDomain);
          return Result;
        };
        Result = this.Store.ExpandCalls(this.FEntries[I].AST2,0,Err);
      } else Result = this.Store.ExpandCalls(this.FEntries[I].AST1,0,Err);
      return Result;
    };
    this.RefreshEntry = function (I, Err) {
      var Result = false;
      Result = false;
      if ((I < 0) || (I > (rtl.length(this.FEntries) - 1))) {
        Err.set(pas["PMS.Types"].TCalcError.ceDomain);
        return Result;
      };
      if (!this.Store.EnsureRefs(this.FEntries[I].AST1,Err)) return Result;
      if ((this.FEntries[I].AST2 !== null) && !this.Store.EnsureRefs(this.FEntries[I].AST2,Err)) return Result;
      Result = true;
      return Result;
    };
    this.SampleEntry = function (I, V, Err) {
      var Result = [];
      var Exp1 = null;
      var Exp2 = null;
      var Line = [];
      Err.set(pas["PMS.Types"].TCalcError.ceNone);
      Result = rtl.arraySetLength(Result,[],0);
      if ((I < 0) || (I > (rtl.length(this.FEntries) - 1)) || !this.FEntries[I].Visible) return Result;
      if ((this.FEntries[I].CacheVer === this.FVersion) && this.SameViewport(this.FEntries[I].CacheV,V)) {
        Result = this.FEntries[I].CacheLines;
        return Result;
      };
      if (!this.RefreshEntry(I,Err)) return Result;
      var $tmp = this.FEntries[I].Kind;
      if ($tmp === $mod.TWSKind.wkFuncY) {
        Exp1 = this.ExpandEntry(I,1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Exp1 = rtl.freeLoc(Exp1);
          return Result;
        };
        Line = pas["PMS.Sampler"].SampleFunc(Exp1,"x",V,this.Store.FCtx,Err);
        Exp1 = rtl.freeLoc(Exp1);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
        Result = rtl.arraySetLength(Result,[],1);
        Result[0] = rtl.arrayRef(Line);
      } else if ($tmp === $mod.TWSKind.wkParam) {
        Exp1 = this.ExpandEntry(I,1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Exp1 = rtl.freeLoc(Exp1);
          return Result;
        };
        Exp2 = this.ExpandEntry(I,2,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Exp1 = rtl.freeLoc(Exp1);
          Exp2 = rtl.freeLoc(Exp2);
          return Result;
        };
        Line = pas["PMS.Sampler"].SampleParam(Exp1,Exp2,"t",this.FEntries[I].T0,this.FEntries[I].T1,V,this.Store.FCtx,Err);
        Exp1 = rtl.freeLoc(Exp1);
        Exp2 = rtl.freeLoc(Exp2);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
        Result = rtl.arraySetLength(Result,[],1);
        Result[0] = rtl.arrayRef(Line);
      } else if ($tmp === $mod.TWSKind.wkPolar) {
        Exp1 = this.ExpandEntry(I,1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Exp1 = rtl.freeLoc(Exp1);
          return Result;
        };
        Line = pas["PMS.Sampler"].SamplePolar(Exp1,"t",this.FEntries[I].T0,this.FEntries[I].T1,V,this.Store.FCtx,Err);
        Exp1 = rtl.freeLoc(Exp1);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
        Result = rtl.arraySetLength(Result,[],1);
        Result[0] = rtl.arrayRef(Line);
      } else if ($tmp === $mod.TWSKind.wkImplicit) {
        Exp1 = this.ExpandEntry(I,1,Err);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) {
          Exp1 = rtl.freeLoc(Exp1);
          return Result;
        };
        pas["PMS.Sampler"].SampleImplicit(Exp1,"x","y",V,120,120,this.Store.FCtx,{get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},Err);
        Exp1 = rtl.freeLoc(Exp1);
        if (Err.get() !== pas["PMS.Types"].TCalcError.ceNone) return Result;
      };
      this.FEntries[I].CacheLines = rtl.arrayRef(Result);
      this.FEntries[I].CacheV.$assign(V);
      this.FEntries[I].CacheVer = this.FVersion;
      return Result;
    };
  });
  $mod.$implcode = function () {
    $impl.ParseOne = function (Text, N, Err, ErrPos) {
      var Result = false;
      N.set(null);
      Result = pas["PMS.Parser"].ParseExpression(Text,N,Err,ErrPos);
      return Result;
    };
  };
},[]);
rtl.module("PMS.Session",["System","SysUtils","Classes","PMS.Types","PMS.AST","PMS.Workspace","PMS.Viewport"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.TJsonKind = {"0": "jkNull", jkNull: 0, "1": "jkBool", jkBool: 1, "2": "jkNum", jkNum: 2, "3": "jkStr", jkStr: 3, "4": "jkArr", jkArr: 4, "5": "jkObj", jkObj: 5};
  rtl.recNewT(this,"TJsonVal",function () {
    this.Kind = 0;
    this.B = false;
    this.N = 0.0;
    this.S = "";
    this.$new = function () {
      var r = Object.create(this);
      r.A = [];
      r.K = [];
      r.V = [];
      return r;
    };
    this.$eq = function (b) {
      return (this.Kind === b.Kind) && (this.B === b.B) && (this.N === b.N) && (this.S === b.S) && (this.A === b.A) && (this.K === b.K) && (this.V === b.V);
    };
    this.$assign = function (s) {
      this.Kind = s.Kind;
      this.B = s.B;
      this.N = s.N;
      this.S = s.S;
      this.A = rtl.arrayRef(s.A);
      this.K = rtl.arrayRef(s.K);
      this.V = rtl.arrayRef(s.V);
      return this;
    };
  });
  this.JsonParse = function (Text, V, ErrPos) {
    var Result = false;
    var P = null;
    P = $impl.TJsonParser.$create("Create$1",[Text]);
    try {
      Result = P.ParseValue(0,V);
      if (Result) {
        P.SkipWS();
        if (!P.AtEnd()) Result = false;
      };
      if (Result) {
        ErrPos.set(0)}
       else ErrPos.set(P.Pos);
    } finally {
      P = rtl.freeLoc(P);
    };
    return Result;
  };
  this.JsonStringify = function (V) {
    var Result = "";
    var I = 0;
    var S = "";
    var $tmp = V.Kind;
    if ($tmp === $mod.TJsonKind.jkNull) {
      Result = "null"}
     else if ($tmp === $mod.TJsonKind.jkBool) {
      if (V.B) {
        Result = "true"}
       else Result = "false"}
     else if ($tmp === $mod.TJsonKind.jkNum) {
      Result = pas.SysUtils.Format$1("%.15g",pas.System.VarRecs(3,V.N),$impl.DotFS)}
     else if ($tmp === $mod.TJsonKind.jkStr) {
      $impl.EscStr(V.S,{get: function () {
          return S;
        }, set: function (v) {
          S = v;
        }});
      Result = S;
    } else if ($tmp === $mod.TJsonKind.jkArr) {
      Result = "[";
      for (var $l = 0, $end = rtl.length(V.A) - 1; $l <= $end; $l++) {
        I = $l;
        if (I > 0) Result = Result + ",";
        Result = Result + $mod.JsonStringify(V.A[I]);
      };
      Result = Result + "]";
    } else if ($tmp === $mod.TJsonKind.jkObj) {
      Result = "{";
      for (var $l1 = 0, $end1 = rtl.length(V.K) - 1; $l1 <= $end1; $l1++) {
        I = $l1;
        if (I > 0) Result = Result + ",";
        $impl.EscStr(V.K[I],{get: function () {
            return S;
          }, set: function (v) {
            S = v;
          }});
        Result = Result + S + ":" + $mod.JsonStringify(V.V[I]);
      };
      Result = Result + "}";
    };
    return Result;
  };
  this.JsonStr = function (S) {
    var Result = $mod.TJsonVal.$new();
    Result.Kind = $mod.TJsonKind.jkStr;
    Result.S = S;
    return Result;
  };
  this.JsonNum = function (N) {
    var Result = $mod.TJsonVal.$new();
    Result.Kind = $mod.TJsonKind.jkNum;
    Result.N = N;
    return Result;
  };
  this.JsonBool = function (B) {
    var Result = $mod.TJsonVal.$new();
    Result.Kind = $mod.TJsonKind.jkBool;
    Result.B = B;
    return Result;
  };
  this.JsonArr = function () {
    var Result = $mod.TJsonVal.$new();
    Result.Kind = $mod.TJsonKind.jkArr;
    Result.A = rtl.arraySetLength(Result.A,$mod.TJsonVal,0);
    return Result;
  };
  this.JsonObj = function () {
    var Result = $mod.TJsonVal.$new();
    Result.Kind = $mod.TJsonKind.jkObj;
    Result.K = rtl.arraySetLength(Result.K,"",0);
    Result.V = rtl.arraySetLength(Result.V,$mod.TJsonVal,0);
    return Result;
  };
  this.JsonArrAdd = function (A, Item) {
    A.A = rtl.arraySetLength(A.A,$mod.TJsonVal,rtl.length(A.A) + 1);
    A.A[rtl.length(A.A) - 1].$assign(Item);
  };
  this.JsonObjAdd = function (O, Key, Item) {
    O.K = rtl.arraySetLength(O.K,"",rtl.length(O.K) + 1);
    O.V = rtl.arraySetLength(O.V,$mod.TJsonVal,rtl.length(O.V) + 1);
    O.K[rtl.length(O.K) - 1] = Key;
    O.V[rtl.length(O.V) - 1].$assign(Item);
  };
  this.JsonObjGet = function (O, Key, Item) {
    var Result = false;
    var I = 0;
    if (O.Kind !== $mod.TJsonKind.jkObj) return false;
    for (var $l = 0, $end = rtl.length(O.K) - 1; $l <= $end; $l++) {
      I = $l;
      if (O.K[I] === Key) {
        Item.$assign(O.V[I]);
        return true;
      };
    };
    Result = false;
    return Result;
  };
  this.SessionSave = function (WS, V, AngleMode, jSON) {
    var Result = false;
    var Root = $mod.TJsonVal.$new();
    var E = $mod.TJsonVal.$new();
    var J = $mod.TJsonVal.$new();
    var Vp = $mod.TJsonVal.$new();
    var I = 0;
    Result = false;
    Root.$assign($mod.JsonObj());
    $mod.JsonObjAdd(Root,"schemaVersion",$mod.JsonNum(1));
    $mod.JsonObjAdd(Root,"app",$mod.JsonStr("PascalMath Studio"));
    E.$assign($mod.JsonArr());
    for (var $l = 0, $end = WS.EntryCount() - 1; $l <= $end; $l++) {
      I = $l;
      J.$assign($mod.JsonObj());
      $mod.JsonObjAdd(J,"text",$mod.JsonStr(WS.EntryRawText(I)));
      $mod.JsonObjAdd(J,"kind",$mod.JsonNum(WS.EntryKind(I)));
      $mod.JsonObjAdd(J,"visible",$mod.JsonBool(WS.EntryVisible(I)));
      $mod.JsonArrAdd(E,J);
    };
    $mod.JsonObjAdd(Root,"entries",E);
    E.$assign($mod.JsonArr());
    for (var $l1 = 0, $end1 = WS.Store.EntryCount() - 1; $l1 <= $end1; $l1++) {
      I = $l1;
      $mod.JsonArrAdd(E,$mod.JsonStr(WS.Store.EntryText(I)));
    };
    $mod.JsonObjAdd(Root,"vars",E);
    Vp.$assign($mod.JsonObj());
    $mod.JsonObjAdd(Vp,"xmin",$mod.JsonNum(V.XMin));
    $mod.JsonObjAdd(Vp,"xmax",$mod.JsonNum(V.XMax));
    $mod.JsonObjAdd(Vp,"ymin",$mod.JsonNum(V.YMin));
    $mod.JsonObjAdd(Vp,"ymax",$mod.JsonNum(V.YMax));
    $mod.JsonObjAdd(Root,"viewport",Vp);
    $mod.JsonObjAdd(Root,"angle",$mod.JsonNum(AngleMode));
    jSON.set($mod.JsonStringify(Root));
    Result = true;
    return Result;
  };
  this.SessionLoad = function (jSON, WS, V, AngleMode, Err) {
    var Result = false;
    var Root = $mod.TJsonVal.$new();
    var It = $mod.TJsonVal.$new();
    var E2 = $mod.TJsonVal.$new();
    var P = 0;
    var I = 0;
    var Ver = 0.0;
    var N = 0.0;
    var Tx = "";
    var Kind = 0;
    var Vis = false;
    Result = false;
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    if (!$mod.JsonParse(jSON,Root,{get: function () {
        return P;
      }, set: function (v) {
        P = v;
      }})) {
      Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
      return Result;
    };
    if ((Root.Kind !== $mod.TJsonKind.jkObj) || !$impl.GetNum(Root,"schemaVersion",{get: function () {
        return Ver;
      }, set: function (v) {
        Ver = v;
      }}) || (pas.System.Trunc(Ver) !== 1)) {
      Err.set(pas["PMS.Types"].TCalcError.ceUnsupported);
      return Result;
    };
    WS.ClearEntries();
    if ($mod.JsonObjGet(Root,"vars",It) && (It.Kind === $mod.TJsonKind.jkArr)) {
      for (var $l = 0, $end = rtl.length(It.A) - 1; $l <= $end; $l++) {
        I = $l;
        if (It.A[I].Kind !== $mod.TJsonKind.jkStr) continue;
        if (!WS.DefineVar(It.A[I].S,Err,{get: function () {
            return P;
          }, set: function (v) {
            P = v;
          }})) return false;
      };
    };
    if ($mod.JsonObjGet(Root,"entries",It) && (It.Kind === $mod.TJsonKind.jkArr)) {
      for (var $l1 = 0, $end1 = rtl.length(It.A) - 1; $l1 <= $end1; $l1++) {
        I = $l1;
        if ((It.A[I].Kind !== $mod.TJsonKind.jkObj) || !$mod.JsonObjGet(It.A[I],"text",E2) || (E2.Kind !== $mod.TJsonKind.jkStr)) continue;
        Tx = E2.S;
        Kind = 0;
        if ($mod.JsonObjGet(It.A[I],"kind",E2) && (E2.Kind === $mod.TJsonKind.jkNum)) Kind = pas.System.Trunc(E2.N);
        if ((Kind < 0) || (Kind > 3)) Kind = 0;
        if (WS.AddExpr(Tx,Kind,Err,{get: function () {
            return P;
          }, set: function (v) {
            P = v;
          }}) < 0) return false;
        Vis = true;
        if ($mod.JsonObjGet(It.A[I],"visible",E2) && (E2.Kind === $mod.TJsonKind.jkBool)) Vis = E2.B;
        WS.SetVisible(WS.EntryCount() - 1,Vis);
      };
    };
    if ($mod.JsonObjGet(Root,"viewport",It) && (It.Kind === $mod.TJsonKind.jkObj)) {
      if ($impl.GetNum(It,"xmin",{get: function () {
          return N;
        }, set: function (v) {
          N = v;
        }})) V.XMin = N;
      if ($impl.GetNum(It,"xmax",{get: function () {
          return N;
        }, set: function (v) {
          N = v;
        }})) V.XMax = N;
      if ($impl.GetNum(It,"ymin",{get: function () {
          return N;
        }, set: function (v) {
          N = v;
        }})) V.YMin = N;
      if ($impl.GetNum(It,"ymax",{get: function () {
          return N;
        }, set: function (v) {
          N = v;
        }})) V.YMax = N;
    };
    AngleMode.set(0);
    if ($impl.GetNum(Root,"angle",{get: function () {
        return N;
      }, set: function (v) {
        N = v;
      }}) && (pas.System.Trunc(N) >= 0) && (pas.System.Trunc(N) <= 2)) AngleMode.set(pas.System.Trunc(N));
    Result = true;
    return Result;
  };
  this.SessionToHash = function (jSON) {
    var Result = "";
    Result = "#" + $impl.UrlEncode(jSON);
    return Result;
  };
  this.SessionFromHash = function (Hash, jSON, Err) {
    var Result = false;
    var S = "";
    Result = false;
    Err.set(pas["PMS.Types"].TCalcError.ceNone);
    S = Hash;
    if ((S !== "") && (S.charAt(0) === "#")) pas.System.Delete({get: function () {
        return S;
      }, set: function (v) {
        S = v;
      }},1,1);
    if (!$impl.UrlDecode(S,jSON)) {
      Err.set(pas["PMS.Types"].TCalcError.ceSyntax);
      return Result;
    };
    Result = true;
    return Result;
  };
  $mod.$implcode = function () {
    $impl.DotFS = pas.SysUtils.TFormatSettings.$new();
    $impl.EscStr = function (S, R) {
      var I = 0;
      var C = "";
      R.set('"');
      for (var $l = 1, $end = S.length; $l <= $end; $l++) {
        I = $l;
        C = S.charAt(I - 1);
        var $tmp = C;
        if ($tmp === '"') {
          R.set(R.get() + '\\"')}
         else if ($tmp === "\\") {
          R.set(R.get() + "\\\\")}
         else if ($tmp === "\b") {
          R.set(R.get() + "\\b")}
         else if ($tmp === "\t") {
          R.set(R.get() + "\\t")}
         else if ($tmp === "\n") {
          R.set(R.get() + "\\n")}
         else if ($tmp === "\f") {
          R.set(R.get() + "\\f")}
         else if ($tmp === "\r") {
          R.set(R.get() + "\\r")}
         else {
          if (C.charCodeAt() < 32) {
            R.set(R.get() + "\\u" + pas.SysUtils.IntToHex(C.charCodeAt(),4))}
           else R.set(R.get() + C);
        };
      };
      R.set(R.get() + '"');
    };
    rtl.createClass($impl,"TJsonParser",pas.System.TObject,function () {
      this.$init = function () {
        pas.System.TObject.$init.call(this);
        this.Text = "";
        this.Pos = 0;
      };
      this.Create$1 = function (T) {
        pas.System.TObject.Create.call(this);
        this.Text = T;
        this.Pos = 1;
        return this;
      };
      this.SkipWS = function () {
        while ((this.Pos <= this.Text.length) && (this.Text.charCodeAt(this.Pos - 1) in rtl.createSet(32,9,10,13))) this.Pos += 1;
      };
      this.AtEnd = function () {
        var Result = false;
        Result = this.Pos > this.Text.length;
        return Result;
      };
      this.ParseValue = function (Depth, V) {
        var Result = false;
        var K = "";
        var Item = $mod.TJsonVal.$new();
        Result = false;
        if (Depth > 32) return Result;
        this.SkipWS();
        if (this.AtEnd()) return Result;
        var $tmp = this.Text.charAt(this.Pos - 1);
        if ($tmp === "{") {
          this.Pos += 1;
          V.$assign($mod.JsonObj());
          this.SkipWS();
          if (!this.AtEnd() && (this.Text.charAt(this.Pos - 1) === "}")) {
            this.Pos += 1;
            return true;
          };
          while (true) {
            this.SkipWS();
            if (!this.ParseStr({get: function () {
                return K;
              }, set: function (v) {
                K = v;
              }})) return Result;
            this.SkipWS();
            if (this.AtEnd() || (this.Text.charAt(this.Pos - 1) !== ":")) return Result;
            this.Pos += 1;
            if (!this.ParseValue(Depth + 1,Item)) return Result;
            $mod.JsonObjAdd(V,K,Item);
            this.SkipWS();
            if (this.AtEnd()) return Result;
            if (this.Text.charAt(this.Pos - 1) === "}") {
              this.Pos += 1;
              return true;
            };
            if (this.Text.charAt(this.Pos - 1) !== ",") return Result;
            this.Pos += 1;
          };
        } else if ($tmp === "[") {
          this.Pos += 1;
          V.$assign($mod.JsonArr());
          this.SkipWS();
          if (!this.AtEnd() && (this.Text.charAt(this.Pos - 1) === "]")) {
            this.Pos += 1;
            return true;
          };
          while (true) {
            if (!this.ParseValue(Depth + 1,Item)) return Result;
            $mod.JsonArrAdd(V,Item);
            this.SkipWS();
            if (this.AtEnd()) return Result;
            if (this.Text.charAt(this.Pos - 1) === "]") {
              this.Pos += 1;
              return true;
            };
            if (this.Text.charAt(this.Pos - 1) !== ",") return Result;
            this.Pos += 1;
          };
        } else if ($tmp === '"') {
          if (!this.ParseStr({get: function () {
              return K;
            }, set: function (v) {
              K = v;
            }})) return Result;
          V.$assign($mod.JsonStr(K));
          return true;
        } else if ($tmp === "t") {
          if (!this.ParseLit("true")) return Result;
          V.$assign($mod.JsonBool(true));
          return true;
        } else if ($tmp === "f") {
          if (!this.ParseLit("false")) return Result;
          V.$assign($mod.JsonBool(false));
          return true;
        } else if ($tmp === "n") {
          if (!this.ParseLit("null")) return Result;
          V.Kind = $mod.TJsonKind.jkNull;
          return true;
        } else {
          if (!this.ParseNum({p: V, get: function () {
              return this.p.N;
            }, set: function (v) {
              this.p.N = v;
            }})) return Result;
          V.Kind = $mod.TJsonKind.jkNum;
          return true;
        };
        return Result;
      };
      this.ParseStr = function (S) {
        var Result = false;
        var C = "";
        var Code = 0;
        var Hex = "";
        Result = false;
        S.set("");
        if (this.AtEnd() || (this.Text.charAt(this.Pos - 1) !== '"')) return Result;
        this.Pos += 1;
        while (!this.AtEnd()) {
          C = this.Text.charAt(this.Pos - 1);
          if (C === '"') {
            this.Pos += 1;
            return true;
          };
          if (C === "\\") {
            this.Pos += 1;
            if (this.AtEnd()) return Result;
            var $tmp = this.Text.charAt(this.Pos - 1);
            if ($tmp === '"') {
              S.set(S.get() + '"')}
             else if ($tmp === "\\") {
              S.set(S.get() + "\\")}
             else if ($tmp === "\/") {
              S.set(S.get() + "\/")}
             else if ($tmp === "b") {
              S.set(S.get() + "\b")}
             else if ($tmp === "f") {
              S.set(S.get() + "\f")}
             else if ($tmp === "n") {
              S.set(S.get() + "\n")}
             else if ($tmp === "r") {
              S.set(S.get() + "\r")}
             else if ($tmp === "t") {
              S.set(S.get() + "\t")}
             else if ($tmp === "u") {
              if ((this.Pos + 4) > this.Text.length) return Result;
              Hex = pas.System.Copy(this.Text,this.Pos + 1,4);
              if (!pas.SysUtils.TryStrToInt("$" + Hex,{get: function () {
                  return Code;
                }, set: function (v) {
                  Code = v;
                }})) return Result;
              if (Code < 0x80) {
                S.set(S.get() + String.fromCharCode(Code))}
               else if (Code < 0x800) {
                S.set(S.get() + String.fromCharCode(0xC0 | (Code >>> 6)) + String.fromCharCode(0x80 | (Code & 0x3F)))}
               else S.set(S.get() + String.fromCharCode(0xE0 | (Code >>> 12)) + String.fromCharCode(0x80 | ((Code >>> 6) & 0x3F)) + String.fromCharCode(0x80 | (Code & 0x3F)));
              this.Pos += 4;
            } else {
              return Result;
            };
            this.Pos += 1;
            continue;
          };
          if (C.charCodeAt() < 32) return Result;
          S.set(S.get() + C);
          this.Pos += 1;
        };
        return Result;
      };
      this.ParseNum = function (N) {
        var Result = false;
        var Start = 0;
        Result = false;
        Start = this.Pos;
        if ((this.Pos <= this.Text.length) && ((this.Text.charAt(this.Pos - 1) === "-") || (this.Text.charAt(this.Pos - 1) === "+"))) this.Pos += 1;
        while ((this.Pos <= this.Text.length) && (this.Text.charCodeAt(this.Pos - 1) in rtl.createSet(null,48,57))) this.Pos += 1;
        if ((this.Pos <= this.Text.length) && (this.Text.charAt(this.Pos - 1) === ".")) {
          this.Pos += 1;
          while ((this.Pos <= this.Text.length) && (this.Text.charCodeAt(this.Pos - 1) in rtl.createSet(null,48,57))) this.Pos += 1;
        };
        if ((this.Pos <= this.Text.length) && ((this.Text.charAt(this.Pos - 1) === "e") || (this.Text.charAt(this.Pos - 1) === "E"))) {
          this.Pos += 1;
          if ((this.Pos <= this.Text.length) && ((this.Text.charAt(this.Pos - 1) === "-") || (this.Text.charAt(this.Pos - 1) === "+"))) this.Pos += 1;
          while ((this.Pos <= this.Text.length) && (this.Text.charCodeAt(this.Pos - 1) in rtl.createSet(null,48,57))) this.Pos += 1;
        };
        if (this.Pos === Start) return Result;
        Result = pas.SysUtils.TryStrToFloat$3(pas.System.Copy(this.Text,Start,this.Pos - Start),N,$impl.DotFS);
        return Result;
      };
      this.ParseLit = function (Lit) {
        var Result = false;
        if (pas.System.Copy(this.Text,this.Pos,Lit.length) === Lit) {
          this.Pos += Lit.length;
          return true;
        };
        Result = false;
        return Result;
      };
    });
    $impl.GetNum = function (O, Key, N) {
      var Result = false;
      var It = $mod.TJsonVal.$new();
      Result = $mod.JsonObjGet(O,Key,It) && (It.Kind === $mod.TJsonKind.jkNum);
      if (Result) N.set(It.N);
      return Result;
    };
    var Unres = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
    $impl.UrlEncode = function (S) {
      var Result = "";
      var I = 0;
      var C = 0;
      Result = "";
      for (var $l = 1, $end = S.length; $l <= $end; $l++) {
        I = $l;
        C = S.charAt(I - 1).charCodeAt() & 255;
        if (pas.System.Pos(String.fromCharCode(C),Unres) > 0) {
          Result = Result + String.fromCharCode(C)}
         else Result = Result + "%" + pas.SysUtils.IntToHex(C,2);
      };
      return Result;
    };
    $impl.UrlDecode = function (S, R) {
      var Result = false;
      var I = 0;
      var Code = 0;
      Result = false;
      R.set("");
      I = 1;
      while (I <= S.length) {
        if (S.charAt(I - 1) === "%") {
          if (((I + 2) > S.length) || !pas.SysUtils.TryStrToInt("$" + pas.System.Copy(S,I + 1,2),{get: function () {
              return Code;
            }, set: function (v) {
              Code = v;
            }})) return Result;
          R.set(R.get() + String.fromCharCode(Code));
          I += 3;
        } else {
          R.set(R.get() + S.charAt(I - 1));
          I += 1;
        };
      };
      Result = true;
      return Result;
    };
  };
  $mod.$init = function () {
    $impl.DotFS.DecimalSeparator = ".";
    $impl.DotFS.ThousandSeparator = ",";
  };
},[]);
rtl.module("program",["System","SysUtils","JS","Web","PMS.AppName","PMS.Types","PMS.Eval","PMS.Workspace","PMS.Viewport","PMS.Sampler","PMS.Session","PMS.Matrix","PMS.Deps"],function () {
  "use strict";
  var $mod = this;
  this.Ctx = null;
  this.WS = null;
  this.V = pas["PMS.Viewport"].TViewport.$new();
  this.Dragging = false;
  this.LastPX = 0;
  this.LastPY = 0;
  this.E2 = 0;
  this.P2 = 0;
  this.Palette = ["#c00000","#0000cc","#008000","#800080","#008080","#ff8000","#800000","#000080"];
  this.El = function (Id) {
    var Result = null;
    Result = document.getElementById(Id);
    return Result;
  };
  this.CanvasEl = function () {
    var Result = null;
    Result = document.getElementById("graph");
    return Result;
  };
  this.Ctx2D = function () {
    var Result = null;
    Result = $mod.CanvasEl().getContext("2d");
    return Result;
  };
  this.Fmt = function (X) {
    var Result = "";
    Result = pas.SysUtils.Format("%.10g",pas.System.VarRecs(3,X));
    return Result;
  };
  this.EscHTML = function (S) {
    var Result = "";
    var I = 0;
    Result = "";
    for (var $l = 1, $end = S.length; $l <= $end; $l++) {
      I = $l;
      var $tmp = S.charAt(I - 1);
      if ($tmp === "&") {
        Result = Result + "&amp;"}
       else if ($tmp === "<") {
        Result = Result + "&lt;"}
       else if ($tmp === ">") {
        Result = Result + "&gt;"}
       else if ($tmp === '"') {
        Result = Result + "&quot;"}
       else {
        Result = Result + S.charAt(I - 1);
      };
    };
    return Result;
  };
  this.Evaluate = function (Event) {
    var Result = false;
    var Src = "";
    var Val = 0.0;
    var E = 0;
    var P = 0;
    Src = $mod.El("expr").value;
    if (pas.SysUtils.Trim(Src) === "") return true;
    if (pas["PMS.Eval"].EvalText(Src,$mod.Ctx,{get: function () {
        return Val;
      }, set: function (v) {
        Val = v;
      }},{get: function () {
        return E;
      }, set: function (v) {
        E = v;
      }},{get: function () {
        return P;
      }, set: function (v) {
        P = v;
      }})) {
      $mod.El("out").innerHTML = $mod.EscHTML($mod.Fmt(Val))}
     else if (P > 0) {
      $mod.El("out").innerHTML = $mod.EscHTML("Error (pos " + pas.SysUtils.IntToStr(P) + "): " + pas["PMS.Types"].CalcErrorMessage(E))}
     else $mod.El("out").innerHTML = $mod.EscHTML("Error: " + pas["PMS.Types"].CalcErrorMessage(E));
    Result = true;
    return Result;
  };
  this.StrokeLines = function (C, Lines, Color, Width) {
    var I = 0;
    var J = 0;
    C.strokeStyle = Color;
    C.lineWidth = Width;
    for (var $l = 0, $end = rtl.length(Lines) - 1; $l <= $end; $l++) {
      J = $l;
      C.beginPath();
      for (var $l1 = 0, $end1 = rtl.length(Lines[J]) - 1; $l1 <= $end1; $l1++) {
        I = $l1;
        if ((I === 0) || !Lines[J][I].Pen) {
          C.moveTo(Lines[J][I].SX,Lines[J][I].SY)}
         else C.lineTo(Lines[J][I].SX,Lines[J][I].SY);
      };
      C.stroke();
    };
  };
  this.Replot = function () {
    var C = null;
    var W = 0;
    var H = 0;
    var TX = [];
    var TY = [];
    var I = 0;
    var K = 0;
    var SX = 0.0;
    var SY = 0.0;
    var Lines = [];
    var E = 0;
    W = $mod.CanvasEl().width;
    H = $mod.CanvasEl().height;
    $mod.V.W = W;
    $mod.V.H = H;
    C = $mod.Ctx2D();
    C.clearRect(0,0,W,H);
    C.strokeStyle = "#e0e0e0";
    C.lineWidth = 1;
    pas["PMS.Viewport"].VNiceTicks($mod.V.XMin,$mod.V.XMax,10,{get: function () {
        return TX;
      }, set: function (v) {
        TX = v;
      }});
    C.beginPath();
    for (var $l = 0, $end = rtl.length(TX) - 1; $l <= $end; $l++) {
      I = $l;
      pas["PMS.Viewport"].VWorldToScreen($mod.V,TX[I],0,{get: function () {
          return SX;
        }, set: function (v) {
          SX = v;
        }},{get: function () {
          return SY;
        }, set: function (v) {
          SY = v;
        }});
      C.moveTo(SX,0);
      C.lineTo(SX,H);
    };
    C.stroke();
    pas["PMS.Viewport"].VNiceTicks($mod.V.YMin,$mod.V.YMax,10,{get: function () {
        return TY;
      }, set: function (v) {
        TY = v;
      }});
    C.beginPath();
    for (var $l1 = 0, $end1 = rtl.length(TY) - 1; $l1 <= $end1; $l1++) {
      I = $l1;
      pas["PMS.Viewport"].VWorldToScreen($mod.V,0,TY[I],{get: function () {
          return SX;
        }, set: function (v) {
          SX = v;
        }},{get: function () {
          return SY;
        }, set: function (v) {
          SY = v;
        }});
      C.moveTo(0,SY);
      C.lineTo(W,SY);
    };
    C.stroke();
    C.strokeStyle = "#000000";
    if (($mod.V.YMin <= 0) && ($mod.V.YMax >= 0)) {
      pas["PMS.Viewport"].VWorldToScreen($mod.V,0,0,{get: function () {
          return SX;
        }, set: function (v) {
          SX = v;
        }},{get: function () {
          return SY;
        }, set: function (v) {
          SY = v;
        }});
      C.beginPath();
      C.moveTo(0,SY);
      C.lineTo(W,SY);
      C.stroke();
    };
    if (($mod.V.XMin <= 0) && ($mod.V.XMax >= 0)) {
      pas["PMS.Viewport"].VWorldToScreen($mod.V,0,0,{get: function () {
          return SX;
        }, set: function (v) {
          SX = v;
        }},{get: function () {
          return SY;
        }, set: function (v) {
          SY = v;
        }});
      C.beginPath();
      C.moveTo(SX,0);
      C.lineTo(SX,H);
      C.stroke();
    };
    for (var $l2 = 0, $end2 = $mod.WS.EntryCount() - 1; $l2 <= $end2; $l2++) {
      K = $l2;
      if (!$mod.WS.EntryVisible(K)) continue;
      Lines = $mod.WS.SampleEntry(K,$mod.V,{get: function () {
          return E;
        }, set: function (v) {
          E = v;
        }});
      if (E === pas["PMS.Types"].TCalcError.ceNone) $mod.StrokeLines(C,Lines,$mod.Palette[$mod.WS.EntryColor(K) % 8],2);
    };
  };
  this.Persist = function () {
    var J = "";
    try {
      if (pas["PMS.Session"].SessionSave($mod.WS,$mod.V,$mod.Ctx.AngleMode,{get: function () {
          return J;
        }, set: function (v) {
          J = v;
        }})) window.localStorage.setItem("pmsession",J);
    } catch ($e) {
    };
  };
  this.LSGet = function (Key) {
    var Result = "";
    var I = 0;
    Result = "";
    try {
      for (var $l = 0, $end = window.localStorage.length - 1; $l <= $end; $l++) {
        I = $l;
        if (window.localStorage.key(I) === Key) {
          Result = window.localStorage.getItem(Key);
          break;
        };
      };
    } catch ($e) {
    };
    return Result;
  };
  this.Restore = function () {
    var J = "";
    var E = 0;
    var A = 0;
    J = $mod.LSGet("pmsession");
    if (J === "") return;
    if (pas["PMS.Session"].SessionLoad(J,$mod.WS,$mod.V,{get: function () {
        return A;
      }, set: function (v) {
        A = v;
      }},{get: function () {
        return E;
      }, set: function (v) {
        E = v;
      }})) {
      $mod.Ctx.AngleMode = A;
      $mod.RefreshEntries();
      $mod.RebuildSliders();
    };
  };
  this.RefreshEntries = function () {
    var Box = null;
    var Row = null;
    var Dot = null;
    var Txt = null;
    var Hide = null;
    var Del = null;
    var Inp = null;
    var I = 0;
    Box = $mod.El("entries");
    Box.innerHTML = "";
    for (var $l = 0, $end = $mod.WS.EntryCount() - 1; $l <= $end; $l++) {
      I = $l;
      Row = document.createElement("div");
      Row.className = "entry";
      Dot = document.createElement("span");
      Dot.className = "dot";
      Dot.setAttribute("style","background:" + $mod.Palette[$mod.WS.EntryColor(I) % 8]);
      Txt = document.createElement("span");
      Txt.className = "etext";
      Txt.innerHTML = $mod.EscHTML($mod.WS.EntryText(I));
      Hide = document.createElement("button");
      Hide.setAttribute("data-i",pas.SysUtils.IntToStr(I));
      Hide.setAttribute("data-a","t");
      if ($mod.WS.EntryVisible(I)) {
        Hide.innerHTML = "hide"}
       else Hide.innerHTML = "show";
      Hide.addEventListener("click",rtl.createSafeCallback($mod,"EntryBtn"));
      Del = document.createElement("button");
      Del.setAttribute("data-i",pas.SysUtils.IntToStr(I));
      Del.setAttribute("data-a","d");
      Del.innerHTML = "x";
      Del.addEventListener("click",rtl.createSafeCallback($mod,"EntryBtn"));
      Inp = document.createElement("input");
      Row.appendChild(Dot);
      Row.appendChild(Txt);
      Row.appendChild(Hide);
      Row.appendChild(Del);
      Box.appendChild(Row);
    };
  };
  this.EntryBtn = function (Event) {
    var Result = false;
    var B = null;
    var I = 0;
    B = Event.target;
    I = pas.SysUtils.StrToIntDef(B.getAttribute("data-i"),-1);
    if ((I < 0) || (I >= $mod.WS.EntryCount())) return true;
    if (B.getAttribute("data-a") === "t") {
      $mod.WS.SetVisible(I,!$mod.WS.EntryVisible(I))}
     else $mod.WS.DeleteEntry(I);
    $mod.RefreshEntries();
    $mod.Replot();
    $mod.Persist();
    Result = true;
    return Result;
  };
  this.RebuildSliders = function () {
    var Box = null;
    var Row = null;
    var Lab = null;
    var Inp = null;
    var I = 0;
    var Pb = pas["PMS.Workspace"].TParamBinding.$new();
    var Val = 0.0;
    Box = $mod.El("sliders");
    Box.innerHTML = "";
    for (var $l = 0, $end = $mod.WS.ParamCount() - 1; $l <= $end; $l++) {
      I = $l;
      Pb.$assign($mod.WS.ParamInfo(I));
      Row = document.createElement("div");
      Row.className = "slider";
      Lab = document.createElement("span");
      Lab.innerHTML = $mod.EscHTML(Pb.Name);
      Inp = document.createElement("input");
      Inp.setAttribute("type","range");
      Inp.setAttribute("min",pas.SysUtils.FloatToStr(Pb.Lo));
      Inp.setAttribute("max",pas.SysUtils.FloatToStr(Pb.Hi));
      Inp.setAttribute("step",pas.SysUtils.FloatToStr(Pb.Step));
      if ($mod.WS.GetVar(Pb.Name,{get: function () {
          return Val;
        }, set: function (v) {
          Val = v;
        }})) {
        Inp.setAttribute("value",pas.SysUtils.FloatToStr(Val))}
       else Inp.setAttribute("value",pas.SysUtils.FloatToStr((Pb.Lo + Pb.Hi) / 2));
      Inp.setAttribute("data-i",pas.SysUtils.IntToStr(I));
      Inp.addEventListener("input",rtl.createSafeCallback($mod,"SliderMoved"));
      Row.appendChild(Lab);
      Row.appendChild(Inp);
      Box.appendChild(Row);
    };
  };
  this.SliderMoved = function (Event) {
    var Result = false;
    var Inp = null;
    var Pb = pas["PMS.Workspace"].TParamBinding.$new();
    Inp = Event.target;
    Pb.$assign($mod.WS.ParamInfo(pas.SysUtils.StrToIntDef(Inp.getAttribute("data-i"),0)));
    $mod.WS.SetVar(Pb.Name,pas.SysUtils.StrToFloatDef(Inp.value,Pb.Lo));
    $mod.Replot();
    $mod.Persist();
    Result = true;
    return Result;
  };
  this.DetectSliders = function () {
    var I = 0;
    for (var $l = 0, $end = $mod.WS.Store.EntryCount() - 1; $l <= $end; $l++) {
      I = $l;
      if ($mod.WS.Store.EntryKind(I) !== pas["PMS.Deps"].TDepKind.dkVar) continue;
      $mod.WS.BindParam($mod.WS.Store.EntryName(I),-5,5,0.1);
    };
    $mod.RebuildSliders();
  };
  this.DetectBtn = function (Event) {
    var Result = false;
    $mod.DetectSliders();
    Result = true;
    return Result;
  };
  this.DoPlot = function (Event) {
    var Result = false;
    var E = 0;
    var P = 0;
    var Idx = 0;
    Idx = $mod.WS.AddExpr($mod.El("plotexpr").value,pas["PMS.Workspace"].TWSKind.wkFuncY,{get: function () {
        return E;
      }, set: function (v) {
        E = v;
      }},{get: function () {
        return P;
      }, set: function (v) {
        P = v;
      }});
    if (Idx < 0) {
      $mod.El("out").innerHTML = $mod.EscHTML("Plot error (pos " + pas.SysUtils.IntToStr(P) + "): " + pas["PMS.Types"].CalcErrorMessage(E));
      return true;
    };
    $mod.El("plotexpr").value = "";
    $mod.RefreshEntries();
    $mod.Replot();
    $mod.Persist();
    Result = true;
    return Result;
  };
  this.DoShare = function (Event) {
    var Result = false;
    var J = "";
    if (!pas["PMS.Session"].SessionSave($mod.WS,$mod.V,$mod.Ctx.AngleMode,{get: function () {
        return J;
      }, set: function (v) {
        J = v;
      }})) return true;
    window.location.hash = pas["PMS.Session"].SessionToHash(J);
    $mod.El("link").value = window.location.href;
    Result = true;
    return Result;
  };
  this.OnPointerDown = function (Event) {
    var Result = false;
    var M = null;
    M = Event;
    $mod.Dragging = true;
    $mod.LastPX = Math.round(M.offsetX);
    $mod.LastPY = Math.round(M.offsetY);
    Result = true;
    return Result;
  };
  this.OnPointerMove = function (Event) {
    var Result = false;
    var M = null;
    if (!$mod.Dragging) return true;
    M = Event;
    pas["PMS.Viewport"].VPanPixels($mod.V,Math.round(M.offsetX) - $mod.LastPX,Math.round(M.offsetY) - $mod.LastPY);
    $mod.LastPX = Math.round(M.offsetX);
    $mod.LastPY = Math.round(M.offsetY);
    $mod.Replot();
    Result = true;
    return Result;
  };
  this.OnPointerUp = function (Event) {
    var Result = false;
    $mod.Dragging = false;
    $mod.Persist();
    Result = true;
    return Result;
  };
  this.OnWheel = function (Event) {
    var Result = false;
    var W = null;
    var WX = 0.0;
    var WY = 0.0;
    W = Event;
    W.preventDefault();
    pas["PMS.Viewport"].VScreenToWorld($mod.V,W.offsetX,W.offsetY,{get: function () {
        return WX;
      }, set: function (v) {
        WX = v;
      }},{get: function () {
        return WY;
      }, set: function (v) {
        WY = v;
      }});
    if (W.deltaY > 0) {
      pas["PMS.Viewport"].VZoom($mod.V,1.25,WX,WY)}
     else pas["PMS.Viewport"].VZoom($mod.V,0.8,WX,WY);
    $mod.Replot();
    $mod.Persist();
    Result = true;
    return Result;
  };
  this.FitCanvas = function () {
    var W = 0;
    W = $mod.El("graph").clientWidth;
    if (W < 100) W = 800;
    $mod.CanvasEl().width = W;
    $mod.CanvasEl().height = Math.round((W * 9) / 16);
  };
  this.OnResize = function (Event) {
    var Result = false;
    $mod.FitCanvas();
    $mod.Replot();
    Result = true;
    return Result;
  };
  this.Wire = function (Id, Evt, H) {
    $mod.El(Id).addEventListener(Evt,rtl.createSafeCallback(null,H));
  };
  this.ImportHash = function () {
    var H = "";
    var J = "";
    var E = 0;
    var A = 0;
    H = window.location.hash;
    if (H === "") return;
    if (pas["PMS.Session"].SessionFromHash(H,{get: function () {
        return J;
      }, set: function (v) {
        J = v;
      }},{get: function () {
        return E;
      }, set: function (v) {
        E = v;
      }}) && pas["PMS.Session"].SessionLoad(J,$mod.WS,$mod.V,{get: function () {
        return A;
      }, set: function (v) {
        A = v;
      }},{get: function () {
        return E;
      }, set: function (v) {
        E = v;
      }})) {
      $mod.Ctx.AngleMode = A;
      $mod.RefreshEntries();
      $mod.RebuildSliders();
    };
  };
  $mod.$main = function () {
    $mod.Ctx = pas["PMS.Types"].TEvalContext.$create("Create$1");
    $mod.WS = pas["PMS.Workspace"].TWorkspace.$create("Create$1");
    $mod.V.$assign(pas["PMS.Viewport"].VDefault(800,450));
    $mod.El("ver").innerHTML = pas["PMS.AppName"].PMSVersion;
    $mod.Wire("eval","click",rtl.createSafeCallback($mod,"Evaluate"));
    $mod.Wire("expr","change",rtl.createSafeCallback($mod,"Evaluate"));
    $mod.Wire("plot","click",rtl.createSafeCallback($mod,"DoPlot"));
    $mod.Wire("plotexpr","change",rtl.createSafeCallback($mod,"DoPlot"));
    $mod.Wire("share","click",rtl.createSafeCallback($mod,"DoShare"));
    $mod.Wire("slidersbtn","click",rtl.createSafeCallback($mod,"DetectBtn"));
    $mod.Wire("graph","pointerdown",rtl.createSafeCallback($mod,"OnPointerDown"));
    $mod.Wire("graph","pointermove",rtl.createSafeCallback($mod,"OnPointerMove"));
    $mod.Wire("graph","pointerup",rtl.createSafeCallback($mod,"OnPointerUp"));
    $mod.Wire("graph","wheel",rtl.createSafeCallback($mod,"OnWheel"));
    window.addEventListener("resize",rtl.createSafeCallback($mod,"OnResize"));
    $mod.FitCanvas();
    $mod.Restore();
    $mod.ImportHash();
    if ($mod.WS.EntryCount() === 0) {
      $mod.WS.AddExpr("sin(x)",pas["PMS.Workspace"].TWSKind.wkFuncY,{p: $mod, get: function () {
          return this.p.E2;
        }, set: function (v) {
          this.p.E2 = v;
        }},{p: $mod, get: function () {
          return this.p.P2;
        }, set: function (v) {
          this.p.P2 = v;
        }});
      $mod.RefreshEntries();
    };
    $mod.Evaluate(null);
    $mod.Replot();
  };
});
