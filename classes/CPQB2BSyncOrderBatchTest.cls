@isTest
public class CPQB2BSyncOrderBatchTest {

    @isTest
    public static void testSyncOrderBatch() {
        Account acc = new Account();
        acc.Name = 'New Account';
        insert acc;

        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        insert c;

        List<Order> recordstoInsert = CPQB2BTestFactory.createOrders(50, true, acc.Id, c.Id, null);
        insert recordstoInsert;
    
        Test.startTest();
            CPQB2BSyncOrderBatch batchJob = new CPQB2BSyncOrderBatch();
            Database.executeBatch(batchJob);
            
            List<ccrz__E_Order__c> orderList = [Select Id, Name FROM ccrz__E_Order__c];
            System.assertEquals(50,orderList.size(),'The returned list size of ' + orderList.size() + 'does not match the expected value of 50.');
        Test.stopTest();
    }
    
}