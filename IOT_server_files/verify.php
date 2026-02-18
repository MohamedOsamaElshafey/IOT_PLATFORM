<?php
include "db.php";

// Only allow POST
if ($_SERVER["REQUEST_METHOD"] != "POST") {
    die("Invalid request.");
}

// Get input
$email = trim($_POST['email'] ?? '');
$otp   = trim($_POST['otp'] ?? '');

if ($email == "" || $otp == "") {
    die("Email and OTP are required.");
}

/*
|--------------------------------------------------------------------------
| 1. Check if OTP exists but expired
|--------------------------------------------------------------------------
*/
$sqlExpired = "SELECT id FROM users
               WHERE email = ?
               AND verify_otp = ?
               AND otp_expire <= NOW()
               AND is_verified = 0";

$stmtExpired = $conn->prepare($sqlExpired);
$stmtExpired->bind_param("ss", $email, $otp);
$stmtExpired->execute();
$resultExpired = $stmtExpired->get_result();

if ($resultExpired->num_rows > 0) {

    // Delete expired registration
    $sqlDelete = "DELETE FROM users WHERE email = ?";
    $stmtDelete = $conn->prepare($sqlDelete);
    $stmtDelete->bind_param("s", $email);
    $stmtDelete->execute();

    echo "OTP expired. Please register again.";
    exit;
}

/*
|--------------------------------------------------------------------------
| 2. Check valid OTP
|--------------------------------------------------------------------------
*/
$sql = "SELECT id FROM users
        WHERE email = ?
        AND verify_otp = ?
        AND otp_expire > NOW()
        AND is_verified = 0";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $email, $otp);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 1) {

    $row = $result->fetch_assoc();
    $user_id = $row['id'];

    // Activate account
    $sql2 = "UPDATE users SET
             is_verified = 1,
             verify_otp = NULL,
             otp_expire = NULL
             WHERE id = ?";

    $stmt2 = $conn->prepare($sql2);
    $stmt2->bind_param("i", $user_id);
    $stmt2->execute();

    echo " Your email has been verified successfully.";

} else {

    echo "❌ Invalid OTP.";
}
?>
