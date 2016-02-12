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

//the line below is for passing request parameters from the command line.
//parse_str(implode('&', array_slice($argv, 1)), $_GET);
$name = $_GET['name'];
$file = $_GET['file'];
$depositionId = $_GET['id'];
$env = $_GET['env'];
$zenodoAccessToken = $_GET['access_token'];

//set necessary curl variables
if ($env == 'dev'){
	$url = "https://sandbox.zenodo.org/api/deposit/depositions/{$depositionId}/files?access_token={$zenodoAccessToken}";	
} else if ($env = 'prod') {
	$url = "https://zenodo.org/api/deposit/depositions/{$depositionId}/files?access_token={$zenodoAccessToken}";
}

//execute as command line since php5-curl does not work correctly
echo exec('curl -F name=' . $name . ' -F file=@' . $file . ' ' . $url);

/*$headers = array("Content-Type:multipart/form-data"); // cURL headers for file uploading

//initiate curl
$ch = curl_init();
$options = array(
		CURLOPT_URL => $url,
		CURLOPT_HEADER => true,
		CURLOPT_POST => 1,
		CURLOPT_HTTPHEADER => $headers,
		CURLOPT_POSTFIELDS => $postfields,
		CURLOPT_RETURNTRANSFER => true,
		CURLOPT_INFILESIZE => filesize($file)
); // cURL options

curl_setopt_array($ch, $options);

echo "execute curl\n";
curl_exec($ch);

if(!curl_errno($ch))
{
	$info = curl_getinfo($ch);
	if ($info['http_code'] == 200)
		$errmsg = "File uploaded successfully";
}
else
{
	$errmsg = curl_error($ch);
}

curl_close($ch);*/

?>