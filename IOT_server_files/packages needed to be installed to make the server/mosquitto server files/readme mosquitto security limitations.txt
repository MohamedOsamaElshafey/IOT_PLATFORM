// all of this describes what found in the mosquito file
# =================================================================
# Security / Payload Protection
# =================================================================

# Limit the maximum size of any single MQTT message payload
# Messages larger than this will be rejected by the broker.
message_size_limit 1048576   # 1 MB

# Limit total memory usage of the broker (for inflight messages, queues, etc.)
# Setting this prevents the broker from using more than 1 GB of RAM
memory_limit 1073741824      # 1024*1024*1024 bytes = 1 GB

# Limit maximum number of inflight messages per client (prevents flooding)
# Each client can only have up to 20 messages being sent and waiting for acknowledgment
max_inflight_messages 20