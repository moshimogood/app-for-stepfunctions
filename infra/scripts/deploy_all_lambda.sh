#!/bin/bash
set -e

echo "=== Build Jar ==="
./gradlew clean shadowJar

JAR_PATH="build/libs/order-workflow.jar"

LAMBDAS=(
    OrderReceiveLambda
    InventoryLambda
    PaymentLambda
    ShippingLambda
    NotifyLambda
)

echo "=== Deploying Lambdas ==="

for FUNC in "${LAMBDAS[@]}"; do
    echo "Updating $FUNC..."
    aws lambda update-function-code \
        --function-name "$FUNC" \
        --zip-file "fileb://$JAR_PATH"
done

echo "=== Done ==="