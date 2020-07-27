/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BMappingUtilsTest {
    @isTest
    public static void testGetCurrencyType() {
        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);

        Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if (isMultiCurrency) {
            System.assertEquals(new CPQB2BMappingUtils('').getCurrencyType(pbe), pbe.get('CurrencyIsoCode'));
        } else {
            System.assertEquals(new CPQB2BMappingUtils('').getCurrencyType(pbe), UserInfo.getDefaultCurrency());
        }
    }

    @isTest
    public static void testGetCCProductToProduct2Map() {
        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;
        
        ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
        insert ccOrder;

        Boolean shouldSyncProduct = false;
        
        if(new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
            shouldSyncProduct = true;
        }

        Boolean isProductActive = true;
        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', shouldSyncProduct, isProductActive);
        insert product;

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

        ccrz__E_OrderItem__c ccOrderItem = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct.Id);
        insert ccOrderItem;

        Map<Id, Id> resultMap = new CPQB2BMappingUtils('').getCCProductToProduct2Map(new List<ccrz__E_OrderItem__c>{ccOrderItem});

        System.assertEquals(1, resultMap.size());

        Id product2Id = resultMap.get(ccProduct.Id);
        System.assertEquals(product.Id, product2Id);
    }

    @isTest
    public static void testGetCCOrderProductMap() {
        Account ac = new Account();
        ac.Name = 'Account';
        insert ac;
        
        ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
        insert ccOrder;

        Boolean shouldSyncProduct = false;
        
        if(new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
            shouldSyncProduct = true;
        }

        Boolean isProductActive = true;
        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', shouldSyncProduct, isProductActive);
        insert product;

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

        ccrz__E_OrderItem__c ccOrderItem = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct.Id);
        insert ccOrderItem;

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Map<Id,List<CPQB2BProductLineItem>> ccOrderProductMap = new CPQB2BMappingUtils('').getProductLineItemMapForOrders(new List<Id> {ccOrder.Id}, standardPricebook.Id);

        System.assert(ccOrderProductMap != null);
        List<CPQB2BProductLineItem> ccOrderProducts = ccOrderProductMap.get(ccOrder.Id);
        System.assertEquals(1, ccOrderProducts.size());
        CPQB2BProductLineItem productlineItem = ccOrderProducts[0];
        System.assertEquals(standardPricebook.Id, productlineItem.PricebookId);
        System.assertEquals(ccOrderItem.ccrz__Price__c, productlineItem.Price);
        System.assertEquals(ccOrderItem.ccrz__Quantity__c, productlineItem.Quantity);
    }
}