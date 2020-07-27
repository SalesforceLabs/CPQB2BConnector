/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * @author Amil Abdallah
 * CPQB2BQuoteBtnCtrl
 * @description This is the main controller for the "Request A Quote button" VF component and page.
 */
global with sharing class CPQB2BQuoteBtnCtrl {
    /**
     * submitQuoteRequest Fires logic to retrieve user's current cart id (encrypted value) and additional details from the user
     * and pass that to the future calculateQuote.
     * @param  ctx ccrz.cc_RemoteActionContext Used to identify the user's current cart
     * @param  quoteDetails String Non-required additional details that can be submitted with the quote request
     */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult submitQuoteRequest(ccrz.cc_RemoteActionContext ctx, String quoteDetails)
    {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success = false;
        
        String cartId = ccrz.cc_CallContext.currCartId;
        
        if(String.isEmpty(cartId)){
            res.success=false;
        }
        else{
            try{
                CPQB2BQuoteBtnCtrl.calculateQuote(cartId,quoteDetails);
                res.success=true;
            }
            catch(Exception e){
                res.success=false;
            }
        }
        return res;
    }
    /**
     * calculateQuote Future method that takes the details passed from the Remote Action submitQuoteRequest method
     * and makes a call to the CPQB2BConnector for a quote to be calculated against the referenced cart id.
     * @param  cartId String encrypted Cart Id value used to retrieve the cart + line items
     * @param  quoteDetails String Non-required additional details that can be submitted with the quote request
     */
    @Future
    global static void calculateQuote(String cartId, String quoteDetails)
    {
        CPQB2BConnector connector = new CPQB2BConnector();
        connector.syncCartToQuote(cartId,quoteDetails,'Future Call');
    }
}