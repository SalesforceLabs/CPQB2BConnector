/**
* @author Amil Abdallah
* @date 02/17/2020
*
* @group CCProduct
* @group-content ../../ApexDocContent/CCProducts.htm
*
* @description Trigger Domain on CCProduct that handles ensuring the correct system flags are set on
* our special accounts (Household, One-to-One), and also detects changes on Household Account that requires
* name updating.
*/
public class CPQB2BCCProductDomain extends CPQB2BDomain {

    /**
     * Constructor
     * @param  records List of Records
     */
    public CPQB2BCCProductDomain(List<ccrz__E_Product__c> records) {
        super(records);
    }

    /***********************************
        Business logic
    ************************************/

    /**
     * A sample CCProduct Action
     * @param  records Trigger.new
     * @param  oldMap  Trigger.oldMap
     */
    // public void ccProductAction(List<ccrz__E_Product__c> records, Map<Id, ccrz__E_Product__c> oldMap) {
    //     // Do something here!
    // }

    /*************************************
        Trigger functions
        Remove the ones you don't use
    **************************************/

    public override void onBeforeInsert() {
        List<ccrz__E_Product__c> ccProducts = (List<ccrz__E_Product__c>)this.records;
    }

    // public override void onAfterInsert() {
    //     List<ccrz__E_Product__c> ccProducts = (List<ccrz__E_Product__c>)this.records;
    // }

    public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
        List<ccrz__E_Product__c> ccProducts = (List<ccrz__E_Product__c>)this.records;
        Map<Id, ccrz__E_Product__c> ccProductMap = (Map<Id, ccrz__E_Product__c>)oldMap;
    }

    // public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    //     List<ccrz__E_Product__c> ccProducts = (List<ccrz__E_Product__c>)this.records;
    //     Map<Id, ccrz__E_Product__c> ccProductMap = (Map<Id, ccrz__E_Product__c>)oldMap;
    // }

    // public override void onBeforeDelete() {
    //     List<ccrz__E_Product__c> ccProducts = (List<ccrz__E_Product__c>)this.records;
    // }

    // public override void onAfterDelete() {
    //     List<ccrz__E_Product__c> ccProducts = (List<ccrz__E_Product__c>)this.records;
    // }

    // public override void onAfterUndelete() {
    //     List<ccrz__E_Product__c> ccProducts = (List<ccrz__E_Product__c>)this.records;
    // }

}