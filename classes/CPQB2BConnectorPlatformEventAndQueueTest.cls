/**
 * Created by javierarroyo on 2/27/20.
 */

@IsTest
private class CPQB2BConnectorPlatformEventAndQueueTest {

    @isTest
    public static void testSyncOrderToCCOrderWithPlatformEvent() {
	    CPQB2BTestInt ti = new CPQB2BTestInt.RunWithPlatformEvent();
        CPQB2BTestHelper h = new CPQB2BTestHelper();
        h.syncOrderToCCOrder(ti, '');
    }

    @isTest
    public static void testSyncCCOrderToOrderWithPlatformEvent() {
   	    CPQB2BTestInt ti = new CPQB2BTestInt.RunWithPlatformEvent();
        CPQB2BTestHelper h = new CPQB2BTestHelper();
        h.syncCCOrderToOrder(ti, '');
    }


    @TestSetup
    static void setup() {
        Boolean shouldSyncProduct = true;
        Boolean isProductActive = true;
        Product2 product = CPQB2BTestFactory.createProduct('My Product Name', 'My Product Description', shouldSyncProduct, isProductActive);
        insert product;

        CPQB2BQueueItem__c qi = new CPQB2BQueueItem__c();
        qi.Object__c = 'Product';
        qi.RecordId__c = product.Id;
        qi.Status__c = 'NEW';
        qi.Priority__c = 0;
        insert qi;
    }

    @IsTest
    static void testSyncProductWithQueue() {

        Test.startTest();
        System.enqueueJob( new CPQB2BQueueItemWorker() );
        Test.stopTest();

        List<CPQB2BQueueItem__c> qiList = [Select Id from CPQB2BQueueItem__c];
        System.assertEquals( 0, qiList.size() );
    }

    @isTest
    public static void testSyncProductWithPlatformEvent() {
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'TEST-1234';
        product.IsActive = true;
        insert product;

        Test.startTest();
        CPQ_B2B_Connector__e e = new CPQ_B2B_Connector__e();
        e.Object_Id__c = product.Id;

        Database.SaveResult sr = EventBus.publish(e);
        Test.getEventBus().deliver();
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }


    @isTest
    public static void testSyncOrderToCCOrderWithQueue() {
      	CPQB2BTestInt ti = new CPQB2BTestInt.RunWithQueue();
        CPQB2BTestHelper h = new CPQB2BTestHelper();
        h.syncOrderToCCOrder(ti, 'Order');
    }

    @isTest
    public static void testSyncCCOrderToOrderWithQueue() {
       	CPQB2BTestInt ti = new CPQB2BTestInt.RunWithQueue();
        CPQB2BTestHelper h = new CPQB2BTestHelper();
        h.syncCCOrderToOrder(ti, 'ccrz__E_Order__c');
    }
}