/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class CPQB2BCCProductSelectorTest {

    @isTest
    public static void testGetCCProductByName(){

        Product2 p1 = new Product2();
        p1.Name = 'TestCCProduct';
        p1.Description = 'TestProduct1';
        p1.ProductCode = 'TEST-1234';
        p1.Sync_Product_To_B2B__c = true;
        p1.IsActive = true;
        insert p1;

        //Checking if SKU syncing is enabled.  If disabled,
        //we then need to create the B2B CCProduct records
        //manually and associate it a Product2 record
        CPQB2BConnector connector = new CPQB2BConnector();
        if(!connector.isSyncEnabled(CPQB2BProcessType.SKU)){
            ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c();
            ccProduct1.Name = 'TestCCProduct';
            ccProduct1.ccrz__SKU__c = p1.ProductCode;
            ccProduct1.Source_Product__c = p1.Id;
            insert ccProduct1;
        }   

        CPQB2BCCProductSelector ccps = new CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> ccProductList = ccps.getCCProductByName('TestCCProduct');

        System.assertEquals(1, ccProductList.size(),'The returned list size of: ' + ccProductList.size() + ' does not match the expected value of 1');
    }

    @isTest
    public static void testSelectById(){
        Product2 p1 = new Product2();
        p1.Name = 'CPQB2B - TestProduct1';
        p1.Description = 'TestProduct1';
        p1.ProductCode = 'TEST-1234';
        p1.Sync_Product_To_B2B__c = true;
        p1.IsActive = true;
        insert p1;

        //Checking if SKU syncing is enabled.  If disabled,
        //we then need to create the B2B CCProduct records
        //manually and associate it a Product2 record
        CPQB2BConnector connector = new CPQB2BConnector();
        if(!connector.isSyncEnabled(CPQB2BProcessType.SKU)){
            ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c();
            ccProduct1.Name = 'CPQB2B - TestProduct1';
            ccProduct1.ccrz__SKU__c = p1.ProductCode;
            ccProduct1.Source_Product__c = p1.Id;
            insert ccProduct1;
        }   

        CPQB2BCCProductSelector ccps = new CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> queriedCCProductList = ccps.selectBySourceIds(new List<Id>{p1.Id});
        System.assertEquals(1, queriedCCProductList.size(),'The returned list size of: ' + queriedCCProductList.size() + ' does not match the expected value of 1');

        ccrz__E_Product__c queriedCCProduct = ccps.selectById(queriedCCProductList[0].Id);

        System.assertEquals(1, queriedCCProductList.size(),'The returned list size of: ' + queriedCCProductList.size() + ' does not match the expected value of 1');
    }

    @isTest
    public static void testSelectBySourceIds(){
        List<Product2> productList = new List<Product2>();
        List<Id> productIdList = new List<Id>();

        Product2 p1 = new Product2();
        p1.Name = 'CPQB2B - TestProduct1';
        p1.Description = 'TestProduct1';
        p1.ProductCode = 'TEST-1234';
        p1.Sync_Product_To_B2B__c = true;
        p1.IsActive = true;
        productList.add(p1);

        Product2 p2 = new Product2();
        p2.Name = 'CPQB2B - TestProduct2';
        p2.Description = 'TestProduct2';
        p2.ProductCode = 'TEST-1235';
        p2.Sync_Product_To_B2B__c = true;
        p2.IsActive = true;
        productList.add(p2);

        insert productList;

        //Checking if SKU syncing is enabled.  If disabled,
        //we then need to create the B2B CCProduct records
        //manually and associate it a Product2 record
        CPQB2BConnector connector = new CPQB2BConnector();
        if(!connector.isSyncEnabled(CPQB2BProcessType.SKU)){
            ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c();
            ccProduct1.Name = 'CPQB2B - TestProduct1';
            ccProduct1.ccrz__SKU__c = p1.ProductCode;
            ccProduct1.Source_Product__c = p1.Id;
            insert ccProduct1;

            ccrz__E_Product__c ccProduct2 = new ccrz__E_Product__c();
            ccProduct2.Name = 'CPQB2B - TestProduct2';
            ccProduct2.ccrz__SKU__c = p2.ProductCode;
            ccProduct2.Source_Product__c = p2.Id;
            insert ccProduct2;
        }   
        
        for(Product2 prod : productList){
            productIdList.add(prod.Id);
        }

        CPQB2BCCProductSelector ccps = new CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> queriedCCProductList = ccps.selectBySourceIds(productIdList);

        System.assertEquals(2, queriedCCProductList.size(),'The returned list size of: ' + queriedCCProductList.size() + ' does not match the expected value of 2');
    }
}