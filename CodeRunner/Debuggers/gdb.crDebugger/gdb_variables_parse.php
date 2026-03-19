<?php
	error_reporting(E_ERROR);
	$variables = array();
	$isArgument = true;
	while ($line = fgets(STDIN)) {
		$line = trim($line);
		if (preg_match('/^(\w+)\s+=\s+(0x[a-f0-9]+)?\s*(.*?)$/', $line, $matches)) {
			$name = $matches[1];
			$hex = $matches[2];
			$value = $matches[3];
			$variable = array("name" => $name);
			if (strlen($value) > 0) {
				$variable["value"] = $value;
			} else if (strlen($hex)) {
				$variable["value"] = $hex;
			}
			if ($isArgument) {
				$variable["kind"] = "parameter";
			}
			array_push($variables, $variable);
		} else if ($line == "-") {
			$isArgument = false;
		}
	}
	echo json_encode($variables);
?>
