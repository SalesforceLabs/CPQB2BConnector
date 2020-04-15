@isTest
public class CPQB2BCCOrderSelectorTest {

    @isTest
    public static void testGetByIds() {
        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;

        ccrz__E_ContactAddr__c ccAddress1 = new ccrz__E_ContactAddr__c();
        ccAddress1.ccrz__AddressFirstline__c = '123 Main Street';
        ccAddress1.ccrz__City__c = 'Noblesville';
        ccAddress1.ccrz__State__c = 'Indiana';
        ccAddress1.ccrz__StateISOCode__c = 'IN';
        ccAddress1.ccrz__PostalCode__c = '46060';
        ccAddress1.ccrz__Country__c = 'USA';

        insert ccAddress1;

        ccrz__E_ContactAddr__c ccAddress2 = new ccrz__E_ContactAddr__c();
        ccAddress2.ccrz__AddressFirstline__c = '123 Main Street';
        ccAddress2.ccrz__City__c = 'Markle';
        ccAddress2.ccrz__State__c = 'Indiana';
        ccAddress1.ccrz__StateISOCode__c = 'IN';
        ccAddress2.ccrz__PostalCode__c = '46770';
        ccAddress2.ccrz__Country__c = 'USA';

        insert ccAddress2;

        ccrz__E_Order__c order = CPQB2BTestFactory.createCCOrder(ac.Id);
        order.Sync_to_CPQ__c = true;
        order.ccrz__ShipTo__c = ccAddress1.Id;
        order.ccrz__BillTo__c = ccAddress2.Id;
        insert order;

        List<ccrz__E_Order__c> results = new CPQB2BCCOrderSelector().getByIds(new List<Id> { order.Id });
        System.assertEquals(1, results.size());

        ccrz__E_Order__c result = results[0];
        System.assertEquals(order.ccrz__Account__c, result.ccrz__Account__c);
        System.assertEquals(order.ccrz__CurrencyISOCode__c, result.ccrz__CurrencyISOCode__c);
        System.assertEquals(order.ccrz__OrderDate__c, result.ccrz__OrderDate__c);       
        System.assertEquals(order.ccrz__Name__c, result.ccrz__Name__c);    
        System.assertEquals(order.ccrz__OrderStatus__c, result.ccrz__OrderStatus__c);   
        System.assertEquals(order.Sync_to_CPQ__c, result.Sync_to_CPQ__c);   

        System.assertEquals(ccAddress1.ccrz__AddressFirstline__c, result.ccrz__ShipTo__r.ccrz__AddressFirstline__c);
        System.assertEquals(ccAddress1.ccrz__City__c, result.ccrz__ShipTo__r.ccrz__City__c);
        System.assertEquals(ccAddress1.ccrz__State__c, result.ccrz__ShipTo__r.ccrz__State__c);
        System.assertEquals(ccAddress1.ccrz__StateISOCode__c, result.ccrz__ShipTo__r.ccrz__StateISOCode__c);
        System.assertEquals(ccAddress1.ccrz__PostalCode__c, result.ccrz__ShipTo__r.ccrz__PostalCode__c);
        System.assertEquals(ccAddress1.ccrz__Country__c, result.ccrz__ShipTo__r.ccrz__Country__c);

        System.assertEquals(ccAddress2.ccrz__AddressFirstline__c, result.ccrz__BillTo__r.ccrz__AddressFirstline__c);
        System.assertEquals(ccAddress2.ccrz__City__c, result.ccrz__BillTo__r.ccrz__City__c);
        System.assertEquals(ccAddress2.ccrz__State__c, result.ccrz__BillTo__r.ccrz__State__c);
        System.assertEquals(ccAddress2.ccrz__StateISOCode__c, result.ccrz__BillTo__r.ccrz__StateISOCode__c);
        System.assertEquals(ccAddress2.ccrz__PostalCode__c, result.ccrz__BillTo__r.ccrz__PostalCode__c);
        System.assertEquals(ccAddress2.ccrz__Country__c, result.ccrz__BillTo__r.ccrz__Country__c);
    }

    @isTest
    public static void testGetBySourceIds() {
        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;

        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        insert c;

        Order o = CPQB2BTestFactory.createOrder(true, ac.Id, c.Id, null);
        insert o;
        
        ccrz__E_Order__c ccOrder;
        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.OrderToCCOrder)){
            ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
            insert ccOrder;
        }

        List<ccrz__E_Order__c> results = new CPQB2BCCOrderSelector().getBySourceOrderIds(new List<Id> { o.Id });
        System.assertEquals(1, results.size());
    }

    @isTest
    public static void testGetCCOrdersToSync() {
        System.Assert(new CPQB2BCCOrderSelector().getCCOrdersToSync() != null);
    }
}