
<?php
include "db.php";
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Adjust the path relative to register.php
require 'codes needed to control casperwe.eg@gmail.com/PHPMailer-master/PHPMailer-master/src/Exception.php';
require 'codes needed to control casperwe.eg@gmail.com/PHPMailer-master/PHPMailer-master/src/PHPMailer.php';
require 'codes needed to control casperwe.eg@gmail.com/PHPMailer-master/PHPMailer-master/src/SMTP.php';

// Only allow POST
if ($_SERVER["REQUEST_METHOD"] != "POST") {
    die("Invalid request.");
}

// Get input safely
$name     = trim($_POST['name'] ?? '');
$email    = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

// Check empty
if ($name == "" || $email == "" || $password == "") {
    die("All fields are required.");
}

// Check if email exists
$stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    die("This email is already registered.");
}

// Generate OTP (6 digits)
$otp = rand(100000, 999999);

// Hash password
$hashed = password_hash($password, PASSWORD_DEFAULT);

// Not verified yet
$is_verified = 0;

// Insert user
$sql = "INSERT INTO users
(name, email, password, is_verified, verify_otp, otp_expire)
VALUES (?, ?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))";

$stmt = $conn->prepare($sql);

$stmt->bind_param(
    "sssis",
    $name,
    $email,
    $hashed,
    $is_verified,
    $otp
);

if ($stmt->execute()) {

    // ----------------------
    // PHPMailer Gmail Setup
    // ----------------------
    $mail = new PHPMailer(true);

    try {
        // Server settings
        $mail->isSMTP();
        $mail->Host       = 'smtp.gmail.com';
        $mail->SMTPAuth   = true;
        $mail->Username   = 'casperwe.eg@gmail.com'; // Your Gmail
        $mail->Password   = 'xbicbrlmgrqerxmd'; // Gmail App Password
        $mail->SMTPSecure = 'tls';
        $mail->Port       = 587;

        // Recipients
        $mail->setFrom('casperwe.eg@gmail.com', 'Casper WE');
        $mail->addAddress($email, $name); // User email

        // Content
        $mail->isHTML(true);
        $mail->Subject = 'Your OTP Verification Code';
        $mail->Body    = "
            <h2>Hello $name</h2>
            <p>Your OTP code is:</p>
            <h1>$otp</h1>
            <p>This code expires in 15 minutes.</p>
            <small>Do not share this code.</small>
        ";
        $mail->AltBody = "Hello $name, Your OTP is: $otp";

        $mail->send();

        echo "Registration successful.\nPlease check your email for the OTP code.";

    } catch (Exception $e) {
        echo "Registration succeeded but email could not be sent. Mailer Error: {$mail->ErrorInfo}";
    }

} else {
    echo "Registration failed. Try again.";
}
?>

