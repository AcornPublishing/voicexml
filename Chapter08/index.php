<?php require("index-head.php") ?>
<?php require("vxml-header.php") ?>
   <form>
      <field name="sid">

         <grammar><![CDATA[ [
            <?php
		for($i=1;$i<=count($stories);$i++) {
                   echo "[$i dtmf-$i] {<option \"".$stories[$i-1]->sid."\">}";
                };
            ?>
         <?php if($older) { ?> [older] {<option "older">} <?php } ?>
         <?php if($newer) { ?> [newer] {<option "newer">} <?php } ?>
         ] ]]></grammar>
         <prompt>
            <if cond="visit_count==0">
               <audio>Tompkins County Green Party by telephone.  Excuse me,  but my pronunciation isn't quite pefect</audio>
            </if>
            <assign name="visit_count" expr="visit_count+1"/>
            <if cond="start==0">
               <audio>Here are the most recent headlines.</audio>
            <else/>
               <audio>Here are headlines <?php echo $start+1 ?> through <?php echo $start+count($stories) ?> of <?php echo $count?>. </audio>
            </if>
	    <audio>Speak or press the number to hear the summary of a story.</audio>
  	    <?php for($i=0;$i<count($stories);$i++) { ?>
               <audio><?php echo ($i+1) ?></audio>
	       <pause>300</pause>
               <audio><?php echo fix_tts($stories[$i]->title) ?></audio>
            <?php } ?>
            <?php if ($older) { ?>
               <audio>say older to hear older headlines</audio>
            <?php } ?>
            <?php if ($older && $newer) { ?>
               <audio>or</audio>
            <?php } ?>
	    <?php if ($newer) { ?>
               <audio>say newer to hear more recent headlines</audio>
	    <?php } ?>
         </prompt>
         <filled>
            <if cond="sid=='older'">
               <assign name="start" expr="'<?php echo $start+9 ?>'"/>
               <submit next="index.php" namelist="start" method="get"/>
            <elseif cond="sid=='newer'"/>
               <assign name="start" expr="'<?php echo $start-9 ?>'"/>
               <submit next="index.php" namelist="start" method="get"/>
            <else/>
               <submit next="story.php" namelist="sid start visit_count" method="get"/>
            </if>
         </filled>
      </field>
  </form>
</vxml>