/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Created by javierarroyo on 2/12/20.
 */

@IsTest(seeAllData=true)
private class CPQB2BMappingSelector_Test {

    @IsTest
    static void testBehavior() {
        System.debug('starting test');

        List<CPQB2BBaseFieldMapping> mappingList = CPQB2BMappingSelector.getMappingByProcess( CPQB2BProcessType.Test );

        System.assertEquals(1, mappingList.size());
    }
}