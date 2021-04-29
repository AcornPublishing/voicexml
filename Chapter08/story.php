<?php require("story-head.php") ?>
<?php require("vxml-header.php") ?>
   <form id="main">
      <field name="input" timeout="2">
         <grammar><![CDATA[ [
            [stop dtmf-0] {<option "stop">}
         ] ]]></grammar>
         <prompt>
            <audio>Say stop to return to the headline list</audio>
            <audio><?php echo fix_tts($story->title) ?></audio>
            <audio><?php echo $_date ?></audio>
            <audio>Contributed by <?php echo fix_tts($_name) ?></audio>
            <audio><?php echo fix_tts($_introtext) ?></audio>
            <?php if ($_words>0) { ?>
               <audio>For the complete story,  an additional <?php echo $_words ?> words visit our web site at w w w dot t c greens dot org</audio>
            <?php } ?>
         </prompt>
         <noinput>
            <submit next="index.php" namelist="start" method="get"/>
         </noinput>
         <filled>
            <audio>in filled handler</audio>
            <submit next="index.php" namelist="start" method="get"/>
         </filled>
      </field>
  </form>
</vxml>
