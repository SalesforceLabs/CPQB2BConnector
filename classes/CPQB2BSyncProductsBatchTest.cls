@isTest
public with sharing class CPQB2BSyncProductsBatchTest {
    @isTest
    public static void testProductBatch() {

        List<Product2> recordstoInsert = new List<Product2>();

        for(Integer x = 0; x <50 ; x++){
            Product2 product = new Product2();
            product.Name = 'Test Product' + x;
            product.ProductCode = 'PBC-' + x;
            product.IsActive = true;
            product.Sync_Product_To_B2B__c = true;
            recordstoInsert.add(product);
        }

        insert recordsToInsert;
  
        Test.startTest();
            CPQB2BSyncProductsBatch batchJob = new CPQB2BSyncProductsBatch();
            Database.executeBatch(batchJob);
            List<ccrz__E_Product__c> ccProductList = [Select Id, Name FROM ccrz__E_Product__c];
            System.assertEquals(50,ccProductList.size(),'The returned list size of ' + ccProductList.size() + 'does not match the expected value of 50.');
        Test.stopTest();
    }
}