<?php

/**
 * SieveRules import filter for INGO
 *
 * The class should be named 'srimport_[filename]'
 * Each import filter must have:
 *   An attribute called name
 *   A pubic function called detector
 *   A pubic function called importer
 * The importer function can return either a string to be parsed by the SieveRules parser
 * or an array, similar to the one created by the SieveRules parser
 */
class srimport_ingo
{
	public $name = 'Horde (INGO)';

	public function detector($script, $name)
	{
		return preg_match('/# [a-z0-9\ ]+/i', $script) ? True : False;
	}

	public function importer($script)
	{
		$i = 0;
		$name = array();
		// tokenize rules
		if ($tokens = preg_split('/(# .+)\r?\n/i', $script, -1, PREG_SPLIT_DELIM_CAPTURE)) {
			// unset first token, its the ingo header
			$tokens[1] = "";

			foreach($tokens as $token) {
				if (preg_match('/^# (.+)/i', $token, $matches)) {
					$name[$i] = $matches[1];
					$content .= "# rule:[" . $name[$i] . "]\n";
				}
				elseif (isset($name[$i])) {
					$token = str_replace(":comparator \"i;ascii-casemap\" ", "", $token);
					
                                        // correct ingo syntax "address :all :contains "From|To", just refer to header
                                        $pregsearch = '/address :all :contains "(From|To)"/';
                                        $pregrepl = 'header :contains "${1}"';
                                        $token = preg_replace($pregsearch, $pregrepl, $token);					
					
					$content .= $token . "\n";
					$i++;
				}
				elseif (preg_match('/^\r?\n?require/i', $token)) {
					$content .= $token . "\n";
				}
			}
		}

		return $content;
	}
}

?>
