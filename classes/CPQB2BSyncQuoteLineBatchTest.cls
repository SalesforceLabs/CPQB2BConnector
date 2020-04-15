@isTest
public class CPQB2BSyncQuoteLineBatchTest {
    @isTest
    public static void testExecuteBatch() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Sync_Quote_To_B2B__c = false;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = 'Approved';
        
        insert quote;

        Product2 product = new Product2();
        product.Name = 'CPQB2B - TestProduct';
        product.ProductCode = 'TEST-1234';
        product.IsActive = true;

        insert product;

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quote.id;
        quoteLine.SBQQ__NetPrice__c = 500;
        quoteLine.SBQQ__Product__c = product.Id;

        insert quoteLine;

        Test.startTest();
            CPQB2BSyncQuoteLineBatch batchJob = new CPQB2BSyncQuoteLineBatch();
            Database.executeBatch(batchJob);
        Test.stopTest();
    }
}