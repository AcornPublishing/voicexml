<?xml version="1.0"?>

<vxml version="1.0" application="root.vxml">

    <form id="start">
		<var name="result"/>

	    <block>
			<prompt>
				<%
					rem set Session("objsession") = Server.CreateObject("MAPI.Session")
					rem Session("objsession").Logon( "Jeff Tang")

					response.write("recepient is: " & Request.QueryString("recepient"))
					response.write("email id is: " & Request.QueryString("emailid"))
					response.write("withattachment is: " & Request.QueryString("withattachment"))
					response.write("send type is: " & Request.QueryString("sendtype"))

					if Request.QueryString("sendtype") = "compose" then
						Set objMsg = Session("objSession").Outbox.Messages.Add
					elseif Request.QueryString("sendtype") = "reply" then
						set objMsgOrig = Session("objsession").GetMessage(Request.QueryString("emailid"))
						set objMsg = objMsgOrig.Reply()
					elseif Request.QueryString("sendtype") = "forward" then
						set objMsgOrig = Session("objsession").GetMessage(Request.QueryString("emailid"))
						set objMsg = objMsgOrig.Forward()
					end if

					if Request.QueryString("withattachment") = "true" then
						Set objAtt = objMsg.Attachments.Add
						objAtt.Name = "MessageFromJeffTang.wav"
						objAtt.ReadFromFile("c:\" & Request.QueryString("emailid") & ".wav")
					end if
 
					' create the recipient - if this is reply, then no need to set recepient 
					if Not Request.QueryString("sendtype") = "reply" then
						Set objOneRecip = objMsg.Recipients.Add
						objOneRecip.Name =  Request.QueryString("recepient")
						objOneRecip.Resolve
					end if

					objMsg.Update
					objMsg.Send 

					rem Session("objsession").Logoff

				%>
			</prompt>

			<assign name="result" expr="'success'"/>
			<return namelist="result"/>
		</block>
	</form>

</vxml>
