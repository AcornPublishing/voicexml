/*
 *
 * File: SOSpell.java
 *
 *  THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
 *  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR
 *  A PARTICULAR PURPOSE.
 *
 * @author: Jeff Tang
 */

import vcommerce.core.util.*;
import vcommerce.util.*;
import vcommerce.util.prompt.*;
import vcommerce.util.context.*;
import vcommerce.core.sc.*;
import vcommerce.sc.*;
import vcommerce.so.*;
import vcommerce.grammar.*;
import nuance.util.grammar.*;
import nuance.core.util.*;
import nuance.util.*;
import nuance.util.prompt.*;
import nuance.core.sc.*;
import nuance.so.*;
import nuance.sc.*;
import java.util.*;


/**
 * class that asks users to spell a word consisting of letters, digits, space, 
 * dash, underscore, at sign, and dot - you can enhance the grammar to allow for more characters.
 */
public class SOSpell extends SODialog
{
    // store the whole spelled text string
    private String m_strSpellings;
    private SpellFilter m_spellFilter;
    
    // Constructor
    public SOSpell() throws VCommerceException
    {
    	super();

        m_strSpellings = "";
        m_spellFilter = new SpellFilter();
        setFilter(m_spellFilter);                                
        
    	// set the grammar for the spelling so
    	setGrammar(new FileDynamicGrammar(                    
            "/grammars/sospell.grammar",                    
            "SOSpell_CORE", this.getClass()));    
    }

   
    // Prompt creation methods 
    protected Playable createInitialPrompt() 
    {
	    return new TTSPrompt("Please spell now.");
    }

    protected Playable createHelpPrompt() 
    {
	    return new TTSPrompt("You can spell the word one character a time.");
    }


    protected SpeechObject.Result createResult(String strResult) 	
        throws VCommerceException 
    {	
        return new Result(strResult);    
    }
    
    protected SpeechObject.Result processRecResult(SpeechChannel sc,
            DialogContext dc,							
            CallState cs,							
            RecResult recResult)
        throws VCommerceException 
    {		
    	int n = recResult.getNumResults();
    	System.out.println("number of results: " + n);

        for (int i=0; i<n; i++)
        {
            SingleResult sr = recResult.getSingleResult(i);
    	    int m = sr.getNumInterpretations();
    	    
    	    // we always use the first interpretation as our spelling grammar is not ambiguous
            Interpretation interp = sr.getInterpretation(0);

            String strSpelling = null;	
            KVSet slots = interp.getSlots();	
            if (slots.keyExists("spelling")) 
            {	    
                strSpelling = (String) slots.getObject("spelling");
                System.out.println("strSpelling=" + strSpelling);
                
                // if this spelling is already confirmed by user as incorrect, skip it
                if (!passesFilter(createResult(strSpelling)))
                {
                    System.out.println("spelling being skipped: " + strSpelling);
                    continue;
                }
            
                // we've got one result that may be correct or incorrect, now confirm with user
                // first compose a user-friendly prompt string
                String strPrompt = strSpelling; 

                // if strSpelling is space, dash, underscore, at, dot, or finished, strPrompt is already set
                if (!strSpelling.equals("space") && !strSpelling.equals("dash") &&
                    !strSpelling.equals("underscore") && !strSpelling.equals("finished"))
                { 
                    if (strSpelling.equals("at"))
                        strPrompt = "the at sign";
                    else if (strSpelling.equals("dot"))
                        strPrompt = "dot as in dot com";
                    else if (Character.isLetter(strSpelling.charAt(0)))
                        strPrompt = promptOf(strSpelling.charAt(0));
                    else if (Character.isDigit(strSpelling.charAt(0)))
                        strPrompt = "number " + strSpelling;
                }
                
                SOYesNo soYN = new SOYesNo();
                soYN.setMaxErrorCount(500);
                soYN.setInitialPrompt(new TTSPrompt(strPrompt + "?"));  
                soYN.setRecognitionErrorPrompt(new TTSPrompt("Did you say " + strPrompt + "?"));
                
                SOYesNo.Result res = (SOYesNo.Result)soYN.invoke(sc, dc, cs);
                System.out.println("You said: " + (res.saidYes() ? "yes" : "no"));
                
                if (res.saidYes())
                {
                    if (strSpelling.equals("finished"))
                        return createResult(m_strSpellings);
                    else
                    {
                        // convert three special utterances to characters
                        if (strSpelling.equals("space"))
                            m_strSpellings += " ";
                        else if (strSpelling.equals("dash"))
                            m_strSpellings += "-";
                        else if (strSpelling.equals("underscore"))
                            m_strSpellings += "_";
                        else if (strSpelling.equals("at"))
                            m_strSpellings += "@";
                        else if (strSpelling.equals("dot"))
                            m_strSpellings += ".";
                        else // this is either a letter or digit
                        {
                            m_strSpellings += strSpelling;
                        }
                        
                        setNoResultFoundPrompt(new TTSPrompt("OK, please continue."));  
                        
                        // reset the filter
                        m_spellFilter.reset();
                        
                        return null;
                    }
                }                    
                else
                { 
                    // an alternative to reprompt user for the spelling is to go thru all the 
                    // remaining n-best result until either user confirms or the list is thru
                    // to go thur the list instead of asking user right away, uncomment the following line
                    // if (i < n-1) continue;
                            
                    // as we return null to indicate no result if found, we set this NoResultFound prompt
                    setNoResultFoundPrompt(new TTSPrompt("Please spell it again."));    
                    
                    // set a filter
                    m_spellFilter.addSkipWord(strSpelling);
                    return null;
                }
            }
        }
        return null;
    }    
    
    protected SpeechObject.Result handleNoResultFound(SpeechChannel sc, 
		    DialogContext dc, 
			CallState callState, 
			RecResult recResult)
        throws VCommerceException 
    {
        //PromptBag.appendPlayable(new DefaultUniversalEventHandler.
        //    ErrorTypePrompt(m_cserrorpromptbag.
        //    getRecognitionErrorPrompt()),sc);
        appendPrompt(getErrorPromptByKey(NO_RESULT_FOUND),sc);
        return null;
    }
    
    private String promptOf(char ch)
    {
        switch (ch)
        {
            case 'A':
                return "a as in apple";
            case 'B':
                return "b as in bob";
            case 'C':
                return "c as in charlie";
            case 'D':
                return "d as in david";
            case 'E':
                return "e as in edward";
            case 'F':
                return "f as in frank";
            case 'G':
                return "g as in george";
            case 'H':
                return "h as in henry";
            case 'I':
                return "i as in idea";
            case 'J':
                return "j as in jeff";
            case 'K':
                return "k as in karen";
            case 'L':
                return "l as in lisa";
            case 'M':
                return "m as in mary";
            case 'N':
                return "n as in nancy";
            case 'O':
                return "o as in oscar";
            case 'P':
                return "p as in peter";
            case 'Q':
                return "q as in queen";
            case 'R':
                return "r as in richard";
            case 'S':
                return "s as in sam";
            case 'T':
                return "t as in tom";
            case 'U':
                return "u as in uncle";
            case 'V':
                return "v as in victor";
            case 'W':
                return "w as in walter";
            case 'X':
                return "x as in xray";
            case 'Y':
                return "y as in yankee";
            case 'Z':
                return "z as in zebra";
        }
        return "";
    }
    
    
    // start of inner class Result
    public static class Result extends SpeechObject.Result
    {
         // convenience function
         public String getSpelling()
         {
             return getString("SPELLING");
         }
      
         // Constructor 
         protected Result(String strSpelling)
         {
             setString("SPELLING", strSpelling);
         }
      
         // Playable that has to be implemented for a concrete class extended from SODialog 
         public void appendTo(PromptPlayer player)
             throws VCommerceException
         {
             player.appendPrompt(getSpelling());
         }

         // this method is also required for a concrete SODialog subclass
         public String toString()
         {
             return getSpelling();
         }

       } // end of inner class Result

    }


// the filter class used to skip incorrect result
class SpellFilter implements ResultFilter 
{
    private Vector m_vecSkipWords;

    public void reset()
    {
        m_vecSkipWords = null;
    }
    
    public void addSkipWord(String strSpelling)
    {
        if (m_vecSkipWords == null)
            m_vecSkipWords = new Vector();
            
        m_vecSkipWords.addElement(strSpelling);
    }        
    
    public boolean pass(SpeechObject.Result result) 
    {
        System.out.println("Inside SpellFilter's pass: result=" + result);
        if (m_vecSkipWords == null)
            System.out.println("No skip words.");
        else 
            for (int i=0; i<m_vecSkipWords.size(); i++)
                System.out.println("@@@skip word #" + i + ": " + m_vecSkipWords.elementAt(i));
    
        if (m_vecSkipWords != null && m_vecSkipWords.contains(((SOSpell.Result)result).getSpelling())) 
            return false;
        else 
            return true;
    }
}


