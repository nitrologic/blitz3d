' hyperdoc.bmx

' history

' 14.6.2006 showtime for blitz3d book output
' 19.4.2006 pagebreak after heading looks crap
' 19.4.2006 blank lines should not overflow description

' 19.4.2006 .table blocks no longer split
' 16.4.2006 enable safari debug magic: defaults write com.apple.Safari IncludeDebugMenu 1
' 14.4.2006 added paginator for pdf publishing
' 14.4.2006 reads .txt chapter based documents and writes .html

Strict

Global Doc:THyperDoc=New THyperDoc

'Doc.ReadDoc "editor.txt"
'Doc.ReadDoc "blitzbasic.txt"
'Doc.ReadDoc "blitz2d.txt"
Doc.ReadDoc "system.txt"
'Doc.ReadDoc "blitz3d.txt"
'Doc.ReadDoc "examples.txt"
'Doc.ReadDoc "blitz3dsdk.txt"
'Doc.ReadDoc "appendix.txt"
'Doc.PublishToHTML "blitz3dmanual.html"

Doc.Publish

'Doc.Dump

End

Type TChapter
	Field id$,name$
	Field doc:TList=New TList
	Field chapters:TList=New TList
End Type

Type TIndex
	Field	name$,desc$	
	Method Compare(other:Object)
		Local i:TIndex=TIndex(other)
		Return desc.Compare(i.desc)
	End Method
End Type

Type THyperDoc
	Field chapterlist:TList=New TList
	Field booklist:TList=New TList
	Field indexlist:TList=New TList
	Field streamstack:TList=New TList

	Field docgui:TDocGui
	
	Method Dump()
		Local book:TChapter
		Local chapter:TChapter
		Local section:TChapter
		Local line$
		
		For book=EachIn booklist
			For chapter=EachIn book.chapters			
				For section=EachIn chapter.chapters
					For line=EachIn section.doc
						Print line+"*"
					Next
				Next			
			Next
		Next				
	End Method
			
	Method Publish()
		Local book:TChapter
		Local chapter:TChapter
		Local section:TChapter
		Local output:TStream
		
		output=WriteFile("manual.html")
		output.writeline "<html>"
		output.writeline "<head>"
		output.writeline "<title>Blitz3D Programming Manual</title>"
		output.writeline "<link rel=~qstyleSheet~q href=~qbbdoc.css~q type=~qtext/css~q>"
		output.writeline "</head>"
		output.writeline "<body>"
		docgui=New TDocGUI.Create()			
		For book=EachIn booklist
'			output.writeline "<h2 id=~q"+book.id+"~q>"+book.name+"</h2>"
			For chapter=EachIn book.chapters
				PreProcess chapter
				PaginateDoc chapter,output
			Next
		Next				
		output.writeline "</body>"
		output.writeline "</html>"
	End Method	
	
	Field code,descr,args,desc,row,hint,warning,table,also,par
	Field oldcode,olddescr,oldargs,olddesc,oldrow,oldhint,oldwarning,oldtable,oldalso,oldpar

' resets section.doc somehow...
	
	Method PreProcess(chapter:TChapter)
		Local section:TChapter
		Local l$,ll$
		Local dlist:TList

		For section=EachIn chapter.chapters
			l$=""
			dlist=New TList
			For ll=EachIn section.doc
				If (ll.length>0 And (ll[..1]="." Or ll[..1]=":") And l="")
'					DebugLog "ll="+ll+" when l="+l
'					dlist.addlast "ll="+ll+" when l="+l	'SHIT"
				Else
					dlist.addlast l
				EndIf
				l=ll
			Next
			dlist.addlast l			
			section.doc=dlist
		Next
	End Method

	Method PaginateDoc(chapter:TChapter,output:TStream)
		Local section:TChapter
		Local page$
		Local newpage$
		Local height
		Local l$,ll$
		Local justbroke

		For section=EachIn chapter.chapters
			l$=""
			For ll=EachIn section.doc
					
				If Not l$
					oldcode=code
					olddescr=descr
					oldargs=args
					olddesc=desc
					oldhint=hint
					oldwarning=warning
					oldtable=table
					oldalso=also
					oldpar=par
				EndIf			
				l:+ConvertLine(ll,section)
				If table Continue		
	'			WriteLine output,l
	'			Print l
	'			AddLine l				
				newpage$=page$+"~n"+l$
				height=docgui.measureheight(newpage)
'				DebugLog "height="+height
				If height>1500
					page:+endpage()
'					Print "**************************************************"
'					Print page
'					Print "**************************************************"
					If output
						output.WriteLine page+endpage()
						output.WriteLine "---turn page---<p>"
					EndIf
					page=startpage()+l$
					justbroke=True
				Else
					page=newpage
					justbroke=False
				EndIf
				
				l=""
			Next
		Next
		l=EndBlock(True)
		If output
			output.WriteLine page
			output.WriteLine l
			output.WriteLine "---new chapter---<p>"
		EndIf
'		WriteLine output,l
	End Method
	
	Method EndPage$()
		Local out$
		If oldargs out="</table>"
		If oldcode out="</pre>~n"
		If oldrow out:+"</td></tr>~n"
		If oldwarning out:+"</div>~n"
		If oldhint out:+"</div>~n"
		If olddescr out:+"</tbody></table>~n"
		Return out
	End Method
	
	Method StartPage$()
		Local out$
		If olddescr
			out="<table class=~qdoc~q cellspacing=~q3~q width=~q100%~q><tbody>~n"
		EndIf
		If olddesc
			out:+"<tr><td class=~qdocleft~q width=~q1%~q>Description continued</td><td class=~qdocright~q>"
		EndIf		
		If oldargs 
			out:+"<tr><td class=~qdocleft~q width=~q1%~q>Args continued...</td><td class=~qdocright~q>~n"
			out:+"<table class=~qarg~q>~n"
		EndIf
		If oldcode 
			out:+"<tr><td class=~qdocleft~q width=~q1%~q>Example continued...</td><td class=~qdocright~q>~n"
			out:+"<pre>~n"
		EndIf
		If oldwarning
			out:+"<div class=~qwarning~q>"
		EndIf
		If oldhint
			out:+"<div class=~qhint~q>"
		EndIf		
		Return out
	End Method
				
	Method EndBlock$(endtable=False)
		Local out$
		If args out="</table>";args=False
		If code out="</pre>~n";code=False
		If desc desc=False
		If row out:+"</td></tr>~n";row=False
		If warning out:+"</div>~n";warning=False
		If hint out:+"</div>~n";hint=False
		If endtable And descr 
			out:+"</tbody></table>~n";descr=False
		EndIf
		If also also=False
		If par par=False
		Return out
	End Method
	
	Method ConvertLine$(ln$,section:TChapter)
		
		Local ident$,proto$,out$,t$,k$
	
		out=""
		If Not ln 
			If table table=0;Return "</table><p>"
			If code Return ""
			par=True
			Return
	'		Return "<p>"
		EndIf
		
		ln=AddAnchors(ln)
	
		If ln[..1]="+"
			ident=ln[1..]
			AddIndex ident,ident
			out="<h4 id=~q"+section.id+"~q>"+ident+"</h4>"
			Return out
		EndIf
	
		If ln[..1]=":"
			proto$=ln[1..].Trim()
			Local i=-1
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
			
			ident$=proto[..i]		
			ident=ident.Replace("_"," ")
			
			Local isfunc=(proto.Find("(")>=0)
			
			proto=proto[i..].Trim()
			proto=proto.Replace( " ","" )
			proto=proto.Replace( "(","( " )
			proto=proto.Replace( ")"," )" )
	'		out:+"<h3>"+ident+" "+proto+"</h3>"
			out=EndBlock(True)
			
			If isfunc
				AddIndex ident,ident+" Function"
			Else
				AddIndex ident,ident+" Command"
			EndIf
			
	'		out:+"<a name=~q"+ident+"~q>"
			out:+"<table class=~qdoc~q id=~q"+ident.tolower()+"~q cellspacing=~q3~q width=~q100%~q><tbody>"
			out:+"<tr><td class=~qdoctop~q colspan=~q2~q>"+ident+" "+proto+"</td></tr>"
			descr=True
			code=False
			Return out
		EndIf
		
		
		Select ln
		Case ".warning"
			warning=1
			Return "<div class=~qwarning~q>"
		Case ".hint"
			hint=1
			Return "<div class=~qhint~q>"
		Case ".table"
			table=1
			Return "<table class=~qdata~q>"
		Case ".args"
			out=EndBlock()
			out:+"<tr><td class=~qdocleft~q width=~q1%~q>Arguments</td><td class=~qdocright~q>"
			row=True
			out:+"<table class=~qarg~q>~n"
			args=True
			Return out
		Case ".desc"
			out=EndBlock()
			out:+"<tr><td class=~qdocleft~q width=~q1%~q>Description</td><td class=~qdocright~q>"
			row=True
			desc=True
			Return out
		Case ".also"
			out=EndBlock()
			out:+"<tr><td class=~qdocleft~q width=~q1%~q>See Also</td><td class=~qdocright~q>"
			also=True
			Return out
		Case ".code"
			out=EndBlock()
			out:+"<tr><td class=~qdocleft~q width=~q1%~q>Example</td><td class=~qdocright~q>"
			row=True
			out:+"<pre>~n"
			code=True
			Return out
		Case ".endcode"
			Return EndBlock()
		End Select
		
		If code Return ln
		
		If table
			If table=1
				ln="<tr><th class=data>"+ln.replace(",","</th><th class=data>")+"</th></tr>"
				table=2
			Else
				ln="<tr><td class=data>"+ln.replace(",","</td><td class=data>")+"</td></tr>"
			EndIf
		EndIf
	
		If args
			Local i1=ln.Find( "-" )
			Local i2=ln.Find( "=" )
			If i1=-1 i1=ln.length
			If i2=-1 i2=ln.length
			Local i=Min(i1,i2)
			If i<ln.length
				Local n$=ln[..i].Trim()
				Local t$=ln[i+1..].Trim()
				ln="<tr><td class=argname>"+n+"</td><td>"+t+"</td></tr>"						
	'			ln=n+":"+t+"<br>"
			Else
				Print "~t~targerr:"+ln
			EndIf
		EndIf
		
		If also
			ln=ln.Replace(".","")
			ln=ln.Replace(",",";")
			ln=ln.Replace(" ","")
			ln=ln.Replace(";"," @")
			ln=addanchors("@"+ln)
	'		Print "also:"+ln
		EndIf
		
		If par
			ln="<p>"+ln
			par=False
		EndIf	
		
		Return ln
	End Method

	Method PublishToHTML(filename$)
		Local book:TChapter
		Local chapter:TChapter
		Local section:TChapter
		Local index:TIndex
		Local output:TStream
		
		output=WriteFile(filename)
		
		output.writeline "<html>"
		output.writeline "<head>"
		output.writeline "<title>Blitz3D Programming Manual</title>"
		output.writeline "<link rel=~qstyleSheet~q href=~qbbdoc.css~q type=~qtext/css~q>"
		output.writeline "</head>"

		output.writeline "<body>"

		output.writeline "<img src=~qdragon.jpg~q>"
		output.writeline "<h1>Blitz3D Programming Manual</h1>"
		
		output.writeline "<ul>"
		For book=EachIn booklist
			output.writeline "<li><a href=~q#"+book.id+"~q>"+book.name+"</a></li>"
		Next
		output.writeline "</ul>"
		
		output.writeline "<h2>Quick Contents</h2>"
		output.writeline "<ul>"
		For book=EachIn booklist
			output.writeline "<li><a href=~q#"+book.id+"~q>"+book.name+"</a></li>"
			output.writeline "<ul>"
			For chapter=EachIn book.chapters
				output.writeline "<li><a href=~q#"+chapter.id+"~q>"+chapter.name+"</a></li>"
			Next
			output.writeline "</ul>"
		Next
		output.writeline "</ul>"
		
		output.writeline "<h2>Contents</h2>"
		output.writeline "<ul>"
		For book=EachIn booklist
			output.writeline "<li><a href=~q#"+book.id+"~q>"+book.name+"</a></li>"
			output.writeline "<ul>"
			For chapter=EachIn book.chapters
				output.writeline "<li><a href=~q#"+chapter.id+"~q>"+chapter.name+"</a></li>"
				output.writeline "<ul>"
				For section=EachIn chapter.chapters
					output.writeline "<li><a href=~q#"+section.id+"~q>"+section.name+"</a></li>"
				Next
				output.writeline "</ul>"
			Next
			output.writeline "</ul>"
		Next
		output.writeline "</ul>"
		
		For book=EachIn booklist
			output.writeline "<h2 id=~q"+book.id+"~q>"+book.name+"</h2>"
			For chapter=EachIn book.chapters
				output.writeline "<h3 id=~q"+chapter.id+"~q>"+chapter.name+"</h3>"		
				For section=EachIn chapter.chapters
					WriteDoc output,section
				Next
			Next
		Next
		
		SortList indexlist
		
		output.writeline "<h2>Index</h2>"
		output.writeline "<ul>"
		For index=EachIn indexlist
			output.writeline "<li><a href=~q#"+index.name+"~q>"+index.desc+"</a></li>"
		Next
		output.writeline "</ol>"
		
		output.writeline "</body>"
		
		CloseFile output
	End Method
	
	Method WriteDoc(output:TStream,section:TChapter)
		Local l$
		For l=EachIn section.doc
			l=ConvertLine(l,section)
			WriteLine output,l
		Next
		l=EndBlock(True)
		WriteLine output,l
	EndMethod

	Method AddIndex:TIndex(n$,d$)
		Local index:TIndex
		n=n.replace(" ","")
		n=n.tolower()
		index=New TIndex
		index.name=n
		index.desc=d
		indexlist.addlast index
		Return index
	End Method
	
	Method PushStream(s:TStream)
		streamstack.AddLast s
	End Method
	
	Method PopStream:TStream()
		If streamstack.isEmpty() Return Null
		Return TStream(streamstack.RemoveLast())
	End Method
			
	Method ReadDoc(path$)
		Local file:TStream
		Local book:TChapter
		Local chapter:TChapter
		Local section:TChapter
		Local l$,a$
				
		file=ReadFile(path)	
	'	While Not Eof(file)
		While True
			If Eof(file)
				file=PopStream()
				If Not file Exit
			EndIf
			l$=file.ReadLine()	
			If l[..8]=".include"
				l=l[9..]
				PushStream file
				file=ReadFile(l)
				If Not file RuntimeError ".include file not found in "+path
				Continue
			EndIf
			If l[..3]=":::"
				a$=l[3..]
				AddIndex(a,a)
				book=New TChapter
				book.name=a
				a=a.replace(" ","").toLower()
				book.id=a
				booklist.AddLast book
				Continue
			EndIf
			If l[..2]="::"
				a$=l[2..]
				AddIndex(a,a)
				chapter=New TChapter
				chapter.name=a
				a=a.replace(" ","").toLower()
				chapter.id=a
				chapterlist.AddLast chapter
				book.chapters.AddLast chapter
				Continue
			EndIf
			If l[..1]=":"
				a$=l[1..]
				Local p=a.find(" ")
				Local q=a.find("(")
				Local r=a.find(".")
				If p=-1 p=a.length
				If q=-1 q=p
				If p>q p=q
				If r=-1 r=p
				If p>r p=r
				If p>0 a=a[..p]
	'			AddIndex(a,a)
				section=New TChapter
				section.name=a.replace("_"," ")
				section.id=a.ToLower()
				section.doc.AddLast l
				chapter.chapters.AddLast section
				Continue
			EndIf
			If l[..1]="+"
				a$=l[1..]
				section=New TChapter
				section.name=a
				a=a.replace(" ","")
				section.id=a.ToLower()
				section.doc.AddLast l
				chapter.chapters.AddLast section
				Continue
			EndIf
			If section
				section.doc.AddLast l
			EndIf		
		Wend
	End Method
	
	Function isChar(c$)
		If c="_" Return True
		Local a=Asc(c$)
		If a>64 And a<91 Return True
		If a>92 And a<127 Return True
		If a>47 And a<58 Return True
	End Function
	
	Function AddAnchors$(ln$)
		Local p,q,t$
		While True
			p=ln.Find("@",p)
			If p=-1 Exit
			Local q=p+1
			While ischar(ln[q..q+1])
				q:+1
			Wend
			t$=ln[p+1..q]		
			ln=ln[..p]+"<a href=#"+t.tolower()+"~q>"+t+"</a>"+ln[q..]
			p=p+t.length*2+16
		Wend
		Return ln
	End Function

End Type

Type TDocGui
	Field window:TGadget
	Field htmlview:TGadget
	
	Method Create:TDocGui()
		window=CreateWindow("DocShop",220,20,1024,GadgetHeight(Desktop())-60)
		htmlview=CreateHTMLView(0,0,ClientWidth(window),ClientHeight(window),window,HTMLVIEW_NONAVIGATE)					
		Return Self
	End Method
	
	Method MeasureHeight(page$)
		Local file:TStream
		file=WriteFile("temppage.html")
		If file=Null RuntimeError "file error"
		WriteLine file,"<html><head><link rel=~qstyleSheet~q href=~qbbdoc.css~q type=~qtext/css~q></head>"
		WriteLine file,"<body onload=~qwindow.location=window.document.body.scrollHeight;~q>"
		WriteLine file,"<div class=divpage>"
		WriteLine file,page
		WriteLine file,"</div></body>"
		CloseFile file		
'		HtmlViewGo htmlview,"file://"+CurrentDir$()+		"/test.html"
		HtmlViewGo htmlview,"file://"+CurrentDir$()+		"/temppage.html"
		While WaitEvent()
'			Print currentevent.ToString()
			Select EventID()
			Case EVENT_GADGETACTION
				Local t$=String(EventExtra())
				t=t.replace("\","/")
				Local h=t.findlast("/")
				If h>0
					t=t[h+1..]
					If Int(t) Return Int(t)
				EndIf
				Print "t$="+t$
			Case EVENT_WINDOWCLOSE
				End
			End Select
		Wend
	End Method
End Type
