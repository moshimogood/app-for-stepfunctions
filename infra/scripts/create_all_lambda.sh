#!/bin/bash
set -e

REGION="${AWS_REGION:-$(aws configure get region)}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/OrderLambdaRole"

JAR_PATH="build/libs/order-workflow.jar"

HANDRERS=(
    OrderReceiveLambda
    InventoryLambda
    PaymentLambda
    ShippingLambda
    NotifyLambda
    CancelOrderLambda
    FraudCheckLambda
    PointCalculateLambda
)


echo "=== Building Jar ==="
./gradlew clean shadowJar

for FUNC in "${HANDRERS[@]}"; do
    case "$FUNC" in
        OrderReceiveLambda)
            HANDLER="com.example.order.handler.OrderReceiveHandler::handleRequest"
            ;;
        InventoryLambda)
            HANDLER="com.example.order.handler.InventoryHandler::handleRequest"
            ;;
        PaymentLambda)
            HANDLER="com.example.order.handler.PaymentHandler::handleRequest"
            ;;
        ShippingLambda)
            HANDLER="com.example.order.handler.ShippingHandler::handleRequest"
            ;;
        NotifyLambda)
            HANDLER="com.example.order.handler.NotifyHandler::handleRequest"
            ;;
        CancelOrderLambda)
            HANDLER="com.example.order.handler.CancelOrderHandler::handleRequest"
            ;;
        FraudCheckLambda)
            HANDLER="com.example.order.handler.FraudCheckHandler::handleRequest"
            ;;
        PointCalculateLambda)
            HANDLER="com.example.order.handler.PointCalculateHandler::handleRequest"
            ;;
        *)
            echo "Unknown function: $FUNC"
            exit 1
            ;;
    esac

    echo "=== Deploying $FUNC ==="

    if aws lambda get-function --function-name "$FUNC" --region "$REGION" >/dev/null 2>&1
    then
      aws lambda update-function-code \
        --function-name "$FUNC" \
        --zip-file "fileb://$JAR_PATH" \
        --region "$REGION"

      aws lambda wait function-updated \
        --function-name "$FUNC" \
        --region "$REGION"

      aws lambda update-function-configuration \
        --function-name "$FUNC" \
        --handler "$HANDLER" \
        --runtime "java21" \
        --role "$ROLE_ARN" \
        --timeout 30 \
        --memory-size 512 \
        --region "$REGION"

      aws lambda wait function-updated \
        --function-name "$FUNC" \
        --region "$REGION"

    else
      aws lambda create-function \
        --function-name "$FUNC" \
        --runtime "java21" \
        --role "$ROLE_ARN" \
        --handler "$HANDLER" \
        --zip-file "fileb://$JAR_PATH" \
        --timeout 30 \
        --memory-size 512 \
        --architectures "x86_64" \
        --region "$REGION"
    fi
    
done

echo "DONE"
