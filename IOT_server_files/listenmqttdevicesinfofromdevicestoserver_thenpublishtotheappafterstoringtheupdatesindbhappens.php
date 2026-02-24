<?php
// ==================================================
// Prevent PHP from timing out (run indefinitely)
// ==================================================
set_time_limit(0); // Allow the script to run forever without timing out

// ==================================================
// Include phpMQTT Library
// ==================================================
require_once("C:/xampp/htdocs/phpMQTT-master/phpMQTT.php"); // Include the phpMQTT library
use Bluerhinos\phpMQTT; // Use the phpMQTT namespace

// ==================================================
// MQTT Broker Configuration
// ==================================================
$server = '127.0.0.1'; // MQTT broker address (localhost)
$port = 1883;           // MQTT broker port
$client_id = 'php_server_listener_' . uniqid(); // Unique client ID for this script
$username = '';          // MQTT username (if required)
$password = '';          // MQTT password (if required)
$useTLS = true;          // Enable TLS for secure WebSocket (WSS)

// ==================================================
// Create MQTT Client and Connect
// ==================================================
$mqtt = new phpMQTT($server, $port, $client_id); // Create a new MQTT client

// Connect to broker via TLS/WSS
if (!$mqtt->connect(true, NULL, $username, $password, $useTLS)) {
    exit("Failed to connect to MQTT broker via WSS\n"); // Exit if connection fails
}
echo "Connected to MQTT broker via WSS!\n"; // Log success

// ==================================================
// MQTT Topic Subscription
// ==================================================
$topic = "devices/server/+/device_channels_values_device_ack_to_the_server/"; 
// '+' wildcard matches any MAC address dynamically

// ==================================================
// Callback Function for Incoming MQTT Messages
// ==================================================
$callback = function($topic, $msg) use ($mqtt) {
    echo "[" . date('Y-m-d H:i:s') . "] Message received on topic: $topic\n";

    // Decode JSON payload from device
    $data = json_decode($msg, true);
    if (!$data) return; // Skip if payload is invalid JSON

    // Extract channel values from message
    $ch1 = $data['ch1_value'] ?? null;
    $ch2 = $data['ch2_value'] ?? null;
    $ch3 = $data['ch3_value'] ?? null;
    $ch4 = $data['ch4_value'] ?? null;

    // Extract device MAC address from topic
    preg_match("/devices\/server\/(.+)\/device_channels_values_device_ack_to_the_server\//", $topic, $matches);
    if (!isset($matches[1])) return; // Skip if MAC address not found
    $mac_address = $matches[1];

    // Connect to MySQL database
    $mysqli = new mysqli("localhost", "root", "", "u.t.m_tech");
    if ($mysqli->connect_error) return; // Skip if DB connection fails

    // ==================================================
    // Update Device in Database
    // ==================================================
    $stmt = $mysqli->prepare("
        UPDATE devices SET
            ch1_value = ?,
            ch2_value = ?,
            ch3_value = ?,
            ch4_value = ?,
            last_seen = NOW(),
            online = 1
        WHERE mac_address = ?
    ");
    $stmt->bind_param("dddds", $ch1, $ch2, $ch3, $ch4, $mac_address);
    $stmt->execute();

    // ==================================================
    // Publish Acknowledgment to App
    // ==================================================
    if ($stmt->affected_rows > 0) {
        echo "Device $mac_address updated successfully\n";

        // Prepare acknowledgment payload
        $ack_payload = json_encode([
            'ch1_value' => $ch1,
            'ch2_value' => $ch2,
            'ch3_value' => $ch3,
            'ch4_value' => $ch4,
            'online'    => 1
        ]);

        // Publish acknowledgment to app topic
        $ack_topic = "server/app/$mac_address/device_channels_values_server_ack_to_the_app/";
        $mqtt->publish($ack_topic, $ack_payload, 0, false);
        echo "Acknowledgment published to $ack_topic\n";
    } else {
        echo "Device $mac_address not found — skipping update.\n";
    }

    // Close statement and database connection
    $stmt->close();
    $mysqli->close();
};

// ==================================================
// Subscribe to MQTT Topic
// ==================================================
$mqtt->subscribe([$topic => ['qos' => 0, 'function' => $callback]]);

// ==================================================
// Offline Detection Configuration
// ==================================================
$offline_check_interval = 60; // Check every 60 seconds
$offline_timeout = 300;       // Consider offline if no updates for 5 minutes
$last_offline_check = time(); // Track last offline check time

// ==================================================
// Main Loop
// ==================================================
while ($mqtt->proc()) {

    // Check periodically for offline devices
    if (time() - $last_offline_check >= $offline_check_interval) {
        $mysqli = new mysqli("localhost", "root", "", "u.t.m_tech");
        if (!$mysqli->connect_error) {

            // Step 1: Select devices that are online but inactive
            $stmt = $mysqli->prepare("
                SELECT mac_address, ch1_value, ch2_value, ch3_value, ch4_value
                FROM devices
                WHERE online = 1 AND last_seen IS NOT NULL
                AND last_seen < (NOW() - INTERVAL ? SECOND)
            ");
            $stmt->bind_param("i", $offline_timeout);
            $stmt->execute();
            $result = $stmt->get_result();

            // Step 2: Loop through offline devices
            while ($row = $result->fetch_assoc()) {
                $mac_address = $row['mac_address'];
                $ch1 = $row['ch1_value'];
                $ch2 = $row['ch2_value'];
                $ch3 = $row['ch3_value'];
                $ch4 = $row['ch4_value'];

                // Step 3: Update database: mark device as offline
                $update_stmt = $mysqli->prepare("
                    UPDATE devices SET online = 0
                    WHERE mac_address = ?
                ");
                $update_stmt->bind_param("s", $mac_address);
                $update_stmt->execute();
                $update_stmt->close();

                echo "[" . date('Y-m-d H:i:s') . "] Device $mac_address marked offline\n";

                // Step 4: Publish offline notification to app
                $offline_payload = json_encode([
                    'ch1_value' => $ch1,
                    'ch2_value' => $ch2,
                    'ch3_value' => $ch3,
                    'ch4_value' => $ch4,
                    'online'    => 0
                ]);
                $offline_topic = "server/app/$mac_address/device_channels_values_server_ack_to_the_app/";
                $mqtt->publish($offline_topic, $offline_payload, 0, false);

                echo "Offline notification published to $offline_topic\n";
            }

            $stmt->close();
        }

        $mysqli->close();
        $last_offline_check = time(); // Reset last check timestamp
    }
}

// Close MQTT connection (never reached in this script)
$mqtt->close();
?>