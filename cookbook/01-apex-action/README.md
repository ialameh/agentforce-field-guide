# Example 1. Apex action: order status lookup

A complete worked example of an Apex `@InvocableMethod` exposed as an agent action. The agent can ask "what's the status of order ORD-1234?" and the action returns the status, expected ship date, and tracking link if available.

## What you get

- An Apex class with input and output wrappers, validation, and error handling.
- A test class with happy path, validation failures, and a not-found case.
- A `GenAiFunction` wrapper with input and output JSON Schemas.
- A permission set granting access.
- An `.agent` snippet showing how to link the action to a topic.

## Files

```
01-apex-action/
    classes/
        GetOrderStatus.cls
        GetOrderStatus.cls-meta.xml
        GetOrderStatusTest.cls
        GetOrderStatusTest.cls-meta.xml
    genAiFunctions/
        Get_Order_Status/
            Get_Order_Status.genAiFunction-meta.xml
            input/schema.json
            output/schema.json
    permissionsets/
        Order_Status_Action.permissionset-meta.xml
```

## Deploy and verify

```bash
# Deploy in order
sf project deploy start -d cookbook/01-apex-action/classes -o <ORG>
sf project deploy start -d cookbook/01-apex-action/permissionsets -o <ORG>
sf project deploy start -d cookbook/01-apex-action/genAiFunctions -o <ORG>

# Assign permission set to the agent user
sf org assign permset -n Order_Status_Action -o <ORG>

# Confirm the action is registered
TOK=$(sf org display -o <ORG> --json | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["accessToken"])')
INSTANCE=$(sf org display -o <ORG> --json | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["instanceUrl"])')

curl -s -H "Authorization: Bearer $TOK" \
  "$INSTANCE/services/data/v62.0/actions/custom/apex/GetOrderStatus" \
  | python3 -m json.tool
```

## Add to your agent

In the Builder, open your agent. Find the topic that handles order questions. Click "Add Action", select "Get Order Status". Map the input `Order ID` to wherever you collect the order id. Map the outputs `Status`, `Expected Ship Date`, and `Tracking URL` to variables your topic will use. Save. Activate.

If you prefer to author from source, here is the `.agent` snippet:

```yaml
actions:
    Get_Order_Status:
        label: "Get Order Status"
        description: "Returns the status, expected ship date, and tracking URL for an order id."
        target: "apex://GetOrderStatus"
        inputs:
            order_id: string
                label: "Order ID"
                description: "The order id, in format ORD-XXXX"
                is_required: True
                complex_data_type_name: "lightning__textType"
                is_user_input: True
                filter_from_agent: False
                is_displayable: False
        outputs:
            status: string
                label: "Status"
                description: "Current status of the order"
                complex_data_type_name: "lightning__textType"
                developer_name: "status"
                is_displayable: True
                filter_from_agent: False
            expected_ship_date: string
                label: "Expected Ship Date"
                description: "ISO 8601 date when the order is expected to ship"
                complex_data_type_name: "lightning__textType"
                developer_name: "expected_ship_date"
                is_displayable: True
                filter_from_agent: False
            tracking_url: string
                label: "Tracking URL"
                description: "Carrier tracking URL, empty if not yet shipped"
                complex_data_type_name: "lightning__textType"
                developer_name: "tracking_url"
                is_displayable: True
                filter_from_agent: False
```

## Test it

In the Builder's test mode, type "What's the status of order ORD-1234?". The agent should ask for clarification if the order does not exist, return the status if it does. Watch the action trace to confirm `Get_Order_Status` fires.

## Things to notice

- **Validation in three layers.** The schema requires `order_id`. The `@InvocableVariable` marks it `required=true`. The Apex method validates that the value matches the expected format. Defence in depth.
- **Bulk shape.** The method returns a list, even though most invocations are single. The platform's invocable runner expects this.
- **Specific exceptions.** A custom `OrderNotFoundException` is thrown when the order does not exist. The agent runtime sees the exception and the topic instructions can handle it gracefully.
- **No external callouts.** The action is fast and cheap. If the data lived externally, you would queue a callout (see Example 4).
