/**
* Created by Amil Abdallah
* @date 02/20/2020
*
* @description Enables schedulable execution of the SyncProductsBatch class
*/
global without sharing class CPQB2BScheduleSyncProducts implements Schedulable{
    /**
     * Fires SyncProductsBatch with a schedulablecontext
     * @param  sc SchedulableContext
     */
    global void execute(SchedulableContext sc) {
        CPQB2BSyncProductsBatch syncProductsBatch = new CPQB2BSyncProductsBatch ();
        Database.executeBatch(syncProductsBatch, 200);
    }
}