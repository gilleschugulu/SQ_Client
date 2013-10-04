<?php

define('LEQUIPE_API_URL', 'http://api.lequipe.fr/Compte/appels_tiers.php');

function call($url, $query, $params)
{
    $url = $url.'?'.$query;
    // die(var_dump($url, $params));
    $curl = curl_init();

    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($params));
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_SSLVERSION, 3);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($curl, CURLOPT_HEADER, true);
    curl_setopt($curl, CURLOPT_FAILONERROR, false);

    $response = curl_exec($curl);
    $header_size = curl_getinfo($curl, CURLINFO_HEADER_SIZE);
    $headers = explode("\r\n", substr($response, 0, $header_size));
    $body = substr($response, $header_size);

    curl_close($curl);
    return array('body' => $body, 'headers' => $headers);
}

$response = call(LEQUIPE_API_URL, $_SERVER['QUERY_STRING'], $_POST);
foreach ($response['headers'] as $value)
    header(trim($value));
die(trim($response['body']));