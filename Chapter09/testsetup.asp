<%    
set Session("objsession") = Server.CreateObject("MAPI.Session")

rem there are two ways to test CDO with IIS/ASP – both use the CDO Logon method.
rem On NT 4, either method will work fine; on Win2K, only the 2nd method works.
  
rem first, use a profile name with the Logon method
Session("objsession").Logon("your default profile")

rem if the above line doesn’t work, comment it and uncomment the following lines:
rem Session("objsession").Logon "", "", False, True, 0, True, 
rem "exchangeServerName" & vbLF & "exchangeE-MailName"  
%>
