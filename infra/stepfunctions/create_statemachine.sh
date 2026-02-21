#!/bin/bash
set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

TMP_FILE=/tmp/order-workflow.resolved.json

sed \
  -e "s|\${ORDER_RECEIVE_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:OrderReceiveLambda|g" \
  -e "s|\${INVENTORY_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:InventoryLambda|g" \
  -e "s|\${PAYMENT_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:PaymentLambda|g" \
  -e "s|\${SHIPPING_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:ShippingLambda|g" \
  -e "s|\${NOTIFY_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:NotifyLambda|g" \
  -e "s|\${CANCEL_ORDER_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:CancelOrderLambda|g" \
  -e "s|\${FRAUD_CHECK_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:FraudCheckLambda|g" \
  -e "s|\${POINT_CALCULATE_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:PointCalculateLambda|g" \
  -e "s|\${ITEM_INVENTORY_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:ItemInventoryLambda|g" \
  -e "s|\${INVENTORY_AGGREGATE_LAMBDA_ARN}|arn:aws:lambda:$REGION:$ACCOUNT_ID:function:InventoryAggregateLambda|g" \
    infra/stepfunctions/order-workflow.asl.json \
  > "$TMP_FILE"

STATE_MACHINE_NAME="OrderWorkflow"
ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/OrderStepFunctionsRole"

# 既存があれば更新、なければ作成
aws stepfunctions update-state-machine \
  --state-machine-arn arn:aws:states:$REGION:$ACCOUNT_ID:stateMachine:$STATE_MACHINE_NAME \
  --definition file://$TMP_FILE \
  || \
aws stepfunctions create-state-machine \
  --name "$STATE_MACHINE_NAME" \
  --definition file://$TMP_FILE \
  --role-arn "$ROLE_ARN" \
  --type STANDARD

echo "Step Functions definition applied."
