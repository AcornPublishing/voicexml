<?xml version="1.0"?>

<vxml version="1.0" application="root.vxml">

	<var name="docAppntNum" expr="1"/>
	<var name="docAppntCount"/>
	<var name="docAppnts"/>

    <form id="start">
        <block>
            <prompt>
				<!-- caltype can be day, week, or month -->
				<!-- time can be 20010301 or or CURRENT (for today or this week or this month) or one of the 12 months -->
			
				<%
				rem set Session("objsession") = Server.CreateObject("MAPI.Session")
				rem Session("objsession").Logon("Jeff Tang")
				
				set objCalFold = Session("objsession").GetDefaultFolder(CdoDefaultFolderCalendar)
				Set collAppointments = objCalFold.Messages

				set msgFilter = collAppointments.Filter
				set mfFields = msgFilter.Fields

				if Request.QueryString("caltype") = "today" then
					call mfFields.Add(&H00600040, date+1)
					call mfFields.Add(&H00610040, date)
				
				elseif Request.QueryString("caltype") = "yesterday" then
					call mfFields.Add(&H00600040, date)
					call mfFields.Add(&H00610040, date-1)

				elseif Request.QueryString("caltype") = "tomorrow" then
					call mfFields.Add(&H00600040, date+2)
					call mfFields.Add(&H00610040, date+1)

				elseif Request.QueryString("caltype") = "day" then
					ayear = Left(Request.QueryString("caltime"), 4)
					amonth = Mid(Request.QueryString("caltime"), 5, 2)
					aday = Right(Request.QueryString("caltime"), 2)

					call mfFields.Add(&H00600040, CDate(amonth & "/" & aday & "/" & ayear)+1)
					call mfFields.Add(&H00610040, CDate(amonth & "/" & aday & "/" & ayear))

				elseif Request.QueryString("caltype") = "thisweek" then
					if weekday(date) = 1 then ' today is sunday - this week means this past week
						call mfFields.Add(&H00600040, date + 1)
						call mfFields.Add(&H00610040, date - 6)
					else ' sunday - saturday: 1 - 7
						call mfFields.Add(&H00600040, date + 9 - weekday(date))
						call mfFields.Add(&H00610040, date + 2 - weekday(date))
					end if
				
				elseif Request.QueryString("caltype") = "lastweek" then
					if weekday(date) = 1 then 
						call mfFields.Add(&H00600040, date + 1)
						call mfFields.Add(&H00610040, date - 6)
					else 
						call mfFields.Add(&H00600040, date + 2 - weekday(date))
						call mfFields.Add(&H00610040, date - 7 - weekday(date))
					end if

				elseif Request.QueryString("caltype") = "nextweek" then
					if weekday(date) = 1 then 
						call mfFields.Add(&H00600040, date + 8)
						call mfFields.Add(&H00610040, date + 1)
					else 
						call mfFields.Add(&H00600040, date + 16 - weekday(date))
						call mfFields.Add(&H00610040, date + 9 - weekday(date))
					end if

				elseif Request.QueryString("caltype") = "week" then
					ayear = Left(Request.QueryString("caltime"), 4)
					amonth = Mid(Request.QueryString("caltime"), 5, 2)
					aday = Right(Request.QueryString("caltime"), 2)
					wd = Weekday(CDate(amonth & "/" & aday & "/" & ayear))
					
					if wd = 1 then ' it's sunday
						call mfFields.Add(&H00600040, CDate(amonth & "/" & aday & "/" & ayear) + 8)
						call mfFields.Add(&H00610040, CDate(amonth & "/" & aday & "/" & ayear) + 1)
					else ' sunday - saturday: 1 - 7
						call mfFields.Add(&H00600040, CDate(amonth & "/" & aday & "/" & ayear) + 9 - wd)
						call mfFields.Add(&H00610040, CDate(amonth & "/" & aday & "/" & ayear) + 2 - wd)
					end if
					
				elseif Request.QueryString("caltype") = "month" then
					amonth = Request.QueryString("caltime")
					if amonth="january" then
						call mfFields.Add(&H00600040, #1/31/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #1/1/2001 12:00:00 AM#)

					elseif amonth="february" then
						call mfFields.Add(&H00600040, #2/28/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #2/1/2001 12:00:00 AM#)

					elseif amonth="march" then
						call mfFields.Add(&H00600040, #3/31/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #3/1/2001 12:00:00 AM#)

					elseif amonth="april" then
						call mfFields.Add(&H00600040, #4/30/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #4/1/2001 12:00:00 AM#)

					elseif amonth="may" then
						call mfFields.Add(&H00600040, #5/31/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #5/1/2001 12:00:00 AM#)

					elseif amonth="june" then
						call mfFields.Add(&H00600040, #6/30/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #6/1/2001 12:00:00 AM#)

					elseif amonth="july" then
						call mfFields.Add(&H00600040, #7/31/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #7/1/2001 12:00:00 AM#)

					elseif amonth="august" then
						call mfFields.Add(&H00600040, #8/31/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #8/1/2001 12:00:00 AM#)

					elseif amonth="september" then
						call mfFields.Add(&H00600040, #9/30/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #9/1/2001 12:00:00 AM#)

					elseif amonth="october" then
						call mfFields.Add(&H00600040, #10/31/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #10/1/2001 12:00:00 AM#)

					elseif amonth="november" then
						call mfFields.Add(&H00600040, #11/30/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #11/1/2001 12:00:00 AM#)

					elseif amonth="december" then
						call mfFields.Add(&H00600040, #12/31/2001 11:59:59 PM#)
						call mfFields.Add(&H00610040, #12/1/2001 12:00:00 AM#)
					end if
				
				end if		

				nCount = 0

				For Each objItem In collAppointments
					nCount = nCount + 1
				Next

				response.write("We have found " & nCount & " appointments you're looking for.")

				%>
            </prompt>

			<script>
				docAppntCount = <%=nCount%>;

				docAppnts = new Array();
				<%  
					i = 0
					For Each objItem In collAppointments
					i = i + 1
				%>
						var appnt = new Object();
						appnt["StartTime"] = "<%=objItem.StartTime%>";
						appnt["EndTime"] = "<%=objItem.EndTime%>";
						appnt["Subject"] = "<%=Replace(objItem.Subject, "&", " ")%>";
						appnt["Text"] = "<%=objItem.Text%>";

						docAppnts[<%=i%>] = appnt;
				<% next%>
			</script>

			<if cond="docAppntCount == 0">
				<goto next="http://www.openland.com/wrox/start.asp"/>
			</if>

        </block>

		<field name="action">
			<grammar>
			[previous next first last forward schedule new check toplevel quit]
			</grammar>

			<prompt>
				Appointment number <value expr="docAppntNum"/>. 
				Start time <value expr="docAppnts[docAppntNum][&quot;StartTime&quot;]"/>,
				End time is <value expr="docAppnts[docAppntNum][&quot;EndTime&quot;]"/>,
				Subject is <value expr="docAppnts[docAppntNum][&quot;Subject&quot;]"/>,
				Text is <value expr="docAppnts[docAppntNum][&quot;Text&quot;]"/>,
				What do you want to do next?
			</prompt>

			<help>
				You can say previous, next, first or last to listen to another appointment. 
			</help>

			<filled>
				<if cond="action == 'toplevel'">
					<goto next="http://www.openland.com/wrox/start.asp"/>
				<elseif cond="action == 'previous'"/>
					<script>
				    <![CDATA[
						docAppntNum = docAppntNum - 1;
						if (docAppntNum < 1) 
							docAppntNum = 1;
					]]>
					</script>
					<clear namelist="action"/>
				<elseif cond="action == 'next'"/>
					<script>
						docAppntNum = docAppntNum + 1;
						if (docAppntNum > docAppntCount) 
							docAppntNum = docAppntCount;
					</script>
					<clear namelist="action"/>
				<elseif cond="action == 'first'"/>
					<script>
						docAppntNum = 1;
					</script>
					<clear namelist="action"/>
				<elseif cond="action == 'last'"/>
					<script>
						docAppntNum = docAppntCount;
					</script>
					<clear namelist="action"/>
				<elseif cond="action == 'schedule' || action == 'new'"/>
					<goto next="#newappnt"/>
				<elseif cond="action == 'check'"/>
					<return/>
				<elseif cond="action == 'quit'"/>
					<prompt>Thank you for using our service. Good bye.</prompt>
					<exit/>
					<disconnect/>
				</if>
			</filled>
		</field>
    </form>

	<form id="newappnt">
		<var name="subjectinput" expr="''"/>
		<var name="textinput" expr="''"/>

		<field name="startdate" type="date">
			<prompt>
				What's the start date of your new appointment?
			</prompt>
		</field>

		<field name="starttime" type="time">
			<prompt>
				What's the start time of your new appointment?
			</prompt>
		</field>

		<field name="enddate" type="date">
			<prompt>
				What's the end date of your new appointment?
			</prompt>
		</field>

		<field name="endtime" type="time">
			<prompt>
				What's the end time of your new appointment?
			</prompt>
		</field>

		<field name="subject">
			<grammar>
			[a b c d e f g h i j k l m n o p q r s t u v w x y z space finished]
			</grammar>

			<prompt cond="subjectinput == ''">
				Please spell your subject now. After you're done, say finished.
			</prompt>

			<filled>
				<if cond="subject == 'finished'">
					<prompt>subject is <value expr="subjectinput"/></prompt>
					<assign name="subject" expr="subjectinput"/>
				<elseif cond="subject == 'space'"/>
					<assign name="subjectinput" expr="subjectinput + ' '"/>
					<clear namelist="subject"/>
				<else/>
					<assign name="subjectinput" expr="subjectinput + subject"/>
					<prompt><value expr="subject"/></prompt>
					<clear namelist="subject"/>
				</if>
			</filled>
		</field>

		<field name="text">
			<grammar>
			[a b c d e f g h i j k l m n o p q r s t u v w x y z space finished]
			</grammar>

			<prompt cond="textinput == ''">
				Please spell your text now. After you're done, say finished.
			</prompt>

			<filled>
				<if cond="text == 'finished'">
					<prompt>subject is <value expr="textinput"/></prompt>
					<assign name="text" expr="textinput"/>
				<elseif cond="text == 'space'"/>
					<assign name="textinput" expr="textinput + ' '"/>
					<clear namelist="text"/>
				<else/>
					<assign name="textinput" expr="textinput + text"/>
					<prompt><value expr="text"/></prompt>
					<clear namelist="text"/>
				</if>
			</filled>
		</field>

		<block><prompt>startdate=<value expr="startdate"/>, starttime=<value expr="starttime"/>,
			enddate=<value expr="enddate"/>, endtime=<value expr="endtime"/>. </prompt></block>

		<subdialog name="scheduleappntasp" method="get" namelist="startdate starttime enddate endtime subject text"
			src="http://www.openland.com/wrox/scheduleappointment.asp"/>
	
		<field name="another" type="boolean">
			<prompt>
				Do you want to schedule another appointment?
			</prompt>
			<filled>
				<if cond="another">
					<clear/>
				<else/>
					<return/>
				</if>
			</filled>
		</field>

	</form>

<%rem Session("objsession").Logoff%>

</vxml>
