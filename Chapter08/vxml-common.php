<?php

   require "vxml-substitutions.php";

   #
   # optional variable $default
   #

   function carry_variable($var) {
      if(isset($GLOBALS[$var])) {
         $val=$GLOBALS[$var];
      } else if (func_num_args()>1) {
         $val=func_get_arg(1);
      } else return;

      if (!is_numeric($val)) {
         $val=addslashes($val);
         $val="'$val'";
      };
        echo "<var name=\"$var\" expr=\"$val\"/>\n";
   };

   function fix_tts($string) {
      global $vxml_subs;

      foreach($vxml_subs as $from=>$to) {
         $string=str_replace($from,$to,$string);
      };

      return $string;
   };

?>