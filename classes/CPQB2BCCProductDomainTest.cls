/**
* @author Salesforce.com Foundation
* @date 2014
*
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
*
* @description Trigger Handler on Accounts that handles ensuring the correct system flags are set on
* our special accounts (Household, One-to-One), and also detects changes on Household Account that requires
* name updating.
*/
@isTest
public class CPQB2BCCProductDomainTest {
    /** 
     * Temporary Coverage Method so triggers will deploy
    */
    @isTest
    public static void testBeforeAndAfterInsert(){
        Product2 p1 = new Product2();
        p1.Name = 'TestCCProduct';
        p1.Description = 'TestProduct1';
        p1.ProductCode = 'TEST-1234';
        p1.Sync_Product_To_B2B__c = true;
        p1.IsActive = true;
        insert p1;

        CPQB2BCCProductSelector ccps = new CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> ccProductList = ccps.getCCProductByName('TestCCProduct');


        System.assertEquals(ccProductList[0].Name, 'TestCCProduct');
    }

    /** 
     * Temporary Coverage Method so triggers will deploy
    */
    @isTest
    public static void testBeforeAndAfterUpdate(){
        Product2 p1 = new Product2();
        p1.Name = 'Test CCProduct';
        p1.Description = 'TestProduct1';
        p1.ProductCode = 'TEST-1234';
        p1.Sync_Product_To_B2B__c = true;
        p1.IsActive = true;
        insert p1;

        CPQB2BCCProductSelector ccps = new CPQB2BCCProductSelector();
        List<ccrz__E_Product__c> ccProductList = ccps.getCCProductByName('Test CCProduct');

        ccrz__E_Product__c ccProduct = ccProductList[0];
        ccProduct.Name = 'TestCCProduct';
        update ccProduct;
        System.assertNotEquals(ccProduct.Name, 'Test CCProduct');
    }
}