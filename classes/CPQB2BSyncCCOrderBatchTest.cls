@isTest
public class CPQB2BSyncCCOrderBatchTest {

    @isTest
    public static void testSyncOrderBatch() {
        user adminUser = CPQB2BTestFactory.createCPQB2BAdminUser(false);
        System.runAs(adminUser) { 
                Integer recordCount = 1;
                Boolean isTriggerActive = true;
                ApexTrigger ccOrderTrigger = [Select Id, Status from ApexTrigger where name='CPQB2BCCOrderTrigger'];

                if(ccOrderTrigger.Status == 'Inactive') {
                    recordCount = 5;
                    isTriggerActive = false;
                }

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
    
                List<ccrz__E_Order__c> orders = CPQB2BTestFactory.createCCOrders(recordCount, ac.Id, false);
                insert orders;
    
                List<ccrz__E_OrderItem__c> ccOrderItems = new List<ccrz__E_OrderItem__c>();
                for (ccrz__E_Order__c testOrder : orders) {
                    ccrz__E_OrderItem__c ccOrderItem1 = CPQB2BTestFactory.createCCOrderItem(testOrder.Id, ccProduct1.Id);
                    ccOrderItem1.ccrz__Quantity__c = 10;
                    ccOrderItems.add(ccOrderItem1);
                }
                insert ccOrderItems;
    
                ccrz__E_Order__c ccOrder = CPQB2BTestFactory.createCCOrder(ac.Id);
                ccOrder.ccrz__OrderDate__c = Date.newInstance(2012, 12, 12);
                insert ccOrder;
    
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
                    for (ccrz__E_Order__c testOrder : orders) {
                        testOrder.Sync_to_CPQ__c = true;
                    }
                    update orders;
                }

                if (!isTriggerActive) {
                    Id batchID;
                    Test.startTest();
                        CPQB2BSyncCCOrderBatch batchJob = new CPQB2BSyncCCOrderBatch();
                        batchID = Database.executeBatch(batchJob, recordCount);
                    Test.stopTest();
                }

                List<Opportunity> opportunities = [SELECT Id, AccountId, StageName FROM Opportunity WHERE AccountId = :ac.Id];
                System.assertEquals(recordCount, opportunities.size());

                Opportunity opportunity = opportunities[0];
                System.assertEquals(ac.Id, opportunity.AccountId);

                List<SBQQ__Quote__c> quotes = [SELECT Id, B2B_Source_Order__c, SBQQ__Primary__c, SBQQ__Account__c, SBQQ__PricebookId__c, SBQQ__Ordered__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opportunity.Id];
                System.assertEquals(1, quotes.size());          
        }
    }
}