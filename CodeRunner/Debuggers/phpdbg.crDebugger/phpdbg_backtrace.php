<?php
	$__cr_frames = array();
	$__cr_debug_backtrace = debug_backtrace();
	for ($__cr_frame_number = 2; $__cr_frame_number < count($__cr_debug_backtrace); $__cr_frame_number++) {
		$__cr_backtrace_array = $__cr_debug_backtrace[$__cr_frame_number];
		$__cr_frame_name = false;
		if ($__cr_backtrace_array["function"] == "unknown") {
			unset($__cr_backtrace_array["function"]);
		} else if ($__cr_backtrace_array["function"]) {
			$__cr_frame_name = $__cr_backtrace_array["function"].(ctype_alnum(str_replace('_', '', $__cr_backtrace_array["function"])) ? "()" : "");
		}
		if (isset($__cr_backtrace_array["class"])) {
			$__cr_frame_name = $__cr_backtrace_array["class"];
			if (isset($__cr_backtrace_array["type"]) && isset($__cr_backtrace_array["function"])) {
				$__cr_frame_name .= $__cr_backtrace_array["type"].$__cr_backtrace_array["function"].(ctype_alnum(str_replace('_', '', $__cr_backtrace_array["function"])) ? "()" : "");
			}
		}
		
		array_push($__cr_frames, array(
			"frame_number" => count($__cr_frames),
			"file" => $__cr_backtrace_array["file"],
			"line" => $__cr_backtrace_array["line"],
			"name" => $__cr_frame_name,
			"current" => empty($__cr_frames),
		));
	}
	$__cr_backtrace = json_encode($__cr_frames);
	unset($__cr_frames);
	unset($__cr_debug_backtrace);
	unset($__cr_backtrace_array);
	unset($__cr_frame_name);
	unset($__cr_frame_number);
?>