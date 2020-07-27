/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BOrderSelectorTest {

    @isTest
    public static void testGetByIds() {
        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;

        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        insert c;

        Order order = CPQB2BTestFactory.createOrder(true, ac.Id, c.Id, null);
        order.ShippingStreet = '123 Main Street';
        order.ShippingCity = 'Indianapolis';
        order.ShippingState = 'Indiana';
        order.ShippingPostalCode = '46060';
        order.ShippingCountry = 'USA';
        insert order;

        List<Order> results = new CPQB2BOrderSelector().getByIds(new List<Id> { order.Id});
        System.assertEquals(1, results.size());

        Order result = results[0];
        System.assertEquals(order.AccountId, result.AccountId);
        System.assertEquals(order.effectiveDate, result.effectiveDate);
        System.assertEquals(order.Name, result.Name);       
        System.assertEquals(order.Sync_to_B2B__c, result.Sync_to_B2B__c);    

        System.assert(result.ShippingAddress != null);
    }

    @isTest
    public static void testGetByQuoteIds() {
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

        SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(ac.Id, false, true, false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        insert quote;

        Order order = CPQB2BTestFactory.createOrder(true, ac.Id, c.Id, null);
        insert order;

        order.SBQQ__Quote__c = quote.Id;
        update order;

        List<Order> results = new CPQB2BOrderSelector().getByQuoteIds(new List<Id> { quote.Id });
        System.assertEquals(1, results.size());
        Order result = results[0];

        System.assertEquals(order.AccountId, result.AccountId);
        System.assertEquals(order.effectiveDate, result.effectiveDate);
        System.assertEquals(order.Name, result.Name);       
        System.assertEquals(order.Sync_to_B2B__c, result.Sync_to_B2B__c);    
        System.assertEquals(order.SBQQ__Quote__c, result.SBQQ__Quote__c);    
    }

    @isTest
    public static void testGetBySourceOrderIds() {
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

        SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(ac.Id, false, true, false);
        quote.SBQQ__Opportunity2__c = opp.Id;
        insert quote;

        ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
        insert ccOrder;

        Order order = CPQB2BTestFactory.createOrder(true, ac.Id, c.Id, null);
        order.B2B_Source_Order__c = ccOrder.Id;
        insert order;

        order.SBQQ__Quote__c = quote.Id;
        update order;

        List<Order> results = new CPQB2BOrderSelector().getBySourceOrderIds(new List<Id> { ccOrder.Id });
        System.assertEquals(1, results.size());
        Order result = results[0];

        System.assertEquals(order.AccountId, result.AccountId);
        System.assertEquals(order.effectiveDate, result.effectiveDate);
        System.assertEquals(order.Name, result.Name);       
        System.assertEquals(order.Sync_to_B2B__c, result.Sync_to_B2B__c);    
        System.assertEquals(order.B2B_Source_Order__c, result.B2B_Source_Order__c);    
    }
    
    @isTest
    public static void getOrdersToSync(){
        Database.QueryLocator queryLoc = new CPQB2BOrderSelector().getOrdersToSync();
        System.assert(queryLoc != null);
    }
}