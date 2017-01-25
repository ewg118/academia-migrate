<?php 
 /**************
 * AUTHOR: Ethan Gruber
 * DATE: Feburary 2016
 * FUNCTION: Accept URL parameters for file, filename, deposition id, and Zenodo access token to post the file to Zenodo
 * REQUIRED LIBRARIES: php5, php5-curl, php5-cgi
 * LICENSE, MORE INFO: 
 **************/
 
//set output header
header('Content-Type: application/json');

//set the environment, 'dev', or 'prod'
$env = 'dev';

//the line below is for passing request parameters from the command line.
//parse_str(implode('&', array_slice($argv, 1)), $_GET);
$name = $_GET['name'];
$file = $_GET['file'];
$depositionId = $_GET['id'];
$zenodoAccessToken = $_GET['access_token'];

//set necessary curl variables
if ($env == 'dev'){
	$url = "https://sandbox.zenodo.org/api/deposit/depositions/{$depositionId}/files?access_token={$zenodoAccessToken}";	
} else if ($env = 'prod') {
	$url = "https://zenodo.org/api/deposit/depositions/{$depositionId}/files?access_token={$zenodoAccessToken}";
}

//execute as command line since php5-curl does not work correctly
$curl = "curl -F 'name={$name}' -F 'file=@{$file}' {$url}";
echo exec($curl);

?>