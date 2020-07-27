/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BCCAccountGrpPriceListSelectorTest {
    @isTest
    public static void testGetCCAccountGroupByIds() {
        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'My Account';
        insert ccAccountGroup;

        Account acc = new Account();
        acc.Name = 'My Account';
        acc.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
        insert acc;

        ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList(ccAccountGroup.Name);
        insert priceList;

        ccrz__E_AccountGroupPriceList__c ccAccountGroupPriceList = CPQB2BTestFactory.createAccountGroupPriceList(priceList.Id, ccAccountGroup.Id);
        insert ccAccountGroupPriceList;

        List<ccrz__E_AccountGroupPriceList__c> results = new CPQB2BCCAccountGrpPriceListSelector().getCCAccountGroupPriceListsByAccountGroupIds(new List<Id> { ccAccountGroup.Id});

        System.assertEquals(1, results.size());
        ccrz__E_AccountGroupPriceList__c result = results[0];
        System.assertEquals(ccAccountGroupPriceList.ccrz__Pricelist__c, result.ccrz__Pricelist__c);
        System.assertEquals(ccAccountGroupPriceList.ccrz__AccountGroup__c, result.ccrz__AccountGroup__c);
        System.assertEquals(priceList.ccrz__CurrencyISOCode__c, result.ccrz__Pricelist__r.ccrz__CurrencyISOCode__c);
        System.assertEquals(ccAccountGroupPriceList.ccrz__AccountGroup__c, result.ccrz__AccountGroup__c);
    }
}