/**
 * CPQB2BProductLineItem
 * @description Wrapper class for storing product price line
 * details for use in quote creation. Keeps track of Product2 Id
 * quantity of that product and pricebook id.
 */
public class CPQB2BProductLineItem{
    public String product2Id {set; get;}
    public Integer quantity {set; get;}
    public String pricebookId {set; get;}
    public Decimal price {set;get;}


    /**
     * CPQB2BProductLineItem Wrapper object contstructor
     * @param  product2Id   Product2 Id
     * @param  pricebookId  The Id of the pricebook
     * @param  quantity     The number of products ordered
     */
    public CPQB2BProductLineItem(String product2Id, String pricebookId, Decimal price, Integer quantity){
        this.product2Id = product2Id;
        this.pricebookId = pricebookId;
        this.price = price;
        this.quantity = quantity;
    }
}