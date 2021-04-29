<HTML>
<HEAD>
<TITLE>Request for Notifier</TITLE>
</HEAD> 
<body>

<!-- http://www.openland.com/wrox/notifierrequest.asp?phone=4089728244&UserID=1234567890&NotifierURL=http://www.openland.com/wrox/notifier.vxml&Email=jtang@openland.com -->

Phone: <%=request.QueryString("Phone")%><br>
UserID: <%=request.QueryString("UserID")%><br>
NotifierURL: <%=request.QueryString("NotifierURL")%><br>
Email: <%=request.QueryString("Email")%><br>

</body>
</HTML>
