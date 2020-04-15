@isTest
public class CPQB2BOrderItemSelectorTest {
    @isTest
    public static void testGetByOrderIds() {
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

        List<OrderItem> results = new CPQB2BOrderItemSelector().getByOrderIds(new List<Id> { order.Id});
        System.assertEquals(1, results.size());

        OrderItem result = results[0];
        System.assertEquals(orderItem.UnitPrice, result.UnitPrice);
        System.assertEquals(orderItem.Quantity, result.Quantity);
        System.assertEquals(product.Id, result.Product2Id);       
        System.assertEquals(order.Id, result.OrderId);    
    }
}