@isTest
public class CPQB2BMappingServiceTest {
    @isTest
    public static void testMapProducts(){
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {

            Product2 product = new Product2();
            product.Name = 'Test Product';
            product.ProductCode = 'TEST-1234';
            product.Description = 'Test Description';
            product.B2B_Storefront__c = 'Test Storefront';
            product.IsActive = true;
            insert product;

            CPQB2BProduct2Selector prodSelector = new CPQB2BProduct2Selector();
            product = prodSelector.selectById(product.Id);

            List<ccrz__E_Product__c> ccProductList = new List<ccrz__E_Product__c>();
            CPQB2BCCProductSelector ccProdSelector = new CPQB2BCCProductSelector();
            ccProductList = ccProdSelector.selectBySourceIds(new List<Id>{product.Id});
            
            //By default, sync flag is false so no cc product records should have been created.
            System.assertEquals(0,ccProductList.size(),'The returned list size of: ' + ccProductList.size() + ' does not match the expected value of 0');

            //updating sync flag to true so we can verify a synced cc product record is created.
            product.Sync_Product_To_B2B__c = true;
            update product;

            //Checking if SKU syncing is enabled.  If disabled,
            //we then need to create the B2B CCProduct records
            //manually and associate it a Product2 record
            CPQB2BConnector connector = new CPQB2BConnector();
            if(!connector.isSyncEnabled(CPQB2BProcessType.SKU)){
                ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c();
                ccProduct1.Name = product.Name;
                ccProduct1.ccrz__SKU__c = product.ProductCode;
                ccProduct1.Source_Product__c = product.Id;
                insert ccProduct1;
            }

            ccProductList = ccProdSelector.selectBySourceIds(new List<Id>{product.Id});
            
            //Verifies that a cc product was created.
            System.assertEquals(1,ccProductList.size(),'The returned list size of: ' + ccProductList.size() + ' does not match the expected value of 1');
            
            ccrz__E_Product__c ccProduct = ccProductList[0];

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getProductFieldMappings();

            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(product.get(fieldMap.sourceField),ccProduct.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Product does not match the field value for ' + fieldMap.destField + ' on CCProduct');
            }

            System.assertEquals('Released',ccProduct.ccrz__ProductStatus__c,'The ProductStatus field value of ' + ccProduct.ccrz__ProductStatus__c + ' does not match the expected value of Released');
        }
    }

    @isTest
    public static void testUpdateExistingCCProduct(){
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            Product2 product = new Product2();
            product.Name = 'Test Product';
            product.ProductCode = 'TEST-1234';
            product.Description = 'Test Description';
            product.Sync_Product_To_B2B__c = true;
            product.IsActive = true;
            product.B2B_Storefront__c = 'DefaultStore';
            insert product;

            CPQB2BProduct2Selector prodSelector = new CPQB2BProduct2Selector();
            product = prodSelector.selectById(product.Id);

            product.Name = 'TestCCProduct';
            update product;

            //Checking if SKU syncing is enabled.  If disabled,
            //we then need to create the B2B CCProduct records
            //manually and associate it a Product2 record
            CPQB2BConnector connector = new CPQB2BConnector();
            if(!connector.isSyncEnabled(CPQB2BProcessType.SKU)){
                ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c();
                ccProduct1.Name = product.Name;
                ccProduct1.ccrz__SKU__c = product.ProductCode;
                ccProduct1.Source_Product__c = product.Id;
                ccProduct1.ccrz__Storefront__c = 'DefaultStore';
                insert ccProduct1;
            }

            CPQB2BCCProductSelector ccProdSelector = new CPQB2BCCProductSelector();
            List<ccrz__E_Product__c> ccProductList = new List<ccrz__E_Product__c>();
            ccProductList = ccProdSelector.selectBySourceIds(new List<Id>{product.Id});
            //Verifies a duplicate record was not created
            System.assertEquals(1,ccProductList.size(),'The returned list size of: ' + ccProductList.size() + ' does not match the expected value of 1');
            ccrz__E_Product__c ccProduct = ccProductList[0];

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getProductFieldMappings();

            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){

                System.assertEquals(product.get(fieldMap.sourceField),ccProduct.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Product does not match the field value for ' + fieldMap.destField + ' on CCProduct');
            }
        }
    }

    @isTest
    public static void testDisableExistingCCProduct(){
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            Product2 product = new Product2();
            product.Name = 'Test Product';
            product.ProductCode = 'TEST-1234';
            product.Description = 'Test Description';
            product.Sync_Product_To_B2B__c = true;
            product.IsActive = true;
            insert product;

            product.IsActive = false;
            update product;

            //Checking if SKU syncing is enabled.  If disabled,
            //we then need to create the B2B CCProduct records
            //manually and associate it a Product2 record
            CPQB2BConnector connector = new CPQB2BConnector();
            if(!connector.isSyncEnabled(CPQB2BProcessType.SKU)){
                ccrz__E_Product__c ccProduct1 = new ccrz__E_Product__c();
                ccProduct1.Name = product.Name;
                ccProduct1.ccrz__SKU__c = product.ProductCode;
                ccProduct1.Source_Product__c = product.Id;
                ccProduct1.ccrz__ProductStatus__c = 'Blocked';
                insert ccProduct1;
            }

            CPQB2BCCProductSelector ccProdSelector = new CPQB2BCCProductSelector();
            List<ccrz__E_Product__c> ccProductList = new List<ccrz__E_Product__c>();
            ccProductList = ccProdSelector.selectBySourceIds(new List<Id>{product.Id});
            //Verifies a duplicate record was not created
            System.assertEquals(1,ccProductList.size(),'The returned list size of: ' + ccProductList.size() + ' does not match the expected value of 1');
            ccrz__E_Product__c ccProduct = ccProductList[0];
            //Verifies CCProduct was set to Blocked when Product2 record is set disabled
            System.assertEquals('Blocked',ccProduct.ccrz__ProductStatus__c,'The ProductStatus field value of ' + ccProduct.ccrz__ProductStatus__c + ' does not match the expected value of Blocked');
        }
    }

    @isTest
    public static void testMapPricingFromPricebook() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            standardPricebook = [SELECT Id, Name, IsActive From PriceBook2 WHERE Id = :Test.getStandardPricebookId()];

            ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceListFromPriceBook(standardPricebook.Id, 'PL Name');
            insert priceList;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
            }

            Decimal price = 100;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            insert pbe;

            List<PriceBookEntry> pbes = new List<PriceBookEntry>();
            pbes.add(pbe);

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe, ccProduct.Id, priceList.Id);
                insert priceListItem;
            }

            Test.startTest();
            service.mapPricing(new List<Id>{pbe.Id});
            Test.stopTest();

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Source_PriceBookEntry_Id__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getPriceBookEntryFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(pbe.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on PriceBookEntry does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapPricingFromPricebookUpdatePriceListItem() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            standardPricebook = [SELECT Id, Name, IsActive From PriceBook2 WHERE Id = :Test.getStandardPricebookId()];

            ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceListFromPriceBook(standardPricebook.Id, 'PL Name');
            insert priceList;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 100;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            insert pbe;

            List<PriceBookEntry> pbes = new List<PriceBookEntry>();
            pbes.add(pbe);

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)){
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe, ccProduct.Id, priceList.Id);
                insert priceListItem;
            }

            Test.startTest();
            service.mapPricing(pbes);

            pbe.UnitPrice = 1000;
            update pbe;

            service.mapPricing(new List<Id> { pbe.Id });

            Test.stopTest();

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Source_PriceBookEntry_Id__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];

            System.assertEquals(pbe.UnitPrice, ccPriceListItem.ccrz__Price__c);

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getPriceBookEntryFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(pbe.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on PriceBookEntry does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapPricingFromIdsPriceBookEntry() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            standardPricebook = [SELECT Id, Name, IsActive From PriceBook2 WHERE Id = :Test.getStandardPricebookId()];

            ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceListFromPriceBook(standardPricebook.Id, 'PL Name');
            insert priceList;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 100;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            insert pbe;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)) {
                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromPriceBookEntry(pbe, ccProduct.Id, priceList.Id);
                insert priceListItem;
            }

            Test.startTest();
            service.mapPricing(new List<Id> { pbe.Id });
            Test.stopTest();

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Source_PriceBookEntry_Id__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];

            System.assertEquals(pbe.UnitPrice, ccPriceListItem.ccrz__Price__c);

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getPriceBookEntryFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(pbe.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on PriceBookEntry does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapPricingFromIdsPriceBookEntryNoCCPriceList() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService('Batch');

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            standardPricebook = [SELECT Id, Name, IsActive From PriceBook2 WHERE Id = :Test.getStandardPricebookId()];

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 100;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            insert pbe;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            Test.startTest();
            service.mapPricing(new List<Id> { pbe.Id });
            Test.stopTest();

            List<CPQB2BLog__c> logs = [SELECT ID, Process_Type__c, Record_Id__c, Source_Record_Id__c, Triggering_Event__c, Error_Message__c FROM CPQB2BLog__c];
            System.assertEquals(1, logs.size());

            CPQB2BLog__c log = logs[0];
            System.assertEquals(log.Process_Type__c, CPQB2BProcessType.Pricing.name());
            System.assertEquals(log.Record_Id__c, standardPricebook.Id);
            System.assertEquals(log.Source_Record_Id__c, pbe.Id);
            System.assertEquals(log.Triggering_Event__c, service.triggerEvent);
            System.assertEquals(log.Error_Message__c, Label.CPQB2B_PriceBookEntry_Sync_No_CCPriceList_Exception);
        }
    }

    @isTest
    public static void testMapPricingFromQuoteLines() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();
            ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
            ccAccountGroup.Name = 'My Account';
            insert ccAccountGroup;

            Account account = new Account();
            account.Name = 'My Account';
            account.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
            insert account;

            ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList(ccAccountGroup.Name);
            insert priceList;

            ccrz__E_AccountGroupPriceList__c agPriceList = CPQB2BTestFactory.createAccountGroupPriceList(priceList.Id, ccAccountGroup.Id);
            insert agPriceList;

            SBQQ__Quote__c quote = CPQB2BTestFactory.createQuoteThatShouldSync(account.Id);
            insert quote;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 500;
            SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
            insert quoteLine;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromQuoteLine(quoteLine, ccProduct.Id, priceList.Id);
                insert priceListItem;
            }

            ApexTrigger quoteLineTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BCCQuoteLineTrigger'];
            if(quoteLineTrigger == null || quoteLineTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapPricing(new List<SBQQ__QuoteLine__c>{quoteLine});
                Test.stopTest();
            }

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Quote_Line__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];

            System.assertEquals(quoteLine.Id, ccPriceListItem.Quote_Line__c);

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getRequiredQuoteLineFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(quoteLine.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Quote Line does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapPricingFromQuoteLinesWithMultiplePriceLists() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();
            ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
            ccAccountGroup.Name = 'My Account';
            insert ccAccountGroup;

            Account account = new Account();
            account.Name = 'My Account';
            account.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
            insert account;

            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            List<SObject> currencyTypes = new List<SObject>();
            List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c>();
            List<ccrz__E_AccountGroupPriceList__c> agPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();

            if (isMultiCurrency) {
                currencyTypes = Database.query('SELECT Id, IsoCode from CurrencyType where isActive = true');
                for (SObject currencyType : currencyTypes) {
                    ccrz__E_PriceList__c priceList2 = new ccrz__E_PriceList__c();
                    priceList2.ccrz__CurrencyISOCode__c = (String)currencyTypes[0].get('IsoCode');
                    priceList2.Name = 'Price List 2';
                    priceList2.ccrz__Enabled__c = true;

                    insert priceList2;
                }
            } else {
                ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList(ccAccountGroup.Name);
                insert priceList;

                ccrz__E_AccountGroupPriceList__c agPriceList = CPQB2BTestFactory.createAccountGroupPriceList(priceList.Id, ccAccountGroup.Id);
                insert agPriceList;
            }

            insert priceLists;

            for (ccrz__E_PriceList__c priceList : priceLists) {
                agPriceLists.add(CPQB2BTestFactory.createAccountGroupPriceList(priceList.Id, ccAccountGroup.Id));
            }
            insert agPriceLists;

            SBQQ__Quote__c quote = CPQB2BTestFactory.createQuoteThatShouldSync(account.Id);
            insert quote;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 500;
            SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
            insert quoteLine;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromQuoteLine(quoteLine, ccProduct.Id, priceLists[0].Id);
                insert priceListItem;
            }

            ApexTrigger quoteLineTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BCCQuoteLineTrigger'];
            if(quoteLineTrigger == null || quoteLineTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapPricing(new List<SBQQ__QuoteLine__c>{quoteLine});
                Test.stopTest();
            }

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Quote_Line__c, ccrz__Pricelist__c, ccrz__Pricelist__r.ccrz__CurrencyISOCode__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];

            System.assertEquals(quoteLine.Id, ccPriceListItem.Quote_Line__c);
            if (isMultiCurrency) {
                System.assertEquals(quote.get('CurrencyIsoCode'), ccPriceListItem.ccrz__Pricelist__r.ccrz__CurrencyISOCode__c);
            }

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getRequiredQuoteLineFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(quoteLine.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Quote Line does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapPricingFromQuoteLinesExpiredQuote() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();
            ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
            ccAccountGroup.Name = 'My Account';
            insert ccAccountGroup;

            Account account = new Account();
            account.Name = 'My Account';
            account.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
            insert account;

            ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList(ccAccountGroup.Name);
            insert priceList;

            ccrz__E_AccountGroupPriceList__c agPriceList = CPQB2BTestFactory.createAccountGroupPriceList(priceList.Id, ccAccountGroup.Id);
            insert agPriceList;

            SBQQ__Quote__c quote = CPQB2BTestFactory.createQuoteThatShouldSync(account.Id);
            quote.SBQQ__ExpirationDate__c = Date.Today().addDays(-3);
            insert quote;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 500;
            SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
            insert quoteLine;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromQuoteLine(quoteLine, ccProduct.Id, priceList.Id);
                insert priceListItem;
            }

            ApexTrigger quoteLineTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BCCQuoteLineTrigger'];
            if(quoteLineTrigger == null || quoteLineTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapPricing(new List<SBQQ__QuoteLine__c>{quoteLine});
                Test.stopTest();
            }

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Quote_Line__c, ccrz__EndDate__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];

            System.assertEquals(quoteLine.Id, ccPriceListItem.Quote_Line__c);
            System.assertEquals(Date.Today().addDays(-1), ccPriceListItem.ccrz__EndDate__c);

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getRequiredQuoteLineFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(quoteLine.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Quote Line does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapPricingFromQuoteLinesWhenSyncIsDisabled() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();
            ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
            ccAccountGroup.Name = 'My Account';
            insert ccAccountGroup;

            Account account = new Account();
            account.Name = 'My Account';
            account.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
            insert account;

            ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList(ccAccountGroup.Name);
            insert priceList;

            ccrz__E_AccountGroupPriceList__c agPriceList = CPQB2BTestFactory.createAccountGroupPriceList(priceList.Id, ccAccountGroup.Id);
            insert agPriceList;

            SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(account.Id, false, true, true);
            insert quote;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 500;
            SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
            insert quoteLine;

            ApexTrigger quoteLineTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BCCQuoteLineTrigger'];
            if(quoteLineTrigger == null || quoteLineTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapPricing(new List<SBQQ__QuoteLine__c>{ quoteLine });
                Test.stopTest();
            }

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Quote_Line__c FROM ccrz__E_PriceListItem__c];
            System.assert(ccPriceListItems.isEmpty());
        }
    }

    @isTest
    public static void testMapPricingFromQuoteLinesMissingAccountGroup() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();
            Account account = new Account();
            account.Name = 'My Account';
            insert account;

            SBQQ__Quote__c quote = CPQB2BTestFactory.createQuoteThatShouldSync(account.Id);
            insert quote;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 500;
            SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
            insert quoteLine;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
                ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList('PL');
                insert priceList;

                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromQuoteLine(quoteLine, ccProduct.Id, priceList.Id);
                insert priceListItem;
            }

            ApexTrigger quoteLineTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BCCQuoteLineTrigger'];
            if(quoteLineTrigger == null || quoteLineTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapPricing(new List<SBQQ__QuoteLine__c>{quoteLine});
                Test.stopTest();
            }

            //Verify Account Group was created
            List<ccrz__E_AccountGroup__c> accountGroups = [SELECT Id, Name FROM ccrz__E_AccountGroup__c];
            System.assert(!accountGroups.IsEmpty());

            ccrz__E_AccountGroup__c accountGroup = accountGroups[0];
            System.assertEquals(account.Name, accountGroup.Name);

            //Verify that the Account Group was created for the account
            List<Account> accounts = [SELECT ccrz__E_AccountGroup__c, Name FROM Account];
            System.assert(!accounts.IsEmpty());

            //Verify that the account group was associated to the account
            Account acc = accounts[0];
            System.assertEquals(acc.ccrz__E_AccountGroup__c, accountGroups[0].Id);

            //Verify that the price list was created
            List<ccrz__E_PriceList__c> ccPriceLists = [SELECT Id, Name, ccrz__CurrencyISOCode__c FROM ccrz__E_PriceList__c];
            System.assert(!ccPriceLists.IsEmpty());

            ccrz__E_PriceList__c ccPriceList = ccPriceLists[0];
            System.assertEquals(acc.Name, ccPriceList.Name);
            if (UserInfo.isMultiCurrencyOrganization()) {
                System.assertEquals(ccPriceList.ccrz__CurrencyISOCode__c, (String)quote.get('CurrencyIsoCode'));
            } else {
                System.assertEquals(ccPriceList.ccrz__CurrencyISOCode__c, UserInfo.getDefaultCurrency());
            }

            //Verify that the CC Account Group Price List were created
            List<ccrz__E_AccountGroupPriceList__c> ccAccountGroupPriceLists = [SELECT Id, ccrz__Pricelist__c FROM ccrz__E_AccountGroupPriceList__c];
            System.assert(!ccAccountGroupPriceLists.IsEmpty());

            ccrz__E_AccountGroupPriceList__c ccAccountGroupPriceList = ccAccountGroupPriceLists[0];
            System.assertEquals(ccPriceList.Id, ccAccountGroupPriceList.ccrz__Pricelist__c);

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Quote_Line__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];
            System.assertEquals(quoteLine.Id, ccPriceListItem.Quote_Line__c);

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getRequiredQuoteLineFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(quoteLine.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Quote Line does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapPricingFromQuoteLinesMissingAccountGroupPriceList() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();
            ccrz__E_AccountGroup__c ccAccountGroup = new ccrz__E_AccountGroup__c();
            ccAccountGroup.Name = 'My Account';
            ccAccountGroup.ccrz__Desc__c = 'Description';

            insert ccAccountGroup;

            Account account = new Account();
            account.Name = 'My Account';
            account.ccrz__E_AccountGroup__c = ccAccountGroup.Id;
            insert account;

            SBQQ__Quote__c quote = CPQB2BTestFactory.createQuoteThatShouldSync(account.Id);
            insert quote;

            Product2 product = CPQB2BTestFactory.createSyncedProduct('My Product Name', 'My Product Description');
            insert product;

            Decimal price = 500;
            SBQQ__QuoteLine__c quoteLine = CPQB2BTestFactory.createQuoteLine(quote.Id, product.Id, price);
            insert quoteLine;

            ccrz__E_Product__c ccProduct;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.Pricing)){
                ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceList('PL');
                insert priceList;

                ccrz__E_PriceListItem__c priceListItem = CPQB2BTestFactory.createPriceListItemFromQuoteLine(quoteLine, ccProduct.Id, priceList.Id);
                insert priceListItem;
            }

            ApexTrigger quoteLineTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BCCQuoteLineTrigger'];
            if(quoteLineTrigger == null || quoteLineTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapPricing(new List<SBQQ__QuoteLine__c>{quoteLine});
                Test.stopTest();
            }

            //Verify that the price list was created
            List<ccrz__E_PriceList__c> ccPriceLists = [SELECT Id, Name, ccrz__CurrencyISOCode__c FROM ccrz__E_PriceList__c];
            System.assert(!ccPriceLists.IsEmpty());

            ccrz__E_PriceList__c ccPriceList = ccPriceLists[0];
            System.assertEquals(account.Name, ccPriceList.Name);

            if (UserInfo.isMultiCurrencyOrganization()) {
                System.assertEquals(ccPriceList.ccrz__CurrencyISOCode__c, (String)quote.get('CurrencyIsoCode'));
            } else {
                System.assertEquals(ccPriceList.ccrz__CurrencyISOCode__c, UserInfo.getDefaultCurrency());
            }

            //Verify Account Group was created
            List<ccrz__E_AccountGroup__c> accountGroups = [SELECT Id, Name, ccrz__Desc__c FROM ccrz__E_AccountGroup__c];
            System.assert(!accountGroups.IsEmpty());

            ccrz__E_AccountGroup__c accountGroup = accountGroups[0];
            System.assertEquals(account.Name, accountGroup.Name);
            System.assertEquals(accountGroup.ccrz__Desc__c, accountGroup.ccrz__Desc__c);

            //Verify that the CC Account Group Price List were created
            List<ccrz__E_AccountGroupPriceList__c> ccAccountGroupPriceLists = [SELECT Id, ccrz__Pricelist__c FROM ccrz__E_AccountGroupPriceList__c];
            System.assert(!ccAccountGroupPriceLists.IsEmpty());

            ccrz__E_AccountGroupPriceList__c ccAccountGroupPriceList = ccAccountGroupPriceLists[0];
            System.assertEquals(ccPriceList.Id, ccAccountGroupPriceList.ccrz__Pricelist__c);

            List<ccrz__E_PriceListItem__c> ccPriceListItems = [SELECT Id, Name, ccrz__Price__c, Quote_Line__c FROM ccrz__E_PriceListItem__c];
            System.assertEquals(1, ccPriceListItems.size());
            ccrz__E_PriceListItem__c ccPriceListItem = ccPriceListItems[0];
            System.assertEquals(quoteLine.Id, ccPriceListItem.Quote_Line__c);

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getRequiredQuoteLineFieldMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                System.assertEquals(quoteLine.get(fieldMap.sourceField),ccPriceListItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Quote Line does not match the field value for ' + fieldMap.destField + ' on CCPriceListItem');
            }
        }
    }

    @isTest
    public static void testMapOrderToCCOrder() {
        CPQB2BMappingService service = new CPQB2BMappingService();

        Map<String, Object> testData = cc_TestDataFactory.setupAccountContactUser(false);

        Product2 product = CPQB2BTestFactory.createProduct('P1', 'P1-C', true, true);
        insert product;

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        Decimal price = 100;
        PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
        insert pbe;

        Test.startTest();

        ccrz__E_Cart__c ccCart = CPQB2BTestFactory.createCCCart(testData);

        Id userId = ((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)).Id;
        Id accountId = ((Account) testData.get(cc_TestDataFactory.TEST_CHILD_ACCOUNT)).Id;
        Id contactId = ((Contact) testData.get(cc_TestDataFactory.TEST_CONTACT)).Id;

        System.runAs((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)){
            String additionalDetails = 'Sample additional details text!';
            CPQB2BQuoteBtnCtrl.calculateQuote(ccCart.ccrz__EncryptedId__c,additionalDetails);
        }

        Test.stopTest();

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Order order = CPQB2BTestFactory.createOrder(true, accountId, contactId, standardPricebook.Id);
        order.ShipToContactId = contactId;
        order.ShippingStreet = '123 Main Street';
        order.ShippingCity = 'Indianapolis';
        order.ShippingState = 'IN';
        order.ShippingPostalCode = '46060';
        order.ShippingCountry = 'USA';

        order.BillingStreet = '123 Main Street';
        order.BillingCity = 'Indianapolis';
        order.BillingState = 'IN';
        order.BillingPostalCode = '46060';
        order.BillingCountry = 'USA';
        insert order;

        OrderItem orderItem = CPQB2BTestFactory.createOrderItem(order.Id, product.Id, pbe.Id);
        insert orderItem;

        orderItem.UnitPrice = 200;
        update orderItem;

        ccrz__E_Product__c ccProduct;

        order.SBQQ__Quote__c = quote.Id;
        update order;

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
            ccProduct = CPQB2BTestFactory.createCCProduct(product);
            insert ccProduct;
        }

        if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.OrderToCCOrder)){
            ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(accountId);
            ccOrder.ccrz__OriginatedCart__c = quote.Id;
            insert ccOrder;

            ccrz__E_OrderItem__c ccOrderItem = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct.Id);
            insert ccOrderItem;
        }

        ApexTrigger orderTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BOrderTrigger'];
        if(orderTrigger == null || orderTrigger.Status == 'Inactive') {
            Test.startTest();
                service.mapCPQOrderToCCOrder(new List<Order>{  order });
            Test.stopTest();
        }

        List<ccrz__E_Order__c> ccOrders = new CPQB2BCCOrderSelector().getBySourceOrderIds(new List<Id>{ order.Id });

        System.assertEquals(1, ccOrders.size());

        ccrz__E_Order__c ccOrder = ccOrders[0];

        System.assertEquals(ccCart.Id, ccOrder.ccrz__OriginatedCart__c, 'The value of ccrz__OriginatedCart__c: ' + ccOrder.ccrz__OriginatedCart__c + ' on Order does not match the orginal CC Cart Record Id: ' + ccCart.Id);

        List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getOrderToCCOrderMappings();
        for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
            if (fieldMap.sourceField != null) {
                System.assertEquals(order.get(fieldMap.sourceField),ccOrder.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Order does not match the field value for ' + fieldMap.destField + ' on CC Order');
            }
        }

        System.assertEquals(order.ShipToContactId, ccOrder.ccrz__Contact__c);
        System.assertEquals(order.EffectiveDate, ccOrder.ccrz__OrderDate__c);
        System.assertEquals(order.ShippingStreet, ccOrder.ccrz__ShipTo__r.ccrz__AddressFirstline__c);
        System.assertEquals(order.ShippingCity, ccOrder.ccrz__ShipTo__r.ccrz__City__c);
        System.assertEquals(order.ShippingState, ccOrder.ccrz__ShipTo__r.ccrz__StateISOCode__c);
        System.assertEquals(order.ShippingPostalCode, ccOrder.ccrz__ShipTo__r.ccrz__PostalCode__c);
        System.assertEquals(order.ShippingCountry, ccOrder.ccrz__ShipTo__r.ccrz__Country__c);

        System.assertEquals(order.BillingStreet, ccOrder.ccrz__BillTo__r.ccrz__AddressFirstline__c);
        System.assertEquals(order.BillingCity, ccOrder.ccrz__BillTo__r.ccrz__City__c);
        System.assertEquals(order.BillingState, ccOrder.ccrz__BillTo__r.ccrz__StateISOCode__c);
        System.assertEquals(order.BillingPostalCode, ccOrder.ccrz__BillTo__r.ccrz__PostalCode__c);
        System.assertEquals(order.BillingCountry, ccOrder.ccrz__BillTo__r.ccrz__Country__c);

        if (userId != null) {
            System.assertEquals(userId, ccOrder.OwnerId);
            System.assertEquals(userId, ccOrder.ccrz__User__c);
        }

        List<ccrz__E_OrderItem__c> ccOrderItems = new CPQB2BCCOrderItemSelector().getByOrderIds(new List<Id>{ ccOrder.Id });
        System.assertEquals(1, ccOrderItems.size());

        ccrz__E_OrderItem__c ccOrderItem = ccOrderItems[0];

        List<CPQB2BBaseFieldMapping> orderLineFieldMappings = CPQB2BFieldMapping.getOrderItemToCCOrderItemMappings();
        for(CPQB2BBaseFieldMapping fieldMap : orderLineFieldMappings){
            if (fieldMap.sourceField != null) {
                System.assertEquals(orderItem.get(fieldMap.sourceField),ccOrderItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Order Item does not match the field value for ' + fieldMap.destField + ' on CC Order Item');
            }
        }
    }

    @isTest
    public static void testMapOrderToCCOrderWithExistingOrder() {
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

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            Decimal price = 100;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            insert pbe;

            Order order = CPQB2BTestFactory.createOrder(true, ac.Id, c.Id, standardPricebook.Id);
            insert order;

            OrderItem orderItem = CPQB2BTestFactory.createOrderItem(order.Id, product.Id, pbe.Id);
            insert orderItem;

            Product2 product2 = CPQB2BTestFactory.createProduct('P2', 'P2-C', true, true);
            insert product2;

            PriceBookEntry pbe2 = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product2.Id, 300);
            insert pbe2;

            OrderItem orderItem2 = CPQB2BTestFactory.createOrderItem(order.Id, product2.Id, pbe2.Id);
            insert orderItem2;

            order.Name = 'Order Name edited';
            update order;

            ccrz__E_Product__c ccProduct1;
            ccrz__E_Product__c ccProduct2;
            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct1 = CPQB2BTestFactory.createCCProduct(product);
                insert ccProduct1;

                ccProduct2 = CPQB2BTestFactory.createCCProduct(product2);
                insert ccProduct2;
            }

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.OrderToCCOrder)){
                ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
                insert ccOrder;

                ccrz__E_OrderItem__c ccOrderItem = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct1.Id);
                insert ccOrderItem;

                ccrz__E_OrderItem__c ccOrderItem2 = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct2.Id);
                insert ccOrderItem2;
            }

            ApexTrigger orderTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BOrderTrigger'];
            if(orderTrigger == null || orderTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapCPQOrderToCCOrder(new List<Order>{  order });
                Test.stopTest();
            }

            List<ccrz__E_Order__c> ccOrders = new CPQB2BCCOrderSelector().getBySourceOrderIds(new List<Id>{ order.Id });
            ccrz__E_Order__c ccOrder = ccOrders[0];
            System.assertEquals(1, ccOrders.size());

            List<CPQB2BBaseFieldMapping> fieldMappings = CPQB2BFieldMapping.getOrderToCCOrderMappings();
            for(CPQB2BBaseFieldMapping fieldMap : fieldMappings){
                if (fieldMap.sourceField != null) {
                    System.assertEquals(order.get(fieldMap.sourceField),ccOrder.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Order does not match the field value for ' + fieldMap.destField + ' on CC Order');
                }
            }

            List<ccrz__E_OrderItem__c> ccOrderItems = new CPQB2BCCOrderItemSelector().getByOrderIds(new List<Id>{ ccOrder.Id });
            System.assertEquals(2, ccOrderItems.size());

            ccrz__E_OrderItem__c ccOrderItem = ccOrderItems[0];

            List<CPQB2BBaseFieldMapping> orderLineFieldMappings = CPQB2BFieldMapping.getOrderItemToCCOrderItemMappings();
            for(CPQB2BBaseFieldMapping fieldMap : orderLineFieldMappings){
                if (fieldMap.sourceField != null) {
                    System.assertEquals(orderItem.get(fieldMap.sourceField),ccOrderItem.get(fieldMap.destField), 'The field value for ' + fieldMap.sourceField + ' on Order Item does not match the field value for ' + fieldMap.destField + ' on CC Order Item');
                }
            }
        }
    }

    /**
     * Temporarily removing System.runAs. Running into mix dml error when trying to use CPQB2BTestFactory admin and B2B's test factory user does not
     * provide permissions to the quote object nor does it allow assignment of a permission set due to portal license
     * Need to re-implement to correctly make use of running code as a test user with the correct profile
     */
    @isTest
    public static void testMapCartToQuote() {
        Map<String, Object> testData = cc_TestDataFactory.setupAccountContactUser(false);

        Map<String, Object> cartValidateResponse;

        String currCartENCID;
        String currCartSFID;

        List<Product2> productList = [SELECT Id FROM Product2];

        Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
        update standardPricebook;

        ccrz__E_PriceList__c priceList = CPQB2BTestFactory.createPriceListFromPriceBook(standardPricebook.Id, 'PL Name');
        insert priceList;

        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        for(Product2 product : productList){
            Decimal price = cc_TestDataFactory.TEST_PRODUCT_PRICE;
            PriceBookEntry pbe = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product.Id, price);
            pbeList.add(pbe);
        }

        insert pbeList;

        Test.startTest();

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = (String) testData.get(cc_TestDataFactory.TEST_STOREFRONT);
        ctx.portalUserId = ((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)).Id;
        ctx.effAccountId = ((Account) testData.get(cc_TestDataFactory.TEST_CHILD_ACCOUNT)).Id;
        ccrz.cc_CallContext.init(ctx);

        Map<String, Object> addToCartResult = ccrz.ccApiCart.addTo(new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.LINE_DATA => new List<Map<String, Object>>{
                new Map<String, Object> {
                    ccrz.ccApiCart.LINE_DATA_SKU => cc_TestDataFactory.TEST_SKU + 1,
                    ccrz.ccApiCart.LINE_DATA_QUANTITY => 2
                }
            }
        });

        currCartENCID = (String) addToCartResult.get(ccrz.ccApiCart.CART_ENCID);

        cartValidateResponse = ccrz.ccApiCart.validate(new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccAPICart.CART_ENCID => currCartENCID
        });

        ctx.currentCartId = currCartENCID;
        ctx.currentPageName = 'ccrz__Cart';

        String cartStatus = CPQB2BMappingSelector.getCustomCartStatus();
        List<ccrz__E_Cart__c> ccCartList = [Select Id,Name, ccrz__EncryptedId__c, ccrz__Account__c,ccrz__Storefront__c FROM ccrz__E_Cart__c];

        String encryptedCartId = ccCartList[0].ccrz__EncryptedId__c;
        Id cartId = ccCartList[0].Id;

        String additionalDetails = 'Sample additional details text!';

        System.runAs((User) testData.get(cc_TestDataFactory.TEST_CHILD_ACC_USER)){
            CPQB2BQuoteBtnCtrl.submitQuoteRequest(ctx,additionalDetails);
        }
        Test.stopTest();

        ccCartList = [SELECT Id, Quote_Additional_Details__c, ccrz__CartStatus__c FROM ccrz__E_Cart__c WHERE Id = :cartId];
        System.assertEquals(cartStatus, ccCartList[0].ccrz__CartStatus__c, 'The Cart Status field value of ' + ccCartList[0].ccrz__CartStatus__c + ' does not match the expected value of ' + cartStatus);
        System.assertEquals(additionalDetails, ccCartList[0].Quote_Additional_Details__c, 'The Quote Details field value of ' + ccCartList[0].Quote_Additional_Details__c + ' does not match the expected value of ' + additionalDetails);

        List<SBQQ__Quote__c> quoteList = [SELECT Id, Quote_Additional_Details__c, SBQQ__Status__c , SBQQ__PricebookId__c, SBQQ__Account__c FROM SBQQ__Quote__c];
        String quoteStatus = CPQB2BMappingSelector.getCustomQuoteStatus();
        System.assertEquals(quoteStatus, quoteList[0].SBQQ__Status__c,'The Quote Status field value of ' + quoteList[0].SBQQ__Status__c + ' does not match the expected value of ' + quoteStatus);
        System.assertEquals(additionalDetails, quoteList[0].Quote_Additional_Details__c,'The Quote Details field value of ' + quoteList[0].Quote_Additional_Details__c + ' does not match the expected value of ' + additionalDetails);
    }

    @isTest
    public static void testMapCCOrderTOOrder() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) {
            CPQB2BMappingService service = new CPQB2BMappingService();

            Account ac = new Account();
            ac.Name = 'Account';
            insert ac;

            Product2 product1 = CPQB2BTestFactory.createProduct('P1', 'P1-C', true, true);
            insert product1;

            Product2 product2 = CPQB2BTestFactory.createProduct('P2', 'P2-C', true, true);
            insert product2;

            Pricebook2 standardPricebook = CPQB2BTestFactory.getStandardPriceBook();
            update standardPricebook;

            ccrz__E_Product__c ccProduct1;
            ccrz__E_Product__c ccProduct2;

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.SKU)) {
                ccProduct1 = CPQB2BTestFactory.createCCProduct(product2);
                insert ccProduct1;

                ccProduct2 = CPQB2BTestFactory.createCCProduct(product2);
                insert ccProduct2;
            } else {
                ccProduct1 = [SELECT id FROM ccrz__E_Product__c WHERE Source_Product__c = :product1.Id LIMIT 1];
                ccProduct2 = [SELECT id FROM ccrz__E_Product__c WHERE Source_Product__c = :product2.Id LIMIT 1];
            }

            List<PriceBookEntry> pbeList = new List<PriceBookEntry>();

            Decimal price1 = 200;
            PriceBookEntry pbe1 = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product1.Id, price1);
            pbeList.add(pbe1);

            Decimal price2 = 500;
            PriceBookEntry pbe2 = CPQB2BTestFactory.createPriceBookEntry(standardPricebook.Id, product2.Id, price2);
            pbeList.add(pbe2);

            insert pbeList;

            ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
            ccOrder.ccrz__OrderDate__c = Date.newInstance(2012, 12, 12);
            insert ccOrder;

            List<ccrz__E_OrderItem__c> ccOrderItems = new List<ccrz__E_OrderItem__c>();
            ccrz__E_OrderItem__c ccOrderItem1 = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct1.Id);
            ccOrderItem1.ccrz__Quantity__c = 10;
            ccOrderItems.add(ccOrderItem1);

            ccrz__E_OrderItem__c ccOrderItem2 = CPQB2BTestFactory.createCCOrderItem(ccOrder.Id, ccProduct2.Id);
            ccOrderItem2.ccrz__Quantity__c = 4;
            ccOrderItems.add(ccOrderItem2);
            insert ccOrderItems;

            if(!new CPQB2BConnector().isSyncEnabled(CPQB2BProcessType.CCOrderToOrder)) {
                SBQQ__Quote__c quote = CPQB2BTestFactory.createQuote(ac.Id, false, true, true);
                insert quote;

                SBQQ__QuoteLine__c quoteLine1 = CPQB2BTestFactory.createQuoteLine(quote.Id, product2.Id, price1);
                insert quoteLine1;

                SBQQ__QuoteLine__c quoteLine2 = CPQB2BTestFactory.createQuoteLine(quote.Id, product2.Id, price2);
                insert quoteLine2;

                quote.SBQQ__Ordered__c = true;
                update quote;

            } else {
                ccOrder.Sync_to_CPQ__c = true;
                update ccOrder;
            }

            ApexTrigger orderTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BOrderTrigger'];
            if(orderTrigger == null || orderTrigger.Status == 'Inactive') {
                Test.startTest();
                    service.mapCCOrderToCPQOrder(new List<ccrz__E_Order__c> {  ccOrder });
                Test.stopTest();
            }

            List<Opportunity> opportunities = [SELECT Id, AccountId, StageName FROM Opportunity];
            System.assertEquals(1, opportunities.size());

            Opportunity opportunity = opportunities[0];
            System.assertEquals(ac.Id, opportunity.AccountId);

            List<SBQQ__Quote__c> quotes = [SELECT Id, B2B_Source_Order__c, SBQQ__Primary__c, SBQQ__Account__c, SBQQ__PricebookId__c, SBQQ__Ordered__c FROM SBQQ__Quote__c];
            System.assertEquals(1, quotes.size());

            SBQQ__Quote__c quote = quotes[0];
            System.assertEquals(ccOrder.Id, quote.B2B_Source_Order__c);
            System.assertEquals(true, quote.SBQQ__Primary__c);
            System.assertEquals(ac.Id, quote.SBQQ__Account__c);
            System.assertEquals(standardPricebook.Id, quote.SBQQ__PricebookId__c);

            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__NetPrice__c, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c];
            System.assertEquals(2, quoteLines.size());

            SBQQ__QuoteLine__c quoteLine1 = quoteLines[0];
            System.assertEquals(ccOrderItem1.ccrz__Price__c, quoteLine1.SBQQ__NetPrice__c);
            System.assertEquals(ccOrderItem1.ccrz__Quantity__c, quoteLine1.SBQQ__Quantity__c);

            SBQQ__QuoteLine__c quoteLine2 = quoteLines[1];
            System.assertEquals(ccOrderItem2.ccrz__Price__c, quoteLine2.SBQQ__NetPrice__c);
            System.assertEquals(ccOrderItem2.ccrz__Quantity__c, quoteLine2.SBQQ__Quantity__c);
        }
    }
}