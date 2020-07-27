/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public abstract class CPQB2BTestInt {
	
    public abstract void run(Id id, String sObjectName);
    
    public class RunWithPlatformEvent extends CPQB2BTestInt {
    
        public override void run(Id id, String sObjectName) {
            // fire the platform event
            CPQ_B2B_Connector__e e = new CPQ_B2B_Connector__e();
            e.Object_Id__c = Id;
    
            Database.SaveResult sr = EventBus.publish(e);
            Test.getEventBus().deliver(); 
        }        
    }
    
    public class RunWithQueue extends CPQB2BTestInt {
    
        public override void run(Id id, String sObjectName) {
            // create the queueItem and enqueue job
            CPQB2BQueueItem__c qi = new CPQB2BQueueItem__c();
            qi.Object__c = sObjectName;
            qi.RecordId__c = Id;
            qi.Status__c = 'NEW';
            qi.Priority__c = 0;
            insert qi;
            System.enqueueJob( new CPQB2BQueueItemWorker() );
        }
        
    }    
    
    
}