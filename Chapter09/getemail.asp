<?xml version="1.0"?>

<vxml version="1.0" application="root.vxml">

	<var name="docEmailNum" expr="1"/>
	<var name="docEmailCount"/>
	<var name="docEmailMsgs"/>

    <form id="start">
	    <block>
			<prompt>
				<%
				rem we'll get a possibly filtered collection of emails and save them into a JavaScript array.
				rem set Session("objsession") = Server.CreateObject("MAPI.Session")
				rem Session("objsession").Logon( "Jeff Tang")

					set objInbox = Session("objsession").Inbox
					If objInbox Is Nothing Then
						Response.Write("You have no emails in your inbox")
					else
						set objMsgs = objInbox.Messages 
						set objMsgFilter = objMsgs.Filter
						if Request.QueryString("emailtype") = "newemail" then
							objMsgFilter.Unread = True
						end if
						if Request.QueryString("emailfilter") = "important" then
							objMsgFilter.Importance = 2
						elseif not Request.QueryString("emailfilter") = "none" then 
							objMsgFilter.Sender = Request.QueryString("emailfilter")
						end if 
						response.write("We have found " & objMsgs.Count & " emails you're looking for.")
					end if
				%>
			</prompt>

			<script>
				docEmailCount = <%=objMsgs.Count%>;

				docEmailMsgs = new Array();
				<%  for i=1 to objMsgs.Count 
					set objMsg = objMsgs.Item(i)
				%>
					var msg = new Object();
					msg["ID"] = "<%=objMsg.ID%>";
					msg["From"] = "<%=objMsg.Sender%>";
					msg["Subject"] = "<%=Replace(objMsg.Subject, "&", " ")%>";
					msg["TimeReceived"] = "<%=objMsg.TimeReceived%>";
					msg["Text"] = "<%=Replace(Replace(Replace(Left(objMsg.Text, 200), vbNewLine, " "), "<", ""), ">", "")%>";

					docEmailMsgs[<%=i%>] = msg;
				<% next%>
			</script>

			<if cond="docEmailCount == 0">
				<return/>
			</if>
	    </block>

		<field name="action">
			<grammar>
		    <![CDATA[
			[
				([list read] ?them) {<action read>}
				[nothing quit] {<action quit>}
				(check ?other ?[email emails]) {<action check>}
			]
			]]>
			</grammar>

			<prompt>
				What do you want to do with those emails?
			</prompt>
		
			<filled>
				<if cond="action == 'quit'">
					<prompt>Thank you for using our service. Good bye.</prompt>
					<exit/>
					<disconnect/>
				<elseif cond="action == 'check'"/>
					<return/>
				</if>
			</filled>
		</field>

		<field name="nextaction">
			<grammar>
			[previous next first last reply forward compose toplevel check quit]
			</grammar>

			<prompt>
				email number <value expr="docEmailNum"/>. 
				From <value expr="docEmailMsgs[docEmailNum][&quot;From&quot;]"/>,
				Subject is <value expr="docEmailMsgs[docEmailNum][&quot;Subject&quot;]"/>,
				Received time is <value expr="docEmailMsgs[docEmailNum][&quot;TimeReceived&quot;]"/>,
				Content is <value expr="docEmailMsgs[docEmailNum][&quot;Text&quot;]"/>.
				What do you want to do next?
			</prompt>

			<help>
				You can say previous, next, first or last to listen to another email. Or say reply, forward, or compose.
			</help>

			<filled>
				<if cond="nextaction == 'toplevel'">
					<goto next="http://www.openland.com/wrox/start.asp"/>
				<elseif cond="nextaction == 'previous'"/>
					<script>
				    <![CDATA[
						docEmailNum = docEmailNum - 1;
						if (docEmailNum < 1) 
							docEmailNum = 1;
					]]>
					</script>
					<clear namelist="nextaction"/>
				<elseif cond="nextaction == 'next'"/>
					<script>
						docEmailNum = docEmailNum + 1;
						if (docEmailNum > docEmailCount) 
							docEmailNum = docEmailCount;
					</script>
					<clear namelist="nextaction"/>
				<elseif cond="nextaction == 'first'"/>
					<script>
						docEmailNum = 1;
					</script>
					<clear namelist="nextaction"/>
				<elseif cond="nextaction == 'last'"/>
					<script>
						docEmailNum = docEmailCount;
					</script>
					<clear namelist="nextaction"/>
				<elseif cond="nextaction == 'check'"/>
					<return/>
				<elseif cond="nextaction == 'quit'"/>
					<prompt>Thank you for using our service. Good bye.</prompt>
					<exit/>
					<disconnect/>
				</if>
			</filled>
		</field>

		<!-- as a design alternative, we can use <goto next="#form_id"/> to replace <subdialog>,
			 but then we'll need to use another <goto> in that form to go back here, plus more global
			 variables to track states - all the nightmare with <goto>! with <subdialog>, it becomes 
			 a lot clearer -->
		<subdialog name="replyemail" cond="nextaction == 'reply'" src="#replyemail">
			<param name="emailid" expr="docEmailMsgs[docEmailNum][&quot;ID&quot;]"/>
			<param name="recepient" expr="docEmailMsgs[docEmailNum][&quot;From&quot;]"/>
			<filled>
				<clear namelist="nextaction replyemail"/> <!-- need to add forwardemail and composeemail here ?? -->
			</filled>
		</subdialog>

		<subdialog name="forwardemail" cond="nextaction == 'forward'" src="#forwardemail">
			<param name="emailid" expr="docEmailMsgs[docEmailNum][&quot;ID&quot;]"/>
			<filled>
				<clear namelist="nextaction forwardemail"/>
			</filled>
		</subdialog>

		<subdialog name="composeemail" cond="nextaction == 'compose'" src="#composeemail">
			<filled>
				<clear namelist="nextaction composeemail"/>
			</filled>
		</subdialog>
    </form>

	<form id="replyemail">
		<var name="emailid"/>
		<var name="recepient"/>
		<var name="uri"/>

		<block>
			<prompt>email id: <value expr="emailid"/>, recepient: <value expr="recepient"/></prompt>
		</block>

		<subdialog name="recordandupload" src="#recordandupload">
			<param name="emailid" expr="emailid"/>
		</subdialog>

		<subdialog name="sendemail" src="#sendemail">
			<param name="emailid" expr="emailid"/>
			<param name="recepient" expr="recepient"/>
			<param name="withattachment" expr="recordandupload.ifrecord"/>
			<param name="sendtype" value="reply"/>
		</subdialog>

		<block>
			<prompt cond="sendemail.result == 'success'">
				Your email has been sent.
			</prompt>

			<return/>
		</block>
	</form>

	<form id="forwardemail">
		<var name="emailid"/>
		<var name="uri"/>
		<var name="recepient"/>

		<block>
			<prompt>email id: <value expr="emailid"/></prompt>
		</block>

		<field name="towhom">
			<grammar>
			<![CDATA[
			[
				<%
				For Each addentry In Session("objSession").AddressLists.Item(1).AddressEntries
				response.write("(?to " & lcase(addentry.name) & ") {<towhom """ & addentry.name & """>}")
				Next
				%>
			]
			]]>
			</grammar>
			
			<prompt>
				To whom do you want to forward this email?
			</prompt>
			
			<help>
				Please say a name is your address book you want to forward this email to.
			</help>
		</field>

		<subdialog name="recordandupload" src="#recordandupload">
			<param name="emailid" expr="emailid"/>
		</subdialog>

		<subdialog name="sendemail" src="#sendemail">
			<param name="emailid" expr="emailid"/>
			<param name="recepient" expr="towhom"/>
			<param name="withattachment" expr="recordandupload.ifrecord"/>
			<param name="sendtype" value="forward"/>
		</subdialog>

		<block>
			<prompt cond="sendemail.result == 'success'">
				Your email has been sent.
			</prompt>

			<return/>
		</block>
	</form>

	<form id="composeemail">
		<var name="uri"/>
		<var name="recepient"/>

		<field name="towhom">
			<grammar>
			<![CDATA[
			[
				<%
				For Each addentry In Session("objSession").AddressLists.Item(1).AddressEntries
				response.write("(?to " & lcase(addentry.name) & ") {<towhom """ & addentry.name & """>}")
				Next
				%>
			]
			]]>
			</grammar>
			
			<prompt>
				To whom do you want to compose a new email?
			</prompt>
			
			<help>
				Please say a name in your address book you want to send a new email to.
			</help>
		</field>

		<subdialog name="recordandupload" src="#recordandupload">
			<param name="emailid" value="1234567890"/>
		</subdialog>

		<subdialog name="sendemail" src="#sendemail">
			<param name="emailid" value="1234567890"/>
			<param name="recepient" expr="towhom"/>
			<param name="withattachment" expr="recordandupload.ifrecord"/>
			<param name="sendtype" value="compose"/>
		</subdialog>

		<block>
			<prompt cond="sendemail.result == 'success'">
				Your email has been sent.
			</prompt>

			<return/>
		</block>
	</form>

	<form id="recordandupload">
		<var name="emailid"/>

		<field name="ifrecord" type="boolean">
			<prompt>
				Do you want to record a message as an attachment to send with this email?
			</prompt>
			<filled>
				<if cond="ifrecord == false">
					<!-- if user doesn't want to record, return immediately -->
					<return namelist="ifrecord"/>
				</if>
			</filled>
		</field>

		<!-- otherwise do the recording and uploading -->
		<record name="emailmsg" beep="true" maxtime="30s" finalsilence="2000ms">
			<prompt> 
				Please record your message after the tone.
			</prompt> 
			<noinput> 
				Sorry I did not hear anything. 
				<reprompt/> 
			</noinput> 
		</record>

		<field name="confirm" type="boolean">
			<prompt>    
				Your message is <value expr="emailmsg"/>. Do you want to keep this message?
			</prompt>
			<filled>
				<if cond="confirm">
					<prompt> 
						OK, please wait while I'm saving your message.
					</prompt>
				<else/> 
					<prompt> OK, let's try again.</prompt>
					<clear namelist="emailmsg confirm"/>
				</if>
			</filled>
		</field> 

		<subdialog name="upload" method="post" namelist="emailmsg emailid"
			src="http://www.openland.com:6666/voice/recordingsave.jsp">
			<param name="emailid" expr="emailid"/>
		</subdialog>


		<block>
			<return namelist="ifrecord"/>
		</block>
	</form>


	<form id="sendemail">
		<var name="emailid"/>
		<var name="recepient"/>
		<var name="withattachment"/>
		<var name="sendtype"/>

		<var name="result" expr="'failure'"/>

		<field name="sendconfirm" type="boolean"> 
			<prompt>
				Now I'm ready to send this message to <value expr="recepient"/>. Please confirm.
			</prompt>

			<filled>
				<if cond="sendconfirm">
					<prompt>
						Please wait while I'm delivering your message.
					</prompt>
				<else/>
					<prompt>
						Your message has been discarded.
					</prompt>
					<assign name="result" value="'discarded'"/>
					<return namelist="result"/>
				</if>
			</filled>
		</field>

		<subdialog name="sendemailasp" cond="sendconfirm" method="get" namelist="recepient emailid withattachment sendtype"
			src="http://www.openland.com/wrox/sendemail.asp">
			<filled> 
				<assign name="result" expr="sendemailasp.result"/>
			</filled>
		</subdialog>

		<block>
			<return namelist="result"/>
		</block>

	</form>

<!-- Subdialogs are useful for dividing a large document or dialog into several smaller ones, which can make it easier to maintain 
and faster to load and execute. But the main use for subdialogs is to allow documents to call each other and exchange data, without 
using CGI or other server-side mechanisms. -->

</vxml>
