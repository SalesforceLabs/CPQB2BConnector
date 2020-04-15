@isTest
public class CPQB2BQuoteLineSelectorTest {

    @isTest
    public static void testSelectQuoteLineById() {
        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'Account Group Name';
        insert ccAccountGroup;

        Account acc = new Account();
        acc.Name = 'Account Name';
        acc.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
        insert acc;

        SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(acc.Id, false, false, false);
        quote.SBQQ__ExpirationDate__c = Date.newInstance(2012, 12, 12);
        insert quote;

        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', false, true);
        insert product;

        Decimal price = 500;
        SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
        insert quoteLine;

        SBQQ__QuoteLine__c result = new CPQB2BQuoteLineSelector().selectQuoteLineById(quoteLine.Id);

        System.assert(result != null);
        System.assertEquals(quoteLine.SBQQ__Quote__c, result.SBQQ__Quote__c);
        System.assertEquals(quoteLine.SBQQ__Product__c, result.SBQQ__Product__c);
        System.assertEquals(quoteLine.SBQQ__NetPrice__c, result.SBQQ__NetPrice__c);
        System.assertEquals(acc.Name, result.SBQQ__Quote__r.SBQQ__Account__r.Name);
        System.assertEquals(quote.Sync_Quote_To_B2B__c, result.SBQQ__Quote__r.Sync_Quote_To_B2B__c);
        System.assertEquals(quote.SBQQ__Primary__c, result.SBQQ__Quote__r.SBQQ__Primary__c);
        System.assertEquals(quote.SBQQ__Status__c, result.SBQQ__Quote__r.SBQQ__Status__c);
        System.assertEquals(ccAccountGroup.Id, result.SBQQ__Quote__r.SBQQ__Account__r.ccrz__E_AccountGroup__c);
        System.assertEquals(quote.SBQQ__ExpirationDate__c, result.SBQQ__Quote__r.SBQQ__ExpirationDate__c);
    }

    @isTest
    public static void testSelectQuoteLinesByIds() {
        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'Account Group Name';
        insert ccAccountGroup;

        Account acc = new Account();
        acc.Name = 'Account Name';
        acc.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
        insert acc;

        SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(acc.Id, false, false, false);
        quote.SBQQ__ExpirationDate__c = Date.newInstance(2012, 12, 12);
        insert quote;

        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', false, true);
        insert product;

        Decimal price = 500;
        SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
        insert quoteLine;

        List<SBQQ__QuoteLine__c> results = new CPQB2BQuoteLineSelector().selectQuoteLinesByIds(new List<Id> {quoteLine.Id});
        System.assertEquals(1, results.size());

        SBQQ__QuoteLine__c result = results[0];

        System.assertEquals(quoteLine.SBQQ__Quote__c, result.SBQQ__Quote__c);
        System.assertEquals(quoteLine.SBQQ__Product__c, result.SBQQ__Product__c);
        System.assertEquals(quoteLine.SBQQ__NetPrice__c, result.SBQQ__NetPrice__c);
        System.assertEquals(quote.Sync_Quote_To_B2B__c, result.SBQQ__Quote__r.Sync_Quote_To_B2B__c);
        System.assertEquals(quote.SBQQ__Primary__c, result.SBQQ__Quote__r.SBQQ__Primary__c);
        System.assertEquals(quote.SBQQ__Status__c, result.SBQQ__Quote__r.SBQQ__Status__c);
        System.assertEquals(ccAccountGroup.Id, result.SBQQ__Quote__r.SBQQ__Account__r.ccrz__E_AccountGroup__c);
        System.assertEquals(quote.SBQQ__ExpirationDate__c, result.SBQQ__Quote__r.SBQQ__ExpirationDate__c);
    }

    @isTest
    public static void testSelectQuoteLinesByQuoteIds() {
        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'Account Group Name';
        insert ccAccountGroup;

        Account acc = new Account();
        acc.Name = 'Account Name';
        acc.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
        insert acc;

        SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(acc.Id, false, false, false);
        quote.SBQQ__ExpirationDate__c = Date.newInstance(2012, 12, 12);
        insert quote;

        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', false, true);
        insert product;

        Decimal price = 500;
        SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
        insert quoteLine;

        List<SBQQ__QuoteLine__c> results = new CPQB2BQuoteLineSelector().selectQuoteLinesByQuoteIds(new List<Id> {quote.Id});
        System.assertEquals(1, results.size());

        SBQQ__QuoteLine__c result = results[0];

        System.assertEquals(quoteLine.SBQQ__Quote__c, result.SBQQ__Quote__c);
        System.assertEquals(quoteLine.SBQQ__Product__c, result.SBQQ__Product__c);
        System.assertEquals(quoteLine.SBQQ__NetPrice__c, result.SBQQ__NetPrice__c);
        System.assertEquals(acc.Name, result.SBQQ__Quote__r.SBQQ__Account__r.Name);
        System.assertEquals(quote.Sync_Quote_To_B2B__c, result.SBQQ__Quote__r.Sync_Quote_To_B2B__c);
        System.assertEquals(quote.SBQQ__Primary__c, result.SBQQ__Quote__r.SBQQ__Primary__c);
        System.assertEquals(quote.SBQQ__Status__c, result.SBQQ__Quote__r.SBQQ__Status__c);
        System.assertEquals(ccAccountGroup.Id, result.SBQQ__Quote__r.SBQQ__Account__r.ccrz__E_AccountGroup__c);
        System.assertEquals(quote.SBQQ__ExpirationDate__c, result.SBQQ__Quote__r.SBQQ__ExpirationDate__c);
    }

    @isTest
    static void testSelectQuoteLinesToSyncToB2B() {
        Database.QueryLocator queryLoc = new CPQB2BQuoteLineSelector().selectQuoteLinesToSyncToB2B();
        System.assert(queryLoc != null);
    }
}