/**
* @author Amil Abdallah
* @date 3-08-2020
*
*
* @description Service class for CC Cart Object
*/
public class CPQB2BCCCartService {
    
    /*******************************************************************************************************
    * @description Updates a cart's status to the custom defined value for the CPQB2B process.  This method
    * is called after a quote has successfully been generated for the associated carts.
    * @param List<ccrz__E_Cart__c> carts
    */
    public static void setCartToQuoteRequested(List<ccrz__E_Cart__c> carts)
    {
        String cartStatus = CPQB2BMappingSelector.getCustomCartStatus();

        for(ccrz__E_Cart__c cart : carts){
            cart.ccrz__ActiveCart__c = false;
            cart.ccrz__CartStatus__c = cartStatus;
        }
        update carts;
    }
}