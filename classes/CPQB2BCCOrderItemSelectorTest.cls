/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BCCOrderItemSelectorTest {

    @isTest
    public static void testGetByOrderIds() {
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

        List<ccrz__E_OrderItem__c> ccOrderItems = new CPQb2BCCOrderItemSelector().getByOrderIds(new List<Id> { ccOrder.Id });

        System.assertEquals(1, ccOrderItems.size());
        ccrz__E_OrderItem__c result = ccOrderItems[0];

        System.assertEquals(ccOrderItem.ccrz__Order__c, result.ccrz__Order__c);     
        System.assertEquals(ccOrderItem.ccrz__ItemStatus__c, result.ccrz__ItemStatus__c);  
        System.assertEquals(ccOrderItem.ccrz__OrderLineType__c, result.ccrz__OrderLineType__c);
        System.assertEquals(ccOrderItem.ccrz__OriginalItemPrice__c, result.ccrz__OriginalItemPrice__c);
        System.assertEquals(ccOrderItem.ccrz__OriginalQuantity__c, result.ccrz__OriginalQuantity__c);
        System.assertEquals(ccOrderItem.ccrz__Quantity__c, result.ccrz__Quantity__c); 
        System.assertEquals(ccOrderItem.ccrz__Product__c, result.ccrz__Product__c);
        System.assertEquals(ccOrderItem.ccrz__Price__c, result.ccrz__Price__c);   
        System.assertEquals(ccOrderItem.ccrz__SubAmount__c, result.ccrz__SubAmount__c);         
    }
}