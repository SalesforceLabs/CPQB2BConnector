@isTest
public class CPQB2BCCPriceListSelectorTest {

    @isTest
    public static void testGetCCPriceListByPriceBookId(){
        Id pb = Test.getStandardPriceBookId();

        ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceListFromPriceBook(pb, 'PL Name');
        insert priceList;

        ccrz__E_PriceList__c result = new CPQB2BCCPriceListSelector().getCCPriceListByPriceBookId(pb);

        System.assertEquals(priceList.ccrz__CurrencyISOCode__c, result.ccrz__CurrencyISOCode__c);
        System.assertEquals(priceList.Source_Price_Book__c, result.Source_Price_Book__c);
        System.assertEquals(priceList.Name, result.Name);
        System.assertEquals(priceList.ccrz__Enabled__c, result.ccrz__Enabled__c);
        System.assertEquals(priceList.ccrz__StartDate__c, result.ccrz__StartDate__c); 
        System.assertEquals(priceList.ccrz__EndDate__c, result.ccrz__EndDate__c);     
    }

    @isTest
    public static void testGetCCPriceListsByPriceBookIds(){
        Id pb = Test.getStandardPriceBookId();

        ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceListFromPriceBook(pb, 'PL Name');
        insert priceList;

        List<ccrz__E_PriceList__c> results = new CPQB2BCCPriceListSelector().getCCPriceListsByPriceBookIds(new List<Id> {pb});
        System.assertEquals(1, results.size());

        ccrz__E_PriceList__c result = results[0];

        System.assertEquals(priceList.ccrz__CurrencyISOCode__c, result.ccrz__CurrencyISOCode__c);
        System.assertEquals(priceList.Source_Price_Book__c, result.Source_Price_Book__c);
        System.assertEquals(priceList.Name, result.Name);
        System.assertEquals(priceList.ccrz__Enabled__c, result.ccrz__Enabled__c);
        System.assertEquals(priceList.ccrz__StartDate__c, result.ccrz__StartDate__c); 
        System.assertEquals(priceList.ccrz__EndDate__c, result.ccrz__EndDate__c);  
    }
}