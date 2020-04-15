@isTest
public class CPQB2BQuoteSelectorTest {

    @isTest
    public static void testSelectQuoteById() {
        Account acc = new Account();
        acc.Name = 'Account Name';
        insert acc;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Sync_Quote_To_B2B__c = true;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = 'Approved';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__ExpirationDate__c = Date.newInstance(2012, 12, 12);
        
        insert quote;

        SBQQ__Quote__c result = new CPQB2BQuoteSelector().selectQuoteById(quote.Id);
        System.assert(result != null);
        System.assertEquals(true, result.Sync_Quote_To_B2B__c);
        System.assertEquals(true, result.SBQQ__Primary__c);
        System.assertEquals(quote.SBQQ__Status__c, result.SBQQ__Status__c);
        System.assertEquals(quote.SBQQ__Account__c, result.SBQQ__Account__c);
        System.assertEquals(acc.Name, result.SBQQ__Account__r.Name);
        System.assertEquals(quote.SBQQ__ExpirationDate__c, result.SBQQ__ExpirationDate__c);
    }

    @isTest
    public static void testSelectQuotesBysId() {
        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'Account Group Name';
        insert ccAccountGroup;

        Account acc = new Account();
        acc.Name = 'Account Name';
        acc.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
        insert acc;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Sync_Quote_To_B2B__c = true;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = 'Approved';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__ExpirationDate__c = Date.newInstance(2012, 12, 12);
        insert quote;

        List<SBQQ__Quote__c> results = new CPQB2BQuoteSelector().selectQuotesByIds(new List<Id> {quote.Id});
        System.assertEquals(1, results.size());
        SBQQ__Quote__c result = results[0];
        System.assertEquals(true, result.Sync_Quote_To_B2B__c);
        System.assertEquals(true, result.SBQQ__Primary__c);
        System.assertEquals(quote.SBQQ__Status__c, result.SBQQ__Status__c);
        System.assertEquals(quote.SBQQ__Account__c, result.SBQQ__Account__c);
        System.assertEquals(acc.Name, result.SBQQ__Account__r.Name);
        System.assertEquals(quote.SBQQ__ExpirationDate__c, result.SBQQ__ExpirationDate__c);
    }
}