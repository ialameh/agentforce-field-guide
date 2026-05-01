/**
 * @description Agent action that returns the status of an order.
 */
public with sharing class GetOrderStatus {

    @JsonAccess(serializable='always' deserializable='always')
    public class ActionInput {
        @InvocableVariable(
            label='Order ID'
            description='The order id, in format ORD-XXXX'
            required=true
        )
        public String order_id;
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class ActionOutput {

        public ActionOutput(String status, String expectedShipDate, String trackingUrl) {
            this.status = status;
            this.expected_ship_date = expectedShipDate;
            this.tracking_url = trackingUrl;
        }

        @InvocableVariable(label='Status' description='Current status of the order')
        public String status;

        @InvocableVariable(label='Expected Ship Date' description='ISO 8601 date when the order is expected to ship')
        public String expected_ship_date;

        @InvocableVariable(label='Tracking URL' description='Carrier tracking URL, empty if not yet shipped')
        public String tracking_url;
    }

    @InvocableMethod(
        label='Get Order Status'
        description='Returns the status, expected ship date, and tracking URL for an order id.'
        category='Orders'
        callout=false
    )
    public static List<ActionOutput> execute(List<ActionInput> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            throw new ActionException('No inputs provided.');
        }

        List<ActionOutput> outputs = new List<ActionOutput>();
        Set<String> orderIds = new Set<String>();

        for (ActionInput input : inputs) {
            validate(input);
            orderIds.add(input.order_id);
        }

        // Bulk query, single SOQL.
        Map<String, Order_Like__c> ordersById = new Map<String, Order_Like__c>();
        for (Order_Like__c o : [
            SELECT Order_Number__c, Status__c, Expected_Ship_Date__c, Tracking_URL__c
            FROM Order_Like__c
            WHERE Order_Number__c IN :orderIds
        ]) {
            ordersById.put(o.Order_Number__c, o);
        }

        for (ActionInput input : inputs) {
            Order_Like__c order = ordersById.get(input.order_id);
            if (order == null) {
                throw new OrderNotFoundException('Order ' + input.order_id + ' was not found.');
            }
            outputs.add(new ActionOutput(
                order.Status__c,
                order.Expected_Ship_Date__c == null ? '' : String.valueOf(order.Expected_Ship_Date__c),
                order.Tracking_URL__c == null ? '' : order.Tracking_URL__c
            ));
        }
        return outputs;
    }

    private static void validate(ActionInput input) {
        if (String.isBlank(input.order_id)) {
            throw new ActionException('order_id is required.');
        }
        if (!Pattern.matches('^ORD-\\d+$', input.order_id)) {
            throw new ActionException('order_id must match format ORD-XXXX, got: ' + input.order_id);
        }
    }

    public class ActionException extends Exception {}
    public class OrderNotFoundException extends Exception {}
}
