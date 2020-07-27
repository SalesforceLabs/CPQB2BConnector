/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public class CPQB2BTestHelper {

    public void syncOrderToCCOrder(CPQB2BTestInt ti, String sObjectName) {
        Map<String, Object> testData = cc_TestDataFactory.setupAccountContactUser(false);

        Product2 product = CPQB2BTestFactory.createProduct('P1', 'P1-C', true, true);
        insert product;

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
        insert pbe;

        Test.startTest();

        ccrz__E_Cart__c ccCart = CPQB2BTestFactory.createCCCart(testData);

        Id userId = ((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)).Id;
        Id accountId = ((Account) testData.get(cc_TestDataFactory.TEST_CHILD_ACCOUNT)).Id;
        Id contactId = ((Contact) testData.get(cc_TestDataFactory.TEST_CONTACT)).Id;

        System.runAs((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)){
            String additionalDetails = 'Sample additional details text!';
            CPQB2BQuoteBtnCtrl.calculateQuote(ccCart.ccrz__EncryptedId__c,additionalDetails);
        }

        Test.stopTest();

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Order order = CPQB2BTestFactory.createOrder(true, accountId, contactId, standardPricebook.Id);
        insert order;

        OrderItem orderItem = CPQB2BTestFactory.createOrderItem(order.Id, product.Id, pbe.Id);
        insert orderItem;

        ccrz__E_Product__c ccProduct;

        order.SBQQ__Quote__c = quote.Id;
        update order;

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
            ccProduct = CPQB2BTestFactory.createCCProduct(product);
            insert ccProduct;
        }

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.OrderToCCOrder)){
            ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(accountId);
            ccOrder.ccrz__OriginatedCart__c = quote.Id;
            insert ccOrder;

            ccrz__E_OrderItem__c ccOrderItem = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct.Id);
            insert ccOrderItem;
        }

        // User the Test Interface to run the connector dynamically
        ti.run(order.id, sObjectName);

        // checks
        List<ccrz__E_Order__c> ccOrders = new CPQB2BCCOrderSelector().getBySourceOrderIds(new List<Id>{ order.Id });

        System.assertEquals(1, ccOrders.size());

        ccrz__E_Order__c ccOrder = ccOrders[0];

        List<ccrz__E_OrderItem__c> ccOrderItems = new CPQB2BCCOrderItemSelector().getByOrderIds(new List<Id>{ ccOrder.Id });
        System.assertEquals(1, ccOrderItems.size());        
    }
    
    public void syncCCOrderToOrder(CPQB2BTestInt ti, String sObjectName) {
        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;

        Product2 product1 = CPQB2BTestFactory.createProduct('P1', 'P1-C', true, true);
        insert product1;

        Product2 product2 = CPQB2BTestFactory.createProduct('P2', 'P2-C', true, true);
        insert product2;

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        ccrz__E_Product__c ccProduct1;
        ccrz__E_Product__c ccProduct2;

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
            ccProduct1 = CPQB2BTestFactory.createCCProduct(product2);
            insert ccProduct1;

            ccProduct2 = CPQB2BTestFactory.createCCProduct(product2);
            insert ccProduct2;
        } else {
            ccProduct1 = [SELECT id FROM ccrz__E_Product__c WHERE Source_Product__c = :product1.Id LIMIT 1];
            ccProduct2 = [SELECT id FROM ccrz__E_Product__c WHERE Source_Product__c = :product2.Id LIMIT 1];
        }

        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();

        Decimal price1 = 200;
        PriceBookEntry pbe1 = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product1.Id, price1);
        pbeList.add(pbe1);

        Decimal price2 = 500;
        PriceBookEntry pbe2 = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product2.Id, price2);
        pbeList.add(pbe2);

        insert pbeList;

        Test.startTest();
        ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
        ccOrder.ccrz__OrderDate__c = Date.newInstance(2012, 12, 12);
        insert ccOrder;

        List<ccrz__E_OrderItem__c> ccOrderItems = new List<ccrz__E_OrderItem__c>();
        ccrz__E_OrderItem__c ccOrderItem1 = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct1.Id);
        ccOrderItem1.ccrz__Quantity__c = 10;
        ccOrderItems.add(ccOrderItem1);

        ccrz__E_OrderItem__c ccOrderItem2 = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct2.Id);
        ccOrderItem2.ccrz__Quantity__c = 4;
        ccOrderItems.add(ccOrderItem2);
        insert ccOrderItems;

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.CCOrderToOrder)) {
            SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(ac.Id, false, true, true);
            insert quote;

            SBQQ__QuoteLine__c quoteLine1 = CPQB2BTestFactory.createQuoteLine(quote.Id, product2.Id, price1);
            insert quoteLine1;

            SBQQ__QuoteLine__c quoteLine2 = CPQB2BTestFactory.createQuoteLine(quote.Id, product2.Id, price2);
            insert quoteLine2;

            quote.SBQQ__Ordered__c = true;
            update quote;

        } else {
            ccOrder.Sync_to_CPQ__c = true;
            update ccOrder;
        }

        // User the Test Interface to run the connector dynamically
        ti.run(ccOrder.id, sObjectName);         

        Test.stopTest();

        List<Opportunity> opportunities = [SELECT Id, AccountId, StageName FROM Opportunity];
        System.assert(opportunities != null);

        Opportunity opportunity = opportunities[0];
        System.assertEquals(ac.Id, opportunity.AccountId);

        List<SBQQ__Quote__c> quotes = [SELECT Id, B2B_Source_Order__c, SBQQ__Primary__c, SBQQ__Account__c, SBQQ__PricebookId__c, SBQQ__Ordered__c FROM SBQQ__Quote__c];
        System.assert(quotes != null);

        SBQQ__Quote__c quote = quotes[0];
        System.assertEquals(ccOrder.Id, quote.B2B_Source_Order__c);
        System.assertEquals(true, quote.SBQQ__Primary__c);
        System.assertEquals(ac.Id, quote.SBQQ__Account__c);
        System.assertEquals(standardPricebook.Id, quote.SBQQ__PricebookId__c);

        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__NetPrice__c, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c];
        System.assert(quoteLines != null);

        SBQQ__QuoteLine__c quoteLine1 = quoteLines[0];
        System.assertEquals(ccOrderItem1.ccrz__Price__c, quoteLine1.SBQQ__NetPrice__c);
        System.assertEquals(ccOrderItem1.ccrz__Quantity__c, quoteLine1.SBQQ__Quantity__c);

        SBQQ__QuoteLine__c quoteLine2 = quoteLines[1];
        System.assertEquals(ccOrderItem2.ccrz__Price__c, quoteLine2.SBQQ__NetPrice__c);
        System.assertEquals(ccOrderItem2.ccrz__Quantity__c, quoteLine2.SBQQ__Quantity__c);
    }    
    
}