@isTest
public class CPQB2BProductLineItemServiceTest {
    @isTest
    public static void testGetProductLineItemsByLowestSequence() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();

            Account ac = new Account();
            ac.Name = 'Account';
            insert ac;

            Contact c = new Contact();
            c.FirstName = 'First';
            c.LastName = 'Last';
            insert c;

            Product2 product = CPQB2BTestFactory.createProduct('P1', 'P1-C', true, true);
            insert product;

            ccrz__E_Product__c ccProduct;

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }
            else{
                ccProduct = [SELECT Id FROM ccrz__E_Product__c WHERE Source_Product__c = :product.Id LIMIT 1];
            }

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            Pricebook2 pricebook_2 = CPQB2BTestFactory.createPriceBook('PB2','PB2');
            insert pricebook_2;

            Decimal price = 200;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            insert pbe;

            Decimal price2 = 100;
            PriceBookEntry pbe2 = CPQB2BTestFactory.createPriceBookEntry(pricebook_2.Id, product.Id, price2);
            insert pbe2;

            ccrz__E_AccountGroup__c ccAccountGroup1 = new ccrz__E_AccountGroup__c();
            ccAccountGroup1.Name = 'My Account';
            insert ccAccountGroup1;
        
            
            List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c>();
            ccrz__E_PriceList__c priceList1 = CPQB2BTestFactory.createPriceList(ccAccountGroup1.Name);
            
            priceList1.Source_Price_Book__c = standardPricebook.Id;
            priceLists.add(priceList1);

            ccrz__E_PriceList__c priceList2 = CPQB2BTestFactory.createPriceList(ccAccountGroup1.Name + '2');
            priceList2.Source_Price_Book__c = pricebook_2.Id;
            priceLists.add(priceList2);

            insert priceLists;

            ccrz__E_PriceListItem__c pli = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe,ccProduct.Id, priceList1.Id);
            ccrz__E_PriceListItem__c pli2 = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe2,ccProduct.Id, priceList2.Id);
            
            List<ccrz__E_PriceListItem__c> pliList = new List<ccrz__E_PriceListItem__c>{pli,pli2};
            insert pliList;

            List<ccrz__E_AccountGroupPriceList__c> agplList = new List<ccrz__E_AccountGroupPriceList__c>();
            ccrz__E_AccountGroupPriceList__c agpl1 = new ccrz__E_AccountGroupPriceList__c();
            agpl1.ccrz__Sequence__c = 100;
            agpl1.ccrz__Pricelist__c = priceList1.Id;
            agpl1.ccrz__AccountGroup__c = ccAccountGroup1.Id;
            agplList.add(agpl1);

            ccrz__E_AccountGroupPriceList__c agpl2 = new ccrz__E_AccountGroupPriceList__c();
            agpl2.ccrz__Sequence__c = 200;
            agpl2.ccrz__Pricelist__c = priceList2.Id;
            agpl2.ccrz__AccountGroup__c = ccAccountGroup1.Id;
            agplList.add(agpl2);

            insert agplList;

            Map<Id,Integer> productToQuantityMap = new Map<Id,Integer>();
            productToQuantityMap.put(ccProduct.Id,1);
            CPQB2BProductLineItemService pliService = new CPQB2BProductLineItemService(new List<Id>{ccProduct.Id},productToQuantityMap,ccAccountGroup1.Id);

            Map<Id,CPQB2BProductLineItem> pliMap = pliService.getProductLineItemsByLowestSequence();
            System.assertEquals(200,pliMap.get(product.Id).price,'The value of the ProductLineItem price does not match the expected value of ' + 200);
        }
    }

    @isTest
    public static void testGetProductLineItemsByLowestPrice() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();

            Account ac = new Account();
            ac.Name = 'Account';
            insert ac;

            Contact c = new Contact();
            c.FirstName = 'First';
            c.LastName = 'Last';
            insert c;

            Product2 product = CPQB2BTestFactory.createProduct('P1', 'P1-C', true, true);
            insert product;

            ccrz__E_Product__c ccProduct;

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }
            else{
                ccProduct = [SELECT Id FROM ccrz__E_Product__c WHERE Source_Product__c = :product.Id LIMIT 1];
            }

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            Pricebook2 pricebook_2 = CPQB2BTestFactory.createPriceBook('PB2','PB2');
            insert pricebook_2;

            Decimal price = 200;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            insert pbe;

            Decimal price2 = 100;
            PriceBookEntry pbe2 = CPQB2BTestFactory.createPriceBookEntry(pricebook_2.Id, product.Id, price2);
            insert pbe2;

            ccrz__E_AccountGroup__c ccAccountGroup1 = new ccrz__E_AccountGroup__c();
            ccAccountGroup1.Name = 'My Account';
            insert ccAccountGroup1;
        
            
            List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c>();
            ccrz__E_PriceList__c priceList1 = CPQB2BTestFactory.createPriceList(ccAccountGroup1.Name);
            
            priceList1.Source_Price_Book__c = standardPricebook.Id;
            priceLists.add(priceList1);

            ccrz__E_PriceList__c priceList2 = CPQB2BTestFactory.createPriceList(ccAccountGroup1.Name + '2');
            priceList2.Source_Price_Book__c = pricebook_2.Id;
            priceLists.add(priceList2);

            insert priceLists;

            ccrz__E_PriceListItem__c pli = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe,ccProduct.Id, priceList1.Id);
            ccrz__E_PriceListItem__c pli2 = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe2,ccProduct.Id, priceList2.Id);
            
            List<ccrz__E_PriceListItem__c> pliList = new List<ccrz__E_PriceListItem__c>{pli,pli2};
            insert pliList;

            List<ccrz__E_AccountGroupPriceList__c> agplList = new List<ccrz__E_AccountGroupPriceList__c>();
            ccrz__E_AccountGroupPriceList__c agpl1 = new ccrz__E_AccountGroupPriceList__c();
            agpl1.ccrz__Sequence__c = 100;
            agpl1.ccrz__Pricelist__c = priceList1.Id;
            agpl1.ccrz__AccountGroup__c = ccAccountGroup1.Id;
            agplList.add(agpl1);

            ccrz__E_AccountGroupPriceList__c agpl2 = new ccrz__E_AccountGroupPriceList__c();
            agpl2.ccrz__Sequence__c = 200;
            agpl2.ccrz__Pricelist__c = priceList2.Id;
            agpl2.ccrz__AccountGroup__c = ccAccountGroup1.Id;
            agplList.add(agpl2);

            insert agplList;

            Map<Id,Integer> productToQuantityMap = new Map<Id,Integer>();
            productToQuantityMap.put(ccProduct.Id,1);
            CPQB2BProductLineItemService pliService = new CPQB2BProductLineItemService(new List<Id>{ccProduct.Id},productToQuantityMap,ccAccountGroup1.Id);

            Map<Id,CPQB2BProductLineItem> pliMap = pliService.getProductLineItemsByLowestPrice();
            System.assertEquals(100,pliMap.get(product.Id).price,'The value of the ProductLineItem price does not match the expected value of ' + 100);
        }
    }
}