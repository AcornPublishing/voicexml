<?xml version="1.0"?>

<vxml version="1.0" application="root.vxml">

    <form id="start">
        <block>
            <prompt>
				<%
				rem set Session("objsession") = Server.CreateObject("MAPI.Session")
				rem Session("objsession").Logon("Jeff Tang")
				
				set objCalFold = Session("objsession").GetDefaultFolder(CdoDefaultFolderCalendar)
				set collAppointments = objCalFold.Messages
				set appntItem = collAppointments.Add

				rem the following add an attachment code works fine.
				rem set objAtt = appntItem.Attachments.Add
				rem objAtt.Name = "MessageFromJeffTang.wav"
				rem objAtt.ReadFromFile("c:\1234567890.wav")

				startdate = Request.QueryString("startdate")
				starttime = Request.QueryString("starttime")
				enddate = Request.QueryString("enddate")
				endtime = Request.QueryString("endtime")

				startyear = Left(startdate, 4)
				startmonth = Mid(startdate, 5, 2)
				startday = Right(startdate, 2)
				starthour = Left(starttime, 2)
				startmin = Mid(starttime, 3, 2)
				if Right(starttime, 1) = "a" then
					startampm = "AM"
				else
					startampm = "PM"
				end if

				endyear = Left(enddate, 4)
				endmonth = Mid(enddate, 5, 2)
				endday = Right(enddate, 2)
				endhour = Left(endtime, 2)
				endmin = Mid(endtime, 3, 2)
				if Right(endtime, 1) = "a" then
					endampm = "AM"
				else
					endampm = "PM"
				end if

				appntItem.StartTime = CDate(startmonth & "/" & startday & "/" & startyear & " " & starthour & ":" & startmin & ":" & "00 " & startampm)
				appntItem.EndTime = CDate(endmonth & "/" & endday & "/" & endyear & " " & endhour & ":" & endmin & ":" & "00 " & endampm)
				appntItem.Subject = Request.QueryString("subject")
				appntItem.Text = Request.QueryString("text")

				appntItem.Update
				
				response.write("Your new appointment has been scheduled.")
				%>
            </prompt>

			<return/>
		</block>
	</form>

<% rem Session("objsession").Logoff%>

</vxml>
