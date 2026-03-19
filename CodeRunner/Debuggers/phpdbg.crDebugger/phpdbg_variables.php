<?php
	if (!function_exists('__cr_encode_function')) {
		function __cr_encode_function($vars, $seen_objects, $is_array, $recurse_time, $depth) {
			global $__cr_variables_show_all;
			global $__cr_variables_depth;
			$result = array();
			if ($depth > $__cr_variables_depth) {
				array_push($result, array("name" => "..."));
				return $result;
			}
			foreach ($vars as $name => &$real_value) {
				$value = $real_value;
				if ($is_array === false) {
					if (strlen($name) >= 5 && substr($name, 0, 5) === '__cr_') {
						continue;
					} else if (!$__cr_variables_show_all && $name === "argc" && $value === 1) {
						continue;
					} else if (!$__cr_variables_show_all && $name === "argv" && count($value) === 1) {
						continue;
					}
				} else if ($name === "__cr_recursion_detection") {
					continue;
				}
				$no_recurse = microtime(true)-$recurse_time > 5.0;
				$type = gettype($value);
				$description = false;
				$array_recursion = false;
				if ($type === 'object') {
					if (in_array($value, $seen_objects, true)) {
						$no_recurse = true;
					}
					$description = "<".get_class($value)." ".substr(md5(spl_object_hash($value)), 0, 6).">";
					if (!$no_recurse) {
						array_push($seen_objects, $value);
						$value = get_object_vars($value);
					}
				} else if ($type === 'array') {
					if (!$__cr_variables_show_all && $is_array === false && strlen($name) >= 1 && $name[0] === "_" && count($value) === 0) {
						continue;
					}
					if (isset($value['__cr_recursion_detection'])) {
						$no_recurse = true;
						$array_recursion = true;
					}
				}
				if (!$no_recurse && ($type === 'array' || $type === 'object')) {
					if ($type === 'array') {
						$real_value['__cr_recursion_detection'] = true;
					}
					$description = count($value)." item".(count($value) != 1 ? "s" : "");
					$value = __cr_encode_function($value, $seen_objects, true, $recurse_time, $depth+1);
					if ($type === 'object') {
						array_pop($seen_objects);
					} else {
						unset($real_value['__cr_recursion_detection']);
					}
				} else {
					if ($type === 'object') {
						$value = $description;
						$description = false;
					} else if ($type === 'array') {
						$value = "Array";
						if ($array_recursion) {
							$value .= " *RECURSION*";
						}
					} else {
						$value = json_encode($value, JSON_UNESCAPED_SLASHES);
					}
					if (strlen($value) > 1500) {
						$value = substr($value, 0, 1500)." [...]";
					}
				}
				if ($is_array === false) {
					$name = '$'.$name;
				}
				array_push($result, array(
					"name" => $name,
					"type" => $type,
					"value" => $value,
					"description" => $description
				));
			}
			return $result;
		}
	}
	if (!isset($__cr_variables_depth)) $__cr_variables_depth = 3;
	$__cr_variables = __cr_encode_function(isset($this) ? array_merge(array("this" => $this), get_defined_vars()) : get_defined_vars(), array(), false, microtime(true), 0);
	$__cr_variables = json_encode($__cr_variables);
?>