/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

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