({
    init : function(component, event, helper) {
        const action = component.get('c.serverInit');
        action.setParams({'opportunityId' : component.get('v.recordId')});
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const responseModel = response.getReturnValue();
                console.log(responseModel.olis[0]);
                component.set('v.olis', responseModel.olis);
                component.set('v.pbes', responseModel.pbes);
            }
            else {
                alert('error: ' + response.getError()[0]);
            }
        });
        $A.enqueueAction(action);
    },

    saveOlis : function(component, event, helper) {
        const theOlis = component.get('v.olis');
        const action = component.get('c.serverSaveOlis');
        action.setParams({'allOlisJSON' : JSON.stringify(theOlis)});
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.olis', response.getReturnValue());
                const toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    'title' : 'Saved!',
                    'message' : 'Your Opportunity has been updated successfully',
                    'type' : 'success'
                });
                toastEvent.fire();
            }
            else {
                console.log(response.getError());
                const toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    'title' : 'Uh oh!',
                    'message' : 'Something went wrong. Your Opportunity was not updated successfully',
                    'type' : 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    addLineItem : function(component, event, helper) {
        const theOlis = component.get('v.olis');
        const defaultProduct = component.get('v.pbes')[0];
        const newOli = {
            'deleteFlag' : false,
            'oli' : {
                'OpportunityId' : component.get('v.recordId'),
                'Quantity' : 0,
                'Product2Id' : defaultProduct.Product2Id,
                'UnitPrice' : defaultProduct.UnitPrice
            }
        }
        theOlis.push(newOli);
        component.set('v.olis', theOlis);
    }
})