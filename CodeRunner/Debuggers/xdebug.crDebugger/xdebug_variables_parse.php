<?php
	$f = fopen("php://stdin", "b");
	$data = "";
	while ($r = fread($f, 1024)) {
		$data .= $r;
	}
	$offset = 0;
	$xml_chunks = array();
	while (preg_match('/(\b(\d+)\\\0)(<\?xml\b)/', $data, $matches, PREG_OFFSET_CAPTURE, $offset)) {
		$offset = $matches[0][1]+strlen($matches[0][0]);
		$bytes = intval($matches[2][0]);
		if ($bytes <= 0) break;
		$start = $matches[3][1];
		$end = $start+$bytes;
		if ($end > strlen($data)) $end = strlen($data);
		$xml = substr($data, $start, $end-$start);
		array_push($xml_chunks, $xml);
	}
	if (count($xml_chunks) > 0) {
		$xml = $xml_chunks[count($xml_chunks)-1];
		$xml_parser = xml_parser_create();
		if (xml_parse_into_struct($xml_parser, $xml, $items)) {
			$vars = array();
			$prev_level = 0;
			foreach ($items as $item) {
				$tag = $item["tag"];
				if ($tag == "PROPERTY") {
					$level = $item["level"];
					$tag_type = $item["type"];
					if ($tag_type === "close") {
						$array = $vars[count($vars)-1]["value"];
						if (count($array) > 1 && $array[0]["name"] === "...") {
							$dots = $array[0];
							array_splice($vars[count($vars)-1]["value"], 0, 1);
							$vars[count($vars)-1]["value"][] = $dots;
						}
					}
					if (isset($item["attributes"])) {
						$attrs = $item["attributes"];
						$value = null;
						if ($tag_type == "open") {
							$value = array();
						}
						if (isset($item["value"])) {
							$value = $item["value"];
							if (isset($attrs["ENCODING"]) && $attrs["ENCODING"] == "base64") {
								$value = base64_decode($value);
							}
						}
						$type = $attrs["TYPE"];
						if ($type === "string") {
							$value = var_export($value, true);
						} else if ($type === "object" && isset($attrs["CLASSNAME"])) {
							$type = $attrs["CLASSNAME"];
						}
						$obj = array(
							"name" => $attrs["NAME"],
							"type" => $type,
							"value" => $value,
							"level" => $level
						);
						if (isset($attrs["FULLNAME"])) {
							$obj["fullname"] = $attrs["FULLNAME"];
						}
						if (isset($attrs["NUMCHILDREN"])) {
							$num = $attrs["NUMCHILDREN"];
							$obj["description"] = $num." item".($num != 1 ? "s" : "");
							if ($obj["value"] === null) {
								$obj["value"] = array(array("name" => "..."));
							} else if (isset($attrs["PAGESIZE"]) && $attrs["PAGESIZE"] < $num) {
								$obj["value"][] = array("name" => "...");
							}
						}
						if (count($vars) > 0 && $level > $vars[count($vars)-1]["level"]) {
							$vars[count($vars)-1]["value"][] = $obj;
						} else {
							$vars[] = $obj;
						}
					}
				}
			}
			echo json_encode($vars);
		}
	}
?>