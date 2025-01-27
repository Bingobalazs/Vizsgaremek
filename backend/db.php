<?php
$servername = "localhost";
$username = "kovacscsabi";
$password = "thisIsMor1czCloudMF!?";
$dbname = "kovacscsabi_wp";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
?>