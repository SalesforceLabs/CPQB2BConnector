/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


trigger CPQB2BConnectorTrigger on CPQ_B2B_Connector__e (after insert) {

    CPQB2BConnectorTriggerHandler th = new CPQB2BConnectorTriggerHandler(Trigger.newMap);
    th.run();

}