@isTest
public class CPQB2BPriceBookEntrySelectorTest {

    @isTest
    public static void testGetPricebookEntryId(){
        Id pb = Test.getStandardPriceBookId();
        Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
        insert product;

        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(pb, product.Id, price);
        insert pbe;

        CPQB2BPriceBookEntrySelector selector = new CPQB2BPriceBookEntrySelector();
        PriceBookEntry result = selector.getPricebookEntryById(pbe.Id);

        System.assertEquals(pbe.PriceBook2Id, result.PriceBook2Id);
        System.assertEquals(pbe.UnitPrice, result.UnitPrice);
        System.assertEquals(product.ProductCode, result.ProductCode);
        System.assertEquals(pbe.IsActive, result.IsActive);
        System.assertEquals(pbe.Product2Id, result.Product2Id);
        System.assertEquals(product.IsActive, result.Product2.IsActive);
        System.assertEquals(product.Sync_Product_To_B2B__c, result.Product2.Sync_Product_To_B2B__c);
    }

    @isTest
    public static void testGetPricebookEntryIds(){
        Id pb = Test.getStandardPriceBookId();

        Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name 1', 'My Product Description 1');
        insert product;

        Product2 product2 = CPQB2BTestFactory.createSyncedProduct('My Product Name 2', 'My Product Description 2');
        insert product2;

        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(pb, product.Id, price);
        insert pbe;

        Decimal price2 = 180;
        PriceBookEntry pbe2 = CPQB2BTestFactory.createPriceBookEntry(pb, product2.Id, price2);
        insert pbe2;

        CPQB2BPriceBookEntrySelector selector = new CPQB2BPriceBookEntrySelector();
        List<Id> ids = new List<Id> { pbe.Id, pbe2.Id };
        List<PriceBookEntry> results = selector.getPricebookEntryByIds(ids);

        System.assertEquals(2, results.size());
    }

    @isTest
    public static void testGetPriceListEntryItemsToSyncQueryLocator(){
        CPQB2BPriceBookEntrySelector selector = new CPQB2BPriceBookEntrySelector();
        Database.QueryLocator queryLoc = selector.getPriceListEntryItemsToSync();

        System.assert(queryLoc != null);
    }
}