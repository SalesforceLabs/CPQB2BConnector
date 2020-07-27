/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BCCContactAddressSelectorTest {

    @isTest
    public static void testSelectByFullAddress() {
        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;

        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        insert c;

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Order order = CPQB2BTestFactory.createOrder(false, ac.Id, c.Id, standardPricebook.Id);
        order.ShippingStreet = '123 Main Street';
        order.ShippingCity = 'Indianapolis';
        order.ShippingState = 'IN';
        order.ShippingPostalCode = '46060';
        order.ShippingCountry = 'USA';

        insert order;

        Order insertedOrder = [Select Id, ShippingAddress from Order];

        ccrz__E_ContactAddr__c ccAddress = new ccrz__E_ContactAddr__c();
        ccAddress.ccrz__AddressFirstline__c = order.ShippingStreet;
        ccAddress.ccrz__City__c = order.ShippingCity;
        ccAddress.ccrz__StateISOCode__c = order.ShippingState;
        ccAddress.ccrz__PostalCode__c = order.ShippingPostalCode;
        ccAddress.ccrz__Country__c = order.ShippingCountry;

        insert ccAddress;

        List<ccrz__E_ContactAddr__c> results = new CPQB2BCCContactAddressSelector().selectByFullAddress(new List<Address>{ insertedOrder.ShippingAddress });

        System.assertEquals(1, results.size());
        ccrz__E_ContactAddr__c result = results[0];

        System.assertEquals(ccAddress.ccrz__AddressFirstline__c, result.ccrz__AddressFirstline__c);
        System.assertEquals(ccAddress.ccrz__City__c, result.ccrz__City__c);
        System.assertEquals(ccAddress.ccrz__StateISOCode__c, result.ccrz__StateISOCode__c);
        System.assertEquals(ccAddress.ccrz__PostalCode__c, result.ccrz__PostalCode__c);
        System.assertEquals(ccAddress.ccrz__Country__c, result.ccrz__Country__c);
    }
}