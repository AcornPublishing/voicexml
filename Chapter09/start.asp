<?xml version="1.0"?>

<%      
set Session("objsession") = Server.CreateObject("MAPI.Session")
Session("objsession").Logon( "Jeff Tang")
%>

<vxml version="1.0" application="root.vxml">

<form id="start">
  <field name="service">
    <grammar>
    <![CDATA[
    [
      (?check ?my [email messages]) {<service email>}
      (?check ?my [calendar appointments diary schedule]) {<service calendar>}
    ]
    ]]>
    </grammar>
      <prompt>
        Welcome to Jeff's Voice Email. Which service do you require?
      </prompt>
    <help>
      You can check your email or calendar.
    </help>
    <filled>
      <if cond="service == 'email'">
        <goto next="#email"/>
      <else/> <!-- service is calendar -->
        <goto next="#calendar"/>
      </if>
    </filled>
  </field>
</form>



<form id="email">
  <field name="emailtype">
    <grammar>
    <![CDATA[
    [
      (?only new [emails email]) {<emailtype newemail>}
      (all ?the [email emails]) {<emailtype allemail>}
      calendar {<emailtype calendar>}
    ]
    ]]>
    </grammar>
      <prompt>
        Do you want to check only new emails or all the emails?
      </prompt>
    <help>
      You can say new emails or all emails.
    </help>
    <filled>
      <if cond="emailtype == 'calendar'">
        <goto next="#calendar"/>
      </if>
    </filled>
  </field>


  <field name="emailfilter">
    <grammar>
        <![CDATA[
    [
      (important ?[email emails]) {<emailfilter important>}
      [no (all ?the ?new [email emails])] {<emailfilter none>}
      [main home (top level)] {<emailfilter toplevel>}
      <%
      For Each addentry In Session("objSession").AddressLists.Item(1).AddressEntries
        response.write("(?email from " & lcase(addentry.name)  & ") {<emailfilter """ & addentry.name & """>}")
      Next
      %>
    ]
    ]]>
    </grammar>
      <prompt>
        Do you want to only check important emails or emails from someone?
    </prompt>
    <help>
      You can say important emails or email from someone in your address book. 
    </help>
    <filled>
      <if cond="emailfilter == 'toplevel'">
        <goto next="#start"/>
      </if>
      Please wait while I get your email information.
    </filled>
  </field>


    <subdialog name="getemail" method="get" namelist="emailtype emailfilter" src="http://www.openland.com/wrox/getemail.asp">
      <filled>
        <clear/>
      </filled>
    </subdialog>

  </form>

  <form id="calendar">
    <var name="caltime" expr="'default'"/>

    <field name="caltype">
      <grammar>
      <![CDATA[
      [
        (?[on a specific] day) {<caltype day>}
        (?[on a specific] week) {<caltype week>}
        (?[on a specific] month) {<caltype month>}

        today {<caltype today>}
        yesterday {<caltype yesterday>}
        tomorrow {<caltype tomorrow>}

        (this week) {<caltype thisweek>}
        (last week) {<caltype lastweek>}
        (next week) {<caltype nextweek>}
        (top level) {<caltype toplevel>}
      ]
      ]]>
      </grammar>

      <prompt>
        How do you want to check your appointments?
      </prompt>
      <help>
        You can say a specific day, week, month, or today, yesterday, tomorrow, or this week, last week, or next week.
      </help>

      <filled>
        <if cond="caltype == 'toplevel'">
          <goto next="#start"/>
        </if>
      </filled>
    </field>


    <field name="calday" type="date" cond="caltype == 'day'">
      <prompt>
        For which day do you want to check the appointments?
      </prompt>
      <help>
        Please say month, day, and year.
      </help>
      <filled>
        <assign name="caltime" expr="calday"/>
      </filled>
    </field>

    <field name="calweek" type="date" cond="caltype == 'week'">
      <prompt>
        For which week do you want to check the appointments? Please give the date of that Monday.
      </prompt>
      <help>
        Please say any date of some day of the week.
      </help>
      <filled>
        <assign name="caltime" expr="calweek"/>
      </filled>
    </field>

    <field name="calmonth" cond="caltype == 'month'">
      <grammar>
      [january february march april may june july august september october november december]
      </grammar>
      <prompt>
        For which month do you want to check appointments?
      </prompt>
      <filled>
        <assign name="caltime" expr="calmonth"/>
      </filled>
    </field>
        
    <subdialog name="getappnt" method="get" namelist="caltype caltime" src="http://www.openland.com/wrox/getappointment.asp">
      <filled>
        <clear/>
      </filled>
    </subdialog>

  </form>

</vxml>
