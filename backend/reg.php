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

    $keresztnev = $_POST['keresztnev'];
    $vezeteknev = $_POST['vezeteknev'];
    $email = $_POST['email'];
    $jelszo = $_POST['jelszo'];
    $eletkor = $_POST['eletkor'];
    $nem = $_POST['nem'];

    $sql = "INSERT INTO users (vezeteknev, keresztnev, email, jelszo, eletkor, nem)
    VALUES ('$keresztnev', '$vezeteknev', '$email', '$jelszo', '$eletkor', '$nem')";

    if (!($conn->query($sql) === TRUE)) {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }

    $conn->close();

    header("Location: index.php");
?>