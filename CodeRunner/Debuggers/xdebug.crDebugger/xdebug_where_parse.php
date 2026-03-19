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
			$current_stack_frame = 0;
			$needle = "current_stack_frame:";
			$pos = strrpos($data, $needle);
			if ($pos !== false) {
				$current_stack_frame = intval(substr($data, $pos+strlen($needle)));
			}
			$locations = array();
			foreach ($items as $item) {
				$tag = $item["tag"];
				if ($tag == "STACK") {
					$attrs = $item["attributes"];
					array_push($locations, array(
						"frame_number" => $attrs["LEVEL"],
						"current" => $attrs["LEVEL"] == $current_stack_frame,
						"file" => $attrs["FILENAME"],
						"line" => $attrs["LINENO"],
						"name" => $attrs["WHERE"],
					));
				}
			}
			echo json_encode($locations);
		}
	}
?>