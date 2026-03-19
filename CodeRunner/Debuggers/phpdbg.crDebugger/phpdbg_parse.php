<?php
	error_reporting(E_ERROR);
	$stack = array();
	$xml_parser = xml_parser_create();
	xml_set_element_handler($xml_parser, "startTag", "endTag");
	xml_set_character_data_handler($xml_parser, "cdata");
	xml_parse($xml_parser, "<document>");
	$partial_stream = false;
	while ($data = fread(STDIN, 8192)) {
		if ($partial_stream) {
			xml_parse($xml_parser, '<stream>');
		}
		for ($i = 0; $i <= 31; $i++) {
			if ($i == 9 || $i == 10 || $i == 13) continue;
			$data = str_replace("&#$i;", "", $data);
		}
		xml_parse($xml_parser, $data);
		$error = xml_get_error_code($xml_parser);
		if ($error != XML_ERROR_NONE) {
			// phpdbg's xml output is full of bugs, so attempt to recover the parser...
			echo "XML Parser Error: ".xml_error_string($error)." ($error)\n";
			xml_parser_free($xml_parser);
			$stack = array();
			$xml_parser = xml_parser_create();
			xml_set_element_handler($xml_parser, "startTag", "endTag");
			xml_set_character_data_handler($xml_parser, "cdata");
			xml_parse($xml_parser, "<document>");
			$partial_stream = false;
			$last_prompt = strrpos($data, '<prompt ');
			if ($last_prompt !== false) {
				xml_parse($xml_parser, substr($data, $last_prompt));
				$new_error = xml_get_error_code($xml_parser);
				if ($new_error != XML_ERROR_NONE) {
					echo "XML Parser Error on attempted recovery: ".xml_error_string($new_error)." ($new_error)\n";
					console_echo("The debugger encountered an unexpected error ($error.$new_error).");
					debugger_exit(1);
				}
			}
		} else if ($stack[count($stack)-1] == "STREAM" && can_break_stream_data($data)) {
			$partial_stream = true;
			xml_parse($xml_parser, '</stream>');
		} else {
			$partial_stream = false;
		}
	}
	
	function startTag($parser, $name, $attrs) {
		global $stack;
		array_push($stack, $name);
		if ($name == "PHP") {
			$msg = $attrs["MSGOUT"];
			$msg = preg_replace('/^\[(.*)\][\s\n]*$/m', '$1', $msg);
			console_echo($msg."\n");
			if (isset($attrs["SEVERITY"]) && $attrs["SEVERITY"] == "error") {
				if (preg_match('/^PHP (.+?):/', $msg, $matches)) {
					$error_type = strtoupper($matches[1]);
					if (preg_match('/\bERROR\b/', $error_type)) {
						debugger_exit(1);
					}
				}
			}
			return;
		} else if ($name == "EXCEPTION") {
			$msg = $attrs["MSGOUT"];
			console_echo($msg);
		} else if ($name == "STOP") {
			debugger_exit(0);
		}
		if (isset($attrs["MSGOUT"])) {
			$msg = $attrs["MSGOUT"];
		} else if (isset($attrs["MSG"])) {
			$msg = $attrs["MSG"];
			$msg = preg_replace('/\*\*(.*?)\*\*/', '$1', $msg);
			$msg = preg_replace('/\$P\b/', 'phpdbg>', $msg);
		}
		if (isset($msg) && strlen($msg) > 0) {
			if ($name == "PROMPT" && $msg[0] != "\n") {
				$msg = "\n".$msg;
			}
			echo $msg;
		}
	}

	function cdata($parser, $cdata) {
		global $stack;
		if ($stack[count($stack)-1] == "STREAM") {
			if (!in_array("EVAL", $stack)) {
				console_echo($cdata);
			} else {
				echo $cdata;
			}
		} else {
			echo $cdata;
		}
	}

	function endTag($parser, $name) {
		global $stack;
		array_pop($stack);
	}
	
	function console_echo($string) {
		global $argv;
		$tty = $argv[1];
		file_put_contents($tty, $string);
	}
	
	function debugger_exit($status) {
		echo "\n[phpdbg server exited ($status)]";
		exit($status);
	}
	
	function can_break_stream_data($data) {
		$amp = false;
		$semicolon = false;
		$hash = false;
		$escaped = false;
		$len = strlen($data);
		for ($i = $len-1; $i >= 0; $i--) {
			if (!$amp) {
				if ($len-$i > 10) {
					return true;
				}
				if ($data[$i] == ';') {
					if ($semicolon) {
						return true;
					}
					$semicolon = true;
				} else if ($data[$i] == '#') {
					if ($hash) {
						return true;
					}
					$hash = true;
				} else if ($data[$i] == '&') {
					$amp = true;
				} else if (!ctype_alnum($data[$i])) {
					return true;
				}
			} else {
				if ($data[$i] == '\\') {
					$escaped = !$escaped;
				} else if ($escaped) {
					return true;
				} else {
					return $semicolon;
				}
			} 
		}
		return true;
	}
?>