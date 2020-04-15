/**
 * CPQB2BLogger
 * @description Logger class is used for translated exceptions and database results
 * into instances of the CPQB2BLog wrapper class. Once translated, they can be
 * serialized into json and passed to the CPQB2BLoggingService where they get
 * inserted into CPQB2BLog__c records
 */
public class CPQB2BLogger {

    public List<CPQB2BLog> logList;

    public CPQB2BLogger() {
        this.logList = new List<CPQB2BLog>();
    }

    public void log(String processType, String recordId, String sourceId, String triggerEvent, String stackTrace, String message){
        CPQB2BLog errorLog = new CPQB2BLog(processType, recordId, sourceId,triggerEvent,stackTrace,message);
        logList.add(errorLog);
    }

    /**
     * log Translates failed Database result records into wrapper log records to eventually
     * be passed for serialization and insertion into a CPQB2BLog__c record
     * @param  processType  The sync process that was running when error occurred
     * @param  triggerEvent The event that started the sync process
     * @param  results      The Database upsert results
     * @param  records      The records that were attempted to be inserted/updated
     */
    public void log(String processType, String triggerEvent, List<Database.UpsertResult> results, List<SObject> records) {
        String sourceIdField = CPQB2BFieldMapping.getSourceIdFieldByProcessType(processType);

        for (Integer i = 0; i < records.size(); i++) {
            Database.UpsertResult ur = results[i];
            SObject origRecord = records[i];
            if (!ur.isSuccess()) {
                String errorMsg = '';
                for (Database.Error err : ur.getErrors()) {
                    errorMsg += err.getMessage() + '\n';
                }
                String srcId;
                if(!String.isBlank(sourceIdField)){
                    srcId = String.valueOf(origRecord.get(sourceIdField));
                }
                log(processType, origRecord.Id, srcId, triggerEvent, null, errorMsg);
            }
        }
    }

    /**
     * log Translates failed Database result records into wrapper log records to eventually
     * be passed for serialization and insertion into a CPQB2BLog__c record
     * @param  processType  The sync process that was running when error occurred
     * @param  triggerEvent The event that started the sync process
     * @param  results      The Database delete results
     * @param  records      The records that were attempted to be inserted/updated
     */
    public void log(String processType, String triggerEvent, List<Database.DeleteResult> results, List<SObject> records) {
        String sourceIdField = CPQB2BFieldMapping.getSourceIdFieldByProcessType(processType);

        for (Integer i = 0; i < records.size(); i++) {
            Database.DeleteResult ur = results[i];
            SObject origRecord = records[i];
            if (!ur.isSuccess()) {
                String errorMsg = '';
                for (Database.Error err : ur.getErrors()) {
                    errorMsg += err.getMessage() + '\n';
                }
                String srcId;
                if(!String.isBlank(sourceIdField)){
                    srcId = String.valueOf(origRecord.get(sourceIdField));
                }
                log(processType, origRecord.Id, srcId, triggerEvent, null, errorMsg);
            }
        }
    }

    /**
     * log Translates Exceptions into wrapper log records to eventually
     * be passed for serialization and insertion into a CPQB2BLog__c record
     * @param  processType   The sync process that was running when error occurred
     * @param  triggerEvent  The event that started the sync process
     * @param  syncException The Exception that occurred during sync process
     * @param  records       The records that were attempted to be inserted/updated
     */
    public void log(String processType, String triggerEvent, Exception syncException, List<SObject> records) {
        String sourceIdField = CPQB2BFieldMapping.getSourceIdFieldByProcessType(processType);
        String stackTrace = syncException.getStackTraceString();
        String stackTraceLog;
        
        if(stackTrace.length() > 2000){
            stackTraceLog = stackTrace.substring(0,2000);
        }
        else{
            stackTraceLog = stackTrace;
        }
        
        for (Integer i = 0; i < records.size(); i++) {
            String srcId;
            
            if(!String.isBlank(sourceIdField)){
                srcId = String.valueOf(records[i].get(sourceIdField));
            }

            log(processType, records[i].Id, srcId, triggerEvent, stackTraceLog, syncException.getMessage());     
        }
    }
    /**
     * write Serializes the generated log wrapper records and 
     * passed the json to the LoggingService where the records
     * are translated and inserted into CPQB2BLog__c records
     */
    public void write() {
        if(this.loglist.size() > 0){
            List<String> jsonLogList = new List<String>();
            for(CPQB2BLog log : logList){
                jsonLogList.add(JSON.serialize(log));
            }
            if(!System.isBatch()){
                if(!System.isFuture()){
                    CPQB2BLoggingService.logErrorsAsync(jsonLogList);
                }
                else{
                    System.debug('Future Context');
                    CPQB2BLoggingService.logErrors(jsonLogList);
                }
            }
            else{
                CPQB2BLoggingService.logBatchErrors(jsonLogList);
            }               
        }
    }
}