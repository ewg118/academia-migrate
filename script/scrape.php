<?php 
 /**************
 * AUTHOR: Ethan Gruber
 * DATE: Feburary 2016
 * FUNCTION: an academia.edu profile URI into the script to parse works (as JSON) owned by the user
 * in order to restructure into XML to read by the XForms engine to initiate a migration into Zenodo.org.
 * REQUIRED LIBRARIES: php5, php5-curl
 * LICENSE, MORE INFO: 
 **************/

//set output header
header('Content-Type: application/xml');

//get uri of academia.edu profile from request parameter
//$uri = 'https://numismatics.academia.edu/EthanGruber';

//the line below is for passing request parameters from the command line.
//parse_str(implode('&', array_slice($argv, 1)), $_GET);
$uri = $_GET['uri'];

//develop XML serialization
$writer = new XMLWriter();
//$writer->openURI("response.xml");
$writer->openURI('php://output');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
$writer->setIndentString("    ");

//validate URI
if (preg_match('/https:\/\/[a-z]+\.academia.edu\/[A-Za-z]+/', $uri)){
	//initiate curl
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $uri);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	$output = curl_exec($ch);
	
	if(curl_exec($ch) !== FALSE) {
		process_html($output, $writer);
	}
	else {
		$writer->startElement('response');
			$writer->writeElement('error', 'Unable to retrieve data from Academia.edu URI.');
		$writer->endElement();
	}
	
	curl_close($ch);
} else {
	$writer->startElement('response');
		$writer->writeElement('error', 'URI does not validate.');
	$writer->endElement();
}

function process_html($output, $writer) {
	//get creator metadata
	preg_match('/c\.User\.set_viewed\((.*)\);\n/', $output, $matches);

	if (isset($matches[1])){
		$user = json_decode(trim($matches[1]));
	
		$userId = $user->id;
		$userName = $user->display_name;
		$url = $user->url;
	
		//process works
		preg_match_all('/workJSON:(.*)\n/', $output, $works);
	
		$count = 0;
		$writer->startElement('response');
		$writer->writeElement('id', $userId);
		$writer->writeElement('name', $userName);
		$writer->writeElement('url', $url);
		if (isset($works[1])){
			$writer->startElement('records');
			foreach ($works[1] as $work){
				$obj = json_decode(trim($work));
	
				//only gather those papers where the owner_id is the current user id.
				if ($obj->owner_id == $userId) {
					//only process papers, etc. that have associated document/presentation files
					if ($obj->attachments) {
	
						$writer->startElement('record');
							
						//by default, set migrate to boolean(true) to enable file upload and document migration
						$writer->writeAttribute('migrate', 'true');
						$writer->writeElement('id', $obj->id);
						$writer->writeElement('title', $obj->title);
						$writer->writeElement('url', $obj->internal_url);
						$writer->writeElement('access_right', 'open');
						$writer->writeElement('license', 'cc-by');
	
						if (isset($obj->section)){
							if ($obj->section == 'Papers'){
								$writer->writeElement('upload_type', 'publication');
	
								//if there are conference dates, then automatically set the publication_type as 'conferencepaper', othewise assume
								//it is an article
								if (isset($metadata->conference_start_date) || isset($metadata->conference_end_date)){
									$writer->writeElement('publication_type', 'conferencepaper');
								} else {
									$writer->writeElement('publication_type', 'article');
								}
							} else if ($obj->section == 'Talks'){
								$writer->writeElement('upload_type', 'presentation');
							}
						} else {
							//set defaults if there is no section
							$writer->writeElement('upload_type', 'publication');
							$writer->writeElement('publication_type', 'article');
						}
							
	
						//gather metadata
						$metadata = $obj->metadata;
	
						if (isset($metadata->abstract)){
							$writer->writeElement('abstract', $metadata->abstract);
						}
						if (isset($metadata->publication_name)){
							$writer->writeElement('publication_name', $metadata->publication_name);
						}
	
						if (isset($metadata->publication_date)){
							foreach ($metadata->publication_date as $k=>$v){
								if (is_string($v)){
									$writer->writeElement('publication_' . $k, $v);
								} else {
									$writer->writeElement('publication_' . $k, '');
								}
							}
						}
	
						if (isset($metadata->conference_start_date) || isset($metadata->conference_end_date)){
							$date = '';
							$date .= normalize_date($metadata->conference_start_date);
							if (isset($metadata->conference_start_date)){
								$date .= ' - ';
							}
							$date .= normalize_date($metadata->conference_end_date);
	
							if (isset($date)){
								$writer->writeElement('conference_dates', $date);
							}
	
							//extract journal title, publication name, or organization as the conference title
							if (isset($metadata->journal_name)){
								$writer->writeElement('conference_title', $metadata->journal_name);
							} else if (isset($metadata->organization)){
								$writer->writeElement('conference_title', $metadata->organization);
							} else if (isset($metadata->publication_name)){
								$writer->writeElement('conference_title', $metadata->publication_name);
							}
						}
	
						//assume location is the conference location
						if (isset($metadata->location)){
							//insert mandatory conference title if there's a location, but no conference dates
							if (!isset($metadata->conference_start_date) == 0 && !isset($metadata->conference_end_date)){
								$writer->writeElement('conference_title', '');
							}
	
							$writer->writeElement('conference_place', $metadata->location);
						}
	
						//insert journal title if conference dates are not used
						if (!isset($metadata->conference_start_date) && !isset($metadata->conference_end_date)){
							if (isset($metadata->journal_name)){
								$writer->writeElement('journal_title', $metadata->journal_name);
							}
						}
	
						//begin creators
						$writer->startElement('creators');
						//insert creator for self
						$writer->startElement('creator');
						if (isset($user->department->university->name)){
							$writer->writeAttribute('affiliation', $user->department->university->name);
						}
						$writer->text($userName);
						$writer->endElement();
							
						//list co-authors
						if (is_array($obj->co_author_tags)){
							foreach ($obj->co_author_tags as $creator){
								$writer->startElement('creator');
								$writer->writeAttribute('affiliation', $creator->affiliation);
								$writer->text($creator->name);
								$writer->endElement();
							}
						}
						$writer->endElement();
	
						$writer->endElement();
	
						//var_dump($obj);
					}
				}
				$count++;
			}
			//end records
			$writer->endElement();
		} else {
			$writer->writeElement('error', 'No works associated with this user id were parsed.');
		}
	
		//end response
		$writer->endElement();
	} else {
		$writer->startElement('response');
			$writer->writeElement('error', 'Unable to parse creator metadata to extract user id.');
		$writer->endElement();
	}	
}

//accept year, month, day integer values and return a human readable date
function normalize_date($date){
	$string = '';
	if (is_int($date->day)){
		$string .= $date->day;
	}
	
	if (is_int($date->month)){
		if (is_int($date->day)) {
			$string .= ' ';
		}
		switch ($date->month){
			case 1:
				$string .= 'January';
				break;
			case 2:
				$string .= 'February';
				break;
			case 3:
				$string .= 'March';
				break;
			case 4:
				$string .= 'April';
				break;
			case 5:
				$string .= 'May';
				break;
			case 6:
				$string .= 'June';
				break;
			case 7:
				$string .= 'July';
				break;
			case 8:
				$string .= 'August';
				break;
			case 9:
				$string .= 'September';
				break;
			case 10:
				$string .= 'October';
				break;
			case 11:
				$string .= 'November';
				break;
			case 12:
				$string .= 'December';
				break;
		}
	}
	
	if (is_int($date->year)){
		$string .= (is_int($date->month) || is_int($date->day) ? ' ' : '') . $date->year;
	}
	
	return $string;
}

//$writer->endElement();
//echo $output;

?>