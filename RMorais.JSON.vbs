Public Function JSON(prJSON) 
	JSONScapeEncode prJSON
	Set JSON = JSONConvert(prJSON,"")
End Function

Private Sub JSONScapeEncode(byref  prJSon)
		Dim Idx
		Dim Aux
		Idx=InStr(1,prJSon,"\")
		While Idx>0
				Aux=Left(prJSon,Idx-1)
				Aux =Aux & vbCr &"chr_" & asc(Mid(prJSon,Idx+1,1)) & vbCr 
				Aux=Aux &Mid(prJSon,Idx+2)
				prJSon=Aux
				Idx=InStr(1,prJSon,"\")
		Wend
End Sub

Private Function JSONScapeDecode( prJSon)
    Dim output
    Dim Aux
    Aux = Split(prJSon, vbcr)
    For Each V In Aux
        If Left(V, 4) = "chr_" Then
            output = output & chr(mid(V, 5))
        Else
            output = output & V
        End If
    Next
    JSONScapeDecode = output
End Function
 
Private Function JSONConvert(prA,prB)
    Dim output : output = null
    If left(prA, 1) = "{" Then
		Set output=JSONObj(prA)
    Else
        If Instr(prA, ":") > 0 Then
            output = JSONProperty(prA)
        End If
    End If

    If left(prB, 1) = "{" Then
		Set output=JSONObj(prB)
    Else
        If left(prB, 1) = "[" Then
            output = JSONArray(prB)
        End If
    End If
    If IsObject(output) Then
		Set JSONConvert=output
	Else
        JSONConvert = output
    End If
 End Function

Private Function JSONObj(prObj)
    Dim output
    output = null
	Set re = CreateObject("VBScript.RegExp")
    re.IgnoreCase = True
    re.Pattern = "^\{.{1,}\}$"
    If re.Test(prObj) Then
		Set output=CreateObject("Scripting.Dictionary")
		re.Pattern = "^\{"
        Aux = re.Replace(prObj, "")
        re.Pattern = "\}$"
        Aux = re.Replace(Aux, "")
        While Not Aux = ""
            Dim idx, pA, pB
            re.Pattern = "[\n\t\r]+"
            Aux = re.Replace(Aux, "")
            Aux = rtrim(ltrim(Aux))
            idx = instr(Aux, ":")
            pA = mid(Aux, 2, idx - 2)
            Aux = ltrim(rtrim(mid(Aux, idx + 1)))
            If (left(aux, 1) = "{") Then
                pB = ""
                GetStringObjJSON Aux, "{", "}", pB
					Set pB=JSONConvert(pA,pB)
					AddIPropertyJSON output, pA, pB
                ElseIf (left(aux, 1) = "[") Then
                pB = ""
                GetStringObjJSON Aux, "[", "]", pB
                    pB = JSONConvert(pA, pB)
                AddIPropertyJSON output, pA, pB
                Else
                If left(Aux, 1) = """" Then
                    idx = Instr(2, mid(Aux, 2), """") + 3
                Else
                    idx = instr(Aux, ",") - 1
                    If idx > 0 Then
                        idx = idx + 2
                    End If
                End If
                If idx > 0 Then
                    pB = left(Aux, idx - 2)
                    Aux = mid(Aux, len(pB) + 1)
                Else
                    pB = aux
                    Aux = ""
                End If
                If left(Aux, 1) = "," Then
                    Aux = mid(Aux, 2)
                End If

                If output.Exists(pA) Then
                    pA = pA & "_" & CStr(output.Count)
                End If
                AddIPropertyJSON output, pA, pB
                End If
			Wend
		End If
	   Set JSONObj=output
End Function

Private Sub AddIPropertyJSON(byRef Dic,prA,prB)
	 	If left(prA,1)="""" Then
			prA=mid(prA,2)
		End If
		If Right(prA,1)="""" Then
					prA=mid(prA,1,len(prA)-1)
		End If
   		 If Dic.Exists(prA) Then
				prA = prA & "_" & CStr(Dic.Count)
		End If
		If not (IsArray(prB) or IsObject(prB)) Then
				If left(prB,1)="""" Then
					prB=mid(prB,2)
				End If
				If Right(prB,1)="""" Then
					prB=mid(prB,1,len(prB)-1)
				End If
		End If
		Dic.Add prA, prB
End Sub

Private Sub GetStringObjJSON(prText, prRefStart, prRefEnd, ByRef prValue)
    Dim nrObj, endpos
    nrObj = ubound(split(prText, prRefStart))
    For i = 0 To nrObj - 1
        endpos = instr(1, prText, prRefEnd)
        prValue = prValue + left(prText, endpos)
        prText = mid(prText, endpos + 1)
        If ubound(split(prValue, prRefStart)) = ubound(split(prValue, prRefEnd)) Then
            i = nrObj + 1
        End If
    Next
End Sub

Private Function JSONArray(prObj)
    ' Matrix will be processed here, but I do not need it now and I'll let it go later.
    Dim output
   	Set re = CreateObject("VBScript.RegExp")
    re.IgnoreCase = True
    re.Pattern = "^\[.{1,}\]$"
    If re.Test(prObj) Then
        output = split(replace(mid(prObj, 2, len(prObj) - 2), """", ""), ",")
    End If
    JSONArray = output
End Function