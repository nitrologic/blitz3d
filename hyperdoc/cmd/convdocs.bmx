
Strict

For Local infile$=EachIn LoadDir(".")

	Local ext$=ExtractExt( infile )
	If ext<>"bbdoc" Continue
	
	Print "Converting..."+infile
	
	Local in:TStream=ReadStream( infile )
	If Not in Throw "Unable to read "+infile
	
	Local outfile$=StripExt(infile)+".tex"
	Local out:TStream=WriteStream( outfile )
	If Not out Throw "Unable to write "+outfile
	
	Local descr,code,args
	
	While Not in.eof()

		Local ln$=in.ReadLine().Trim()
		If Not ln
			If Not code out.WriteLine ""
			Continue
		EndIf
		
		If ln[..1]=":"
			If descr
				out.WriteLine "\end{description}"
				descr=False
			EndIf
			Local proto$=ln[1..].Trim(),i=-1
			Repeat
				i:+1
				If i=proto.length Exit
				Local c=proto[i]
				If c=Asc("_") Continue
				If c>=Asc("0")And c<=Asc("9") Continue
				If c>=Asc("A")And c<=Asc("Z") Continue
				If c>=Asc("a")And c<=Asc("z") Continue
				Exit
			Forever
			Local ident$=proto[..i]
			proto=proto[i..].Trim()
			proto=proto.Replace( " ","" )
			proto=proto.Replace( "(","( " )
			proto=proto.Replace( ")"," )" )
			out.WriteLine "\index{"+ident+"}"
			out.WriteLine "\begin{description}"
			out.WriteLine "\item[Function]~~\\"
			out.WriteLine "\verb|"+ident+" "+proto+"|"
			descr=True
			code=False
			Continue
		EndIf
		
		Select ln
		Case ".args"
			args=True
			code=False
			out.WriteLine "\item[Arguments]~~\\"
			Continue
		Case ".desc"
			args=False
			code=False
			out.WriteLine "\item[Description]~~\\"
			Continue
		Case ".also"
			args=False
			code=False
			out.WriteLine "\item[See Also]~~\\"
			Continue
		Case ".code"
			args=False
			code=True
			Continue
		End Select
		
		If code Continue

'# $ % & ~ _ ^ \ { }
'		ln=ln.Replace( "\","$\backslash$" )
		ln=ln.Replace( "#","\#" )
		ln=ln.Replace( "$","\$" )
		ln=ln.Replace( "%","\%" )
		ln=ln.Replace( "&","\&" )
		ln=ln.Replace( "~~","\~~" )
		ln=ln.Replace( "_","\_" )
		ln=ln.Replace( "^","\^" )
		ln=ln.Replace( "{","\{" )
		ln=ln.Replace( "}","\}" )

		If args
			Local i1=ln.Find( "-" )
			Local i2=ln.Find( "=" )
			If i1=-1 i1=ln.length
			If i2=-1 i2=ln.length
			Local i=Min(i1,i2)
			If i<ln.length
				Local n$=ln[..i].Trim()
				Local t$=ln[i+1..].Trim()
				ln="{\tt "+n+"} : "+t+"\\"
			EndIf
		EndIf

		out.WriteLine ln
	
	Wend
	
	If descr out.Writeline "\end{description}"
	
	out.Close
	in.Close
	
	Print "Done!"

Next

