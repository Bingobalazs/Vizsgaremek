<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

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

    $sql = "SELECT vezeteknev, keresztnev, email FROM users";
    $result = $conn->query($sql);
    
    if ($result->num_rows > 0) {
        echo "<table class='table'><tr><th>Név</th><th>Email</th></tr>";
        // output data of each row
        while($row = $result->fetch_assoc()) {
            echo "<tr><td>" . $row["vezeteknev"] . " " . $row["keresztnev"] . "</td><td>" . $row["email"] . "</td></tr>";
        }
        echo "</table>";
    } else {
        echo "0 results";
    }
    
    $conn->close();
?>
<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mindenki</title>
</head>
<body>
    
</body>
</html>