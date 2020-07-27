/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BOrderServiceTest {
    @isTest
    public static void testGetOrderCurrencyMap() {
        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;

        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        insert c;

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;
        Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
        insert product;
        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
        insert pbe;

        Order order = CPQB2BTestFactory.createOrder(true, ac.Id, c.Id, standardPricebook.Id);
        insert order;

        OrderItem orderItem = CPQB2BTestFactory.createOrderItem(order.Id, product.Id, pbe.Id);
        insert orderItem;

        Map<Id, String> result = new CPQB2BOrderService().getOrderCurrencyMap(new List<OrderItem>{orderItem});
        System.assertEquals(result.get(order.Id), new CPQB2BMappingUtils().getCurrencyType(pbe));
    }

    @isTest
    public static void testGetContactUserMapForOrder() {
        Map<String, Object> testData = cc_TestDataFactory.setupAccountContactUser(false);
        Id userId = ((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)).Id;
        Id accountId = ((Account) testData.get(cc_TestDataFactory.TEST_CHILD_ACCOUNT)).Id;
        Id contactId = ((Contact) testData.get(cc_TestDataFactory.TEST_CONTACT)).Id;

        Product2 product = CPQB2BTestFactory.createProduct('P1', 'P1-C', true, true);
        insert product; 

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
        insert pbe;

        Order order = CPQB2BTestFactory.createOrder(true, accountId, contactId, standardPricebook.Id);
        order.ShipToContactId = contactId;
        insert order;

        OrderItem orderItem = CPQB2BTestFactory.createOrderItem(order.Id, product.Id, pbe.Id);
        insert orderItem;

        Map<Id, User> result = new CPQB2BOrderService().getContactUserMapForOrder(new List<Order>{order});
        System.assertEquals(result.get(contactid).Id, userId);
    }

    @isTest
    public static void testUpdateSyncedCPQOrders() {
        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;

        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        insert c;

        Opportunity opp = new Opportunity();
        opp.AccountId = ac.Id;
        opp.Name = 'hi';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.newInstance(2012, 12, 12);
        insert opp;

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(ac.Id, false, true, false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        insert quote;

        Order order = CPQB2BTestFactory.createOrder(false, ac.Id, c.Id, null);
        insert order;

        ccrz__E_ContactAddr__c ccAddress1 = new ccrz__E_ContactAddr__c();
        ccAddress1.ccrz__AddressFirstline__c = '123 Main Street';
        ccAddress1.ccrz__City__c = 'Noblesville';
        ccAddress1.ccrz__StateISOCode__c = 'IN';
        ccAddress1.ccrz__PostalCode__c = '46060';
        ccAddress1.ccrz__Country__c = 'USA';

        insert ccAddress1;

        ccrz__E_ContactAddr__c ccAddress2 = new ccrz__E_ContactAddr__c();
        ccAddress2.ccrz__AddressFirstline__c = '123 Main Street';
        ccAddress2.ccrz__City__c = 'Markle';
        ccAddress2.ccrz__StateISOCode__c = 'IN';
        ccAddress2.ccrz__PostalCode__c = '46770';
        ccAddress2.ccrz__Country__c = 'USA';

        insert ccAddress2;

        ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
        ccOrder.Sync_to_CPQ__c = true;
        ccOrder.ccrz__ShipTo__c = ccAddress1.Id;
        ccOrder.ccrz__BillTo__c = ccAddress2.Id;
        insert ccOrder;

        Map<Id, ccrz__E_Order__c> ccOrderMap = new Map<Id, ccrz__E_Order__c>();
        ccOrderMap.put(ccOrder.id, new CPQB2BCCOrderSelector().getByIds(new List<Id> { ccOrder.Id})[0]);

        order.SBQQ__Quote__c = quote.Id;
        order.B2B_Source_Order__c = ccOrder.Id;
        update order;

        Test.startTest();
        new CPQB2BOrderService().updateSyncedCPQOrders(new List<SBQQ__Quote__c> { quote }, ccOrderMap);
        Test.stopTest();

        Order result = [SELECT Id, Status, ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, 
        BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Order Limit 1];
        System.assertEquals(CPQB2BMappingSelector.getCustomOrderStatus(), result.Status);

        System.assertEquals(ccAddress1.ccrz__AddressFirstline__c, result.ShippingStreet);
        System.assertEquals(ccAddress1.ccrz__City__c, result.ShippingCity);
        System.assertEquals(ccAddress1.ccrz__StateISOCode__c, result.ShippingState);
        System.assertEquals(ccAddress1.ccrz__PostalCode__c, result.ShippingPostalCode);
        System.assertEquals(ccAddress1.ccrz__Country__c, result.ShippingCountry);

        System.assertEquals(ccAddress2.ccrz__AddressFirstline__c, result.BillingStreet);
        System.assertEquals(ccAddress2.ccrz__City__c, result.BillingCity);
        System.assertEquals(ccAddress2.ccrz__StateISOCode__c, result.BillingState);
        System.assertEquals(ccAddress2.ccrz__PostalCode__c, result.BillingPostalCode);
        System.assertEquals(ccAddress2.ccrz__Country__c, result.BillingCountry);
    }
}