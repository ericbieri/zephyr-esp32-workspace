#!/bin/bash

# Cleanup function
cleanup() {
    echo "Container stopping, cleaning up..."
    if [ -x /workspace/scripts/usbip/client/usbip-stop.sh ]; then
        echo "Stopping USBIP client..."
        /workspace/scripts/usbip/client/usbip-stop.sh
    fi
    exit 0
}

# Trap container stop signals
trap cleanup SIGTERM SIGINT

# Start USBIP client
if [ -x /workspace/scripts/usbip/client/usbip-start.sh ]; then
    echo "Starting USBIP client..."
    /workspace/scripts/usbip/client/usbip-start.sh
fi

# Executes the command passed as arguments to this script.
exec "$@"
