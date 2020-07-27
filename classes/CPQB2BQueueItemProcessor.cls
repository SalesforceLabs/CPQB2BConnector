/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * @description Class called from the CPQB2BQueueItemTrigger to start processing items in the queue
 */
public without sharing class CPQB2BQueueItemProcessor {
    public CPQB2BQueueItemProcessor() {
        throw new CPQB2BQueueItemProcessorException('This class should not be constructed');
    }

    /**
     * @description  determine if there is already a job queued or processing QueueItem__c records
     * enqueue if there is no job currently executing to process records
     */
    public static void execute() {

        String[] classNameParts = CPQB2BQueueItemProcessor.class.getName().split('\\.');
        String ns = (classNameParts.size() == 2) ? classNameParts[0] : '';

        List<String> classNames = new List<String> {
                CPQB2BQueueItemProcessor.class.getName().removeStart(ns + '.'),
                CPQB2BQueueItemProcessor.class.getName().removeStart(ns + '.')
        };

        // get class details for querying the job table
        Map<Id, ApexClass> classMap = new Map<Id, ApexClass>([SELECT Id
                , Name
                , NamespacePrefix
        FROM ApexClass
        WHERE Name IN :classNames
        AND NamespacePrefix = :ns]);

        // determine if there are any queueable jobs executing in my namespace's classes
        List <AsyncApexJob> jobs = [SELECT Id
        FROM AsyncApexJob
        WHERE JobType = 'Queueable'
        AND (Status = 'Queued' OR Status = 'Holding' OR Status = 'Processing')
        AND (ApexClassId IN :classMap.keyset())
        ];

        system.debug('AsyncApexJob records found: ' + jobs);

        if (jobs.size() == 0) {
            system.enqueueJob(new CPQB2BQueueItemWorker());
        }
    }

    public class CPQB2BQueueItemProcessorException extends Exception {}
}