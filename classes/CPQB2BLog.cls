/**
 * CPQB2BLog
 * @description Wrapper class for storing error log details
 * Class is being utilized for storing log records so they can
 * be serialized and passed to a future method to be parsed
 * and translated/inserted into CPQB2BLog__c records.  SF does not
 * support serialize/deserialize of custom objects so we have to use
 * this wrapper class.
 */
public class CPQB2BLog{
    public String processType {set; get;}
    public String recordId {set; get;}    
    public String sourceId {set; get;}
    public String message {set; get;}
    public String triggerEvent {set; get;}
    public String stackTrace {set; get;}

    /**
     * CPQB2BLog Wrapper object contstructor 
     * @param  processType  The sync process type that failed
     * @param  recordId     The Id of the record that failed
     * @param  sourceId     The source record Id if the object has one
     * @param  triggerEvent The event that kicked of the record sync attempt
     * @param  stackTrace   The error stack trace message, if it exists
     * @param  message      The error message text
     */
    public CPQB2BLog(String processType, String recordId, String sourceId, String triggerEvent, String stackTrace, String message){
        this.processType = processType;
        this.recordId = recordId;
        this.sourceId = sourceId;
        this.triggerEvent = triggerEvent;
        this.stackTrace = stackTrace;
        this.message = message;
    }
}