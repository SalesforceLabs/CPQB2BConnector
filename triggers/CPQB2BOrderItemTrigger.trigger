/**
 * @description Trigger to handle of syncing OrderItems to CC Order Items
 */
trigger CPQB2BOrderItemTrigger on OrderItem (after insert, after update) {
    CPQB2BDomain.triggerHandler(CPQB2BOrderItemDomain.class);
}