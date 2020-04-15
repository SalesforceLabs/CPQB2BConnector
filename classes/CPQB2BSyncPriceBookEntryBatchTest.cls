@isTest
public class CPQB2BSyncPriceBookEntryBatchTest {

    @isTest
    public static void testExecuteBatch() {
        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
        insert product;

        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
        insert pbe;

        Test.startTest();
            CPQB2BSyncPriceBookEntryBatch batchJob = new CPQB2BSyncPriceBookEntryBatch();
            Database.executeBatch(batchJob);
        Test.stopTest();
    }
}