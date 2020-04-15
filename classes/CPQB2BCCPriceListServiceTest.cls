@isTest
public class CPQB2BCCPriceListServiceTest {

    @isTest
    public static void testSetAccountGroupAccounts() {
        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'My Account';
        insert ccAccountGroup;

        Account account = new Account();
        account.Name = 'My Account';
        insert account;

        Map<Id, ccrz__E_AccountGroup__c> agLookup = new Map<Id,ccrz__E_AccountGroup__c>();
        agLookup.put(account.Id, ccAccountGroup);

        new CPQB2BCCPriceListService('').setAccountGroupAccounts(agLookup);

        account = [SELECT ccrz__E_AccountGroup__c FROM Account];
        System.assertEquals(ccAccountGroup.Id, account.ccrz__E_AccountGroup__c);
    }

    @isTest
    public static void testGetPriceListsByAccountGroup() {
        ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
        ccAccountGroup.Name = 'My Account';
        insert ccAccountGroup;

        Account account = new Account();
        account.Name = 'My Account';
        insert account;

        ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList(ccAccountGroup.Name);
        insert priceList;

        ccrz__E_AccountGroupPriceList__c agPriceList = CPQB2BTestFactory.createAccountGroupPriceList(priceList.Id, ccAccountGroup.Id);
        insert agPriceList;

        Map<Id, List<ccrz__E_PriceList__c>> returned = new CPQB2BCCPriceListService('').getPriceListsByAccountGroup(new List<Id> { ccAccountGroup.Id });

        List<ccrz__E_PriceList__c> priceLists = returned.get(ccAccountGroup.Id);
        System.assert(priceLists != null);
        System.assertEquals(1, priceLists.size());
    }
}