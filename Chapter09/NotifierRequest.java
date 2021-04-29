import java.io.*;
import java.net.*;
import java.util.*;

public class NotifierRequest
{
    
    public static void main(String[] argv)
    {
		if (argv.length < 4)
		{
			System.out.println("Usage: java NotifierRequest <phone> <user_id> <notifier_url> <email>");
			System.exit(1);
		}

        try
        {
		    URL u = new URL("http://www.openland.com/wrox/notifierrequest.asp?phone=" + argv[0] + 
				"&UserID=" + argv[1] + "&NotifierURL=" + argv[2] + "&Email=" + argv[3]);
		    BufferedReader br = new BufferedReader(new InputStreamReader(u.openStream()));

		    String strLine;
		    String strResult = ""; 
		    while ((strLine = br.readLine()) != null)
		    {
			    strResult += strLine + "\n";
		    }       
		    System.out.println(strResult);
        }
        catch (Exception e)
        {
            System.out.println("" + e);
        }
	}
}
    
   
