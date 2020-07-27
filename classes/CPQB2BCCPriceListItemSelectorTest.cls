/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BCCPriceListItemSelectorTest {
    @isTest
    public static void testGetCCPriceListItemsByPriceBookEntryIds() {
        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        standardPricebook = [SELECT Id, Name, IsActive From PriceBook2 WHERE Id = :Test.getStandardPricebookId()];

        ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceListFromPriceBook(standardPricebook.Id, 'PL Name');
        insert priceList;

        Boolean shouldSyncProduct = false;
        Boolean isProductActive = true;

        if(new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
            shouldSyncProduct = true;
        }
        
        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', shouldSyncProduct, isProductActive);
        insert product;

        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
        insert pbe;

        pbe = new CPQB2BPriceBookEntrySelector().getPricebookEntryById(pbe.Id);

        ccrz__E_Product__c ccProduct;
        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
            ccProduct = CPQB2BTestFactory.createCCProduct(product);
            insert ccProduct;
        }
        else{
            CPQB2BCCProductSelector ccProdSelector = new CPQB2BCCProductSelector();
            List<ccrz__E_Product__c> ccProdList = ccProdSelector.selectBySourceIds(new List<Id>{product.Id});
            ccProduct = ccProdList[0];
        }

        ccrz__E_PriceListItem__c pli = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe, ccproduct.Id, priceList.Id);

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
            insert pli;
        } else {
            new CPQB2BMappingService('').mapPricing(new List<PriceBookEntry>{ pbe });
        }

        List<ccrz__E_PriceListItem__c> results = new CPQB2BCCPriceListItemSelector().getCCPriceListItemsByPriceBookEntryIds(new Set<Id> {pbe.Id});
        System.assertEquals(1, results.size());

        ccrz__E_PriceListItem__c result = results[0];

        System.assertEquals(pli.ccrz__Price__c, result.ccrz__Price__c);
        System.assertEquals(pli.ccrz__Pricelist__c, result.ccrz__Pricelist__c);
        System.assertEquals(pli.Source_PriceBookEntry_Id__c, result.Source_PriceBookEntry_Id__c);
        System.assertEquals(pli.ccrz__Product__c, result.ccrz__Product__c);
    }

    @isTest
    public static void getCCPriceListItemsByQuoteLineIds() {
        Pricebook2 pb = CPQB2BTestFactory.createPriceBook();
        insert pb;

        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'Account Group Name';
        insert ccAccountGroup;

        Account acc = new Account();
        acc.Name = 'Account Name';
        acc.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
        insert acc;

        Boolean shouldSyncQuote = true;
        Boolean isPrimaryQuote = false;
        Boolean isQuoteApproved = false;
        SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(acc.Id, shouldSyncQuote, isPrimaryQuote, isQuoteApproved);
        insert quote;

        Boolean shouldSyncProduct = false;
        
        if(new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
            shouldSyncProduct = true;
        }

        Boolean isProductActive = true;
        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', shouldSyncProduct, isProductActive);
        insert product;

        Decimal price = 500;
        SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
        insert quoteLine;

        ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList('My PriceList');
        insert priceList;

        ccrz__E_Product__c ccProduct;
        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
            ccProduct = CPQB2BTestFactory.createCCProduct(product);
            insert ccProduct;
        }
        else{
            CPQB2BCCProductSelector ccProdSelector = new CPQB2BCCProductSelector();
            List<ccrz__E_Product__c> ccProdList = ccProdSelector.selectBySourceIds(new List<Id>{product.Id});
            ccProduct = ccProdList[0];
        }

        ccrz__E_PriceListItem__c pli = CPQB2BTestFactory.createPriceListItemFromQuoteLine(quoteLine, ccproduct.Id, priceList.Id);

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
            insert pli;
        } else {
            pli = [SELECT Id, Name, ccrz__Price__c, Quote_Line__c, ccrz__Product__c, ccrz__Pricelist__c FROM ccrz__E_PriceListItem__c LIMIT 1];
        }

        List<ccrz__E_PriceListItem__c> results = new CPQB2BCCPriceListItemSelector().getCCPriceListItemsByQuoteLineIds(new Set<Id> { quoteLine.Id });
        ccrz__E_PriceListItem__c result = results[0];
        
        System.assertEquals(pli.ccrz__Price__c, result.ccrz__Price__c);
        System.assertEquals(pli.ccrz__Pricelist__c, result.ccrz__Pricelist__c);
        System.assertEquals(pli.Quote_Line__c, result.Quote_Line__c);
        System.assertEquals(pli.ccrz__Product__c, result.ccrz__Product__c);
    }
}