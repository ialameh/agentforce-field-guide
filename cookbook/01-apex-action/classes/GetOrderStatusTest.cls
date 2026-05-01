@IsTest
public with sharing class GetOrderStatusTest {

    @TestSetup
    static void setup() {
        insert new Order_Like__c(
            Order_Number__c = 'ORD-1234',
            Status__c = 'Shipped',
            Expected_Ship_Date__c = Date.newInstance(2026, 5, 1),
            Tracking_URL__c = 'https://tracking.example.com/ORD-1234'
        );
    }

    @IsTest
    static void execute_existingOrder_returnsStatus() {
        GetOrderStatus.ActionInput input = new GetOrderStatus.ActionInput();
        input.order_id = 'ORD-1234';

        Test.startTest();
        List<GetOrderStatus.ActionOutput> outputs = GetOrderStatus.execute(
            new List<GetOrderStatus.ActionInput>{input}
        );
        Test.stopTest();

        System.assertEquals(1, outputs.size());
        System.assertEquals('Shipped', outputs[0].status);
        System.assertEquals('https://tracking.example.com/ORD-1234', outputs[0].tracking_url);
    }

    @IsTest
    static void execute_blankOrderId_throws() {
        GetOrderStatus.ActionInput input = new GetOrderStatus.ActionInput();
        input.order_id = '';

        Test.startTest();
        try {
            GetOrderStatus.execute(new List<GetOrderStatus.ActionInput>{input});
            System.assert(false, 'Expected ActionException');
        } catch (GetOrderStatus.ActionException e) {
            System.assert(e.getMessage().contains('required'));
        }
        Test.stopTest();
    }

    @IsTest
    static void execute_invalidFormat_throws() {
        GetOrderStatus.ActionInput input = new GetOrderStatus.ActionInput();
        input.order_id = 'not-a-real-id';

        Test.startTest();
        try {
            GetOrderStatus.execute(new List<GetOrderStatus.ActionInput>{input});
            System.assert(false, 'Expected ActionException');
        } catch (GetOrderStatus.ActionException e) {
            System.assert(e.getMessage().contains('format'));
        }
        Test.stopTest();
    }

    @IsTest
    static void execute_nonExistentOrder_throws() {
        GetOrderStatus.ActionInput input = new GetOrderStatus.ActionInput();
        input.order_id = 'ORD-9999';

        Test.startTest();
        try {
            GetOrderStatus.execute(new List<GetOrderStatus.ActionInput>{input});
            System.assert(false, 'Expected OrderNotFoundException');
        } catch (GetOrderStatus.OrderNotFoundException e) {
            System.assert(e.getMessage().contains('not found'));
        }
        Test.stopTest();
    }

    @IsTest
    static void execute_bulkShape_handlesMultipleInputs() {
        insert new Order_Like__c(
            Order_Number__c = 'ORD-2000',
            Status__c = 'Pending'
        );

        List<GetOrderStatus.ActionInput> inputs = new List<GetOrderStatus.ActionInput>();
        for (String id : new List<String>{'ORD-1234', 'ORD-2000'}) {
            GetOrderStatus.ActionInput in_ = new GetOrderStatus.ActionInput();
            in_.order_id = id;
            inputs.add(in_);
        }

        Test.startTest();
        List<GetOrderStatus.ActionOutput> outputs = GetOrderStatus.execute(inputs);
        Test.stopTest();

        System.assertEquals(2, outputs.size());
    }
}
