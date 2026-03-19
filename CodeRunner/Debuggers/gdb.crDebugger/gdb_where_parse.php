<?php
	error_reporting(E_ERROR);
	$current_thread_line = false;
	$locations = array();
	$thread = "";
	while ($line = fgets(STDIN)) {
		$line = trim($line, "\n\r");
		$matches = array();
		if (!$current_thread_line) {
			if ($line == "No stack.") {
				exit(57);
			}
			$current_thread_line = $line;
		} else if (preg_match('/(?:Thread\s+)?(.*?)\s*\(Thread (\w+) of process (\d+)\):/', $line, $matches)) {
			$thread = $matches[1];
		} else if ($thread) {
			if (preg_match('/^#(\d+)\s+(?:\w+\s+in\s+)?(.+?)\s+(?:\(.*\))?(?:\s*(?:from|at)\s+(\/.*?)(?::(\d+))?)?$/', $line, $matches)) {
				$location = array(
					"thread" => $thread,
					"frame_number" => intval($matches[1]),
					"name" => $matches[2]
				);
				if ($matches[3]) {
					$location["file"] = $matches[3];
				}
				if (strlen($matches[4]) > 0) {
					$location["line"] = $matches[4];
				}
				if ($line == $current_thread_line) {
					$location["current"] = true;
				}
				array_push($locations, $location);
			}
		}
	}
	echo json_encode($locations);
?>
