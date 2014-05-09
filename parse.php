#!/usr/bin/php
<?php

$file = 'abc.xml';
$h = fopen($file, 'r');

$xml = array();

$inside_tag = 0;
$data = '';
$tagstack = array();

$tag_counter = 0;

function &get_ptr(&$xml, &$tagstack)
	{
	$ptr = &$xml;
	if ($tagstack) foreach ($tagstack as $tag_id)
		$ptr = &$ptr[$tag_id];
	return $ptr;
	}

while ($line = fgets($h))
	{
	$line = trim($line);

	for ($i = 0; $i < strlen($line); ++$i)
		{
		$char = substr($line, $i, 1);
		if ($char == '<')
			{
			$inside_tag = 1;
			$data = '';
			}
		else if ($char == '>' && substr($data, 0, 1) == '?')
			{
			$inside_tag = 0;
			$data = '';
			}
		else if ($char == '>' && substr($data, 0, 1) != '?')
			{
			$inside_tag = 0;
			
			if (substr($data, 0, 1) == '/')
				{
				$close_tag = substr($data, 1);
				//print "\tClose tag: $close_tag\n";

				array_pop($tagstack);
				}
			else
				{
				++$tag_counter;
				$tagstack[] = $tag_counter;

				list($open_tag, $rest) = explode(' ', $data, 2);
				if (substr($open_tag, -1) == '/') $open_tag = substr($open_tag, 0, -1);
				if ($rest == '/') $rest = '';
				//print "\tOpen tag: $open_tag\n";

				$ptr = &get_ptr($xml, $tagstack);
				$ptr['tag'] = $open_tag;
				$ptr['rest'] = $rest;

				// check of this is an open and close tag
				if (substr(trim($data), -1) == '/')
					array_pop($tagstack);
				}
			$data = '';
			}
		else
			{
			if ($inside_tag == 0)
				{
				$ptr = &get_ptr($xml, $tagstack);
				$ptr['data'] .= $char;
				}
			else
				$data .= $char;
			}
		}
	}

fclose($h);

print_r($xml);

?>
