/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * @description Trigger to forward the handling of sync processes to the connector
 */
trigger CPQB2BQueueItemTrigger on CPQB2BQueueItem__c (after insert) {

    // a trigger typically inserts QueueItem__c records to put work into the queue
    // Priority 0 is default, set this value higher to move to the head of the processing line
    // Process After is now() by default, set this in the future to delay processing of the record
    //
    // after an item is placed in the queue, start the processor
    CPQB2BQueueItemProcessor.execute();
}