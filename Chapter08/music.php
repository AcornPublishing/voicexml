<vxml>
   <form>
      <field name="main"> 
      <grammar>
      <![CDATA[
        [
        [dtmf-1 1] {<option "1">}
        [dtmf-2 2] {<option "2">}
        [dtmf-3 3] {<option "3">}
        ]
      ]]>
      </grammar>
         <prompt>
            <audio>Speak or say the number to hear a song,  or say headlines to return to the index</audio> 
            <pause>400</pause>
            <audio>1 The Countdown,  featuring Adam Horowitz and Ralph Nader</audio>
            <pause>400</pause>
            <audio>2 No Respect for the Process,  with Hal Wilner and Jim Hightower</audio>
            <pause>400</pause>
            <audio>3 What Side are you on by Paula Gonzales</audio>
         </prompt>
         <filled>
            <if cond="main=='headlines'">
               <goto next="index.php"/>
            <else/>
               <goto expritem="'song'+main"/>
            </if>
         </filled>
      </field>
      <field name="song1">
         <grammar><![CDATA[ [
            [stop dtmf-0] {<option "stop">}
         ] ]]></grammar>
         <prompt>
            <audio>Say stop to return to the list of songs</audio>
            <audio src="media/Countdown-phone.wav"/>
         </prompt>
         <noinput>
            <goto expritem="'main'"/>
         </noinput>
         <filled>
            <goto expritem="'main'"/>
         </filled>
      </field>
      <field name="song2">
         <grammar><![CDATA[ [
            [stop dtmf-0] {<option "stop">}
         ] ]]></grammar>
         <prompt>
            <audio>Say stop to return to the list of songs</audio>
            <audio src="media/NoRespectfortheProcess-phone.wav"/>
         </prompt>
         <noinput>
            <goto expritem="'main'"/>
         </noinput>
         <filled>
            <goto expritem="'main'"/>
         </filled>
      </field>
      <field name="song3">
         <grammar><![CDATA[ [
            [stop dtmf-0] {<option "stop">}
         ] ]]></grammar>
         <prompt>
            <audio>Say stop to return to the list of songs</audio>
            <audio src="media/whatside-phone.wav"/>
         </prompt>
         <noinput>
            <goto expritem="'main'"/>
         </noinput>
         <filled>
            <goto expritem="'main'"/>
         </filled>
      </field>
  </form>
</vxml>