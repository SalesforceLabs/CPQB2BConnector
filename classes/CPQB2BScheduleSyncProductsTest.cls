@isTest
public class CPQB2BScheduleSyncProductsTest {
   
    @isTest
    public static void testScheduleBatch() {
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'PBC';
        product.IsActive = true;
        insert product;

        Test.startTest();
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = System.schedule('ScheduleSyncProducts', CRON_EXP, new CPQB2BScheduleSyncProducts());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            System.assertEquals(0, ct.TimesTriggered); 
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));         
        Test.stopTest();
    }
}