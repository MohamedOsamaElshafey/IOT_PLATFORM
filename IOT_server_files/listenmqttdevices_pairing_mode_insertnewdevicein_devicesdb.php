<?php
// ==================================================
// MQTT PHP Listener with HTML Debug Output
// ==================================================

// Include the existing database connection file
include "db.php"; // provides $conn as a mysqli connection

// Enable full error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Prevent PHP script from timing out (run indefinitely)
set_time_limit(0);

// Enable MySQLi exceptions for better error handling
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

// Force output to the browser immediately for live debug updates
ob_implicit_flush(true);
ob_end_flush();

// Start HTML output for browser display
echo "<!DOCTYPE html><html><head><title>MQTT Debug</title></head><body>";
echo "<h1>MQTT PHP Debug Output</h1><pre>";

// ==================================================
// Include phpMQTT library
// ==================================================
require_once("C:/xampp/htdocs/phpMQTT-master/phpMQTT.php");
use Bluerhinos\phpMQTT;

// ==================================================
// MQTT Broker Configuration
// ==================================================
$server    = '127.0.0.1';                     // MQTT broker host
$port      = 1883;                            // MQTT broker port
$client_id = 'php-mqtt-pairing_' . uniqid();  // Unique client ID
$username  = '';                               // MQTT username (if required)
$password  = '';                               // MQTT password (if required)
$useTLS    = false;                            // Use TLS (WSS) if true

// Create MQTT client instance
$mqtt = new phpMQTT($server, $port, $client_id);

// Attempt to connect to MQTT broker
if (!$mqtt->connect(true, NULL, $username, $password, $useTLS)) {
    echo "Failed to connect to MQTT broker\n</pre></body></html>";
    exit; // Stop execution if connection fails
}
echo "[".date('Y-m-d H:i:s')."] Connected to MQTT broker\n";

// ==================================================
// Define subscription topic (per-device, using wildcard +)
// ==================================================
$subscribe_topic = 'devices/server/+/pairing_mode/pairing_data/';

// ==================================================
// Callback function executed when a message is received
// ==================================================
$callback = function($topic, $msg) use ($mqtt, $conn) {
    // Print debug info for topic and message
    echo "[".date('Y-m-d H:i:s')."] Callback for topic: $topic\n";
    echo "Message: $msg\n";

    // Decode the JSON message payload
    $data = json_decode($msg, true);
    if (!$data) {
        echo "Invalid JSON\n";
        return;
    }

    // Define required fields in the JSON
    $requiredFields = ['device_type','owner_user_id','ch1_value','ch2_value','ch3_value','ch4_value'];
    foreach ($requiredFields as $f) {
        if (!isset($data[$f])) {
            echo "Missing $f\n";
            return;
        }
    }

    // Extract MAC address from topic
    // Topic format: devices/server/<mac_address>/pairing_mode/pairing_data
    $parts = explode('/', $topic);
    if (count($parts) < 5) {
        echo "Invalid topic format\n"; 
        return; 
    }
    $mac_address = $parts[2]; // 3rd segment is MAC address

    try {
        // Prepare SQL statement to insert or update device in DB
        $stmt = $conn->prepare("
            INSERT INTO devices (
                mac_address, device_type,
                ch1_value, ch2_value, ch3_value, ch4_value,
                owner_user_id, last_seen, online
            ) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), 1)
            ON DUPLICATE KEY UPDATE
                device_type=VALUES(device_type),
                ch1_value=VALUES(ch1_value),
                ch2_value=VALUES(ch2_value),
                ch3_value=VALUES(ch3_value),
                ch4_value=VALUES(ch4_value),
                owner_user_id=VALUES(owner_user_id),
                last_seen=NOW(),
                online=1
        ");

        // Bind variables to the prepared statement (types: s=string, d=double, i=int)
        $stmt->bind_param(
            "ssddddi",
            $mac_address,
            $data['device_type'],
            $data['ch1_value'],
            $data['ch2_value'],
            $data['ch3_value'],
            $data['ch4_value'],
            $data['owner_user_id']
        );

        // Execute SQL statement
        $stmt->execute();
        echo "Device $mac_address paired successfully\n";

        // Publish acknowledgment back to the device-specific topic
        $ack_topic = "devices/server/$mac_address/pairing_mode/ack/";
        $mqtt->publish($ack_topic,json_encode([
            "message" => "Device paired successfully",
           
        ]),0);
        echo "Acknowledgment sent to $ack_topic\n";

        // Close statement (do NOT close $conn as it's shared)
        $stmt->close();
    } catch (mysqli_sql_exception $e) {
        echo "Database error: ".$e->getMessage()."\n";
    }
};

// ==================================================
// Subscribe to the wildcard topic
// ==================================================
$mqtt->subscribe([
    $subscribe_topic => [
        'qos' => 0,
        'function' => $callback
    ]
]);
echo "[".date('Y-m-d H:i:s')."] Subscribed to topic $subscribe_topic\n";

// ==================================================
// Main loop to keep processing incoming MQTT messages
// ==================================================
while ($mqtt->proc()) {
    usleep(100000); // Sleep 0.1s to reduce CPU usage
}

// Close MQTT connection (normally never reached)
$mqtt->close();

echo "</pre></body></html>";
?>