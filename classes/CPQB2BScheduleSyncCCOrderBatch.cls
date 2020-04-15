/**
* @author Ashlee Zeigler
* @date 3-11-2020
*
* @see CPQB2BSyncCCOrderBatch
* @description This is the Schedulable class that will schedule the Sync Order batch to run at a certain time
*/
global with sharing class CPQB2BScheduleSyncCCOrderBatch implements Schedulable {
    /*******************************************************************************************************
    * @description Execute the scheduling of the batch
    * @param Database.SchedulableContext
    */  
   global void execute(SchedulableContext sc) {
        CPQB2BSyncCCOrderBatch batch = new CPQB2BSyncCCOrderBatch();
        Database.executeBatch(batch, 5);
    }
}