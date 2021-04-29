<?xml version="1.0"?>

<vxml version="1.0" application="root.vxml">
<form>
	<var name="emailid"/> <!-- this variable does get passed via param in subdialog -->
        <%@ page import="java.io.*" %>
        <%@ page import="java.util.*" %>
	
	<block>

        <%
            ServletInputStream myIn = request.getInputStream();
            int reqLength = request.getContentLength();
            System.out.println("In the JSP!");
            System.out.println("request class is " + request.getClass());
            System.out.println("request length is " + reqLength);

            String val = request.getParameter("emailmsg");
			String emailid = request.getParameter("emailid");
			System.out.println("emailid = " + emailid);

			//long l = System.currentTimeMillis();
			//String filename ="c:/" + l +".wav";
			String filename ="c:/" + emailid +".wav";
			System.out.println("filename=" + filename);

            OutputStream myout = new FileOutputStream(new File(filename));

            myout.write(val.getBytes());
            myout.close();
        %>
      <prompt>
			Your message has been saved. emailid=<value expr="emailid"/>.
      </prompt>

	  <return/>

    </block>

</form>

</vxml>


